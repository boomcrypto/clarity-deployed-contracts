;; @contract Stacking Pool
;; @version 1
;;
;; Stacking DAO stacking pool
;; One of the pools that will be used by the StackingDAO protocol.
;; Others can also delegate to this pool directly.

;; Stacking delegation
;;
;; 1) User needs to set correct amount to delegate
;;    `revoke-delegate-stx` and `delegate-stx` to (re)set amount to delegate
;;
;; 2) Pool must perform user delegation
;;    `delegate-stack-stx` for first time user to start stacking
;;    `delegate-stack-extend` once for next cycle
;;    `delegate-stack-increase` if need to stack more
;;
;; 3) Pool must commit aggregation result
;;    `stack-aggregation-commit-indexed` to commit to a reward cycle and get reward index, only done once per cycle
;;    `stack-aggregation-increase` with index from previous commit to increase amount stacked
;;

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_CAN_NOT_PREPARE u205001)
(define-constant ERR_MISSING_SIGNER_INFO u205002)

;;-------------------------------------
;; Variables
;;-------------------------------------

(define-data-var pox-reward-address { version: (buff 1), hashbytes: (buff 32) } { version: 0x04, hashbytes: 0x2fffa9a09bb7fa7dced44834d77ee81c49c5f0cc })

;;-------------------------------------
;; Maps
;;-------------------------------------

;; Map cycle+topic to signer info
(define-map cycle-signer-info
  { 
    reward-cycle: uint, 
    topic: (string-ascii 14) 
  }
  {
    pox-addr: { version: (buff 1), hashbytes: (buff 32) },
    max-amount: uint,
    auth-id: uint,
    signer-key: (buff 33),
    signer-sig: (buff 65)
  }
)

;; Map cycle to reward index
(define-map cycle-to-index uint uint)

;;-------------------------------------
;; Getters
;;-------------------------------------

(define-read-only (get-pox-reward-address)
  (var-get pox-reward-address)
)

(define-read-only (get-cycle-signer-info (reward-cycle uint) (topic (string-ascii 14)))
  (map-get? cycle-signer-info { reward-cycle: reward-cycle, topic: topic })
)

(define-read-only (get-cycle-to-index (cycle uint))
  (map-get? cycle-to-index cycle)
)

;;-------------------------------------
;; Helpers
;;-------------------------------------

(define-read-only (is-error (response (response bool uint)))
  (is-err response)
)

(define-read-only (can-prepare)
  (let (
    (current-cycle (current-pox-reward-cycle))
    (start-block-next-cycle (reward-cycle-to-burn-height (+ current-cycle u1)))
    (withdraw-offset (contract-call? .data-core-v1 get-cycle-withdraw-offset))
  )
    (> burn-block-height (- start-block-next-cycle withdraw-offset))
  )
)

;;-------------------------------------
;; Public - StackingDAO Delegates
;;-------------------------------------

(define-public (prepare-stacking-dao)
  (let (
    (delegates (contract-call? .data-pools-v1 get-pool-delegates (as-contract tx-sender)))
  )
    (prepare-delegate-many delegates)
  )
)

;;-------------------------------------
;; Public - Delegates
;;-------------------------------------

(define-public (delegate-stx (amount-ustx uint) (until-burn-ht (optional uint)))
  (begin
    (print { action: "delegate-stx", data: { tx-sender: tx-sender, amount-ustx: amount-ustx, block-height: block-height } })

    (match (pox-delegate-stx amount-ustx (as-contract tx-sender) until-burn-ht)
      result (ok result)
      error (err (to-uint error))
    )
  )
)

(define-public (revoke-delegate-stx)
  (begin
    (print { action: "revoke-delegate-stx", data: { tx-sender: tx-sender, block-height: block-height } })

    (match (pox-revoke-delegate-stx)
      result (ok result)
      error (err error)
    )
  )
)

(define-public (prepare-delegate (delegate principal))
  (begin
    (asserts! (can-prepare) (err ERR_CAN_NOT_PREPARE))

    ;; 1. Delegate
    (try! (delegation delegate))

    ;; 2. Aggregate - ignore error ERR_STACKING_THRESHOLD_NOT_MET
    (match (aggregation)
      success true
      error (begin
        (asserts! (is-eq error u11) (err error))
        true
      )
    )

    (print { action: "prepare-delegate", data: { delegate: delegate, block-height: block-height } })
    (ok true)
  )
)

(define-public (prepare-delegate-many (delegates (list 50 principal)))
  (let (
    ;; 1. Delegate
    (delegation-errors (filter is-error (map delegation delegates)))
    (delegation-error (element-at? delegation-errors u0))
  )
    (asserts! (can-prepare) (err ERR_CAN_NOT_PREPARE))
    (asserts! (is-eq delegation-error none) (unwrap-panic delegation-error))

    ;; 2. Aggregate - ignore error ERR_STACKING_THRESHOLD_NOT_MET
    (match (aggregation)
      success true
      error (begin
        (asserts! (is-eq error u11) (err error))
        true
      )
    )

    (print { action: "prepare-delegate-many", data: { block-height: block-height } })
    (ok true)
  )
)

;;-------------------------------------
;; Helpers 
;;-------------------------------------

(define-private (delegation (delegate principal))
  (let (
    (delegation-info (get-check-delegation delegate))
    (delegation-amount (if (is-none delegation-info)
      u0
      (unwrap-panic (get amount-ustx delegation-info))
    ))
  )
    (if (is-eq delegation-amount u0)
      ;; No delegation, do nothing
      false

      (if (is-none (get-stacker-info delegate))
        ;; Not stacking yet
        (begin 
          (try! (as-contract (delegate-stack-stx delegate delegation-amount (get-pox-reward-address) burn-block-height u1)))
          true
        )

        ;; Already stacking
        (begin
          ;; Extend for next cycle if not extended yet
          (if (unwrap-panic (not-extended-next-cycle delegate))
            (begin
              (try! (as-contract (delegate-stack-extend delegate (get-pox-reward-address) u1)))
              true
            )
            true
          )

          ;; Increase if needed
          (let (
            (locked-amount (get locked (get-stx-account delegate)))
          )
            (if (> delegation-amount locked-amount)
              (begin
                (try! (as-contract (delegate-stack-increase delegate (get-pox-reward-address) (- delegation-amount locked-amount))))
                true
              )
              true
            )
          )
        )
      )
    )
    (ok true)
  )
)

(define-private (aggregation)
  (let (
    (next-cycle (+ (current-pox-reward-cycle) u1))
    (index (map-get? cycle-to-index next-cycle))
    (signer-info (if (is-none index)
      (get-cycle-signer-info next-cycle "agg-commit")
      (get-cycle-signer-info next-cycle "agg-increase")
    ))
  )
    (asserts! (is-some signer-info) (err ERR_MISSING_SIGNER_INFO))

    (if (is-none index)
      ;; No index yet, commit
      (let (
        (reward-index (try! (as-contract (stack-aggregation-commit-indexed 
          (unwrap-panic (get pox-addr signer-info))
          next-cycle
          (get signer-sig signer-info)
          (unwrap-panic (get signer-key signer-info))
          (unwrap-panic (get max-amount signer-info))
          (unwrap-panic (get auth-id signer-info))
        ))))
      )
        (print { action: "aggregation", data: { reward-index: reward-index, block-height: block-height } })
        (map-set cycle-to-index next-cycle reward-index)
        true
      )

      ;; Already have an index for cycle
      (begin
        (print { action: "aggregation", data: { reward-index: (unwrap-panic index), block-height: block-height } })
        (try! (as-contract (stack-aggregation-increase 
          (unwrap-panic (get pox-addr signer-info))
          next-cycle
          (unwrap-panic index)
          (get signer-sig signer-info)
          (unwrap-panic (get signer-key signer-info))
          (unwrap-panic (get max-amount signer-info))
          (unwrap-panic (get auth-id signer-info))
        )))
        true
      )
    )
    (ok true)
  )
)

;;-------------------------------------
;; Helpers
;;-------------------------------------

(define-read-only (not-extended-next-cycle (delegate principal))
  (let (
    (current-cycle (current-pox-reward-cycle))
    (next-cycle-height (reward-cycle-to-burn-height (+ current-cycle u1)))
    (unlock-height (get unlock-height (get-stx-account delegate)))
  )
    (ok (<= unlock-height next-cycle-height))
  )
)


;;-------------------------------------
;; Admin
;;-------------------------------------

(define-public (set-pox-reward-address (new-address { version: (buff 1), hashbytes: (buff 32) }))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set pox-reward-address new-address)
    (ok true)
  )
)

(define-public (set-cycle-signer-info 
  (reward-cycle uint)
  (topic (string-ascii 14))
  (pox-addr { version: (buff 1), hashbytes: (buff 32) })
  (max-amount uint)
  (auth-id uint)
  (signer-key (buff 33))
  (signer-sig (buff 65))
)
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set cycle-signer-info
      {
        reward-cycle: reward-cycle,
        topic: topic
      }
      {
        pox-addr: pox-addr,
        max-amount: max-amount,
        auth-id: auth-id,
        signer-key: signer-key,
        signer-sig: signer-sig
      }
    )
    (ok true)
  )
)


(define-public (set-cycle-to-index (cycle uint) (index uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set cycle-to-index cycle index)
    (ok true)
  )
)


;;-------------------------------------
;; PoX Wrappers
;;-------------------------------------

(define-public (delegate-stack-stx
  (stacker principal)
  (amount-ustx uint)
  (pox-addr { version: (buff 1), hashbytes: (buff 32) })
  (start-burn-ht uint)
  (lock-period uint)
)
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (print { action: "delegate-stack-stx", data: { stacker: stacker, amount: amount-ustx, start-height: start-burn-ht, period: lock-period, block-height: block-height } })
    
    (match (as-contract (pox-delegate-stack-stx stacker amount-ustx pox-addr start-burn-ht lock-period))
      result (ok result)
      error (err (to-uint error))
    )
  )
)

(define-public (delegate-stack-extend (stacker principal) (pox-addr { version: (buff 1), hashbytes: (buff 32) }) (extend-count uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (print { action: "delegate-stack-extend", data: { stacker: stacker, extend: extend-count, block-height: block-height } })

    (match (as-contract (pox-delegate-stack-extend stacker pox-addr extend-count))
      result (ok result)
      error (err (to-uint error))
    )
  )
)

(define-public (delegate-stack-increase (stacker principal) (pox-addr { version: (buff 1), hashbytes: (buff 32) }) (increase-by uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (print { action: "delegate-stack-increase", data: { stacker: stacker, increase-by: increase-by, block-height: block-height } })

    (match (as-contract (pox-delegate-stack-increase stacker pox-addr increase-by))
      result (ok result)
      error (err (to-uint error))
    )
  )
)

(define-public (stack-aggregation-commit-indexed
  (pox-addr { version: (buff 1), hashbytes: (buff 32) })
  (reward-cycle uint)
  (signer-sig (optional (buff 65)))
  (signer-key (buff 33))
  (max-amount uint)
  (auth-id uint)
)
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (print { action: "stack-aggregation-commit-indexed", data: { reward-cycle: reward-cycle, signer-sig: signer-sig, signer-key: signer-key, max-amount: max-amount, auth-id: auth-id, block-height: block-height } })

    (match (as-contract (pox-stack-aggregation-commit-indexed pox-addr reward-cycle signer-sig signer-key max-amount auth-id))
      result (ok result)
      error (err (to-uint error))
    )
  )
)

(define-public (stack-aggregation-increase
  (pox-addr { version: (buff 1), hashbytes: (buff 32) })
  (reward-cycle uint)
  (reward-cycle-index uint)
  (signer-sig (optional (buff 65)))
  (signer-key (buff 33))
  (max-amount uint)
  (auth-id uint)
)
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (print { action: "stack-aggregation-increase", data: { reward-cycle: reward-cycle, reward-cycle-index: reward-cycle-index, signer-sig: signer-sig, signer-key: signer-key, max-amount: max-amount, auth-id: auth-id, block-height: block-height } })

    (match (as-contract (pox-stack-aggregation-increase pox-addr reward-cycle reward-cycle-index signer-sig signer-key max-amount auth-id))
      result (ok result)
      error (err (to-uint error))
    )
  )
)


;;-------------------------------------
;; PoX Helpers
;;-------------------------------------

(define-read-only (get-stx-account (account principal))
  (stx-account account)
)

(define-read-only (get-check-delegation (delegate principal))
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 get-check-delegation delegate)
)

(define-read-only (current-pox-reward-cycle) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 current-pox-reward-cycle)
)

(define-read-only (reward-cycle-to-burn-height (cycle-id uint)) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 reward-cycle-to-burn-height cycle-id)
)

(define-private (pox-delegate-stx (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint))) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 delegate-stx amount-ustx delegate-to until-burn-ht none)
)

(define-private (pox-revoke-delegate-stx)
  (begin
    (match (contract-call? 'SP000000000000000000002Q6VF78.pox-4 revoke-delegate-stx)
      result (ok result)
      error (if (is-eq error 34) (ok (get-check-delegation tx-sender)) (err (to-uint error)))
    )
  )
)

(define-read-only (get-stacker-info (delegate principal)) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 get-stacker-info delegate)
)   

(define-private (pox-delegate-stack-stx 
  (stacker principal)
  (amount-ustx uint)
  (pox-addr { version: (buff 1), hashbytes: (buff 32) })
  (start-burn-ht uint)
  (lock-period uint)
) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 delegate-stack-stx stacker amount-ustx pox-addr start-burn-ht lock-period)
)

(define-private (pox-delegate-stack-extend (stacker principal) (pox-addr { version: (buff 1), hashbytes: (buff 32) }) (extend-count uint)) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 delegate-stack-extend stacker pox-addr extend-count)
)

(define-private (pox-delegate-stack-increase (stacker principal) (pox-addr { version: (buff 1), hashbytes: (buff 32) }) (increase-by uint)) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 delegate-stack-increase stacker pox-addr increase-by)
)

(define-private (pox-stack-aggregation-commit-indexed
  (pox-addr { version: (buff 1), hashbytes: (buff 32) })
  (reward-cycle uint)
  (signer-sig (optional (buff 65)))
  (signer-key (buff 33))
  (max-amount uint)
  (auth-id uint)
) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 stack-aggregation-commit-indexed pox-addr reward-cycle signer-sig signer-key max-amount auth-id)
)

(define-private (pox-stack-aggregation-increase
  (pox-addr { version: (buff 1), hashbytes: (buff 32) })
  (reward-cycle uint)
  (reward-cycle-index uint)
  (signer-sig (optional (buff 65)))
  (signer-key (buff 33))
  (max-amount uint)
  (auth-id uint)
) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 stack-aggregation-increase pox-addr reward-cycle reward-cycle-index signer-sig signer-key max-amount auth-id)
)
