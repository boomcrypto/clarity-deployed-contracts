
;;  ---------------------------------------------------------
;; Burn Baby Burn
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
	(contract-call? 'SP3YTJRGXXMXDQ1V4T5GTFQC2KJ8G5EMYW93A4Q1G.stacking-turtle-stxcity transfer u3241083000000 tx-sender 'SP000000000000000000002Q6VF78 none)
)
