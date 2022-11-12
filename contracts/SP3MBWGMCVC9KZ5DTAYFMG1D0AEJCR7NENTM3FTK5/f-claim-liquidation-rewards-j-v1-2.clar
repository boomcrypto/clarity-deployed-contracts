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

;; ------------------------------------------
;; Keepers job
;; ------------------------------------------

(define-public (initialize)
  (ok true)
)

(define-read-only (check-job)
  (let (
    (total-reward-ids (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-liquidation-rewards-v1-2 get-total-reward-ids))
    (last-id (contract-call? .f-claim-liquidation-rewards-e-v1-2 get-last-total-reward-ids))
  )
    (ok (> (- total-reward-ids u1) last-id))
  )
)

(define-public (run-job)
  (begin
    (asserts! (unwrap-panic (check-job)) (ok false))
    (try! (contract-call? .lydian-dao-executor-v1-1 execute-proposal .f-claim-liquidation-rewards-e-v1-2))
    (ok true)
  )
)

;; ------------------------------------------
;; Admin
;; ------------------------------------------

(define-public (run-job-deployer)
  (begin
    (asserts! (is-eq tx-sender (var-get deployer)) (err ERR-NOT-AUTHORIZED))
    (try! (contract-call? .lydian-dao-executor-v1-1 execute-proposal .f-claim-liquidation-rewards-e-v1-2))
    (ok true)
  )
)
