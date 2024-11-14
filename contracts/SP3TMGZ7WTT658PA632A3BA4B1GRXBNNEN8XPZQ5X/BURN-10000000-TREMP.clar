
;;  ---------------------------------------------------------
;; Burn token event | Created on: stx.city/deploy
;; 10,000,000 burn in honor of Nakamoto update
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
	(contract-call? 'SP3TMGZ7WTT658PA632A3BA4B1GRXBNNEN8XPZQ5X.donald-trump transfer u10000000 tx-sender 'SP000000000000000000002Q6VF78 none)
)
