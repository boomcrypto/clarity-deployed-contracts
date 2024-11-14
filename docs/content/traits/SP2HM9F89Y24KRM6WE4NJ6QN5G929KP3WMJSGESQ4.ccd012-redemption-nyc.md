---
title: "Trait ccd012-redemption-nyc"
draft: true
---
```
(define-constant owner tx-sender)

(define-constant D8 u100000000) 

(define-public (a1 (in uint))  
    (begin 
        (asserts! (is-eq tx-sender owner) (err u444))
        (let
            (
                (aa (stx-get-balance tx-sender))
                (b1 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnyc D8 in none)))
                (b2 (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd012-redemption-nyc redeem-nyc)))
                (ab (stx-get-balance tx-sender)))

            (asserts! (>= ab aa) (err (- aa ab)))
            (print { start: aa, finish: ab })

            (ok (- ab aa))
        )
    )
) 


(define-public (redeem-nyc (amount uint))
    (let
        ((a (list (a1 amount) (a1 amount))))
        (ok a)
    )
)
```
