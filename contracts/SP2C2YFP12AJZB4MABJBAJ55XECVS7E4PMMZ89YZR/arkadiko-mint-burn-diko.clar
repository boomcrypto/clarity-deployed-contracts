(define-public (migrate-diko)
  (let (
    (balance u442708333330)
  )
    (try! (contract-call? .arkadiko-dao burn-token .arkadiko-token balance 'SP3C1KZN3WZD7HS5S2VKCD3GHBWXBSRPK6NAGGMQJ))
    (try! (contract-call? .arkadiko-dao mint-token .arkadiko-token balance 'SP3TF26QFS3YMYHC9N3ZZTZQKCM4AFYMVW1WMFRTT))

    (ok true)
  )
)
