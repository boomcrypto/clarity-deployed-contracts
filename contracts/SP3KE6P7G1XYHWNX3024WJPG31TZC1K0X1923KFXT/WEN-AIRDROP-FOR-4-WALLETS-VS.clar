
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP25K3XPVBNWXPMYDXBPSZHGC8APW0Z21CWJ3Y3B1.wen-nakamoto-stxcity send-many (list {to: 'SP64S2NKACHC493HFPDGNJSH3C9M1NV9KNAW8VHB, amount: u22222000000, memo: none} {to: 'SP16CCGD1ZCDP5VY4ZHDXKDX46QNEHVZ672F3KGDJ, amount: u22222000000, memo: none} {to: 'SPWWS0CYKWZD24XBQC6M6RE04HTKWY09D60H0XBA, amount: u22222000000, memo: none} {to: 'SP2HKAX6H828H5NWYZR83F417J6WGGC3QKR4Q4T2S, amount: u22222000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
