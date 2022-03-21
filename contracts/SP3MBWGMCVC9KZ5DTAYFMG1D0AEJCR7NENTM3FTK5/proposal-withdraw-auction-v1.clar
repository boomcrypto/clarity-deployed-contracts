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

(define-data-var wallet principal tx-sender)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (let (
    (balance (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance .auction-v1-1)))

    (liquidity-tokens u32062883425)
    (treasury-tokens (- balance liquidity-tokens))
  )
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    ;; Transfer to treasury
    (try! (contract-call? .auction-v1-1 transfer-tokens 
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
      treasury-tokens 
      .treasury-v1-1
    ))

    ;; Transfer to wallet
    (try! (contract-call? .auction-v1-1 transfer-tokens 
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
      liquidity-tokens 
      (var-get wallet)
    ))

    ;; Audit reserves
    (try! (contract-call? .treasury-v1-1 audit-reserve-token 
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
      .value-calculator-v1-1
    ))

    (ok true)
  )
)

