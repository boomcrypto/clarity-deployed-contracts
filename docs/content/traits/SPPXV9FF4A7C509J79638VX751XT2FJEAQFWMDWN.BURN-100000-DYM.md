---
title: "Trait BURN-100000-DYM"
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
	(contract-call? 'SPPXV9FF4A7C509J79638VX751XT2FJEAQFWMDWN.dynamic-stxcity transfer u100000000000 tx-sender 'SP000000000000000000002Q6VF78 none)
)

```
