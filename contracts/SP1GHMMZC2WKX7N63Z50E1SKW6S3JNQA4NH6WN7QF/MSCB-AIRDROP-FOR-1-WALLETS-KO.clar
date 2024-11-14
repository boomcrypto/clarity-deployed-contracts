
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1GHMMZC2WKX7N63Z50E1SKW6S3JNQA4NH6WN7QF.squirrel-mclub send-many (list {to: 'SP2F4QC563WN0A0949WPH5W1YXVC4M1R46QKE0G14, amount: u8000000000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
