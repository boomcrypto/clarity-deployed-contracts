;; @contract Claim DIKO rewards from staking
;; @version 1.1

(impl-trait 'SP3C0TCQS0C0YY8E0V3EJ7V4X9571885D44M8EFWF.arkadiko-automation-trait-v1.automation-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var deployer principal tx-sender)
(define-data-var last-claim-block uint u0)

;; ------------------------------------------
;; Keepers job
;; ------------------------------------------

(define-public (initialize)
  (ok true)
)

(define-read-only (check-job)
  (begin
    (ok (> (- block-height (var-get last-claim-block)) (* u144 u4)))
  )
)

(define-public (run-job)
  (begin
    (asserts! (unwrap-panic (check-job)) (ok false))
    (try! (contract-call? .lydian-dao-executor-v1-1 execute-proposal .f-claim-diko-stake-rewards-e-v1-2))
    (var-set last-claim-block block-height)
    (ok true)
  )
)

;; ------------------------------------------
;; Admin
;; ------------------------------------------

(define-public (run-job-deployer)
  (begin
    (asserts! (is-eq tx-sender (var-get deployer)) (err ERR-NOT-AUTHORIZED))
    (try! (contract-call? .lydian-dao-executor-v1-1 execute-proposal .f-claim-diko-stake-rewards-e-v1-2))
    (var-set last-claim-block block-height)
    (ok true)
  )
)
