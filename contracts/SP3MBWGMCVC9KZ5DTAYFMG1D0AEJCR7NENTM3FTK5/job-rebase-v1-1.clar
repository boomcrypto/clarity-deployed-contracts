;; Rebase job

(impl-trait 'SP3C0TCQS0C0YY8E0V3EJ7V4X9571885D44M8EFWF.arkadiko-automation-trait-v1.automation-trait)

(define-public (initialize)
  (ok true)
)

(define-read-only (check-job)
  (let (
    (epoch-end-block (contract-call? .staking-v1-1 get-epoch-end-block))
  )
    (asserts! (<= epoch-end-block block-height) (ok false))
    (ok true)
  )
)

(define-public (run-job)
  (begin
    (asserts! (unwrap-panic (check-job)) (ok false))
    (unwrap-panic (contract-call? 
      .staking-v1-1
      rebase
      .staking-distributor-v1-1
      .treasury-v1-1
    ))
    (ok true)
  )
)
