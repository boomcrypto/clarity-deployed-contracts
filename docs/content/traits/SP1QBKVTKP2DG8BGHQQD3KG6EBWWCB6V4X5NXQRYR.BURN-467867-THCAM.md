---
title: "Trait BURN-467867-THCAM"
draft: true
---
```

;;  ---------------------------------------------------------
;; Celebrating the historic moments of Bitcoin and stx.
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
	(contract-call? 'SP1QBKVTKP2DG8BGHQQD3KG6EBWWCB6V4X5NXQRYR.eth-thcam-stxcity transfer u467867000000 tx-sender 'SP000000000000000000002Q6VF78 none)
)

```
