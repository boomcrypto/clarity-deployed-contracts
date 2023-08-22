;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (unwrap-panic (contract-call? .staking-distributor-v1-1 set-adjustment .staking-v1-1 true u0 u0))
    (try! (contract-call? .staking-distributor-v1-1 add-recipient .staking-v1-1 u0))

    (ok true)
  )
)