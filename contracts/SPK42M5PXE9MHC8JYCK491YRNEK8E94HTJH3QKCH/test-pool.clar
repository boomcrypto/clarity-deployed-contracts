;; (impl-trait ST33GW755MQQP6FZ58S423JJ23GBKK5ZKH3MGR55N.pool-registry-v2.pox-trait-ext)
;; (impl-trait SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60.pool-registry-v1.pox-trait-ext)
(define-constant err-missing-user-pox-addr (err u100))
(define-constant err-map-set-failed (err u101))
(define-constant err-pox-failed (err u102))
(define-constant err-delegate-below-minimum (err u103))
(define-constant err-missing-user (err u104))
(define-constant err-non-positive-amount (err u105))
(define-constant err-not-pool-member (err u106))
(define-constant err-no-user-info (err u107))
(define-constant err-no-stacker-info (err u108))

;; keep track of the last delegation
;; pox-addr: raw bytes of user's account to receive rewards, can be encoded as btc or stx address
;; cycle: cycle id of time of delegation
;; lock-period: desired number of cycles to lock
(define-map user-data principal {pox-addr: (tuple (hashbytes (buff 20)) (version (buff 1))), cycle: uint, lock-period: uint})

;; Keep track of stackers grouped by pool, reward-cycle id and lock-period
;; "grouped-stackers-len" returns the number of lists for the given group
;; "grouped-stackers" returns the actual list
(define-map grouped-stackers {pool: principal, reward-cycle: uint, lock-period: uint, index: uint}
  (list 30 {lock-amount: uint, stacker: principal, unlock-burn-height: uint, pox-addr: (tuple (hashbytes (buff 20)) (version (buff 1))), cycle: uint, lock-period: uint}))
(define-map grouped-stackers-len {pool: principal, reward-cycle: uint, lock-period: uint} uint)

;; Keep track of total stxs stacked grouped by pool, reward-cycle id and lock-period
(define-map grouped-totals {pool: principal, reward-cycle: uint, lock-period: uint} uint)

;;
;; Genesis pox function calls
;;

;; Backport of .pox's burn-height-to-reward-cycle
(define-private (burn-height-to-reward-cycle (height uint))
    (let (
        (pox-info (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox get-pox-info)))
    )
    (/ (- height (get first-burnchain-block-height pox-info)) (get reward-cycle-length pox-info)))
)

;; Backport of .pox's reward-cycle-to-burn-height
(define-private (reward-cycle-to-burn-height (cycle uint))
    (let (
        (pox-info (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox get-pox-info)))
    )
    (+ (get first-burnchain-block-height pox-info) (* cycle (get reward-cycle-length pox-info))))
)

;; What's the current PoX reward cycle?
(define-private (current-pox-reward-cycle)
    (burn-height-to-reward-cycle burn-block-height))


;; Get stacker info
(define-private (pox-get-stacker-info (user principal))
   (contract-call? 'SP000000000000000000002Q6VF78.pox get-stacker-info user))

;; Revoke and delegate stx
(define-private (pox-delegate-stx (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint)))
  (let ((result-revoke (contract-call? 'SP000000000000000000002Q6VF78.pox revoke-delegate-stx)))
    (match (contract-call? 'SP000000000000000000002Q6VF78.pox delegate-stx amount-ustx delegate-to until-burn-ht none)
      success (ok success)
      error (err (* u1000 (to-uint error))))))

;;
;; Helper functions
;;

(define-private (min (amount-1 uint) (amount-2 uint))
  (if (< amount-1 amount-2)
    amount-1
    amount-2))

(define-private (asserts-panic (value bool))
  (unwrap-panic (if value (some true) none)))

;;
;; Helper functions for "grouped-stackers" map
;;

(define-private (merge-details (stacker {lock-amount: uint, stacker: principal, unlock-burn-height: uint}) (user {pox-addr: (tuple (hashbytes (buff 20)) (version (buff 1))), cycle: uint, lock-period: uint}))
  {lock-amount: (get lock-amount stacker),
  stacker: (get stacker stacker),
  unlock-burn-height: (get unlock-burn-height stacker),
  pox-addr: (get pox-addr user),
  cycle: (get cycle user),
  lock-period: (get lock-period user)})

(define-private (insert-in-new-list (pool principal) (reward-cycle uint) (last-index uint) (details {lock-amount: uint, stacker: principal, unlock-burn-height: uint, pox-addr: (tuple (hashbytes (buff 20)) (version (buff 1))), cycle: uint, lock-period: uint}))
  (let ((index (+ last-index u1)))
    (asserts-panic (map-insert grouped-stackers (print {pool: pool, reward-cycle: reward-cycle, lock-period: (get lock-period details), index: index}) (list details)))
    (asserts-panic (map-set grouped-stackers-len {pool: pool, reward-cycle: reward-cycle, lock-period: (get lock-period details)} index))))

(define-private (map-set-details (pool principal) (details {lock-amount: uint, stacker: principal, unlock-burn-height: uint, pox-addr: (tuple (hashbytes (buff 20)) (version (buff 1))), cycle: uint, lock-period: uint}))
  (let ((reward-cycle (+ (burn-height-to-reward-cycle burn-block-height) u1))
        (lock-period (get lock-period details)))
    (let ((last-index (get-status-list-length pool reward-cycle lock-period)))
      (match (map-get? grouped-stackers {pool: pool, reward-cycle: reward-cycle, lock-period: lock-period, index: last-index})
        stackers (match (as-max-len? (append stackers details) u30)
                new-list (map-set grouped-stackers (print {pool: pool, reward-cycle: reward-cycle, lock-period: lock-period, index: last-index}) new-list)
                (insert-in-new-list pool reward-cycle last-index details))
        (map-insert grouped-stackers (print {pool: pool, reward-cycle: reward-cycle, lock-period: lock-period, index: last-index}) (list details)))
      (map-set grouped-totals {pool: pool, reward-cycle: reward-cycle, lock-period: lock-period} (+ (get-total pool reward-cycle lock-period) (get lock-amount details))))))

;; Genesis delegate-stack-stx call.
;; Stores the result in "grouped-stackers".
(define-private (pox-delegate-stack-stx (details {user: principal, amount-ustx: uint})
                  (context (tuple
                      (pox-address (tuple (hashbytes (buff 20)) (version (buff 1))))
                      (start-burn-ht uint)
                      (lock-period uint)
                      (result (list 30 (response (tuple (lock-amount uint) (stacker principal) (unlock-burn-height uint)) uint))))))
  (let ((user (get user details)))
    (let ((pox-address (get pox-address context))
        (start-burn-ht (get start-burn-ht context))
        (lock-period (get lock-period context))
        (amount-ustx (min (get amount-ustx details) (stx-get-balance user))))
      (let ((stack-result
        (if (> amount-ustx u0)
          (match (map-get? user-data user)
            user-details
              (match (contract-call? 'SP000000000000000000002Q6VF78.pox delegate-stack-stx
                          user amount-ustx
                          pox-address start-burn-ht lock-period)
                stacker-details  (begin
                              (map-set-details tx-sender (merge-details stacker-details user-details))
                              (ok stacker-details))
                error (err (* u1000 (to-uint error))))
            err-missing-user)
          err-non-positive-amount)))
        {pox-address: pox-address,
          start-burn-ht: start-burn-ht,
          lock-period: lock-period,
          result: (unwrap-panic (as-max-len? (append (get result context) stack-result) u30))}))))

;;
;; Public function
;;

;; As defined by "pool-registry.pox-trait-ext" trait.
;; Users call this function to delegate the stacking rights to a pool.
;;
;; user-pox-addr: raw bytes of user's address that should be used for payout of rewards by pool admins.
;; lock-period: desired lock period that pool admin should respect.
(define-public (delegate-stx (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint))
              (pool-pox-addr (optional (tuple (hashbytes (buff 20)) (version (buff 1)))))
              (user-pox-addr (tuple (hashbytes (buff 20)) (version (buff 1))))
              (lock-period uint))
  (begin
    (asserts! (map-set user-data tx-sender
                {pox-addr: user-pox-addr, cycle: (current-pox-reward-cycle), lock-period: lock-period})
      err-map-set-failed)
    (pox-delegate-stx amount-ustx delegate-to until-burn-ht)))

;; Pool admins call this function to lock stacks of their pool members in batches
(define-public (delegate-stack-stx (users (list 30 (tuple
                                      (user principal)
                                      (amount-ustx uint))))
                                    (pox-address { version: (buff 1), hashbytes: (buff 20) })
                                    (start-burn-ht uint)
                                    (lock-period uint))
    (let ((stack-result (get result (fold pox-delegate-stack-stx users {start-burn-ht: start-burn-ht, pox-address: pox-address, lock-period: lock-period, result: (list)}))))
      (ok stack-result)))

;;
;; Read-only functions
;;

;; Returns the user's stacking details from pox contract,
;; the user's delegation details from "user-data" and the
;; total locked stacks for the given pool and user's stacking parameters.
;; Note, that user can stack with a different pool, results need to verify stacker-info.pox-addr
(define-read-only (get-status (pool principal) (user principal))
  (match (pox-get-stacker-info user)
    stacker-info  (match (map-get? user-data user)
      user-info
        (ok {stacker-info: stacker-info, user-info: user-info, total: (get-total pool (get first-reward-cycle stacker-info) (get lock-period stacker-info))})
      err-no-user-info)
    err-no-stacker-info))

;; Get hte number of lists of stackers that have locked their stx for the given pool, cycle and lock-period.
(define-read-only (get-status-list-length (pool principal) (reward-cycle uint) (lock-period uint))
  (default-to u0 (map-get? grouped-stackers-len {pool: pool, reward-cycle: reward-cycle, lock-period: lock-period}))
)

;; Get a list of stackers that have locked their stx for the given pool, cycle and lock-period.
;; index: must be smaller than get-status-list-length
(define-read-only (get-status-list (pool principal) (reward-cycle uint)  (lock-period uint) (index uint))
  {total: (get-total pool reward-cycle lock-period),
  status-list: (map-get? grouped-stackers {pool: pool, reward-cycle: reward-cycle, lock-period: lock-period, index: index})}
)

;; Get total stacks locked by given pool, reward-cycle and lock-period.
;; The total for a given reward cycle needs to be calculated off-chain
;; depending on the pool's policy.
(define-read-only (get-total (pool principal) (reward-cycle uint) (lock-period uint))
  (default-to u0 (map-get? grouped-totals {pool: pool, reward-cycle: reward-cycle, lock-period: lock-period}))
)