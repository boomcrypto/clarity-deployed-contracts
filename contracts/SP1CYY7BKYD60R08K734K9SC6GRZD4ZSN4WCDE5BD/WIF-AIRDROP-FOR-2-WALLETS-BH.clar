
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1CYY7BKYD60R08K734K9SC6GRZD4ZSN4WCDE5BD.dog-wif-hat send-many (list {to: 'SPA0SZQ6KCCYMJV5XVKSNM7Y1DGDXH39A11ZX2Y8, amount: u1000000, memo: none} {to: 'SP3TMGZ7WTT658PA632A3BA4B1GRXBNNEN8XPZQ5X, amount: u1000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
