;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

(define-data-var deployer principal tx-sender)


;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (try! (contract-call? .treasury-v1-1 migrate-funds
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
      (var-get deployer)
    ))

    (try! (contract-call? .treasury-v1-1 migrate-funds
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
      (var-get deployer)
    ))


    (try! (contract-call? .treasury-v1-1 migrate-funds
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token
      (var-get deployer)
    ))


    (ok true)
  )
)
