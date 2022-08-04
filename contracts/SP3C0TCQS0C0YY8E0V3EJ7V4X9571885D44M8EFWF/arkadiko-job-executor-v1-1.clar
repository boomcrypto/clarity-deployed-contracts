;; Arkadiko Automate - Job Executor
;; Run a job
;; Intermediate contract to isolate running
(impl-trait .arkadiko-job-executor-trait-v1.job-executor-trait)
(use-trait automation-trait .arkadiko-automation-trait-v1.automation-trait)

(define-constant ERR-NOT-AUTHORIZED u403)

(define-public (run (job <automation-trait>))
  (begin
    (asserts! (is-eq contract-caller .arkadiko-job-registry-v1-1) (err ERR-NOT-AUTHORIZED))

    (try! (as-contract (contract-call? job run-job)))
    (ok true)
  )
)
