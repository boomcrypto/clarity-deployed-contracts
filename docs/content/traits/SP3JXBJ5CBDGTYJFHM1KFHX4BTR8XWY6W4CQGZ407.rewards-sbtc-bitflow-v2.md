---
title: "Trait rewards-sbtc-bitflow-v2"
draft: true
---
```
(define-constant ERR_NOT_ADMIN (err u2104))
(define-constant ERR_NOT_REWARDED_ALL (err u2108))
(define-constant ERR_NOT_SNAPSHOTTED_ALL_PARTICIPANTS (err u2109))
(define-constant ERR_NOT_ALL_SNAPSHOTS (err u2111))
(define-constant ERR_CANNOT_DISTRIBUTE_REWARDS (err u2112))
(define-constant ERR_ALREADY_REWARDED (err u2113))
(define-constant ERR_CONTRACT_ALREADY_ACTIVE (err u2117))
(define-constant ERR_CONTRACT_NOT_ACTIVE (err u2118))
(define-constant ERR_STX_BLOCK_IN_FUTURE (err u2120))
(define-constant ERR_SNAPSHOTS_NOT_CONCLUDED (err u2121))
(define-constant ERR_SNAPSHOTS_ALREADY_CONCLUDED (err u2122))
(define-constant ERR_SET_CAN_DISTRIBUTE_ALREADY_CALLED (err u2123))
(define-constant ERR_ADD_PARTICIPANTS_COUNT (err u2130))
(define-constant ERR_STX_BLOCK_NOT_VALIDATED_IN_YIELD (err u2131))
(define-constant ERR_NOT_PARTICIPANT_THIS_CYCLE (err u2132))
(define-constant ERR_YIELD_REWARDS_NOT_SENT_YET (err u2133))
(define-constant ERR_ALREADY_SET_SNAPSHOT_PARTICIPANTS_COUNT (err u2134))
(define-constant ERR_SNAPSHOTTED_ALL_PARTICIPANTS (err u2135))
(define-constant ERR_NO_SBTC_BALANCE (err u2136))
(define-constant ERR_CYCLE_DATA_NOT_SAVED (err u2137))

;; This is a dummy snapshot index to be used when we don't have a snapshot
;; index. It is used to avoid counting the same participant twice in the same
;; cycle.
(define-constant DUMMY_SNAPSHOT_INDEX u1000)
(define-constant DUMMY_TENURE_NOT_REACHED u1000000)

(define-data-var admin principal tx-sender)
(define-data-var is-contract-active bool false)
(define-data-var nr-snapshots-cycle uint u0)
(define-data-var nr-blocks-snapshot uint u0)
(define-data-var can-distribute-rewards bool false)
(define-data-var rewards-to-distribute uint u0)
(define-data-var rewarded-count uint u0)
(define-data-var current-cycle-total uint u0)
(define-data-var current-snapshot-participants-count uint u0)
(define-data-var current-snapshot-index uint u0)
(define-data-var current-snapshot-total uint u0)
(define-data-var current-snapshot-stacks-block-height uint u0)
(define-data-var concluded-snapshots bool false)
;; This data var is used for tracking the number of participants that will be
;; rewarded in the current cycle. One participant tracked here was snapshot at
;; least once in the current cycle.
(define-data-var current-cycle-participants-count uint u0)
(define-data-var participants-count uint u0)
(define-data-var last-cycle-id uint u0)
(define-data-var local-stx-id-header-hash
  (buff 32)
  0x0000000000000000000000000000000000000000000000000000000000000000
)
;; The number of participants to snapshot in the current cycle. This will be
;; set by the admin just before the snapshot computation. It will be reset to
;; -1 on snapshot/cycle conclusion.
(define-data-var participants-to-snapshot int -1)

(define-map participant-holding
  { cycle-id: uint, address: principal }
  { amount: uint, last-snapshot: uint, rewarded: bool }
)

;; Contract Initialization.

;; The contract initialization function. This function should be called once to
;; initialize the contract. It will sync the contract with the Yield contract.
(define-public (initialize-contract)
  (let
    (
      (yield-cycle-id (yield-contract-cycle-id))
      (yield-snapshot-index (yield-contract-snapshot-index))
      ;; If Yield contract is not initialized this will throw
      ;; `ERR_STX_BLOCK_NOT_VALIDATED_IN_YIELD`.
      (current-snapshot-stx-block-height
        (unwrap!
          (get-stacks-block-height-for-cycle-snapshot
            yield-cycle-id
            yield-snapshot-index
          )
          ERR_STX_BLOCK_NOT_VALIDATED_IN_YIELD
        )
      )
    )
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (not (var-get is-contract-active)) ERR_CONTRACT_ALREADY_ACTIVE)

    (try! (reset-state-for-cycle yield-cycle-id))
    (update-snapshot-for-new-cycle current-snapshot-stx-block-height)

    ;; This way we sync the cycle id with the yield contract. It starts with
    ;; the current snapshot index, and it does not compute previous snapshots.
    (var-set last-cycle-id yield-cycle-id)
    (var-set current-snapshot-index yield-snapshot-index)
    (ok (var-set is-contract-active true))
  )
)

(define-public (reset-state-for-cycle (yield-cycle-id-wanted uint)) 
  (let 
    (
      (yield-data 
        (contract-call? 
          'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.yield-cycles-map 
          get-yield-cycle-data 
          yield-cycle-id-wanted
        )
      )
      (updated-nr-blocks-snapshot (unwrap! (get nr-blocks-snapshot yield-data) ERR_CYCLE_DATA_NOT_SAVED))
      (updated-nr-snapshots-cycle (unwrap! (get nr-snapshots-cycle yield-data) ERR_CYCLE_DATA_NOT_SAVED))
    )
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (var-set can-distribute-rewards false)
    (var-set current-cycle-total u0)
    (var-set current-snapshot-total u0)
    (var-set concluded-snapshots false)
    (var-set rewarded-count u0)
    ;; Participants can't enroll. 0 participants on initialization and on every
    ;; new cycle.
    (var-set current-cycle-participants-count u0)
    ;; If the Yield contract cycle rules change, sync the contract cycle rules
    ;; with the Yield contract.
    (var-set nr-snapshots-cycle updated-nr-snapshots-cycle)
    (ok (var-set nr-blocks-snapshot updated-nr-blocks-snapshot))
  )
)

(define-private (update-snapshot-for-new-cycle (stx-block-height uint))
  (begin
    (var-set current-snapshot-participants-count u0)
    (var-set current-snapshot-index u0)
    (var-set current-snapshot-stacks-block-height stx-block-height)
    (var-set participants-to-snapshot -1)
  )
)

;; Snapshot Balances Computation.

;; This function sets the number of participants to snapshot in the current
;; snapshot. If the participants count in the DeFi pool is 0, then the admin
;; has to explicitly set the participants count to 0 using this function. Then,
;; the contract can head to the next snapshot/cycle without computing the
;; balances.
(define-public (set-snapshot-participants-count (count uint))
  (begin 
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts!
      (is-eq -1 (var-get participants-to-snapshot))
      ERR_ALREADY_SET_SNAPSHOT_PARTICIPANTS_COUNT
    )

    (var-set local-stx-id-header-hash
      (unwrap!
        (get-stacks-block-info?
          id-header-hash
          (var-get current-snapshot-stacks-block-height)
        )
        ERR_STX_BLOCK_IN_FUTURE
      )
    )
    (ok (var-set participants-to-snapshot (to-int count)))
  )
)

;; This function will be called by the admin to compute all the participants'
;; balances for the current snapshot. This function should be called right
;; after the admin sets the participants count.
;; 
;; Do not call if the participants count was set to 0. You can head to the next
;; cycle/snapshot without computing the balances in this case.
(define-public (compute-current-snapshot-balances
    (principals (list 900 principal))
  )
  (begin
    (asserts!
      (> (var-get participants-to-snapshot) -1)
      ERR_ADD_PARTICIPANTS_COUNT
    )
    (asserts! (is-eq contract-caller (var-get admin)) ERR_NOT_ADMIN)
    ;; If all participants were already snapshotted in this cycle, we don't need
    ;; to compute the balances again.
    (asserts!
      (not
        (is-eq
          (var-get participants-to-snapshot)
          (to-int (var-get current-snapshot-participants-count))
        )
      )
      ERR_SNAPSHOTTED_ALL_PARTICIPANTS
    )
    (let
      (
        (snapshot-total
          (fold compute-and-update-balances-one-user principals u0)
        )
      )
      (var-set current-snapshot-total
        (+ (var-get current-snapshot-total) snapshot-total)
      )
      (ok snapshot-total)
    )
  )
)

(define-private (compute-and-update-balances-one-user
    (address principal)
    (current-total uint)
  )
  (let
    (
      (balance
        (unwrap-panic
          (at-block
            (var-get local-stx-id-header-hash)
            (get-user-total-sBTC-balance address)
          )
        )
      )
      (local-last-cycle-id (var-get last-cycle-id))
      (new-total (+ current-total balance))
      (participant-hold
        (map-get? participant-holding
          { cycle-id: local-last-cycle-id, address: address }
        )
      )
      (local-current-snapshot-index (var-get current-snapshot-index))
    )
    ;; Check if the participant was snapshotted in the current snapshot. If
    ;; last snapshot from participant-hold is the same as the current snapshot
    ;; index, then the participant was already snapshotted in this cycle.
    (if 
      (is-eq
        local-current-snapshot-index
        (default-to DUMMY_SNAPSHOT_INDEX (get last-snapshot participant-hold)))
      ;; The user was already snapshot in this cycle. We don't need to count
      ;; him again.
      current-total
      ;; The user was not snapshot in this cycle. We need to count him.
      (begin
        ;; Track number of unique participants for this snapshot.
        (var-set current-snapshot-participants-count
          (+ (var-get current-snapshot-participants-count) u1)
        )
        ;; Track number of unique participants for this cycle.
        (if
          (is-none participant-hold)
          (var-set current-cycle-participants-count
            (+ u1 (var-get current-cycle-participants-count))
          )
          false
        )
        (map-set participant-holding
          { cycle-id: local-last-cycle-id, address: address }
          { 
            amount: (+ balance (default-to u0 (get amount participant-hold))),
            last-snapshot: local-current-snapshot-index,
            rewarded: false
          }
        )
        (print 
          {
            cycle-id: local-last-cycle-id,
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

;; Heading to the Next Snapshot.

;; This function will be called at the end of each snapshot, apart from the
;; last snapshot of the cycle. If the last computed snapshot was the last one
;; of the cycle, call `conclude-cycle-snapshots` instead. Before calling this
;; function, the admin should have called `set-snapshot-participants-count`.
(define-public (head-to-next-snapshot)
  (let
    (
      ;; If in the last snapshot of the cycle, the following unwrap will throw 
      ;; `ERR_STX_BLOCK_NOT_VALIDATED_IN_YIELD`.
      (local-current-snapshot-index (var-get current-snapshot-index))
      (next-snapshot-stx-block-height
        (unwrap!
          (contract-call?
             'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3
            get-stacks-block-height-for-cycle-snapshot
            (var-get last-cycle-id)
            (+ u1 local-current-snapshot-index)
          )
          ERR_STX_BLOCK_NOT_VALIDATED_IN_YIELD
        )
      )
      (local-participants-to-snapshot (var-get participants-to-snapshot))
    )
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts!
      (> local-participants-to-snapshot -1)
      ERR_ADD_PARTICIPANTS_COUNT
    )
    (asserts!
      (is-eq
        (var-get current-snapshot-participants-count)
        (to-uint local-participants-to-snapshot)
      )
      ERR_NOT_SNAPSHOTTED_ALL_PARTICIPANTS
    )
    (var-set current-cycle-total
      (+ (var-get current-cycle-total) (var-get current-snapshot-total))
    )
    (var-set current-snapshot-total u0)
    (var-set current-snapshot-participants-count u0)
    (var-set participants-to-snapshot -1)
    (var-set current-snapshot-index (+ local-current-snapshot-index u1))
    (ok
      (var-set current-snapshot-stacks-block-height
        next-snapshot-stx-block-height
      )
    )
  )
)

;; This function will be called after the last snapshot of the cycle. It will
;; compute the total amount of the cycle and mark the snapshots as concluded.
(define-public (conclude-cycle-snapshots)
  (let
    (
      (local-participants-to-snapshot (var-get participants-to-snapshot))
    )
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts!
      (is-eq
        (+ u1 (var-get current-snapshot-index))
        (var-get nr-snapshots-cycle)
      )
      ERR_NOT_ALL_SNAPSHOTS
    )
    (asserts!
      (not (is-eq local-participants-to-snapshot -1))
      ERR_ADD_PARTICIPANTS_COUNT
    )
    (asserts!
      (is-eq
        (var-get current-snapshot-participants-count)
        (to-uint local-participants-to-snapshot)
      )
      ERR_NOT_SNAPSHOTTED_ALL_PARTICIPANTS
    )
    (asserts!
      (not (var-get concluded-snapshots))
      ERR_SNAPSHOTS_ALREADY_CONCLUDED
    )
    ;; Increase the total amount of the cycle with the last snapshot's total.
    (var-set current-cycle-total
      (+ (var-get current-cycle-total) (var-get current-snapshot-total))
    )
    (print
      {
        cycle-id: (var-get last-cycle-id),
        current-cycle-total: (var-get current-cycle-total),
        function-name: "conclude-cycle-snapshots"
      }
    )
    (ok (var-set concluded-snapshots true))
  )
)

;; Rewards Distribution.

;; This function will be called by the admin to start the rewards distribution
;; for the current cycle. It will enable the `distribute-rewards` function to
;; be called.
(define-public (set-can-distribute-rewards)
  (begin 
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts! 
      (not (var-get can-distribute-rewards)) 
      ERR_SET_CAN_DISTRIBUTE_ALREADY_CALLED
    )
    (asserts! (var-get concluded-snapshots) ERR_SNAPSHOTS_NOT_CONCLUDED)
    (asserts! 
      (can-call-set-can-distribute-rewards)
      ERR_YIELD_REWARDS_NOT_SENT_YET
    )
    (let
      (
        ;; Distribute the entire amount sent to the smart contract. The maximum
        ;; allowed reward amount is capped by the APR specified in the Yield
        ;; smart contract.
        ;; 
        ;; It uses reward-amount-for-cycle-and-reward-address because the same
        ;; DeFi app can have multiple contracts holding sBTC and all of them
        ;; should get the rewards to this smart contract
        (pool-rewards 
          (unwrap! 
            (contract-call?
               'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3
              reward-amount-for-cycle-and-reward-address
              (var-get last-cycle-id)
              (as-contract tx-sender)
            )
            ERR_YIELD_REWARDS_NOT_SENT_YET
          )
        )
      )
      (var-set rewards-to-distribute pool-rewards)
      (if 
        (is-eq pool-rewards u0)
        (var-set rewarded-count (var-get current-cycle-participants-count))
        false
      )

      (var-set can-distribute-rewards true)
      ;; Return amount to be distributed in this cycle.
      ;; If 0, no need to call `distribute-rewards`, will call directly
      ;; `head-to-next-cycle` when appropriate.
      (ok pool-rewards)
    )
  )
)

;; This function will be called by any user to distribute the rewards for the
;; current cycle. It will distribute the rewards to all participants that were
;; not rewarded yet. If there are no participants across all snapshots, this
;; function can be skipped and `head-to-next-cycle` can be called directly.
(define-public (distribute-rewards (principals (list 900 principal))) 
  (begin
    (asserts! (var-get can-distribute-rewards) ERR_CANNOT_DISTRIBUTE_REWARDS)
    (if 
      (or (is-eq (var-get rewards-to-distribute) u0) (is-eq (var-get current-cycle-total) u0))
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
      (local-last-cycle-id (var-get last-cycle-id))
      (holding-state
        (unwrap!
          (map-get? participant-holding
            {address: user, cycle-id: local-last-cycle-id}
          )
          ERR_NOT_PARTICIPANT_THIS_CYCLE
        )
      )
      (reward-amount 
        (/ 
          (* 
            (get amount holding-state) 
            (var-get rewards-to-distribute))
          (var-get current-cycle-total)
        )
      )
    )
    (if
      (get rewarded holding-state)
      ERR_ALREADY_REWARDED
      (begin
        (var-set rewarded-count (+ (var-get rewarded-count) u1))
        (map-set participant-holding
          {address: user, cycle-id: local-last-cycle-id}
          (merge holding-state {rewarded: true})
        )
        (if
          (> reward-amount u0) 
          (try!
            (as-contract
              (contract-call?
                'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                transfer
                reward-amount
                tx-sender
                user
                none
              )
            )
          )
          false
        )
        (print
          {
            cycle-id: local-last-cycle-id,
            enrolled-address: user,
            reward-address: user,
            amount: reward-amount,
            function-name: "distribute-rewards"
          }
        )
        (ok true)
      )
    )
  )
)

;; This function will be called at the end of each cycle, after:
;;  1. the cycle advances in the Yield SC.
;;  2. the rewards are distributed to all participants.
(define-public (head-to-next-cycle) 
  (let
    (
      (local-last-cycle-id (var-get last-cycle-id))
      (next-cycle-stx-block-height
        (unwrap!
          (contract-call?
            'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3
            get-stacks-block-height-for-cycle-snapshot
            (+ u1 local-last-cycle-id)
            u0
          )
          ERR_STX_BLOCK_NOT_VALIDATED_IN_YIELD
        )
      )
      (stx-block-header-hash
        (unwrap!
          (get-stacks-block-info? id-header-hash next-cycle-stx-block-height)
          ERR_STX_BLOCK_IN_FUTURE
        )
      )
    )
    (asserts! (var-get is-contract-active) ERR_CONTRACT_NOT_ACTIVE)
    (asserts!
      (is-eq
        (var-get current-cycle-participants-count)
        (var-get rewarded-count)
      )
      ERR_NOT_REWARDED_ALL
    )
    
    (try! (reset-state-for-cycle (+ local-last-cycle-id u1)))
    (update-snapshot-for-new-cycle next-cycle-stx-block-height)
    (ok (var-set last-cycle-id (+ local-last-cycle-id u1)))
  )
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
          (var-get admin)
          none
        )
      )
    )
    (ok true)
  )
)

(define-read-only (get-is-yield-active) 
  (contract-call? 'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3 get-is-contract-active)
)

;; Read-only function used to get the current cycle's stacks block height from
;; the yield contract.
(define-read-only (yield-contract-current-cycle-stacks-block-height)
  (get current-cycle-stacks-block-height (contract-call? 'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3 cycle-data))
)

(define-read-only (yield-contract-cycle-id)
  (get cycle-id (contract-call? 'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3 cycle-data))
)

(define-read-only (yield-contract-snapshot-index)
  (get current-snapshot-index (contract-call? 'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3 cycle-data))
)

(define-read-only (yield-contract-nr-snapshots-cycle)
  (get nr-snapshots-cycle (contract-call? 'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3 cycle-data))
)

(define-read-only (yield-contract-nr-blocks-snapshot)
  (get nr-blocks-snapshot (contract-call? 'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3 cycle-data))
)

(define-read-only (cycle-data) 
  {
    cycle-id: (var-get last-cycle-id),
    current-snapshot-index: (var-get current-snapshot-index),
    participants-count: (var-get current-cycle-participants-count),
    nr-snapshots-cycle: (var-get nr-snapshots-cycle),
    nr-blocks-snapshot: (var-get nr-blocks-snapshot),
  }
)

(define-read-only (snapshot-data) 
  {
    current-snapshot-count: (var-get current-snapshot-participants-count),
    current-snapshot-total: (var-get current-snapshot-total),
    current-snapshot-index: (var-get current-snapshot-index),
  }
)

(define-read-only (rewarded-data) 
  {
    rewarded-count: (var-get rewarded-count),
    can-distribute-rewards: (var-get can-distribute-rewards),
    participants-count: (var-get current-cycle-participants-count),
  }
)

(define-read-only (check-can-distribute-rewards) 
  (var-get can-distribute-rewards)
)

(define-read-only (get-stacks-block-height-for-cycle-snapshot
    (checked-cycle-id uint)
    (checked-snapshot-id uint)
  )
  (contract-call?
     'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3
    get-stacks-block-height-for-cycle-snapshot
    checked-cycle-id
    checked-snapshot-id
  )
)

(define-read-only (get-tenure-height-for-cycle-snapshot
    (checked-cycle-id uint)
    (checked-snapshot-id uint)
  )
  (contract-call?
     'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3
    get-tenure-height-for-cycle-snapshot
    checked-cycle-id
    checked-snapshot-id
  )
)

(define-read-only (current-overview-data) 
  {
    cycle-id: (var-get last-cycle-id),
    snapshot-index: (var-get current-snapshot-index),
    nr-snapshots-cycle: (var-get nr-snapshots-cycle)
  }
)

(define-read-only (get-admin)
  (var-get admin)
)

(define-read-only (get-is-contract-active)
  (var-get is-contract-active)
)

(define-read-only (can-call-set-can-distribute-rewards)
  ;; Checks yield sc cycle id to be > rewards cycle id.
  (is-some
    (contract-call?
       'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3
      stx-block-height-distribution-finalized
      (var-get last-cycle-id)
    )
  )
)

(define-read-only (stx-block-height-distribution-finalized)
  ;; Checks yield sc cycle id to be > rewards cycle id.
  (get stx-block-height
    (contract-call?
       'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3
      stx-block-height-distribution-finalized
      (var-get last-cycle-id)
    )
  )
)

(define-read-only (stx-block-height-distribution-finalized-for-wanted-cycle 
    (cycle-id uint)
  )
  (get stx-block-height
    (contract-call?
       'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3
      stx-block-height-distribution-finalized
      cycle-id
    )
  )
)

(define-read-only (can-call-set-snapshot-participants-count
    (offset-tenures uint)
  ) 
  (begin
    ;; True if current tenure > tenure for operation on yield + offset and
    ;; participants weren't set yet.
    (and 
      (is-eq -1 (var-get participants-to-snapshot))
      (>
        tenure-height
        (+
          offset-tenures
          (default-to DUMMY_TENURE_NOT_REACHED
            (get-tenure-height-for-cycle-snapshot
              (var-get last-cycle-id)
              (var-get current-snapshot-index)
            )
          )
        )
      )
    )
  )
)

(define-read-only (can-head-to-next-cycle-or-snapshot)
  (let 
    (
      (yield-data (contract-call?  'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3 current-overview-data))
      (yield-cycle-id (get cycle-id yield-data))
      (yield-snapshot-index (get snapshot-index yield-data))
    )
    ;; For this check the cycle-id is already the same.
    (or
      (> yield-cycle-id (var-get last-cycle-id))
      (> yield-snapshot-index (var-get current-snapshot-index))
    )
  )
)


;; DeFi App related calls

;; Get total sBTC balance in BitFlow pools
(define-read-only (get-total-sBTC-balance)
  (ok (+
    (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.xyk-sbtc-reader-pool-21-v-1-2 get-total-sbtc-balance))
    (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.xyk-sbtc-reader-pool-22-v-1-2 get-total-sbtc-balance))
    (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.xyk-sbtc-reader-pool-23-v-1-2 get-total-sbtc-balance))
    (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-sbtc-reader-pool-2-v-1-2 get-total-sbtc-balance))
  ))
)

;; Get user's total sBTC balance in BitFlow pools
(define-read-only (get-user-total-sBTC-balance (user principal)) 
  (ok (+ 
    (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.xyk-sbtc-reader-pool-21-v-1-2 get-user-sbtc-balance user))
    (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.xyk-sbtc-reader-pool-22-v-1-2 get-user-sbtc-balance user))
    (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.xyk-sbtc-reader-pool-23-v-1-2 get-user-sbtc-balance user))
    (try! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-sbtc-reader-pool-2-v-1-2 get-user-sbtc-balance user))
  ))
)


;; Get sBTC balance function for a given address
(define-read-only (get-total-balance-at-stacks-block
    (stacks-height uint)
    (address principal)
  )
  (ok (at-block
      ;; Inexistent balance on that block height - should never happen.
      (unwrap!
        (get-stacks-block-info? id-header-hash stacks-height)
        ERR_STX_BLOCK_IN_FUTURE
      )
      (get-user-total-sBTC-balance address)
    )
  )
)

```
