;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

(define-data-var deployer principal tx-sender)


;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (try! (contract-call? .wrapped-stacks-token wrap u191637142896))

    (try! (contract-call? .wrapped-stacks-token transfer 
      u191637142896
      .lydian-dao
      (var-get deployer)
      none
    ))

    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer 
      u93763140465
      .lydian-dao
      (var-get deployer)
      none
    ))

    (ok true)
  ) 
)
