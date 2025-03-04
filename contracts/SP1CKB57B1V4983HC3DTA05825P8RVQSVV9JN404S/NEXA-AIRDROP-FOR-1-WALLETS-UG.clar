
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1CKB57B1V4983HC3DTA05825P8RVQSVV9JN404S.nexa-stxcity send-many (list {to: 'SP2B8TACFW07BC0N5N64PJ7J6PBF059AQ4Y78K25Q, amount: u6000000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
