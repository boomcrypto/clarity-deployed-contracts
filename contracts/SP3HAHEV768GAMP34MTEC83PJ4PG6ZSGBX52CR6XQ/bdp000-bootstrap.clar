;; Title: BDP000 Bootstrap
;; Description:
;; Sets up and configure the BigMarket DAO

(impl-trait  'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.proposal-trait.proposal-trait)

(define-constant token-supply u100000000000000)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .bigmarket-dao set-extensions
			(list
				{extension: .bme000-0-governance-token, enabled: true}
				{extension: .bme001-0-proposal-voting, enabled: true}
				{extension: .bme003-0-core-proposals, enabled: true}
				{extension: .bme006-0-treasury, enabled: true}
				{extension: .bme010-0-liquidity-contribution, enabled: true}
				{extension: .bme021-0-market-voting, enabled: true}
				{extension: .bme022-0-market-gating, enabled: true}
				{extension: .bme024-0-market-scalar-pyth, enabled: true}
				{extension: .bme024-0-market-predicting, enabled: true}
				{extension: .bme030-0-reputation-token, enabled: true}
				{extension: .bme032-0-scalar-strategy-hedge, enabled: true}
			)
		))
		;; Set initial members who are able to make proposals
		(try! (contract-call? .bme003-0-core-proposals set-core-team-member 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ true))
		(try! (contract-call? .bme003-0-core-proposals set-core-team-member 'SPEZD95XQ194X67C1QJW4PHKDG8F5D66ZCT8BY29 true))
		(try! (contract-call? .bme003-0-core-proposals set-core-team-member 'SP2XFH8D1MM2G11C0S6AZRSNP031RAY92XCARPRSQ true))
		(try! (contract-call? .bme003-0-core-proposals set-core-team-member 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z true))

		;; initial market creators
		;; Allowed = ["SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ", "SPEZD95XQ194X67C1QJW4PHKDG8F5D66ZCT8BY29", "SP2XFH8D1MM2G11C0S6AZRSNP031RAY92XCARPRSQ", "SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z", 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9','SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D'];
		(try! (contract-call? .bme022-0-market-gating set-merkle-root-by-principal .bme024-0-market-predicting 0xa268e9042d73cf2939ba07ddbc2972cd1c6dad1ad30125a57b2ee040e60a2ead))
		(try! (contract-call? .bme022-0-market-gating set-merkle-root-by-principal .bme024-0-market-scalar-pyth 0xa268e9042d73cf2939ba07ddbc2972cd1c6dad1ad30125a57b2ee040e60a2ead))
		
		;; Category contract setting
		(try! (contract-call? .bme024-0-market-predicting set-resolution-agent 'SP3NS9010CQ9AK3M6XN3XD9EHNTDZVGYSMFWZ288Z))
		(try! (contract-call? .bme024-0-market-predicting set-dev-fund 'SM38XBR119DCN8D3WTBGWYYXC3K8X0FY0F9TSD8AF))
		(try! (contract-call? .bme024-0-market-predicting set-dao-treasury .bme006-0-treasury))
		(try! (contract-call? .bme024-0-market-predicting set-creation-gated true))
		(try! (contract-call? .bme024-0-market-predicting set-allowed-token .big-play true))
		(try! (contract-call? .bme024-0-market-predicting set-market-fee-bips-max u1000))
		(try! (contract-call? .bme024-0-market-predicting set-token-minimum-seed .big-play u1000000000))

		;; Scalar contract setting
		(try! (contract-call? .bme024-0-market-scalar-pyth set-resolution-agent 'SP3NS9010CQ9AK3M6XN3XD9EHNTDZVGYSMFWZ288Z))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-dev-fund 'SM38XBR119DCN8D3WTBGWYYXC3K8X0FY0F9TSD8AF))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-dao-treasury .bme006-0-treasury))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-creation-gated true))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-allowed-token .big-play true))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-market-fee-bips-max u1000))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-token-minimum-seed .big-play u1000000000))

		;; STXUSD / BTCUSD / SOLUSD / ETHUSD / SUIUSD / TONUSD
		(try! (contract-call? .bme024-0-market-scalar-pyth set-price-band-width 0xec7a775f46379b5e943c3526b1c8d54cd49749176b0b98e02dde68d1bd335c17 u2000))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-price-band-width 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43 u100))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-price-band-width 0xef0d8b6fda2ceba41da15d4095d1da392a0d2f8ed0c6c7bc0f4cfac8c280b56d u500))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-price-band-width 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace u1000))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-price-band-width 0x23d7315113f5b1d3ba7a83604c44b94d79f4fd69af77f804fc7f920a6dc65744 u900))
		(try! (contract-call? .bme024-0-market-scalar-pyth set-price-band-width 0x8963217838ab4cf5cadc172203c1f0b763fbaa45f346d8ee50ba994bbcac3026 u600))

		 ;; premint BIG for reputation and a small amount (100) for initial operations 
		(try! (contract-call? .bme000-0-governance-token bmg-mint-many
			(list
				{amount: (/ (* u1500 token-supply) u10000), recipient: .bme006-0-treasury}
				{amount: u100000000, recipient: 'SP3HAHEV768GAMP34MTEC83PJ4PG6ZSGBX52CR6XQ}
				{amount: u100000000, recipient: 'SPEZD95XQ194X67C1QJW4PHKDG8F5D66ZCT8BY29}
				{amount: u100000000, recipient: 'SP2XFH8D1MM2G11C0S6AZRSNP031RAY92XCARPRSQ}
				{amount: u100000000, recipient: 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z}
				{amount: u100000000, recipient: 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9}
				{amount: u100000000, recipient: 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D}
			)
		))

		(try! (contract-call? .bme030-0-reputation-token set-launch-height))

		;; for simulating deep markets with play token
		(try! (contract-call? .big-play seed-once))

		(print "BigMarket DAO has risen.")
		(ok true)
	)
)
