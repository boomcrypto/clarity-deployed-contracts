(define-public (burn-and-mint)
  (begin
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token u3687919069 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v1-1)))
    (try! (as-contract (contract-call? .arkadiko-dao mint-token .usda-token u3687919069 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR)))

    (try! (as-contract (contract-call? .arkadiko-dao burn-token .arkadiko-token u697570158 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v1-1)))
    (try! (as-contract (contract-call? .arkadiko-dao mint-token .arkadiko-token u697570158 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR)))
    (ok true)
  )
)
