
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u18375880000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP3QZ9VDXBC7KXC7CSTT97TE201JNH189JFGH6YD7 none)
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
