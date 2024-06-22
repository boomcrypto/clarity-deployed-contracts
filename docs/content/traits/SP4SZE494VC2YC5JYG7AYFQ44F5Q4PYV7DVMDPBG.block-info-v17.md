---
title: "Trait block-info-v17"
draft: true
---
```

(define-read-only (get-user-hermetica (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u146526)
      (ok u0)
      (ok (at-block block-hash (get-user-hermetica-helper account)))
    )
  )
)

(define-read-only (get-user-hermetica-helper (account principal))
  (let (
    (token-balance (unwrap-panic (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.token-ststx-earn-v1 get-balance account)))
    (ratio (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.vault-ststx-earn-v1 get-underlying-per-token))
    (wallet-amount (/ (* token-balance ratio) u1000000))

    (queued-amount (get-queued-hermetica-helper account))
  )
    (+ wallet-amount queued-amount)
  )
)

(define-read-only (get-queued-hermetica-helper (account principal))
  (let (
    (deposit-claims (get deposit-claims (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.vault-ststx-earn-v1 get-claims-for-address account)))
  )
    (fold + (map get-claim-iter deposit-claims) u0)
  )
)

(define-read-only (get-claim-iter (claim-id uint))
  (let (
    (claim (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.vault-ststx-earn-v1 get-claim claim-id))
  )
    (get underlying-amount (unwrap-panic claim))
  )
)

```
