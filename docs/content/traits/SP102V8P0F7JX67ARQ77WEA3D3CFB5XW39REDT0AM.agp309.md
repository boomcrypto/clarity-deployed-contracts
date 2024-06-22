---
title: "Trait agp309"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(begin
   (try! (contract-call? .alex-farming add-token .token-amm-pool-v2-01 u13))
   (try! (contract-call? .alex-farming set-activation-block .token-amm-pool-v2-01 u13 u46601))
   (try! (contract-call? .alex-farming set-apower-multiplier-in-fixed .token-amm-pool-v2-01 u13 u30000000))
   (try! (contract-call? .alex-farming set-coinbase-amount .token-amm-pool-v2-01 u13 u28380000000000 u28380000000000 u28380000000000 u14190000000000 u7095000000000))
   (try! (contract-call? .alex-farming add-token .token-amm-pool-v2-01 u19))
   (try! (contract-call? .alex-farming set-activation-block .token-amm-pool-v2-01 u19 u46601))
   (try! (contract-call? .alex-farming set-apower-multiplier-in-fixed .token-amm-pool-v2-01 u19 u30000000))
   (try! (contract-call? .alex-farming set-coinbase-amount .token-amm-pool-v2-01 u19 u2500000000000 u2500000000000 u2500000000000 u1250000000000 u625000000000))
   (try! (contract-call? .alex-farming add-token .token-amm-pool-v2-01 u21))
   (try! (contract-call? .alex-farming set-activation-block .token-amm-pool-v2-01 u21 u46601))
   (try! (contract-call? .alex-farming set-apower-multiplier-in-fixed .token-amm-pool-v2-01 u21 u30000000))
   (try! (contract-call? .alex-farming set-coinbase-amount .token-amm-pool-v2-01 u21 u250000000000 u250000000000 u250000000000 u125000000000 u62500000000))
(ok true)))
```
