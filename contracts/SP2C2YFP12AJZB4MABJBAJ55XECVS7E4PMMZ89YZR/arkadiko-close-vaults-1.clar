
(define-constant ERR-NOT-AUTHORIZED u12345)

(define-constant DAO-OWNER tx-sender)

(define-public (mint-usda-for-debt (amount uint))
  (begin
    (asserts! (is-eq tx-sender DAO-OWNER) (err ERR-NOT-AUTHORIZED))

    (as-contract (contract-call? .arkadiko-dao mint-token .usda-token amount DAO-OWNER))
  )
)

(define-public (pay-debt (vault-id uint))
  (let (
    (debt (get debt (contract-call? .arkadiko-vault-data-v1-1 get-vault-by-id vault-id)))
  )
    (contract-call? .arkadiko-freddie-v1-1 burn
      vault-id 
      debt 
      .arkadiko-stx-reserve-v1-1 
      .arkadiko-token 
      .arkadiko-collateral-types-v1-1
    )
  )
)

