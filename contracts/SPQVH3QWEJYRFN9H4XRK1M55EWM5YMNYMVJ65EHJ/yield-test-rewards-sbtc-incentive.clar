(define-constant ERR_ACTIVATION_HEIGHT_NOT_MET (err u100))
(define-constant ERR_ALREADY_ENROLLED (err u101))
(define-constant ERR_USER_BLACKLISTED (err u102))
(define-constant ERR_NOT_ENROLLED (err u103))
(define-constant ERR_NOT_ADMIN (err u104))
;; This should never be thrown
(define-constant ERR_CYCLE_ENDED_2 (err u107))
(define-constant ERR_NOT_REWARDED_ALL (err u108))
(define-constant ERR_NOT_SNAPSHOTTED_ALL_PARTICIPANTS (err u109))
(define-constant ERR_CYCLE_ENDED (err u110))
(define-constant ERR_NOT_ALL_SNAPSHOTS (err u111))
(define-constant ERR_CANNOT_DISTRIBUTE_REWARDS (err u112))
(define-constant ERR_ALREADY_REWARDED (err u113))
(define-constant ERR_STX_BLOCK_TOO_LOW (err u114))
(define-constant ERR_STX_BLOCK_TOO_HIGH (err u115))
(define-constant ERR_NOT_NEW_CYCLE_YET (err u116))
(define-constant ERR_CONTRACT_ALREADY_ACTIVE (err u117))
(define-constant ERR_CONTRACT_NOT_ACTIVE (err u118))
(define-constant ERR_NOT_NEW_SNAPSHOT_YET (err u119))
(define-constant ERR_STX_BLOCK_IN_FUTURE (err u120))
(define-constant ERR_SNAPSHOTS_NOT_CONCLUDED (err u121))
(define-constant ERR_SNAPSHOTS_ALREADY_CONCLUDED (err u122))
(define-constant ERR_SET_CAN_DISTRIBUTE_ALREADY_CALLED (err u123))
(define-constant ERR_ALREADY_FINALIZED (err u124))
(define-constant ERR_REWARDS_NOT_SENT_YET (err u125))
(define-constant ERR_CANNOT_FINALIZE (err u126))
(define-constant ERR_ENROLL_MINIMUM_HOLD_NOT_MET (err u127))
(define-constant ERR_NO_SBTC_BALANCE (err u128))
(define-constant ERR_APR_TOO_HIGH (err u998))
(define-constant ERR_APR_TOO_LOW (err u999))

(define-constant our-sbtc-address 'SPQVH3QWEJYRFN9H4XRK1M55EWM5YMNYMVJ65EHJ)


(define-constant first_snapshot_new_cycle u1000)
(define-constant average-burn-blocks-year u52560)
(define-constant APR_DECIMALS u100000000)
(define-constant MIN_APR_ONE_EIGHT u1000000) ;; 1% APR - 0,01 * 10^8
(define-constant MAX_APR_ONE_EIGHT u6000000) ;; 6% APR - 0,1 * 10^8

;; Modularize the variables for different networks

(define-data-var is-contract-active bool false)
(define-data-var cycle-id uint u0)

(define-data-var current-cycle-stacks-block-height uint u0)
(define-data-var current-snapshot-tenure-height uint u0)
(define-data-var current-snapshot-stacks-block-height uint u0)
(define-data-var concluded-snapshots bool false)

;; For Testnet
(define-data-var current-cycle-tenure-height uint u0)
(define-data-var nr-blocks-snapshot uint u0)
(define-data-var nr-snapshots-cycle uint u0) ;; last snapshot is: next-cycle-bitcoin-block - nr-blocks-snapshot

(if is-in-mainnet 
  (begin 
    (var-set current-cycle-tenure-height u181638) 
    (var-set nr-snapshots-cycle u3)
    (var-set nr-blocks-snapshot u40)
  )
  ;; simnet and testnet use the same chain-id
  (begin 
    (var-set current-cycle-tenure-height u40) 
    (var-set nr-snapshots-cycle u14)
    (var-set nr-blocks-snapshot u150)
  )
)

(define-data-var next-nr-blocks-snapshot uint (var-get nr-blocks-snapshot))
(define-data-var next-nr-snapshots-cycle uint (var-get nr-snapshots-cycle)) 

(define-data-var rewarded-count uint u0)
(define-data-var participants-count uint u0)
(define-data-var min-hold-for-enrollment uint u0)

;; Number of participants enrolled at the beginning of the current cycle
(define-data-var current-cycle-participants-count uint u0)

(define-data-var current-cycle-total uint u0)

(define-data-var local-stx-id-header-hash (buff 32) 0x0000000000000000000000000000000000000000000000000000000000000000)

(define-data-var current-snapshot-total uint u0)
(define-data-var current-snapshot-count uint u0)
(define-data-var current-snapshot-index uint u0)

(define-data-var next-cycle-tenure-height uint (+ (var-get current-cycle-tenure-height) (* (var-get nr-blocks-snapshot) (var-get nr-snapshots-cycle))))
(define-data-var can-distribute-rewards bool false)
;; yield of the smart contract -> total rewards for this cycle
;; if rewards_cycle/total_sbtc_cycle % > max-rate %
;; rewards_cycle = max-rate% * total_sbtc_cycle, the remaining will be used for future cycles
(define-data-var rewards-to-distribute uint u0)

(define-data-var admin principal contract-caller)
;; APR - annual percentage rate scaled by 10^8. This represents the maximum
;; percentage of the sBTC yield contributors are ready to give away as rewards
;; in a year.
(define-data-var APR uint u6000000)
(define-data-var next-APR uint u6000000)

;; data maps
;;
;; when someone enrolls, gets added to the map
;; when someone leaves, gets removed from the map
;; verify at get-burn-block-info state of map when doing calculations
(define-map participants 
  { address: principal } 
  { 
    rewarded-address: principal, ;; default contract-caller if not set
  }
)

(define-map blacklist 
  { address: principal } 
  { 
    blacklisted: bool, ;; default true
  }
)
;; (map-set blacklist {address: ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP} {blacklisted: true}) ;; wallet 8
;; the Foundation and other sBTC holders, will not be taken into account by default as they haven't enrolled in the SC (and they should not enroll)

(define-map participant-holding { cycle-id: uint, address: principal } { amount: uint, last-snapshot: uint, rewarded: bool, reward-amount: uint })
(define-map rewards-holding { cycle-id: uint, rewarded-address: principal } { amount: uint })

(define-map cycle-snapshot-to-stx-block-height
  { cycle-id: uint, snapshot-id: uint }
  { stx-block-height: uint, tenure-height-stored: uint }
)

(define-map distribution-finalized-stx-block-height-when-called { cycle-id: uint } { stx-block-height: uint })

(define-public (update-initialize-block (new-tenure-height uint))
  (begin 
    (asserts! (not (var-get is-contract-active)) ERR_CONTRACT_ALREADY_ACTIVE)
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (var-set current-cycle-tenure-height new-tenure-height)) 
  )
)

(define-public (compute-current-snapshot-balances (principals (list 900 principal)))
  (let
    ((stx-id-header-hash (unwrap! (get-stacks-block-info? id-header-hash (var-get current-snapshot-stacks-block-height)) ERR_STX_BLOCK_IN_FUTURE)))
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (var-set local-stx-id-header-hash stx-id-header-hash)
    (let ((snapshot-total (fold compute-and-update-balances-one-user principals u0)))  
      (var-set current-snapshot-total (+ (var-get current-snapshot-total) snapshot-total))
      (ok snapshot-total)
    )
  )
)

(define-private (compute-and-update-balances-one-user (address principal) (current-total uint))
  (let
    (
      (cycle-id-current (var-get cycle-id))
      (is-user-enrolled-this-cycle (is-enrolled-this-cycle address))
      (balance (at-block
        ;; nonexistent balance on that block height - should never happen
        (var-get local-stx-id-header-hash)
        (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance-available address))))
      (new-total (+ current-total balance))
      (participant-hold (map-get? participant-holding { cycle-id: cycle-id-current, address: address }))
      (local-current-snapshot-index (var-get current-snapshot-index))
    )
    ;; only add those that are part of the pool and aren't already snapshotted
    (if 
      (or 
        (not is-user-enrolled-this-cycle) 
        (and is-user-enrolled-this-cycle (is-eq (default-to first_snapshot_new_cycle (get last-snapshot participant-hold)) local-current-snapshot-index))
      )
      ;; don't count him
      current-total
      ;; count him
      (begin 
        (var-set current-snapshot-count (+ (var-get current-snapshot-count) u1))
        (map-set participant-holding 
          { cycle-id: cycle-id-current, address: address }
          { 
            amount: (+ balance  (default-to u0 (get amount participant-hold))),
            last-snapshot: local-current-snapshot-index,
            rewarded: false,
            reward-amount: u0
          }
        )
        (print 
          {
            cycle-id: cycle-id-current,
            snapshot-index: local-current-snapshot-index,
            balance: balance,
            enrolled-address: address,
            function-name: "compute-current-snapshot-balance"
          }
        )
        new-total
      )
    )
  )
)

(define-private (reset-state-for-cycle (stx-block-height uint)) 
  (begin 
    (var-set nr-blocks-snapshot (var-get next-nr-blocks-snapshot))
    (var-set nr-snapshots-cycle (var-get next-nr-snapshots-cycle))
    (var-set APR (var-get next-APR))
    (var-set can-distribute-rewards false)
    (var-set current-cycle-stacks-block-height stx-block-height)
    (var-set current-cycle-total u0)
    (var-set current-snapshot-total u0)
    (var-set rewarded-count u0) 
    (var-set concluded-snapshots false)
    (var-set current-cycle-participants-count 
      (at-block (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height)) (var-get participants-count)))
  )
)

;; contract initialization
(define-public (initialize-contract (stx-block-height uint))
  (begin 
    (asserts! (>= tenure-height (var-get current-cycle-tenure-height)) ERR_ACTIVATION_HEIGHT_NOT_MET)
    (asserts! (not (var-get is-contract-active)) ERR_CONTRACT_ALREADY_ACTIVE)
    (asserts! (> (var-get current-cycle-tenure-height) (block-height-to-tenure-height (- stx-block-height u1))) ERR_STX_BLOCK_TOO_HIGH)
    (asserts! (is-eq (var-get current-cycle-tenure-height) (block-height-to-tenure-height stx-block-height)) ERR_STX_BLOCK_TOO_LOW)
    
    (reset-state-for-cycle stx-block-height)
    (update-snapshot-for-new-cycle stx-block-height)
    (map-set cycle-snapshot-to-stx-block-height 
      {cycle-id: (var-get cycle-id), snapshot-id: (var-get current-snapshot-index)}
      {stx-block-height: stx-block-height, tenure-height-stored: (var-get current-cycle-tenure-height)}
    )
    (ok (var-set is-contract-active true))
  )
)

;; enroll-for-rewards
(define-public (enroll (rewarded-address (optional principal)))
  (let ((rewards-recipient (default-to contract-caller rewarded-address)))
    (asserts! (is-none (map-get? participants {address: contract-caller})) ERR_ALREADY_ENROLLED)
    (asserts! (is-none (map-get? blacklist {address: contract-caller})) ERR_USER_BLACKLISTED)
    (asserts! (>= (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance-available contract-caller)) (var-get min-hold-for-enrollment)) ERR_ENROLL_MINIMUM_HOLD_NOT_MET)
    (var-set participants-count (+ (var-get participants-count) u1))
    (print
      {
        tenure-height: tenure-height,
        reward-address: rewards-recipient,
        enrolled-address: contract-caller,
        function-name: "enroll"
      }
    )
    (ok 
      (map-set participants 
        {address: contract-caller} 
        {rewarded-address: rewards-recipient}
      )
    )
  )
)

(define-public (enroll-defi (defi-contract principal) (rewarded-address (optional principal)))
  (let ((rewards-recipient (default-to defi-contract rewarded-address)))
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (is-none (map-get? participants {address: defi-contract})) ERR_ALREADY_ENROLLED)
    (asserts! (is-none (map-get? blacklist {address: defi-contract})) ERR_USER_BLACKLISTED)
    (var-set participants-count (+ (var-get participants-count) u1))
    (print
      {
        tenure-height: tenure-height,
        reward-address: rewards-recipient,
        enrolled-address: defi-contract,
        function-name: "enroll"
      }
    )
    (ok 
      (map-set participants 
        {address: defi-contract} 
        {rewarded-address: rewards-recipient}
      )
    )
  )
)

(define-public (enroll-defi-batch (defi-contracts (list 900 {defi-contract: principal, rewarded-address: (optional principal)})))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (map enroll-defi-one defi-contracts))
  )
)

(define-private (enroll-defi-one (entry {defi-contract: principal, rewarded-address: (optional principal)}))
  (let 
    (
      (defi-contract (get defi-contract entry))
      (rewarded-address (get rewarded-address entry))
    )
    (try! (enroll-defi defi-contract rewarded-address))
    (ok true)
  )
)

(define-public (change-reward-address (new-address principal)) 
  (let ((participant (map-get? participants {address: contract-caller})))
    (asserts! (is-some participant) ERR_NOT_ENROLLED)
    (ok 
      (map-set participants 
        {address: contract-caller} 
        (merge (unwrap-panic participant) {rewarded-address: new-address})
      )
    )
  )
)

(define-public (change-reward-address-defi (defi-contract principal) (new-reward-address principal)) 
  (let ((participant (map-get? participants {address: defi-contract})))
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (is-some participant) ERR_NOT_ENROLLED)
    (ok (map-set participants 
      {address: defi-contract} 
      (merge (unwrap-panic participant) {rewarded-address: new-reward-address})
    ))
  )
)

(define-private (remove-participant (address principal))
  (begin 
    (print
      {
        tenure-height: tenure-height,
        enrolled-address: address,
        function-name: "opt-out"
      }
    )
    (map-delete participants {address: address})
    (var-set participants-count (- (var-get participants-count) u1))
  )
)

(define-public (opt-out) 
  (begin 
    (asserts! (is-some (map-get? participants {address: contract-caller})) ERR_NOT_ENROLLED)
    (ok (remove-participant contract-caller))
  )
)

(define-public (opt-out-defi (defi-contract principal))
  (begin 
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (is-some (map-get? participants {address: defi-contract})) ERR_NOT_ENROLLED)
    (ok (remove-participant defi-contract))
  )
)

(define-public (add-blacklisted (address principal))
  (begin 
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (if (is-some (map-get? participants {address: address}))
      (begin 
        (remove-participant address)
        (ok (map-set blacklist {address: address} {blacklisted: true}))
      )
      (ok (map-set blacklist {address: address} {blacklisted: true}))
    )
  )
)

(define-public (add-blacklisted-batch (addresses (list 200 principal)))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (ok (map add-blacklisted addresses))
  )
)

(define-public (remove-blacklisted (address principal))
  (begin 
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (ok (map-delete blacklist {address: address}))
  )
)

(define-public (update-admin (new-admin-address principal)) 
  (begin 
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (var-set admin new-admin-address))
  )
)

(define-public (update-min-hold-for-enrollment (new-min-hold uint))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (ok (var-set min-hold-for-enrollment new-min-hold))
  )
)

;; update cycle/snapshot rules - admin functions

;; Update the number of blocks per snapshot. The new value will be picked up
;; in the next cycle, after the head-to-next-cycle function is called.
(define-public (update-snapshot-length (updated-nr-blocks-snapshot uint))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (ok (var-set next-nr-blocks-snapshot updated-nr-blocks-snapshot))
  )
)

;; Update the number of snapshots per cycle. The new value will be picked up
;; in the next cycle, after the head-to-next-cycle function is called.
(define-public (update-nr-snapshots-cycle (updated-nr-snapshots-cycle uint))
  (begin 
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (ok (var-set next-nr-snapshots-cycle updated-nr-snapshots-cycle))
  )
)

;; Update the number of snapshots per cycle and the number of blocks per snapshot. 
;; The new value will be picked up in the next cycle, after the 
;; head-to-next-cycle function is called.
(define-public (update-cycle-data (updated-nr-snapshots-cycle uint) (updated-nr-blocks-snapshot uint))
  (begin
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (var-set next-nr-snapshots-cycle updated-nr-snapshots-cycle)
    (ok (var-set next-nr-blocks-snapshot updated-nr-blocks-snapshot))
  )
)

(define-public (update-APR (new-apr-one-eight uint))
  (begin 
    (asserts! (is-eq (var-get admin) contract-caller) ERR_NOT_ADMIN)
    (asserts! (>= new-apr-one-eight MIN_APR_ONE_EIGHT) ERR_APR_TOO_LOW)
    (asserts! (<= new-apr-one-eight MAX_APR_ONE_EIGHT) ERR_APR_TOO_HIGH)
    (ok (var-set next-APR new-apr-one-eight))
  )
)


(define-read-only (check-new-cycle-valid-stacks-block-height (stx-block-height uint)) 
  (begin
    (asserts! (> (var-get current-cycle-tenure-height) (block-height-to-tenure-height (- stx-block-height u1))) ERR_STX_BLOCK_TOO_HIGH)
    (ok (asserts! (is-eq (var-get current-cycle-tenure-height) (block-height-to-tenure-height stx-block-height)) ERR_STX_BLOCK_TOO_LOW))
  )
)

(define-read-only (check-new-snapshot-valid-stacks-block-height (stx-block-height uint)) 
  (begin
    (asserts! (> (var-get current-snapshot-tenure-height) (block-height-to-tenure-height (- stx-block-height u1))) ERR_STX_BLOCK_TOO_HIGH)
    (ok (asserts! (is-eq (var-get current-snapshot-tenure-height) (block-height-to-tenure-height stx-block-height)) ERR_STX_BLOCK_TOO_LOW))
  )
)

(define-public (head-to-next-snapshot (new-stx-block-height uint))
  (let ((next-snapshot-tenure-height (+ (var-get current-snapshot-tenure-height) (var-get nr-blocks-snapshot))))
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts! (>= tenure-height next-snapshot-tenure-height) ERR_NOT_NEW_SNAPSHOT_YET)
    (asserts! (is-eq (var-get current-snapshot-count) (var-get current-cycle-participants-count)) ERR_NOT_SNAPSHOTTED_ALL_PARTICIPANTS)
    (asserts! (not (is-eq (var-get nr-snapshots-cycle) (+ (var-get current-snapshot-index) u1))) ERR_CYCLE_ENDED)
    (asserts! (< next-snapshot-tenure-height (var-get next-cycle-tenure-height)) ERR_CYCLE_ENDED_2)
    (asserts! (> next-snapshot-tenure-height (block-height-to-tenure-height (- new-stx-block-height u1))) ERR_STX_BLOCK_TOO_HIGH)
    (asserts! (is-eq next-snapshot-tenure-height (block-height-to-tenure-height new-stx-block-height)) ERR_STX_BLOCK_TOO_LOW)

    (var-set current-snapshot-tenure-height next-snapshot-tenure-height)
    (var-set current-cycle-total (+ (var-get current-cycle-total) (var-get current-snapshot-total)))
    (var-set current-snapshot-total u0)
    (var-set current-snapshot-count u0)
    (var-set current-snapshot-index (+ (var-get current-snapshot-index) u1))
    (map-set cycle-snapshot-to-stx-block-height 
      { cycle-id: (var-get cycle-id), snapshot-id: (var-get current-snapshot-index)}
      { stx-block-height: new-stx-block-height, tenure-height-stored: next-snapshot-tenure-height }
    )
    (ok (var-set current-snapshot-stacks-block-height new-stx-block-height))
  )
)

(define-private (update-snapshot-for-new-cycle (stx-block-height uint))
  (begin
    (var-set current-snapshot-tenure-height (var-get current-cycle-tenure-height))
    (var-set current-snapshot-count u0)
    (var-set current-snapshot-index u0)
    (var-set current-snapshot-stacks-block-height stx-block-height)
  )
)

(define-public (finalize-reward-distribution) 
  (begin
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts! (is-eq (var-get current-cycle-participants-count) (var-get rewarded-count)) ERR_NOT_REWARDED_ALL)
    (asserts! (var-get can-distribute-rewards) ERR_CANNOT_FINALIZE)
    (asserts! (is-none (map-get? distribution-finalized-stx-block-height-when-called {cycle-id: (var-get cycle-id)})) ERR_ALREADY_FINALIZED)

    ;; Used by DeFi apps to call their rewards distribution afterward it is finalized here
    (ok (map-set distribution-finalized-stx-block-height-when-called {cycle-id: (var-get cycle-id)} {stx-block-height: stacks-block-height}))
  )
)

(define-public (head-to-next-cycle (stx-block-height uint)) 
  (begin
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts! (>= tenure-height (var-get next-cycle-tenure-height)) ERR_NOT_NEW_CYCLE_YET)
    (asserts! (is-eq (var-get current-cycle-participants-count) (var-get rewarded-count)) ERR_NOT_REWARDED_ALL) 
    (asserts! (is-some (map-get? distribution-finalized-stx-block-height-when-called {cycle-id: (var-get cycle-id)})) ERR_REWARDS_NOT_SENT_YET)
    (asserts! (> (var-get next-cycle-tenure-height) (block-height-to-tenure-height (- stx-block-height u1))) ERR_STX_BLOCK_TOO_HIGH)
    (asserts! (is-eq (var-get next-cycle-tenure-height) (block-height-to-tenure-height stx-block-height)) ERR_STX_BLOCK_TOO_LOW)
  
    (var-set current-cycle-tenure-height 
      (+ (var-get current-cycle-tenure-height) 
        (* (var-get nr-blocks-snapshot) (var-get nr-snapshots-cycle))))
    (reset-state-for-cycle stx-block-height)
    (var-set next-cycle-tenure-height 
      (+ (var-get current-cycle-tenure-height) 
        (* (var-get nr-blocks-snapshot) (var-get nr-snapshots-cycle))))
    (var-set cycle-id (+ (var-get cycle-id) u1))
    (update-snapshot-for-new-cycle stx-block-height)

    (ok 
      (map-set cycle-snapshot-to-stx-block-height 
        { cycle-id: (var-get cycle-id), snapshot-id: (var-get current-snapshot-index)}
        { stx-block-height: stx-block-height, tenure-height-stored: (var-get current-cycle-tenure-height) }
      )
    )
  )
)

(define-public (distribute-rewards (principals (list 900 principal))) 
  (let 
    ((stx-id-header-hash (unwrap! (get-stacks-block-info? id-header-hash (var-get current-cycle-stacks-block-height)) ERR_STX_BLOCK_IN_FUTURE)))
    (var-set local-stx-id-header-hash stx-id-header-hash)
    (asserts! (var-get can-distribute-rewards) ERR_CANNOT_DISTRIBUTE_REWARDS)
    (if 
      (is-eq (var-get current-cycle-total) u0)
        (begin 
          (var-set rewarded-count (var-get current-cycle-participants-count))
          (ok (list ))
        )
        (ok (map distribute-reward-user principals))
    )
  )
)

(define-private (distribute-reward-user (user principal)) 
  (let 
    (
      (cycle-id-current (var-get cycle-id))
      (holding-state (unwrap! (map-get? participant-holding {address: user, cycle-id: cycle-id-current}) ERR_NOT_ENROLLED))
      (already-rewarded-amount (default-to u0 (get amount (map-get? rewards-holding {rewarded-address: user, cycle-id: cycle-id-current}))))
      (participant-state (unwrap! (at-block (var-get local-stx-id-header-hash) (map-get? participants {address: user})) ERR_NOT_ENROLLED))
      (rewarded-address (get rewarded-address participant-state))
      (reward-amount 
        (/
          (* 
            (get amount holding-state) 
            (var-get rewards-to-distribute)
          ) 
          (* 
            (var-get current-cycle-total)
            APR_DECIMALS
          )
        )
      )
    )
    (if (get rewarded holding-state)
      ERR_ALREADY_REWARDED
      (begin
        (var-set rewarded-count (+ (var-get rewarded-count) u1))
        (map-set participant-holding 
          {address: user, cycle-id: cycle-id-current} 
          (merge holding-state {rewarded: true, reward-amount: reward-amount})
        )
        (map-set rewards-holding {rewarded-address: rewarded-address, cycle-id: cycle-id-current} 
          {amount: (+ already-rewarded-amount reward-amount)}
        )
        (if (> reward-amount u0) 
          (try! (as-contract (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token transfer 
            reward-amount
            tx-sender rewarded-address none)))
          false
        )
        (print
          {
            cycle-id: cycle-id-current,
            enrolled-address: user,
            reward-address: rewarded-address,
            amount: reward-amount,
            function-name: "distribute-rewards"
          }
        )
        (ok true)
      )
    )
  )
)

(define-public (conclude-cycle-snapshots) 
  (begin 
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts! (not (var-get concluded-snapshots)) ERR_SNAPSHOTS_ALREADY_CONCLUDED)
    (asserts! (is-eq (+ (var-get current-snapshot-index) u1) (var-get nr-snapshots-cycle)) ERR_NOT_ALL_SNAPSHOTS)
    (asserts! (is-eq (var-get current-snapshot-count) (var-get current-cycle-participants-count)) ERR_NOT_SNAPSHOTTED_ALL_PARTICIPANTS)
    ;; add in the calculation the total amount from the last snapshot
    (var-set current-cycle-total (+ (var-get current-cycle-total) (var-get current-snapshot-total)))
    (print
      {
        cycle-id: (var-get cycle-id),
        current-cycle-total: (var-get current-cycle-total),
        function-name: "conclude-cycle-snapshots"
      }
    )
    (ok (var-set concluded-snapshots true))
  )
)

(define-public (set-can-distribute-rewards)
  (begin 
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts! (not (var-get can-distribute-rewards)) ERR_SET_CAN_DISTRIBUTE_ALREADY_CALLED)
    (asserts! (var-get concluded-snapshots) ERR_SNAPSHOTS_NOT_CONCLUDED)
    (let ((pool-rewards (at-block 
                  (unwrap-panic (get-stacks-block-info? id-header-hash (var-get current-snapshot-stacks-block-height))) 
                  (unwrap-panic (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance-available (as-contract contract-caller)))))
          ;; This is the real value
          (max-cap-rewards (/ (* (cycle-percentage-rate) (var-get current-cycle-total)) (var-get nr-snapshots-cycle))) 
          (local-rewards-to-distribute 
            (if 
              (< (* APR_DECIMALS pool-rewards) max-cap-rewards) 
              (* APR_DECIMALS pool-rewards)
              max-cap-rewards)))
      (var-set rewards-to-distribute local-rewards-to-distribute)
      (ok (var-set can-distribute-rewards true))
    )
  )
)

;; Number of cycles per year - average number of blocks in a year / number of
;; blocks in a cycle. When nr-blocks-snapshot or next-nr-snapshots-cycle are
;; updated, this value is recalculated.
(define-read-only (nr-cycles-year) 
  (/ average-burn-blocks-year (* (var-get nr-blocks-snapshot) (var-get nr-snapshots-cycle)))
)

;; Cycle percentage rate scaled by 10^8. This represents the maximum
;; percentage of the sBTC yield contributors are ready to give away as rewards
;; in a cycle.
;; CPR = APR / nr-cycles-per-year
;; When APR or nr-cycles-per-year are updated, this value is recalculated.
(define-read-only (cycle-percentage-rate) 
  (/ (var-get APR) (nr-cycles-year))
)

(define-read-only (block-height-to-tenure-height (stx-block-height uint)) 
  (at-block (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height)) tenure-height)
)

(define-read-only (is-enrolled-in-next-cycle (address principal)) 
  (is-some (map-get? participants {address: address}))
)

(define-read-only (is-enrolled-this-cycle (address principal)) 
  (is-some 
    (at-block 
      (unwrap-panic (get-stacks-block-info? id-header-hash (var-get current-cycle-stacks-block-height)))
      (map-get? participants {address: address}))
  )
)

(define-read-only (get-is-blacklisted (address principal)) 
  (is-some (map-get? blacklist {address: address}))
)

(define-read-only (get-is-blacklisted-list (addresses (list 900 principal)))
  (map is-blacklisted addresses)
)

(define-private (is-blacklisted (address principal))
  (is-some (map-get? blacklist {address: address}))
)

(define-read-only (cycle-data) 
  {
    cycle-id: (var-get cycle-id),
    current-cycle-tenure-height: (var-get current-cycle-tenure-height),
    next-cycle-tenure-height: (var-get next-cycle-tenure-height),
    current-cycle-stacks-block-height: (var-get current-cycle-stacks-block-height),
    participants-count: (var-get current-cycle-participants-count),
    nr-snapshots-cycle: (var-get nr-snapshots-cycle),
    nr-blocks-snapshot: (var-get nr-blocks-snapshot),
    current-snapshot-index: (var-get current-snapshot-index),
  }
)

(define-read-only (current-cycle-id)
  (var-get cycle-id)
)

(define-read-only (snapshot-data) 
  {
    current-snapshot-tenure-height: (var-get current-snapshot-tenure-height),
    current-snapshot-stacks-block-height: (var-get current-snapshot-stacks-block-height),
    current-snapshot-count: (var-get current-snapshot-count),
    current-snapshot-total: (var-get current-snapshot-total),
    current-snapshot-index: (var-get current-snapshot-index),
    nr-blocks-snapshot: (var-get nr-blocks-snapshot),
  }
)

(define-read-only (rewarded-data) 
  {
    rewarded-count: (var-get rewarded-count),
    can-distribute-rewards: (var-get can-distribute-rewards),
  }
)

(define-read-only (check-can-distribute-rewards) 
  (var-get can-distribute-rewards)
)

;; if SC not initialized, returns tenure block height for it
;; else returns the tenure block height for next snapshot/cycle
(define-read-only (tenure-height-for-next-state)
  (if (var-get is-contract-active) 
    (+ (var-get current-snapshot-tenure-height) (var-get nr-blocks-snapshot))
    (var-get current-cycle-tenure-height)
  )
)

(define-read-only (current-overview-data) 
  {
    cycle-id: (var-get cycle-id),
    snapshot-index: (var-get current-snapshot-index),
    nr-snapshots-cycle: (var-get nr-snapshots-cycle)
  }
)

(define-read-only (get-admin)
  (var-get admin))

(define-read-only (get-is-contract-active)
  (var-get is-contract-active))

(define-read-only (get-current-tenure-height) 
  tenure-height)

(define-read-only (get-latest-reward-address (address principal))
  (get rewarded-address (map-get? participants {address: address})))

(define-read-only (get-stacks-block-height-for-cycle-snapshot
    (checked-cycle-id uint)
    (checked-snapshot-id uint)
  )
  (get stx-block-height
    (map-get? cycle-snapshot-to-stx-block-height
      { 
        cycle-id: checked-cycle-id,
        snapshot-id: checked-snapshot-id
      }
    )
  )
)

(define-read-only (get-tenure-height-for-cycle-snapshot
    (checked-cycle-id uint)
    (checked-snapshot-id uint)
  )
  (get tenure-height-stored
    (map-get? cycle-snapshot-to-stx-block-height
      { 
        cycle-id: checked-cycle-id,
        snapshot-id: checked-snapshot-id
      }
    )
  )
)

(define-read-only (stx-block-height-distribution-finalized (wanted-cycle-id uint)) 
  (map-get? distribution-finalized-stx-block-height-when-called {cycle-id: wanted-cycle-id})
)

(define-read-only (reward-amount-for-cycle-and-address (wanted-cycle-id uint) (address principal)) 
  (get reward-amount (map-get? participant-holding {
    cycle-id: wanted-cycle-id,
    address: address
  }))
)

(define-read-only (reward-amount-for-cycle-and-reward-address (wanted-cycle-id uint) (reward-address principal)) 
  (get amount (map-get? rewards-holding {
    cycle-id: wanted-cycle-id,
    rewarded-address: reward-address
  }))
)

(define-read-only (get-cycle-current-state)
  {
    cycle-id: (var-get cycle-id),
    first-tenure: (var-get current-cycle-tenure-height),
    last-tenure: (- (var-get next-cycle-tenure-height) u1), 
  }
)

(define-read-only (get-min-hold-for-enrollment)
  (var-get min-hold-for-enrollment)
)

(define-public (extract-funds-safety)
  (let
    (
      (sbtc-amount (unwrap! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance-available (as-contract tx-sender)) ERR_NO_SBTC_BALANCE))
    )
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (try!
      (as-contract
        (contract-call?
          'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
          transfer
          sbtc-amount
          tx-sender
          our-sbtc-address
          none
        )
      )
    )
    (ok true)
  )
)
