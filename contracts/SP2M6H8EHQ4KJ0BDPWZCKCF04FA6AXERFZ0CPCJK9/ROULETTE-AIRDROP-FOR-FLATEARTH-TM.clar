
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP2M6H8EHQ4KJ0BDPWZCKCF04FA6AXERFZ0CPCJK9.russian-roulette-stxcity send-many (list {to: 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9, amount: u100000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
