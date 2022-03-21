;; @contract Lydian DAO
;; @version 1

(use-trait lydian-dao-proposal-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1003001)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var active-governance principal .governance-v1-1)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-active-governance)
  (var-get active-governance)
)

;; ------------------------------------------
;; Core
;; ------------------------------------------

(define-public (execute-proposal (proposal-trait <lydian-dao-proposal-trait>))
  (begin
    (asserts! (is-eq contract-caller (var-get active-governance)) (err  ERR-NOT-AUTHORIZED))
    (as-contract (contract-call? proposal-trait execute))
  )
)

(define-public (set-active-governance (governance principal))
  (begin
    (asserts! (is-eq tx-sender .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (var-set active-governance governance)
    (ok true)
  )
)