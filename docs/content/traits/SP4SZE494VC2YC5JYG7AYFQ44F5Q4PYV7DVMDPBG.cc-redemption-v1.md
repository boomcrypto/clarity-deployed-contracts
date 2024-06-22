---
title: "Trait cc-redemption-v1"
draft: true
---
```
;; @contract CityCoins Redemption
;; @version 1
;;

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)
(use-trait direct-helpers-trait .direct-helpers-trait-v1.direct-helpers-trait)
(use-trait staking-trait .staking-trait-v1.staking-trait)
(use-trait commission-trait .commission-trait-v1.commission-trait)

;;-------------------------------------
;; Main 
;;-------------------------------------

(define-public (deposit
  (reserve <reserve-trait>) 
  (commission <commission-trait>) 
  (staking <staking-trait>) 
  (direct-helpers <direct-helpers-trait>)
  (referrer (optional principal)) 
  (pool (optional principal))
) 
  (let (
    ;; TODO: update for mainnet
    (redemption-stx (unwrap-panic (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd012-redemption-nyc redeem-nyc))))
  )
    (contract-call? .stacking-dao-core-v2 deposit reserve commission staking direct-helpers redemption-stx referrer pool)
  )
)

```
