;;; Core: maintains a historical distribution of stake shares.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-stake-preconditions    (err u901))
(define-constant err-stake-postconditions   (err u902))
(define-constant err-unstake-preconditions  (err u903))
(define-constant err-unstake-postconditions (err u904))
(define-constant err-share-preconditions    (err u905))
(define-constant err-share-postconditions   (err u906))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; constants
(define-constant MIN-STAKE u1)
(define-constant STAKING-TOKEN .wstx-long)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Map blocks to epochs
(define-constant EPOCH-LENGTH  u500) ;; ~1 week at ~10min/block
(define-constant GENESIS-BLOCK block-height)
(define-constant GENESIS-EPOCH (calc-epoch GENESIS-BLOCK)) ;;zero

(define-read-only (current-epoch) (calc-epoch block-height))

;; Crash on block in the past.
(define-read-only (calc-epoch (block uint))
  (/ (- block GENESIS-BLOCK) EPOCH-LENGTH))

(define-read-only (calc-epoch-start (epoch uint))
  (+ GENESIS-BLOCK (* EPOCH-LENGTH epoch)))

(define-read-only (calc-epoch-end (epoch uint))
  (- (+ GENESIS-BLOCK (* EPOCH-LENGTH (+ epoch u1))) u1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; state
(define-data-var total-staked
  {epoch: uint, ;;last state change
   min  : uint, ;;minimum staked during current epoch
   end  : uint} ;;total staked during current epoch
  {epoch: GENESIS-EPOCH,
   min  : u0,
   end  : u0})

(define-map user-staked
  principal
  {epoch: uint,
   min  : uint,
   end  : uint})

(define-read-only (get-total-staked) (var-get total-staked))

(define-read-only (get-user-staked (user principal))
  (default-to
    {epoch: GENESIS-EPOCH, min: u0, end: u0}
    (map-get? user-staked user)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stake
(define-public (stake (amt uint))
  (let ((user      tx-sender)
        (protocol  (as-contract tx-sender))

        (epoch     (current-epoch))

        (t-staked  (get-total-staked))
        (u-staked  (get-user-staked user))
        (t-end1    (+ (get end t-staked) amt))
        (u-end1    (+ (get end u-staked) amt)) )

    ;; Preconditions
    (asserts!
     (and
      (>= epoch GENESIS-EPOCH)
      (>= epoch (get epoch t-staked))
      (>= epoch (get epoch u-staked))
      (>= (get epoch t-staked) (get epoch u-staked))
      (>  amt u0)
      (>= u-end1 MIN-STAKE)
      )
     err-stake-preconditions)

    ;; Update global state
    (try! (contract-call? .wstx-long transfer amt user protocol none))

    ;; Update local state
    ;; N.B. during the genesis epoch, min is always zero.
    (if (is-eq epoch (get epoch t-staked))
        (var-set total-staked
                 (merge t-staked {end: t-end1}))
        (var-set total-staked
                 {epoch: epoch,
                  min  : (get end t-staked),
                  end  : t-end1}))

    (if (is-eq epoch (get epoch u-staked))
        (map-set user-staked user (merge u-staked {end: u-end1}))
        (map-set user-staked user
                 {epoch: epoch,
                  min  : (get end u-staked),
                  end  : u-end1}))

    ;; Postconditions
    (asserts!
      (>= (unwrap-panic (contract-call? .wstx-long get-balance protocol))
          (get end (get-total-staked)))
     err-stake-postconditions)

    ;; Return
    (let ((event
           {op       : "stake",
            user     : user,
            amt      : amt,
            epoch    : epoch,
            total-old: t-staked,
            user-old : u-staked,
            total-new: (get-total-staked),
            user-new : (get-user-staked user)
           }))
      (print event)
      (ok event)
      )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; unstake
(define-public (unstake (amt uint))
  (let ((user      tx-sender)
        (protocol  (as-contract tx-sender))

        (epoch     (current-epoch))

        (t-staked  (get-total-staked))
        (u-staked  (get-user-staked user))
        (t-end1    (- (get end t-staked) amt))
        (u-end1    (- (get end u-staked) amt))
        (t-min1    (min t-end1 (get min t-staked))) ;;unstake most recent first
        (u-min1    (min u-end1 (get min u-staked))) )

    ;; Preconditions
    (asserts!
     (and
      (>= epoch GENESIS-EPOCH)
      (>= epoch (get epoch t-staked))
      (>= epoch (get epoch u-staked))
      (>= (get epoch t-staked) (get epoch u-staked))
      (>  amt u0)
    ;;(<= amt (get end u-staked))
      (or (>= u-end1 MIN-STAKE)
          (is-eq u-end1 u0))
      )
     err-unstake-preconditions)

    ;; Update global state
    (try! (as-contract (contract-call? .wstx-long transfer amt protocol user none)))

    ;; Update local state
    ;; N.B. during the genesis epoch, min is always zero.
    (if (is-eq epoch (get epoch t-staked))
        (var-set total-staked (merge t-staked {min: t-min1, end: t-end1}))
        (var-set total-staked
                 {epoch: epoch,
                  min  : t-end1,
                  end  : t-end1}))

    (if (is-eq epoch (get epoch u-staked))
        (map-set user-staked user (merge u-staked {min: u-min1, end: u-end1}))
        (map-set user-staked user
                 {epoch: epoch,
                  min  : u-end1,
                  end  : u-end1}))

    ;; Postconditions
    (asserts!
     (and
      (>= (unwrap-panic (contract-call? .wstx-long get-balance protocol))
          (get end (get-total-staked)))
      )
     err-unstake-postconditions)

    ;; Return
    (let ((event
           {op       : "unstake",
            user     : user,
            amt      : amt,
            epoch    : epoch,
            total-old: t-staked,
            user-old : u-staked,
            total-new: (get-total-staked),
            user-new : (get-user-staked user)
           }))
      (print event)
      (ok event) )))

(define-read-only (min (x uint) (y uint)) (if (<= x y) x y))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; staking distribution over time

;; convenience/testing
(define-read-only
  (get-unstable-share-at
     (user  principal)
     (epoch uint))
  (if (< epoch (current-epoch))
      (get-share-at user epoch)
      (let ((t     (get-total-staked))
            (u     (get-user-staked user))
            (t-amt (get end t))
            (u-amt (get end u))
            (share {staked: u-amt, total: t-amt}))
        (ok share))))

(define-read-only
  (get-share-at
   (user  principal)
   (epoch uint))

  (let ((last-block (calc-epoch-end epoch))
        (header     (unwrap-panic (get-block-info? id-header-hash last-block)))
        (t-at       (at-block header (get-total-staked)))
        (u-at       (at-block header (get-user-staked user)))
        (t-amt      (eligible-amount epoch t-at))
        (u-amt      (eligible-amount epoch u-at))
        (share      {staked: u-amt, total: t-amt}) )

    ;; Preconditions
    (asserts!
     (and
      (< epoch (current-epoch))
      (<= (get epoch t-at) epoch)
      (<= (get epoch u-at) epoch)
      )
     err-share-preconditions)

      (ok share) ))

(define-read-only
  (eligible-amount
   (goal  uint)
   (entry {epoch: uint, min: uint, end: uint}))

  (if (is-eq goal (get epoch entry))
      ;; If the specific epoch we are looking at had interactions,
      ;; only the minimum amount staked continuously during that
      ;; period counts.
      (get min entry)
      ;; Otherwise carry over staked amount from previous active epoch.
      (get end entry)) )

;;; eof
