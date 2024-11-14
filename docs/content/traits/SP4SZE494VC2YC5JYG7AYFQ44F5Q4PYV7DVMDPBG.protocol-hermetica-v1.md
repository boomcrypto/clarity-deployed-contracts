---
title: "Trait protocol-hermetica-v1"
draft: true
---
```
;; @contract Supported Protocol - Zest
;; @version 1

(impl-trait .protocol-trait-v1.protocol-trait)

;;-------------------------------------
;; Arkadiko 
;;-------------------------------------

(define-read-only (get-balance (user principal))
  (let (
    (token-balance (unwrap-panic (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.token-ststx-earn-v1 get-balance user)))
    (ratio (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.vault-ststx-earn-v1 get-underlying-per-token))
    (wallet-amount (/ (* token-balance ratio) u1000000))

    (queued-amount (get-queued-hermetica-helper user))
  )
    (ok (+ wallet-amount queued-amount))
  )
)

(define-read-only (get-queued-hermetica-helper (user principal))
  (let (
    (deposit-claims (get deposit-claims (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.vault-ststx-earn-v1 get-claims-for-address user)))
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
