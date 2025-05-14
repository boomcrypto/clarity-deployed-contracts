---
title: "Trait Boopa6"
draft: true
---
```

(define-fungible-token boopa)

(define-constant deployer tx-sender)

(define-public (mint-initial-supply)
  (begin
    (asserts! (is-eq tx-sender deployer) (err u100))
    (ft-mint? boopa u1000000000000000 deployer)
  )
)

(define-public (transfer (amount uint) (recipient principal))
  (ft-transfer? boopa amount tx-sender recipient)
)

(define-read-only (get-token-metadata)
  (ok {
    name: "Boopa",
    symbol: "BOOPA",
    decimals: u6,
    image: "https://gateway.pinata.cloud/ipfs/bafkreidlfswhz7jbxdzwjbpqtipkczg3zbgeadyfvczwray5nwqzrisvx4"
  })
)


```
