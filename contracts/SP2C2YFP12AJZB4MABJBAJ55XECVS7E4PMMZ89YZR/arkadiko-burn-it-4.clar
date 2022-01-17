
(define-constant ERR-NOT-AUTHORIZED u12345)


(define-constant DAO-OWNER tx-sender)



(define-public (burn-usda-1)
  (let (
    (balance-1 (unwrap-panic (contract-call? .usda-token get-balance 'SP3RW4CVYVF4K6TK6085BX913Q3032S7RMSJVDKR8)))

  )
    (asserts! (is-eq tx-sender DAO-OWNER) (err ERR-NOT-AUTHORIZED))

    (if (is-eq balance-1 u0)
      true
      (try! (as-contract (contract-call? .arkadiko-dao burn-token .usda-token balance-1 'SP3RW4CVYVF4K6TK6085BX913Q3032S7RMSJVDKR8)))
    )
  
    (ok true)
  )
)
