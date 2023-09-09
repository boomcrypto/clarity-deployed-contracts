;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
  
    ;; Close vault
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-freddie-v1-1 release-stacked-stx 
      u2272
    ))

    (ok true)
  )
)
