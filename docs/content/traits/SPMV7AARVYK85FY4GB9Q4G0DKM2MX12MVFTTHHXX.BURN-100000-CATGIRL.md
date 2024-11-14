---
title: "Trait BURN-100000-CATGIRL"
draft: true
---
```

;;  ---------------------------------------------------------
;; The first burn of token - 2 % of the total supply | created by stx.city
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
	(contract-call? 'SPMV7AARVYK85FY4GB9Q4G0DKM2MX12MVFTTHHXX.catgirl-meme transfer u100000 tx-sender 'SP000000000000000000002Q6VF78 none)
)

```
