;; @contract ALEX to atALEX
;; @version 1.1

(impl-trait 'SP3C0TCQS0C0YY8E0V3EJ7V4X9571885D44M8EFWF.arkadiko-automation-trait-v1.automation-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var deployer principal tx-sender)

;; ------------------------------------------
;; Keepers job
;; ------------------------------------------

(define-public (initialize)
  (ok true)
)

(define-read-only (check-job)
  (let (
    (balance (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance .lydian-dao)))
  )
    (ok (> balance u100000000))
  )
)

(define-public (run-job)
  (begin
    (asserts! (unwrap-panic (check-job)) (ok false))
    (try! (contract-call? .lydian-dao-executor-v1-1 execute-proposal .farm-exec-stake-alex-v1-2))
    (ok true)
  )
)

;; ------------------------------------------
;; Admin
;; ------------------------------------------

(define-public (run-job-deployer)
  (begin
    (asserts! (is-eq tx-sender (var-get deployer)) (err ERR-NOT-AUTHORIZED))
    (try! (contract-call? .lydian-dao-executor-v1-1 execute-proposal .farm-exec-stake-alex-v1-2))
    (ok true)
  )
)
