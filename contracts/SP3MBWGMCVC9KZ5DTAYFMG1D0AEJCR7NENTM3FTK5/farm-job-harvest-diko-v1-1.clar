;; @contract Compound DIKO rewards to DIKO/USDA
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
(define-data-var last-total-reward-ids uint u0)

;; ------------------------------------------
;; Keepers job
;; ------------------------------------------

(define-public (initialize)
  (ok true)
)

(define-read-only (check-job)
  (let (
    (total-reward-ids (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-total-reward-ids))
  )
    (if (> total-reward-ids (var-get last-total-reward-ids))
      (ok true)
      (ok false)
    )
  )
)

(define-public (run-job)
  (let (
    (total-reward-ids (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-total-reward-ids))
  )
    (asserts! (unwrap-panic (check-job)) (ok false))
    (try! (contract-call? .lydian-dao-executor-v1-1 execute-proposal .farm-exec-harvest-diko-v1-1))
    (var-set last-total-reward-ids total-reward-ids)
    (ok true)
  )
)

;; ------------------------------------------
;; Admin
;; ------------------------------------------

(define-public (reset)
  (begin
    (asserts! (is-eq tx-sender (var-get deployer)) (err ERR-NOT-AUTHORIZED))
    (var-set last-total-reward-ids u0)
    (ok true)
  )
)

(define-public (run-job-deployer)
  (let (
    (total-reward-ids (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-total-reward-ids))
  )
    (asserts! (is-eq tx-sender (var-get deployer)) (err ERR-NOT-AUTHORIZED))
    (try! (contract-call? .lydian-dao-executor-v1-1 execute-proposal .farm-exec-harvest-diko-v1-1))
    (var-set last-total-reward-ids total-reward-ids)
    (ok true)
  )
)
