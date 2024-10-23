
;;  ---------------------------------------------------------
;; Burn token event
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
	(contract-call? 'SP1KRCZRTQ8GE6VDVD7WQEG230V710M00ANH5R5D1.pepe-the-king-prawn transfer u99900000 tx-sender 'SP000000000000000000002Q6VF78 none)
)
