;;; Staking distributor: receive and distribute rewards.

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait .univ2-share-fee-to-trait.share-fee-to-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-check-core                (err u802))
(define-constant err-distribute-preconditions  (err u803))
(define-constant err-distribute-postconditions (err u804))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auth
(define-data-var core principal .univ2-core)
(define-read-only (get-core) (var-get core))
(define-private (check-core)
  (ok (asserts! (is-eq tx-sender (get-core)) err-check-core)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; accounting
(define-map revenue
  {pool: uint, epoch: uint}
  {token0: uint, token1: uint}) ;;total revenue shared for that pool (per epoch)

(define-read-only (get-revenue-at (pool uint) (epoch uint))
  (default-to
    {token0: u0, token1: u0}
    (map-get? revenue {pool: pool, epoch: epoch}) ))

;; Called by univ2-core.clar on swap.
;; MUST ALWAYS BE ACCOMPANIED BY A CORRECT TRANSFER!
;; Could also store balance and compare to previous but that adds code.
(define-public
  (receive
    (pool      uint)
    (is-token0 bool)
    (amt       uint))

  (let ((epoch (contract-call? .staking-core-neebs current-epoch))
        (key   {pool: pool, epoch: epoch})
        (r0    (get-revenue-at pool epoch))
        (t0r   (get token0 r0))
        (t1r   (get token1 r0))
        (r1    {token0: (if is-token0 (+ t0r amt) t0r),
                token1: (if is-token0 t1r (+ t1r amt)) }))

    (try! (check-core)) ;;XXX: crucial to enforce invariant!
    (ok (map-set revenue key r1)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; claims
(define-map claims
  {user: principal, pool: uint, epoch: uint}
  uint) ;;block number claimed at

(define-private
  (do-claim
   (user  principal)
   (pool  uint)
   (epoch uint))
  (map-set claims
           {user: user, pool: pool, epoch: epoch}
           block-height))

(define-read-only
  (has-claimed-epoch
   (user  principal)
   (pool  uint)
   (epoch uint))
  (is-some (map-get? claims {user: user, pool: pool, epoch: epoch})))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; low level API
(define-private
  (do-distribute
   (user   principal)
   (token0 <ft-trait>)
   (token1 <ft-trait>)
   (amts   {token0: uint, token1: uint}))

  (let ((protocol (as-contract tx-sender))
        (amt0     (get token0 amts))
        (amt1     (get token1 amts))
        (tx0      (if (> amt0 u0)
                    (try! (as-contract (contract-call? token0 transfer
                                                       amt0 protocol user none)))
                    true) )
        (tx1      (if (> amt1 u0)
                    (try! (as-contract (contract-call? token1 transfer
                                                       amt1 protocol user none)))
                    true)))
    (if (and tx0 tx1) (ok true) err-distribute-postconditions) ))

(define-read-only
  (calc-distribute
   (share {staked: uint, total: uint})
   (rev   {token0: uint, token1: uint}))
  {
  token0: (if (> (get total share) u0)
              (/ (* (get token0 rev) (get staked share)) (get total share))
            u0),
  token1: (if (> (get total share) u0)
              (/ (* (get token1 rev) (get staked share)) (get total share))
            u0)
  })

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; distribute-epoch
(define-public
  (distribute-epoch
   (user   principal)
   (id     uint)
   (token0 <ft-trait>)
   (token1 <ft-trait>)
   (epoch  uint))

  (let ((pool  (contract-call? .univ2-core do-get-pool id))
        (share (try! (contract-call? .staking-core-neebs get-share-at user epoch)))
        (rev   (get-revenue-at id epoch))
        (amts  (calc-distribute share rev)) )

    ;; Preconditions
    (asserts!
     (and
      (not (has-claimed-epoch user id epoch))
    ;;(< epoch (current-epoch)) checked by get-share-at
      (is-eq (contract-of token0) (get token0 pool))
      (is-eq (contract-of token1) (get token1 pool))
      )
     err-distribute-preconditions)

    ;; Update global state
    (try! (do-distribute user token0 token1 amts))

    ;; Update local state
    (do-claim user id epoch)

    ;; Postconditions

    ;; Return
    (let ((event
           {op     : "distribute-epoch",
            user   : user,
            pool   : pool,
            epoch  : epoch,
            share  : share,
            revenue: rev,
            amts   : amts
           }))
      (print event)
      (ok event)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; distribute-epochs
(define-private
  (distribute-epochs-step
   (epoch uint)
   (args  {user: principal, pool: uint, token0: <ft-trait>, token1: <ft-trait>}))

  (let ((event_
         (unwrap-panic
          (distribute-epoch
           (get user args)
           (get pool args)
           (get token0 args)
           (get token1 args)
           epoch)) ))
    args))

(define-public
  (distribute-epochs
   (user   principal)
   (pool   uint)
   (token0 <ft-trait>)
   (token1 <ft-trait>)
   (epochs (list 10 uint))) ;;XXX: MAX-EPOCHS

  (let ((args {user  : user,
               pool  : pool,
               token0: token0,
               token1: token1})
        (res_ (fold distribute-epochs-step epochs args)))

    ;; Return
    (let ((event
           {op    : "distribute-epochs",
            user  : user,
            pool  : pool,
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
  (has-reward (reward {token0: uint, token1: uint}))
  (or (> (get token0 reward) u0)
      (> (get token1 reward) u0)) )

(define-read-only
  (get-reward
   (user  principal)
   (pool  uint)
   (epoch uint))

  (let ((share   (try! (contract-call? .staking-core-neebs get-share-at user epoch)))
        (rev     (get-revenue-at pool epoch))
        (claimed (has-claimed-epoch user pool epoch))
        (amts    (calc-distribute share rev)))

    (ok (if claimed {token0: u0, token1: u0} amts) )))

(define-read-only
  (get-rewards-step
   (epoch uint)
   (state {args: {user: principal, pool: uint},
           acc : (list 10 ;;XXX: MAX-EPOCHS
                       {epoch : uint,
                        reward: {token0: uint, token1: uint}}) }) )

  (let ((reward (unwrap-panic
                 (get-reward (get user (get args state))
                             (get pool (get args state))
                             epoch))))

    {args: (get args state),
     acc : (if (has-reward reward)
               (unwrap-panic
                (as-max-len?
                 (append (get acc state) {epoch: epoch, reward: reward})
                 u10))
               (get acc state))
     }))

(define-read-only
  (get-rewards
   (user        principal)
   (pool        uint)
   (start-epoch uint))

  (let ((end-epoch     (+ start-epoch MAX-EPOCHS)) ;;next
        (epochs_       (mkepochs start-epoch))
        (args          {user: user, pool: pool})
        (reward-epochs (fold get-rewards-step epochs_ {args: args, acc: (list)})))

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
  (let ((current (contract-call? .staking-core-neebs current-epoch))
        (state0  {epoch: start-epoch, current: current, acc: (list)})
        (state   (fold epochs-step OFFSETS state0)))
    (get acc state)))

;;; eof
