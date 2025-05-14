---
title: "Trait faucet"
draft: true
---
```
(define-constant SUCCESS (ok true))

(define-public (get-stx (amount uint) (to principal))
  (let
    (
      (balance (stx-get-balance (as-contract tx-sender)))
    )
    (asserts! (>= balance amount) (err "not enough STX in the faucet"))
    (unwrap! (as-contract (stx-transfer? amount tx-sender to)) (err "error sending STX"))
    SUCCESS
  )
)

(define-public (get-mock-usdc (amount uint))
  (let
    (
      (balance (stx-get-balance (as-contract tx-sender)))
      (user tx-sender)
    )
    (try! (contract-call? .mock-usdc mint amount user))
    SUCCESS
  )
)

(define-public (get-mock-btc (amount uint))
  (let
    (
      (balance (stx-get-balance (as-contract tx-sender)))
      (user tx-sender)
    )
    (try! (contract-call? .mock-btc mint amount user))
    SUCCESS
  )
)

(define-public (get-mock-eth (amount uint))
  (let
    (
      (balance (stx-get-balance (as-contract tx-sender)))
      (user tx-sender)
    )
    (try! (contract-call? .mock-eth mint amount user))
    SUCCESS
  )
)

```
