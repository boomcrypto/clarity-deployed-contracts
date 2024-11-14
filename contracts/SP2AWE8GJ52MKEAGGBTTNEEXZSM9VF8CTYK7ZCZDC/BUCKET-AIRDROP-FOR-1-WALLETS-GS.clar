
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP2AWE8GJ52MKEAGGBTTNEEXZSM9VF8CTYK7ZCZDC.bucket-coin-stxcity send-many (list {to: 'SP2EK6MPWJYXM0JE3K19AWCDT0041DFPMJERAPP9Y, amount: u150000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
