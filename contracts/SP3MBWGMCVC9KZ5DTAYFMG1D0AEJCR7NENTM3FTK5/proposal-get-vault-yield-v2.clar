;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

(define-data-var deployer principal tx-sender)


;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin

    ;; (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-claim-yield-v2-1 claim
    ;;   u2272
    ;;   'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stx-reserve-v1-1
    ;;   'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-collateral-types-v3-1
    ;;   false
    ;; ))

    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-claim-usda-yield-v2-1 claim-and-burn
      u2272
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stx-reserve-v1-1
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-collateral-types-v3-1
    ))


    (ok true)
  )
)
