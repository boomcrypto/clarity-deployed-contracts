
(define-private (send-stx (recipient principal) (amount uint))
	(begin
		(try! (stx-transfer? amount tx-sender (as-contract recipient)))
		(ok true)
	)
)
(contract-call? 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8.gm-stxcity send-many (list {to: 'SP1DEM9J1FH8GC9VM9VMQ69EX419S6W7BFRAKJ3NP, amount: u10000000000, memo: none} {to: 'SP2ZM0FFZGQ64SX8G287QJEPH2KYF0EZRDJ15PSYC, amount: u10000000000, memo: none} {to: 'SP1H9ZKGH940EH9V5JCHJW1XMH33ASTBTQ35W2NQ, amount: u10000000000, memo: none} {to: 'SP30TN9ZWDW49BSDEQM3SCXSGGF309V61ERZ764J0, amount: u10000000000, memo: none} {to: 'SP280DM0CJ9YS8RZV7SXN11PHZGQPN0F162T65Z7V, amount: u10000000000, memo: none} {to: 'SPG7NZBX51ZH59DWNR0QC4DDQGTVVTENMQRGJ4HT, amount: u10000000000, memo: none} {to: 'SP2Y4W97PRB251QGA1M5ZJZVW861FQ1DS1MXM03FH, amount: u10000000000, memo: none} {to: 'SP3MYBF6D6AT4MHCCY9RJKQDNRAZN18FC8SJVTNMG, amount: u10000000000, memo: none} {to: 'SP1NTTJ1RK90T8A6FQD51ZBTQWX9E55E9XWFEYABX, amount: u10000000000, memo: none} {to: 'SP265GY6CSRQENNMBWQQS0EBB8J1MACNTXZVXSGPP, amount: u10000000000, memo: none} {to: 'SP2MQAA52HTDGNBKH9DKNHW8TBFDJW366GQX7ENDY, amount: u10000000000, memo: none} {to: 'SP25SKSXDBBXDN1HR7151FBH81H6AXF0RKQPHK886, amount: u10000000000, memo: none} {to: 'SP1X0Y1N4D3ZBRYY806Z4FFG5YJE1Q2YXRXA7J39N, amount: u10000000000, memo: none} {to: 'SP389APB4DHZ836P4AE9RJW7EKEZAPV5NPDNG7N46, amount: u10000000000, memo: none} {to: 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75, amount: u10000000000, memo: none} {to: 'SPM2JZ5R7M6AZQTXKEM94K63E2CN95TT6AMMA5PP, amount: u10000000000, memo: none} {to: 'SP10HSK80JRJNB1DQH610KANEQAVSX18229Z7H9DX, amount: u10000000000, memo: none} {to: 'SP3W79C3AK8S0WKEPP2FARXZRJ65WT0E04SX1QQ05, amount: u10000000000, memo: none} {to: 'SPPQHD39H09R19MKA1VBACDFZ8KPVRVVSAZN8A4X, amount: u10000000000, memo: none}))
(begin
	
	(try! (send-stx 'SP1FQ3DQDR5N9HJX3XC5DNKFCG4DHH48EFJQV6QH0 u1000000))
)
