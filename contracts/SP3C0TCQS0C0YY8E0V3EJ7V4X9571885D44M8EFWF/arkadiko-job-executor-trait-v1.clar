(use-trait automation-trait .arkadiko-automation-trait-v1.automation-trait)

(define-trait job-executor-trait
  (
    ;; run automation
    (run (<automation-trait>) (response bool uint))
  )
)
