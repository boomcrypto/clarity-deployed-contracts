
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u25000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R none)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u25000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP24GGMA1P2ZSV921SPHNWC8Q2YDCE1MR8QZ79TKS none)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u25000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP2WC112DEJR44WVAX5A2WZ21VCTTVMY000AJKKYT none)
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
