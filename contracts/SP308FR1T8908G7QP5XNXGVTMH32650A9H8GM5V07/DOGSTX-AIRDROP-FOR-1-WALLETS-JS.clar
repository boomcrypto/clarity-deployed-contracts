
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP308FR1T8908G7QP5XNXGVTMH32650A9H8GM5V07.dog-go-to-the-moon-on-stx-stxcity send-many (list {to: 'SP14EFAF85KE7G42GR9SVEGWXT8XW2VDP3QTPBTKY, amount: u15000000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
