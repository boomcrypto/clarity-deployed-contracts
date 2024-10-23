
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP3F27JXPG7FDNBBJTBQQ435WDP28R6PHWVPE3FX3.chewy send-many (list {to: 'SP4WNNT002QZS3CMMZ2GMYB4CVRDNR2G6KW93WGZ, amount: u1000000000000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
