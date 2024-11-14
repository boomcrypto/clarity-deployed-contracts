---
title: "Trait BURN-925400000-TATE"
draft: true
---
```

;;  ---------------------------------------------------------
;; Burn token event | Created on: stx.city/deploy
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
	(contract-call? 'SP2470N2A31DGDHX541MK2FKJSRHSCW907S5KKYTR.andrew-tate transfer u925400000000000 tx-sender 'SP000000000000000000002Q6VF78 none)
)

```
