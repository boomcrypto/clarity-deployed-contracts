
(define-constant ERR-NOT-AUTHORIZED u12345)


(define-constant DAO-OWNER tx-sender)

(define-public (burn-usda-1)
  (begin
    (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token u85062690000000 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR)))
    (ok true)
  )
)
