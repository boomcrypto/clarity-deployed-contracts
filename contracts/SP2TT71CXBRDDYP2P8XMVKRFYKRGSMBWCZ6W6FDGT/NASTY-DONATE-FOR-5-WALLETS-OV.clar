
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u10000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP2V8AFRXRFYQE1B04QREA21JJ2HGJRJZ1H93GB6B none)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u10000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP3T3W1AYBEYEAK86K382XZ9SS6923E0A6HCW782T none)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u10000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP2PDKPKD0385W4K47YD4AJP7P10B9WHWJ8BB5QK0 none)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u10000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SPJ7EMRY9Z7M4Y4P4VSW8H8CK16MXQC47G6JFKJK none)
(contract-call? 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT.notastrategy transfer u10000000000000 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT 'SP3H9SMKBR3872Q8HVHFYXEM5CXT2ZCNZ0RCHFFJ3 none)
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
