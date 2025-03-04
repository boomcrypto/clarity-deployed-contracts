(define-constant ERR_STX_BLOCK_IN_FUTURE (err u101))


(define-data-var last-cycle-id uint u0)
(define-data-var current-cycle-participants-count uint u0)

(define-data-var current-snapshot-participants-count uint u0)
(define-data-var current-snapshot-index uint u0)
(define-data-var current-snapshot-total uint u0)

(define-data-var local-stx-id-header-hash
  (buff 32)
  0x0000000000000000000000000000000000000000000000000000000000000000
)

(define-map participant-holding
  { cycle-id: uint, address: principal }
  { amount: uint, last-snapshot: uint, rewarded: bool }
)

(define-constant DUMMY_SNAPSHOT_INDEX u1000)


;; This function will be called by the admin to compute all the participants'
;; balances for the current snapshot. This function should be called right
;; after the admin sets the participants count.
;; 
;; Do not call if the participants count was set to 0. You can head to the next
;; cycle/snapshot without computing the balances in this case.
(define-public (compute-current-snapshot-balances
    (stx-block-height uint)
    (principals (list 900 principal))
  )
  (begin
    (var-set local-stx-id-header-hash 
      (unwrap!
        (get-stacks-block-info?
          id-header-hash
          stx-block-height
        )
        ERR_STX_BLOCK_IN_FUTURE
      )
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
      (var-set current-snapshot-total u0)
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
        (unwrap! 
          (at-block
            (var-get local-stx-id-header-hash)
            (contract-call? 'SP2MR06G4ET2SSW7M8JABQ1ASA81J4HV8RSPSEAVT.tiger-lion-puma-0 get-user-total-sBTC-balance address)
          ) 
          u0
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
