;; @contract Stacking Strategy
;; @version 2
;;
;; Simple contract which allows protocol to delegate to a certain pool, given
;; a list of delegate contracts.
;; Amount calculations need to be done off chain.

(use-trait stacking-delegate-trait .stacking-delegate-trait-v1.stacking-delegate-trait)
(use-trait reserve-trait .reserve-trait-v1.reserve-trait)

;;-------------------------------------
;; Inflow/outflow info 
;;-------------------------------------

(define-read-only (get-total-stacking)
  (unwrap-panic (contract-call? .reserve-v1 get-stx-stacking))
)

;; Calculate STX outflow or inflow for next cycle.
(define-read-only (get-outflow-inflow)
  (let (
    (total-withdrawals (unwrap-panic (contract-call? .reserve-v1 get-stx-for-withdrawals)))
    (total-idle (unwrap-panic (contract-call? .reserve-v1 get-stx-balance)))

    (outflow (if (> total-withdrawals total-idle)
      (- total-withdrawals total-idle)
      u0
    ))

    (inflow (if (> total-idle total-withdrawals )
      (- total-idle total-withdrawals )
      u0
    ))
  )
    { outflow: outflow, inflow: inflow, total-stacking: (get-total-stacking), total-idle: total-idle, total-withdrawals: total-withdrawals }
  )
)

;;-------------------------------------
;; Perform pool delegation
;;-------------------------------------

;; Perform delegation to pool
;; If amount in delegates-info list is 0, delegation is revoked. Otherwise, delegation is set.
(define-public (perform-pool-delegation (pool principal) (delegates-info (list 10 { delegate: <stacking-delegate-trait>, amount: uint})))
  (let (
    (delegate-to-list (list-10-principal pool))
    (burn-ht-list (list-10-uint (get-next-cycle-end-burn-height)))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (let (
      (helper-result (map perform-pool-delegation-helper delegates-info delegate-to-list burn-ht-list))
      (helper-errors (filter is-error helper-result))
      (helper-error (element-at? helper-errors u0))
    )
      (asserts! (is-eq helper-error none) (unwrap-panic helper-error))
      (ok true)
    )
  )
)

(define-private (perform-pool-delegation-helper (delegate-info { delegate: <stacking-delegate-trait>, amount: uint}) (delegate-to principal) (until-burn-ht uint))
  (let (
    (delegate-contract (get delegate delegate-info))
    (delegate-amount (get amount delegate-info))
  )
    (if (is-eq delegate-amount u0)
      (try! (contract-call? .delegates-handler-v1 revoke delegate-contract .reserve-v1 .rewards-v1))
      (try! (contract-call? .delegates-handler-v1 revoke-and-delegate delegate-contract .reserve-v1 .rewards-v1 delegate-amount delegate-to until-burn-ht))
    )

    (print { action: "perform-pool-delegation-helper", data: { delegate-info: delegate-info, delegate-to: delegate-to, until-burn-ht: until-burn-ht, block-height: block-height } })
    (ok true)
  )
)

;;-------------------------------------
;; PoX Helpers
;;-------------------------------------

(define-read-only (get-pox-cycle)
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 current-pox-reward-cycle)
)

(define-read-only (reward-cycle-to-burn-height (cycle-id uint)) 
  (contract-call? 'SP000000000000000000002Q6VF78.pox-4 reward-cycle-to-burn-height cycle-id)
)

(define-read-only (get-next-cycle-end-burn-height)
  (reward-cycle-to-burn-height (+ (get-pox-cycle) u2))
)

;;-------------------------------------
;; Helpers
;;-------------------------------------

(define-read-only (is-error (response (response bool uint)))
  (is-err response)
)

(define-read-only (list-10-uint (item uint)) 
  (list item item item item item item item item item item)
)

(define-read-only (list-10-principal (item principal)) 
  (list item item item item item item item item item item)
)
