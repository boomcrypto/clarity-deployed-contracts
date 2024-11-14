---
title: "Trait red1"
draft: true
---
```
(define-constant owner tx-sender)

(define-constant D8 u100000000) 
(define-constant fifty u5000000000)

(define-public (a1) 
    (begin 
        (let
            (
                (aa (stx-get-balance tx-sender))
                (b1 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc D8 fifty none)))
                (b2 (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd012-redemption-nyc redeem-nyc)))
                (ab (stx-get-balance tx-sender)))
            (asserts! (>= ab aa) (err (- aa ab)))
            (ok (- ab aa))
        )
    )
) 


(define-public (func)
    (let
        ((a (list (a1) (a1))))
        (ok a)
    )
)
```
