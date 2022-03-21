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

    ;; Enable minters
    (try! (contract-call? .treasury-v1-1 set-active-minter-info .bond-teller-v1-1 true))
    (try! (contract-call? .treasury-v1-1 set-active-minter-info .staking-distributor-v1-1 true))

    ;; USDA token as treasury token
    (try! (contract-call? .treasury-v1-1 enable-reserve-token 
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
      false 
      .value-calculator-v1-1
    ))

    (ok true)
  )
)

