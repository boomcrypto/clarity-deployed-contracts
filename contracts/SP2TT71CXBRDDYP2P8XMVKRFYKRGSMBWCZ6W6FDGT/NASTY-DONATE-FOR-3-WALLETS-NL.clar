
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u75000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP3G9PTDQ03M7DM10HJXAAJWKFY0GED64690PH2RS none)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u75000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP63SYHXYMCCEHQHXKHW3JN55V8YTPKM04GP329S none)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u75000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP3SNAASXAS98Q3GDJ0PZXYVEC45PP0DED3EE0JE5 none)
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
