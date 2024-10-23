
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP45RYP4W83SMSCG5C7MZCM1EFVRJY4K6D0E05Z6.il-donaldo-trumpo send-many (list {to: 'SP1TDCN5VVHVDTVZ3MYN8BXPHX8X6HS4FNR9M31ZC, amount: u1000000, memo: none} {to: 'SP98HPX4GPN68QNCM5RQF81FNTXSV5V50V16RQ4A, amount: u1000000, memo: none} {to: 'SP3HHJ8PARYMZN5CCP40MH1YDHHK8BKSWWDB3SK7C, amount: u1000000, memo: none} {to: 'SP2163R7QNAPYN9F3GB7N12E45TM2S1AA16204XC0, amount: u1000000, memo: none} {to: 'SP3MQ1C57SB0A5BSE0Z1J0F77AAKCG50W6Q67HEVR, amount: u1000000, memo: none} {to: 'SP17008T92D4D79PEKE180RP4QBMWVDJHAKHDA3XS, amount: u1000000, memo: none} {to: 'SPK7NREYJYEVRD2WQ0PT7XM6AXJCV6ZDKQ68JTQP, amount: u1000000, memo: none} {to: 'SP2X1GD24FA3TGGV6T4TRPKT8MVZ8F02RZESYWEH5, amount: u1000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
