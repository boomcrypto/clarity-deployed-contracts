;;; Distributor: receive and distribute rewards.

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .farming-receive-trait.farming-receive-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-check-owner               (err u801))
(define-constant err-receive-preconditions     (err u802))
(define-constant err-distribute-preconditions  (err u803))
(define-constant err-distribute-postconditions (err u804))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; constants
(define-constant REWARD-TOKEN .neebs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auth
(define-data-var owner principal tx-sender)
(define-read-only (get-owner) (var-get owner))
(define-private (check-owner)
  (ok (asserts! (is-eq tx-sender (get-owner)) err-check-owner)))
(define-public (set-owner (new-owner principal))
  (begin
   (try! (check-owner))
   (ok (var-set owner new-owner)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; accounting
(define-map revenue uint uint) ;;epoch -> cumulative token rewards

(define-read-only (get-revenue-at (epoch uint))
  (default-to u0 (map-get? revenue epoch) ))

;; Called by operator.
;; MUST ALWAYS BE ACCOMPANIED BY A CORRECT TRANSFER!
;; Could also store balance and compare to previous but that adds code.
(define-data-var balance uint u0)

(define-read-only (get-balance)
  (var-get balance))

(define-private (sync (new-balance uint))
  (var-set balance new-balance))

(define-public
  (receive
   (token <ft-trait>)
   (amt   uint)
   (from  principal))

  (let ((epoch (contract-call? .farming-wstx-neebs-core current-epoch))
        (r     (get-revenue-at epoch))
        (bal   (unwrap-panic
                (contract-call?
                 token get-balance (as-contract tx-sender)))))

    (asserts!
     (and
      (is-eq (contract-of token) REWARD-TOKEN)
    ;;(> amt u0)
      (is-eq from (get-owner))
      (>= bal (+ (get-balance) amt))
      )
      err-receive-preconditions)

    (try! (check-owner))
    (sync bal)
    ;; (var-set balance (+ (var-get balance) amt))
    (ok (map-set revenue epoch (+ r amt)) )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; claims
(define-map claims
  {user: principal, epoch: uint}
  uint) ;;block number claimed at

(define-private
  (do-claim
   (user principal)
   (epoch uint))
  (map-set claims
           {user: user, epoch: epoch}
           block-height))

(define-read-only
  (has-claimed-epoch
   (user principal)
   (epoch uint))
  (is-some (map-get? claims {user: user, epoch: epoch})))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; low level API
(define-private
  (do-distribute
   (user  principal)
   (token <ft-trait>)
   (amt   uint))

  (let ((protocol (as-contract tx-sender)))
    (ok (if (> amt u0)
        (try!
         (as-contract
          (contract-call?
           token transfer amt protocol user none)))
        true)) ))

(define-read-only
  (calc-distribute
   (share {staked: uint, total: uint})
   (amt   uint))

  (if (> (get total share) u0)
      (/ (* amt (get staked share)) (get total share))
      u0) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; distribute-epoch
(define-private
  (distribute-epoch
   (user   principal)
   (token  <ft-trait>)
   (epoch  uint))

  (let ((reward (unwrap-panic (get-reward user epoch))))

    ;; Preconditions
    (asserts!
     (and
      (not (has-claimed-epoch user epoch))
    ;;(< epoch (current-epoch)) checked by get-share-at
      (is-eq (contract-of token) REWARD-TOKEN)
      )
     err-distribute-preconditions)

    ;; Update global state
    (try! (do-distribute user token (get amt reward)))

    ;; Update local state
    (do-claim user epoch)

    ;; Postconditions

    (ok true)) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; distribute-epochs
(define-private
  (distribute-epochs-step
   (epoch uint)
   (args  {user: principal, token: <ft-trait>}))

  (let ((res_
         (unwrap-panic
          (distribute-epoch
           (get user args)
           (get token args)
           epoch)) ))
    args))

(define-public
  (distribute-epochs
   (user   principal)
   (token  <ft-trait>)
   (epochs (list 10 uint))) ;;XXX: MAX-EPOCHS

  (let ((args {user : user,
               token: token})
        (res_ (fold distribute-epochs-step epochs args))
        (bal (unwrap-panic (contract-call? token get-balance (as-contract tx-sender)))))

    (asserts!
      (is-eq (contract-of token) REWARD-TOKEN)
      err-distribute-preconditions)

    ;; Update local state
    (sync bal)

    ;; Return
    (let ((event
           {op    : "distribute-epochs",
            user  : user,
            epochs: epochs
            }))
      (print event)
      (ok event) )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; compute reward epoch list

;; Returns epochs starting at `start-epoch' for which `user' has
;; non-zero rewards.
;; Pagination via GENESIS-EPOCH and `end-epoch'.
(define-read-only
  (get-reward
   (user principal)
   (epoch uint))

  (let ((share   (try! (contract-call? .farming-wstx-neebs-core get-share-at user epoch)))
        (rev     (get-revenue-at epoch))
        (calc    (calc-distribute share rev))
        (claimed (default-to u0 (map-get? claims {user: user, epoch: epoch})))
        (amt     (if (is-eq claimed u0) calc u0)))
    (ok {share  : share,
         rev    : rev,
         calc   : calc,
         claimed: claimed,
         amt    : amt})))

(define-read-only
  (get-rewards-step
   (epoch uint)
   (state {user: principal,
           acc : (list 10 ;;XXX: MAX-EPOCHS
                       {epoch : uint,
                        reward: uint}) }) )

  (let ((reward (unwrap-panic
                 (get-reward (get user state)
                             epoch)))
        (amt    (get amt reward)))

    {user: (get user state),
     acc : (if (> amt u0)
               (unwrap-panic
                (as-max-len?
                 (append (get acc state) {epoch: epoch, reward: amt}) ;;FIXME: reward?
                 u10))
               (get acc state))
     }))

(define-read-only
  (get-rewards
   (user        principal)
   (start-epoch uint))

  (let ((end-epoch     (+ start-epoch MAX-EPOCHS)) ;;next
        (epochs_       (mkepochs start-epoch))
        (reward-epochs (fold get-rewards-step epochs_ {user: user, acc: (list)})))

    {reward-epochs: (get acc reward-epochs),
     end-epoch    : end-epoch} ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; epochs
(define-constant OFFSETS (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9))
(define-constant MAX-EPOCHS (len OFFSETS)) ;;10

(define-private
  (epochs-step
   (i_    uint)
   (state {epoch: uint, current: uint, acc: (list 10 uint)})) ;; XXX: MAX-EPOCHS
  {epoch: (+ (get epoch state) u1),
   current: (get current state),
   acc  : (if (>= (get epoch state) (get current state))
              (get acc state)
              (unwrap-panic
               (as-max-len?
                (append (get acc state) (get epoch state))
                u10)))
   })

(define-read-only (mkepochs (start-epoch uint))
  (let ((current (contract-call? .farming-wstx-neebs-core current-epoch))
        (state0  {epoch: start-epoch, current: current, acc: (list)})
        (state   (fold epochs-step OFFSETS state0)))
    (get acc state)))

;;; eof
