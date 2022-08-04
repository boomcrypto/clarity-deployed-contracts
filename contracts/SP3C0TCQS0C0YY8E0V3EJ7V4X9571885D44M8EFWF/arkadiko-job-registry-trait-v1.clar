(use-trait automation-trait .arkadiko-automation-trait-v1.automation-trait)
(use-trait cost-trait .arkadiko-job-cost-calculation-trait-v1.cost-calculation-trait)
(use-trait executor-trait .arkadiko-job-executor-trait-v1.job-executor-trait)

(define-trait job-registry-trait
  (
    (register-job (principal uint <cost-trait>) (response bool uint))
    (run-job (uint <automation-trait> <executor-trait>) (response bool uint))
  )
)
