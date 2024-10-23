
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP1QBKVTKP2DG8BGHQQD3KG6EBWWCB6V4X5NXQRYR.eth-thcam-stxcity send-many (list {to: 'SP1GM1XMXG4M41DSC87ZS4K80EH06QNEJF2H9VDS8, amount: u10000000000, memo: none} {to: 'SP3A7J0MA1X3RTZ9BGDQ7KR154W0GNA6S5Z448XP9, amount: u10000000000, memo: none} {to: 'SP372RK3G7A7WNYH52AEYQ63B1XPRVPNYWCGHXFX6, amount: u10000000000, memo: none} {to: 'SP20QA1A3M5XSEWVP82QSDEG1V2HERQK5438ESFN3, amount: u10000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
