---
title: "Trait balance-call-example"
draft: true
---
```

;; this example is designed for a specific token, it can be modularized to parse the trait and support any of the pools you have
(define-public (get-user-sbtc-ratio-in-liquidity-pool-x (address principal))
    (let 
        (
            (current-pair (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-pair-data  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2) (err u101)))
            ;; Grabbing all data from PairsDataMap
            (current-balance-x (get balance-x current-pair))
            (current-total-shares (get total-shares current-pair))
            (hodl-balance-x 
                (/ 
                    (* 
                        current-balance-x 
                        ;; TODO: get the user's balance of LP tokens
                        (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2 get-balance address) (err u102))
                    ) 
                current-total-shares
                )
            )
        )
        (ok hodl-balance-x)
  )
)

```
