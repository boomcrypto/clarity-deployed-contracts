;; Burn USDA that is stuck in USDA yield contract
(define-public (burn-and-mint)
  (begin
    (try! (contract-call? .arkadiko-dao burn-token .usda-token u16531688727 .arkadiko-claim-yield-v2-1))
    (try! (contract-call? .arkadiko-dao mint-token .usda-token u16531688727 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR))

    (ok true)
  )
)
