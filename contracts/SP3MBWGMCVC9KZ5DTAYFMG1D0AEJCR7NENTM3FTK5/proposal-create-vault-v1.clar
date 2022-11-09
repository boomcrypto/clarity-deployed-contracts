;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    ;; Get wSTX
    (try! (contract-call? .treasury-v1-1 transfer-tokens 
      .wrapped-stacks-token 
      u190000000000
      .lydian-dao
      .value-calculator-v1-1
    ))

    ;; Unwrap
    (try! (contract-call? .wrapped-stacks-token unwrap 
      u190000000000
    ))

    ;; Create vault
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-freddie-v1-1 collateralize-and-mint 
      u190000000000
      u20000000000
      { auto-payoff: true, stack-pox: true }
      "STX-A"
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stx-reserve-v1-1
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.xstx-token
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-collateral-types-v3-1
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v1-1
    ))

    (ok true)
  )
)
