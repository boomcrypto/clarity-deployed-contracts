;; @contract pox-3 Self-Service Pool
;; @version 2
;; Changelog: fix decrease error, add stacking stats for this pool

;; Self-service non-custodial stacking pool
;; The pool locks for 1 cycle, amount can be increased at each cycle.
;; Users trust the reward admin that they will receive their share of rewards.
;; Reward admin can be a contract as well.
;;
;; User calls delegate-stx once.
;; For next cycles, users can call delegate-stx
;; or ask automation, friends or family to extend stacking using delegate-stack-stx.

;; Self-service function "delegate-stx" does the following:
;; 1. Revoke delegation if necessary.
;; 2. Delegates STX.
;; 3. For first time user, stacks the caller's stx tokens for 1 cycle.
;;    For stackerd user, extends locking and if needed increases amount.
;;    The amount is the minimum of the balance and the delegate amount
;;    minus some STX as buffer.
;;    The STX buffer is left unlocked for users to call revoke-delegate-stx.
;; 4. If possible, commits the pool's amount.
;; Returns (ok true) if the aggregation commit happened, otherwise (ok false).

;; Pool operator function "delegate-stack-stx" does
;; step 3. (for stacked users) and 4. from "delegate-stx" for
;; the following cycles.
;; This function can be called by anyone when less than 1050 blocks are
;; left until the cycle start. This gives the stacker 1 week to unlock
;; the STX if wanted before it can be locked again for friends and family (or enemies).

;;
;; Data storage
;;

;; Map of reward cycle to pox reward set index.
;; Reward set index gives access to the total locked stx of the pool.
(define-map pox-addr-indices uint uint)
;; Map of reward cyle to block height of last commit
(define-map last-aggregation uint uint)
;; Map of users to locked amounts with this pool
;; used to handle pool members swimming in two pools
(define-map locked-amounts principal {amount-ustx: uint, unlock-height: uint})
;; Map of admins that can change the pox-address
(define-map reward-admins principal bool)
(map-set reward-admins tx-sender true)

(define-data-var active bool true)
(define-data-var pool-pox-address {hashbytes: (buff 32), version: (buff 1)}
  {version: 0x04,
   hashbytes: 0x83ed66860315e334010bbfb76eb3eef887efee0a})
(define-data-var stx-buffer uint u1000000) ;; 1 STX

;; Half cycle lenght is 1050 for mainnet
(define-constant half-cycle-length (/ (get reward-cycle-length (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-pox-info))) u2))

(define-constant err-unauthorized (err u401))
(define-constant err-forbidden (err u403))
(define-constant err-too-early (err u500))
(define-constant err-decrease-forbidden (err u503))
(define-constant err-pox-address-deactivated (err u504))
;; Error code 3 is used by pox-3 contract for already stacking errors
(define-constant err-already-stacking (err u603))
;; Error code 9 is used by pox-3 contract for permission denied errors
(define-constant err-stacking-permission-denied (err u609))
;; Allowed contract-callers handling a user's stacking activity.
(define-map allowance-contract-callers
  { sender: principal, contract-caller: principal}
  { until-burn-ht: (optional uint)})


;;
;; Helper functions for pox-3 calls
;;

;; Revokes and delegates stx
(define-private (delegate-stx-inner (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint)))
  (let ((result-revoke
            ;; Calls revoke and ignores result
          (contract-call? 'SP000000000000000000002Q6VF78.pox-3 revoke-delegate-stx)))
    ;; Calls delegate-stx, converts any error to uint
    (match (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stx amount-ustx delegate-to until-burn-ht none)
      success (ok success)
      error (err (* u1000 (to-uint error))))))

;; Locks the users STX and extends the locking period
;; and increases the amount if necessary.
;; If possible, the locked stx of the pool are commited
(define-private (lock-and-commit (user principal) (current-cycle uint))
  (match (as-contract (lock-delegated-stx user))
    lock-result (ok {lock-result: lock-result,
      commit-result: (maybe-stack-aggregation-commit current-cycle)})
    error (err error)))

;; Tries to lock delegated stx (delegate-stack-stx).
;; If user already stacked then extend and increase
(define-private (lock-delegated-stx (user principal))
  (let ((start-burn-ht (+ burn-block-height u1))
        (pox-address (var-get pool-pox-address))
        (buffer-amount (var-get stx-buffer))
        (user-account (stx-account user))
        (allowed-amount (min (get-delegated-amount user)
                             (+ (get locked user-account) (get unlocked user-account))))
        ;; Amount to lock must be leq allowed-amount and geq locked amount.
        ;; Increase the locked amount if possible, but leave a buffer for revoke tx fees if possible.
        ;; Decreasing the locked amount requires a cool down cycle.
        (amount-ustx (if (> allowed-amount buffer-amount)
                            (max (get locked user-account) (- allowed-amount buffer-amount))
                            allowed-amount)))
    (asserts! (var-get active) err-pox-address-deactivated)
    (match (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stack-stx
             user amount-ustx
             pox-address start-burn-ht u1)
      stacker-details  (begin
                          (map-set locked-amounts user {amount-ustx: amount-ustx, unlock-height: (get unlock-burn-height stacker-details)})
                          (ok stacker-details))
      error (if (is-eq error 3) ;; check whether user is already stacked
              (delegate-stack-extend-increase user amount-ustx pox-address)
              (err (* u1000 (to-uint error)))))))

(define-private (lock-delegated-stx-fold (user principal) (result (list 30 (response {lock-amount: uint, stacker: principal, unlock-burn-height: uint} uint))))
  (let ((stack-result (lock-delegated-stx user)))
    (unwrap-panic (as-max-len? (append result stack-result) u30))))

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
                  ;; update locked-amounts map if necessary
                  (asserts! (> unlock-burn-height (get unlock-height status)) err-already-stacking)
                  (map-extend-locked-amount user unlock-burn-height)
                  (ok {lock-amount: locked-amount,
                      stacker: user,
                      unlock-burn-height: unlock-burn-height}))
                ;; else increase
                (let ((increase-by (- amount-ustx locked-amount)))
                  (match (contract-call? 'SP000000000000000000002Q6VF78.pox-3 delegate-stack-increase
                          user pox-address increase-by)
                    success-increase (begin
                                      (map-extend-increase-locked-amount user increase-by unlock-burn-height)
                                      (ok {lock-amount: (get total-locked success-increase),
                                          stacker: user,
                                          unlock-burn-height: unlock-burn-height}))
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

;; Tries to calls stack aggregation commit. If the minimum is met,
;; subsequent calls increase the total amount using
;; the index of the first successful call.
;; This index gives access to the internal map of the pox-3 contract
;; that handles the reward addresses.
(define-private (maybe-stack-aggregation-commit (current-cycle uint))
  (let ((reward-cycle (+ u1 current-cycle)))
    (match (map-get? pox-addr-indices reward-cycle)
            ;; Total stacked already reached minimum.
            ;; Call stack-aggregate-increase.
            ;; It might fail because called in the same cycle twice.
      index (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-3 stack-aggregation-increase (var-get pool-pox-address) reward-cycle index))
              success (map-set last-aggregation reward-cycle block-height)
              error (begin (print {err-increase-ignored: error}) false))
            ;; Total stacked is still below minimum.
            ;; Just try to commit, it might fail because minimum not yet met
      (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-3 stack-aggregation-commit-indexed (var-get pool-pox-address) reward-cycle))
        index (begin
                (map-set pox-addr-indices reward-cycle index)
                (map-set last-aggregation reward-cycle block-height))
        error (begin (print {err-commit-ignored: error}) false))))) ;; ignore errors

(define-private (map-extend-locked-amount (user principal) (unlock-height uint))
  (match (map-get? locked-amounts user)
    locked-amount (map-set locked-amounts user (merge locked-amount {unlock-height: unlock-height}))
    true))

(define-private (map-extend-increase-locked-amount (user principal) (increase-by uint) (unlock-height uint))
  (match (map-get? locked-amounts user)
    locked-amount (map-set locked-amounts user {amount-ustx: (+ (get amount-ustx locked-amount) increase-by), unlock-height: unlock-height})
    true))

;;
;; Public functions
;;

;; @desc User calls this function to delegate and lock their tokens to the self-service pool.
;; Users can revoke delegation and stx tokens will unlock at the end of the locking period.
;;
;; @param amount-ustx; amount to delegate. Can be higher than current stx balance.
(define-public (delegate-stx (amount-ustx uint))
  (let ((user tx-sender)
        (current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle)))
    ;; Must be called directly by the tx-sender or by an allowed contract-caller
    (asserts! (check-caller-allowed) err-stacking-permission-denied)
    ;; Do 1. and 2.
    (try! (delegate-stx-inner amount-ustx (as-contract tx-sender) none))
    ;; Do 3. and 4.
    (lock-and-commit user current-cycle)))

;; Stacks the delegated amount for the given user for the next cycle.
;; This function can be called by automation, friends or family for user that have delegated once.
;; This function can be called only after the current cycle is half through
(define-public (delegate-stack-stx (user principal))
  (let ((current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle)))
    (asserts! (can-lock-now current-cycle) err-too-early)
    ;; Do 3.
    (try! (as-contract (lock-delegated-stx user)))
    ;; Do 4.
    (ok (maybe-stack-aggregation-commit current-cycle))))

;; Stacks the delegated amount for the given users for the next cycle.
;; This function can be called by automation, friends or family for users that have delegated once.
;; This function can be called only after the current cycle is half through
(define-public (delegate-stack-stx-many (users (list 30 principal)))
  (let ((current-cycle (contract-call? 'SP000000000000000000002Q6VF78.pox-3 current-pox-reward-cycle))
        (start-burn-ht (+ burn-block-height u1)))
    (asserts! (can-lock-now current-cycle) err-too-early)
    ;; Do 3. for users
    (let ((locking-result
            (as-contract (fold lock-delegated-stx-fold users (list)))))
      ;; Do 4.
      (ok {locking-result: locking-result,
        commit-result: (maybe-stack-aggregation-commit current-cycle)}))))

;;
;; Admin functions
;;

(define-public (set-active (is-active bool))
  (begin
    (asserts! (default-to false (map-get? reward-admins contract-caller)) err-unauthorized)
    (ok (var-set active is-active))))

(define-public (set-pool-pox-address (pox-addr {hashbytes: (buff 32), version: (buff 1)}))
  (begin
    (asserts! (default-to false (map-get? reward-admins contract-caller)) err-unauthorized)
    (ok (var-set pool-pox-address pox-addr))))

(define-public (set-stx-buffer (amount-ustx uint))
  (begin
    (asserts! (default-to false (map-get? reward-admins contract-caller)) err-unauthorized)
    (ok (var-set stx-buffer amount-ustx))))

(define-public (set-reward-admin (new-admin principal) (enable bool))
  (begin
    (asserts! (default-to false (map-get? reward-admins contract-caller)) err-unauthorized)
    (asserts! (not (is-eq contract-caller new-admin)) err-forbidden)
    (ok (map-set reward-admins new-admin enable))))

;;
;; Read-only functions
;;

;; Total of locked stacked by cycle.
;; Function get-reward-set-pox-address contains the information but
;; is deleted when stx unlock.
;; Therefore, we look at the value at the end of that cycle, more
;; precisely at the last stack-aggregation-* call for the next cycle (that happens
;; during the request cycle).
(define-read-only (get-reward-set (reward-cycle uint))
  (match (print (map-get? last-aggregation (+ reward-cycle u1)))
    stacks-height (get-reward-set-at-block reward-cycle stacks-height)
    none))

(define-read-only (get-reward-set-at-block (reward-cycle uint) (stacks-height uint))
  (at-block (unwrap! (get-block-info? id-header-hash stacks-height) none)
    (match (print (map-get? pox-addr-indices reward-cycle))
      index (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-reward-set-pox-address reward-cycle index)
      none)))

;; Returns currently delegated amount for a given user
(define-read-only (get-delegated-amount (user principal))
  (default-to u0 (get amount-ustx (contract-call? 'SP000000000000000000002Q6VF78.pox-3 get-delegation-info user))))

(define-read-only (get-pox-addr-index (cycle uint))
  (map-get? pox-addr-indices cycle))

(define-read-only (not-locked-for-cycle (unlock-burn-height uint) (cycle uint))
  (<= unlock-burn-height (contract-call? 'SP000000000000000000002Q6VF78.pox-3 reward-cycle-to-burn-height cycle)))

(define-read-only (get-last-aggregation (cycle uint))
  (map-get? last-aggregation cycle))

(define-read-only (is-admin-enabled (admin principal))
  (map-get? reward-admins admin))

(define-read-only (get-pool-pox-address)
  (var-get pool-pox-address))

(define-read-only (can-lock-now (cycle uint))
  (> burn-block-height (+ (contract-call? 'SP000000000000000000002Q6VF78.pox-3 reward-cycle-to-burn-height cycle) half-cycle-length)))

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
