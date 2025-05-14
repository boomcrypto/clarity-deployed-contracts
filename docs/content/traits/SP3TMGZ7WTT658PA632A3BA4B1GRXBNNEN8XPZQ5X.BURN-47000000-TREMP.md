---
title: "Trait BURN-47000000-TREMP"
draft: true
---
```

;;  ---------------------------------------------------------
;; Donald J. Trump, 47th President. Make Stacks Great Again
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
	(contract-call? 'SP3TMGZ7WTT658PA632A3BA4B1GRXBNNEN8XPZQ5X.donald-trump transfer u47000000 tx-sender 'SP000000000000000000002Q6VF78 none)
)

```
