;; Add DIKO to liquidation pool every 1008 blocks

(impl-trait 'SP3C0TCQS0C0YY8E0V3EJ7V4X9571885D44M8EFWF.arkadiko-automation-trait-v1.automation-trait)

(define-public (initialize)
  (ok true)
)

(define-read-only (check-job)
  (let (
    (end-epoch-block (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-diko-v1-1 get-end-epoch-block)))
  )
    (asserts! (> block-height end-epoch-block) (ok false))
    (ok true)
  )
)

(define-public (run-job)
  (begin
    (asserts! (unwrap-panic (check-job)) (ok false))
    (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-diko-v1-1 add-rewards 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2))
    (ok true)
  )
)
