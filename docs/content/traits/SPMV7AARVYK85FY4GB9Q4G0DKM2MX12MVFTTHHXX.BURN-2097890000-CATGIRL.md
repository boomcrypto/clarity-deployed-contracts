---
title: "Trait BURN-2097890000-CATGIRL"
draft: true
---
```

;;  ---------------------------------------------------------
;; Burn token event - Burn 10% of the total supply | Created on: stx.city/deploy
;; ---------------------------------------------------------
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender recipient))
		(ok true)
	)
)
;; ---------------------------------------------------------
;; Burn
;; ---------------------------------------------------------
(begin
	(try! (send-stx 'SP2PYTA4H455ENBTQ3C1FWC5W5NEJ5CG821FY6G5Z u1000000))
	(contract-call? 'SPMV7AARVYK85FY4GB9Q4G0DKM2MX12MVFTTHHXX.catgirl-meme transfer u2097890000 tx-sender 'SP000000000000000000002Q6VF78 none)
)

```
