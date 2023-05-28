;; @contract pox-3 wrapper contract for stacking pools
;; @version 2
;; Changelog: fix decrease error, add stacking stats for this pool, add metadata for users

;; User calls delegate-stx at first and provides a btc address to receive rewards.
;; Pool operators lock the user's delegated STX tokens according to their rules.
;; Some pools require a minimum amount. Most pool operators lock the delegated STX
;; for the next cycle only.
;; Users can delegate more stx by calling delegate-stx with a higher amount for the next cycle.

;;
;; Data storage
;;
(define-constant err-not-found (err u404))
(define-constant err-non-positive-amount (err u500))
(define-constant err-no-stacker-info (err u501))
(define-constant err-no-user-info (err u502))
(define-constant err-decrease-forbidden (err u503))
;; Error code 3 is used by pox-3 contract for already stacking errors
(define-constant err-already-stacking (err u603))
;; Error code 9 is used by pox-3 contract for stacking-permission-denied
(define-constant err-stacking-permission-denied (err u609))

;; Allowed contract-callers handling a user's stacking activity.
(define-map allowance-contract-callers
  { sender: principal, contract-caller: principal}
  { until-burn-ht: (optional uint)})

;; Keep track of the last delegation
;; pox-addr: raw bytes of user's account to receive rewards, can be encoded as btc or stx address
;; cycle: cycle id of time of delegation
(define-map user-data principal {pox-addr: {hashbytes: (buff 32), version: (buff 1)}, cycle: uint})

;; more metadata for each stacker
(define-map metadata {stacker: principal, key: (string-ascii 8)} (string-ascii 80))

;; Keep track of stackers grouped by pool and reward-cycle id
;; "grouped-stackers-len" returns the number of lists for the given group
;; "grouped-stackers" returns the actual list
(define-map grouped-stackers {pool: principal, reward-cycle: uint, index: uint}
  (list 30 {lock-amount: uint, stacker: principal, unlock-burn-height: uint, pox-addr: {hashbytes: (buff 32), version: (buff 1)}, cycle: uint}))
(define-map grouped-stackers-len {pool: principal, reward-cycle: uint} uint)

;; Keep track of total stxs stacked grouped by pool and reward-cycle id
(define-map grouped-totals {pool: principal, reward-cycle: uint} uint)

;;
;; Helper functions for "grouped-stackers" map
;;

(define-private (merge-details (stacker {lock-amount: uint, stacker: principal, unlock-burn-height: uint}) (user {pox-addr: {hashbytes: (buff 32), version: (buff 1)}, cycle: uint}))
  {lock-amount: (get lock-amount stacker),
   stacker: (get stacker stacker),
   unlock-burn-height: (get unlock-burn-height stacker),
   pox-addr: (get pox-addr user),
   cycle: (get cycle user)})

(define-private (insert-in-new-list (pool principal) (reward-cycle uint) (last-index uint) (details {lock-amount: uint, stacker: principal, unlock-burn-height: uint, pox-addr: {hashbytes: (buff 32), version: (buff 1)}, cycle: uint}))
  (let ((index (+ last-index u1)))
    (map-insert grouped-stackers (print {pool: pool, reward-cycle: reward-cycle, index: index}) (list details))
    (map-set grouped-stackers-len {pool: pool, reward-cycle: reward-cycle} index)))

(define-private (map-set-details (pool principal) (details {lock-amount: uint, stacker: principal, unlock-burn-height: uint, pox-addr: {hashbytes: (buff 32), version: (buff 1)}, cycle: uint}))
  (let ((reward-cycle (+ (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle) u1))
        (last-index (get-status-lists-last-index pool reward-cycle))
        (stacker-key {pool: pool, reward-cycle: reward-cycle, index: last-index}))
    (match (map-get? grouped-stackers stacker-key)
      stackers (match (as-max-len? (append stackers details) u30)
                 updated-list (map-set grouped-stackers stacker-key updated-list)
                 (insert-in-new-list pool reward-cycle last-index details))
      (map-insert grouped-stackers stacker-key (list details)))
    (map-set grouped-totals {pool: pool, reward-cycle: reward-cycle} (+ (get-total pool reward-cycle) (get lock-amount details)))))

;;
;; Helper functions for pox-3 calls
;;

;; Get stacker info
(define-private (pox-get-stacker-info (user principal))
  (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-stacker-info user))

;; Revokes and delegates stx
(define-private (delegate-stx-inner (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint)))
  (let ((result-revoke
            ;; Calls revoke and ignores result
          (contract-call? 'SP000000000000000000002Q6VF78.pox-3 revoke-delegate-stx)))
    ;; Calls delegate-stx, converts any error to uint
    (match (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stx amount-ustx delegate-to until-burn-ht none)
      success (ok success)
      error (err (* u1000 (to-uint error))))))


;; Calls pox-3 delegate-stack-extend and delegate-stack-increase.
;; parameter amount-ustx must be lower or equal the stx balance and the delegated amount
(define-private (delegate-stack-extend-increase (user principal)
                  (amount-ustx uint)
                  (pox-address {hashbytes: (buff 32), version: (buff 1)}))
  (let ((status (stx-account user))
        (locked-amount (get locked status)))
    (asserts! (>= amount-ustx locked-amount) err-decrease-forbidden)
    (match (maybe-extend-for-next-cycle user pox-address status)
      success-extend (let ((unlock-burn-height (get unlock-burn-height success-extend)))
            (if (is-eq amount-ustx locked-amount)
                ;; do not increase
                (begin
                  (asserts! (> unlock-burn-height (get unlock-height status)) err-already-stacking)
                  (ok {lock-amount: (get locked status),
                      stacker: user,
                      unlock-burn-height: unlock-burn-height}))
                ;; else increase
                (let ((increase-by (- amount-ustx locked-amount)))
                  (match (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stack-increase
                          user pox-address increase-by)
                    success-increase (ok {lock-amount: (get total-locked success-increase),
                                          stacker: user,
                                          unlock-burn-height: unlock-burn-height})
                    error-increase (err (* u1000000000 (to-uint error-increase)))))))
      error (err (* u1000000 (to-uint error))))))

;; Tries to extend the user's locking to the next cycle
;; if not yet locked until the end of the next cycle.
(define-private (maybe-extend-for-next-cycle
                  (user principal)
                  (pox-address {hashbytes: (buff 32), version: (buff 1)})
                  (status {locked: uint, unlocked: uint, unlock-height: uint})
                )
  (let ((current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle))
        (unlock-height (get unlock-height status)))
    (if (not-locked-for-cycle unlock-height (+ u1 current-cycle))
      (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stack-extend
             user pox-address u1)
      (ok {stacker: user, unlock-burn-height: unlock-height}))))

;; Stacks given amount of delegated stx tokens.
;; Stores the result in "grouped-stackers".
(define-private (delegate-stack-stx-fold (details {user: principal, amount-ustx: uint})
                  (context {pox-address: {hashbytes: (buff 32), version: (buff 1)},
                            start-burn-ht: uint,
                            result: (list 30 (response {lock-amount: uint, stacker: principal, unlock-burn-height: uint} uint))}))
  (let ((user (get user details))
        (user-account (stx-account user))
        (amount-ustx (min (get amount-ustx details) (+ (get locked user-account) (get unlocked user-account)))))
    (pox-delegate-stack-stx-amount user amount-ustx context)))

;; Stacks maximal amount of delegated stx tokens.
;; Stores the result in "grouped-stackers".
(define-private (delegate-stack-stx-simple-fold (user principal)
                  (context {pox-address: {hashbytes: (buff 32), version: (buff 1)},
                            start-burn-ht: uint,
                            result: (list 30 (response {lock-amount: uint, stacker: principal, unlock-burn-height: uint} uint))}))
  (let ((buffer-amount u1000000)
        (user-account (stx-account user))
        (allowed-amount (min (get-delegated-amount user) (+ (get locked user-account) (get unlocked user-account))))
        ;; Amount to lock must be leq allowed-amount and geq locked amount.
        ;; Increase the locked amount if possible, but leave a buffer for revoke tx fees if possible.
        ;; Decreasing the locked amount requires a cool down cycle.
        (amount-ustx (if (> allowed-amount buffer-amount)
                            (max (get locked user-account) (- allowed-amount buffer-amount))
                            allowed-amount)))
    (pox-delegate-stack-stx-amount user amount-ustx context)))

;; Stacks the given amount of delegated stx tokens
(define-private (pox-delegate-stack-stx-amount (user principal) (amount-ustx uint)
                  (context {pox-address: {hashbytes: (buff 32), version: (buff 1)},
                            start-burn-ht: uint,
                            result: (list 30 (response {lock-amount: uint, stacker: principal, unlock-burn-height: uint} uint))}))
  (let ((pox-address (get pox-address context))
        (start-burn-ht (get start-burn-ht context))
        (stack-result
          (if (> amount-ustx u0)
            (match (map-get? user-data user)
              user-details
                ;; Call delegate-stack-stx
                ;; On failure, call delegate-stack-extend and increase
              (match (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stack-stx
                       user amount-ustx
                       pox-address start-burn-ht u1)
                stacker-details  (begin
                                  ;; Store result on success
                                   (map-set-details tx-sender (merge-details stacker-details user-details))
                                   (ok stacker-details))
                error (if (is-eq error 3) ;; Check whether user is already stacked
                        (match (delegate-stack-extend-increase user amount-ustx pox-address)
                          stacker-details-2 (begin
                                  ;; Store result on success
                                   (map-set-details tx-sender (merge-details stacker-details-2 user-details))
                                   (ok stacker-details-2))
                          error-extend-increase (err error-extend-increase))
                        (err (* u1000 (to-uint error)))))
              err-not-found)
            err-non-positive-amount)))
        ;; Return a tuple even if delegate-stack-stx call failed
    {pox-address: pox-address,
     start-burn-ht: start-burn-ht,
     result: (unwrap-panic (as-max-len? (append (get result context) stack-result) u30))}))
;;
;; Public functions
;;

;; @desc User calls this function to delegate the stacking rights to a pool.
;; Users can revoke delegation and stx tokens will unlock at the end of the locking period.
;;
;; @param amount-ustx; amount to delegate. Can be higher than current stx balance.
;; @param delegate-to; the pool's Stacks address.
;; @param until-burn-ht; optional maximal duration of the pool membership. Can be none for undetermined membership.
;; @param pool-pox-addr; the optional pool's bitcoin reward address. Can be none, so that the pool operator can choose different addresses.
;; @param user-pox-addr; raw bytes of user's address that should be used for payout of rewards by pool admins.
(define-public (delegate-stx (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint))
                 (pool-pox-addr (optional {hashbytes: (buff 32), version: (buff 1)}))
                 (user-pox-addr {hashbytes: (buff 32), version: (buff 1)})
                 (user-metadata (optional {keys: (list 30 (string-ascii 8)), values: (list 30 (string-ascii 80))})))
  (begin
    ;; Must be called directly by the tx-sender or by an allowed contract-caller
    (asserts! (check-caller-allowed) err-stacking-permission-denied)
    (match user-metadata
      md (map set-metadata-internal (get keys md) (get values md))
      (list true))
    (map-set user-data tx-sender
      {pox-addr: user-pox-addr, cycle: (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle)})
    (delegate-stx-inner amount-ustx delegate-to until-burn-ht)))

;; @desc Pool admins call this function to lock stacks of their pool members in batches for 1 cycle.
;; @param users; list of users with amounts to lock.
;; @param pox-address; the pool's bitcoin reward address.
;; @param start-burn-ht; a future bitcoin height of the current cycle.
(define-public (delegate-stack-stx (users (list 30 {user: principal, amount-ustx: uint}))
                 (pox-address { version: (buff 1), hashbytes: (buff 32)})
                 (start-burn-ht uint))
  (begin
    (asserts! (check-caller-allowed) err-stacking-permission-denied)
    (ok (get result
          (fold delegate-stack-stx-fold users {start-burn-ht: start-burn-ht, pox-address: pox-address, result: (list)})))))

;; @desc Pool admins call this function to lock stacks of their pool members in batches for a lock period of 1 cycle.
;; The locking amount is determined from the delegated amount and the users balances.
;; @param users; list of current pool members.
;; @param pox-address; the pool's bitcoin reward address.
;; @param start-burn-ht; a future bitcoin height of the current cycle.
(define-public (delegate-stack-stx-simple (users (list 30 principal))
                 (pox-address { version: (buff 1), hashbytes: (buff 32)})
                 (start-burn-ht uint))
  (begin
    (asserts! (check-caller-allowed) err-stacking-permission-denied)
    (ok (get result
          (fold delegate-stack-stx-simple-fold users {start-burn-ht: start-burn-ht, pox-address: pox-address, result: (list)})))))
;;
;; Read-only functions
;;

;; Returns the user's stacking details from pox contract,
;; the user's delegation details from "user-data" and the
;; total locked stacks for the given pool and cycle-id.
(define-read-only (get-status (pool principal) (user principal) (cycle-id uint))
  (let ((stacker-info (unwrap! (pox-get-stacker-info user) err-no-stacker-info)))
    (ok {stacker-info: stacker-info,
         user-info: (unwrap! (map-get? user-data user) err-no-user-info),
         total: (get-total pool cycle-id)})))

;; Returns the number of lists of stackers that have locked their stx for the given pool and cycle.
(define-read-only (get-status-lists-last-index (pool principal) (reward-cycle uint))
  (default-to u0 (map-get? grouped-stackers-len {pool: pool, reward-cycle: reward-cycle})))

;; Returns a list of stackers that have locked their stx for the given pool and cycle.
;; index: must be smaller than get-status-lists-last-index
(define-read-only (get-status-list (pool principal) (reward-cycle uint) (index uint))
  {total: (get-total pool reward-cycle),
   status-list: (map-get? grouped-stackers {pool: pool, reward-cycle: reward-cycle, index: index})})

;; Returns currently delegated amount for a given user
(define-read-only (get-delegated-amount (user principal))
  (default-to u0 (get amount-ustx (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-delegation-info user))))

;; Returns information about last delegation call for a given user
;; This information can be obsolete due to a normal revoke call
(define-read-only (get-user-data (user principal))
  (map-get? user-data user))

;; Returns locked and unlocked amount for given user
(define-read-only (get-stx-account (user principal))
  (stx-account user))

;; Returns total stacks locked by given pool, reward-cycle.
;; The total for a given reward cycle needs to be calculated off-chain
;; depending on the pool's policy.
(define-read-only (get-total (pool principal) (reward-cycle uint))
  (default-to u0 (map-get? grouped-totals {pool: pool, reward-cycle: reward-cycle})))

;; Returns true if the given burn chain height is smaller
;; than the start of the given reward cycle id.
(define-read-only (not-locked-for-cycle (unlock-burn-height uint) (cycle uint))
  (<= unlock-burn-height (contract-call? 'SP000000000000000000002Q6VF78.pox-3 reward-cycle-to-burn-height cycle)))

;;
;; Functions to handle metadata
;;

(define-read-only (get-metadata (key {stacker: principal, key: (string-ascii 8)}))
  (map-get? metadata key))

(define-read-only (get-metadata-many (keys (list 30 {stacker: principal, key: (string-ascii 8)})))
  (map get-metadata keys))

(define-public (set-metadata (key (string-ascii 8)) (value (string-ascii 80)))
  (begin
    (asserts! (check-caller-allowed) err-stacking-permission-denied)
    (ok (set-metadata-internal key value))))

(define-public (set-metadata-many (keys (list 30 (string-ascii 8))) (values (list 30 (string-ascii 80))))
  (begin
    (asserts! (check-caller-allowed) err-stacking-permission-denied)
    (ok (map set-metadata-internal keys values))))

(define-private (set-metadata-internal (key (string-ascii 8)) (value (string-ascii 80)))
  (map-set metadata {stacker: tx-sender, key: key} value))

;; Returns minimum
(define-private (min (amount-1 uint) (amount-2 uint))
  (if (< amount-1 amount-2)
    amount-1
    amount-2))

;; Returns maximum
(define-private (max (amount-1 uint) (amount-2 uint))
  (if (> amount-1 amount-2)
    amount-1
    amount-2))

;;
;; Functions about allowance of delegation/stacking contract calls
;;

;; Give a contract-caller authorization to call stacking methods
;;  normally, stacking methods may only be invoked by _direct_ transactions
;;   (i.e., the tx-sender issues a direct contract-call to the stacking methods)
;;  by issuing an allowance, the tx-sender may call through the allowed contract
(define-public (allow-contract-caller (caller principal) (until-burn-ht (optional uint)))
  (begin
    (asserts! (is-eq tx-sender contract-caller) err-stacking-permission-denied)
    (ok (map-set allowance-contract-callers
          { sender: tx-sender, contract-caller: caller}
          { until-burn-ht: until-burn-ht}))))

;; Revokes contract-caller authorization to call stacking methods
(define-public (disallow-contract-caller (caller principal))
  (begin
    (asserts! (is-eq tx-sender contract-caller) err-stacking-permission-denied)
    (ok (map-delete allowance-contract-callers { sender: tx-sender, contract-caller: caller}))))

;; Verifies that the contract caller has allowance to handle the tx-sender's stacking
(define-read-only (check-caller-allowed)
  (or (is-eq tx-sender contract-caller)
    (let ((caller-allowed
                 ;; if not in the caller map, return false
            (unwrap! (map-get? allowance-contract-callers
                       { sender: tx-sender, contract-caller: contract-caller})
              false))
          (expires-at
               ;; if until-burn-ht not set, then return true (because no expiry)
            (unwrap! (get until-burn-ht caller-allowed) true)))
          ;; is the caller allowance still valid
      (< burn-block-height expires-at))))

;; Returns the burn height at which a particular contract is allowed to stack for a particular principal.
;; The result is (some (some X)) if X is the burn height at which the allowance terminates.
;; The result is (some none) if the caller is allowed indefinitely.
;; The result is none if there is no allowance record.
(define-read-only (get-allowance-contract-callers (sender principal) (calling-contract principal))
  (map-get? allowance-contract-callers { sender: sender, contract-caller: calling-contract}))
