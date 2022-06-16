;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var deployer principal tx-sender)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    ;; Transfer USDA
    (unwrap-panic (contract-call? .treasury-v1-1 transfer-tokens 
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
      u2703000000 
      (var-get deployer)
      .value-calculator-v1-1
    ))

    ;; Fix teller
    (try! (contract-call? .bond-teller-v1-2 set-contract-is-enabled false))
    (try! (contract-call? .lydian-token set-active-minter (as-contract tx-sender)))
    (try! (contract-call? .lydian-token mint .staking-v1-1 u744000000))
    (try! (contract-call? .lydian-token set-active-minter .treasury-v1-1))
    (try! (contract-call? .staked-lydian-token mint .bond-teller-v1-2 u744000000))

    (ok true)
  )
)
