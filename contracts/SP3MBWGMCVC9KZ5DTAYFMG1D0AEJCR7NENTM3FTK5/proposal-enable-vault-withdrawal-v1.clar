;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stacker-payer-v3-7 enable-vault-withdrawals
      u2272
    ))

    (ok true)
  )
)
