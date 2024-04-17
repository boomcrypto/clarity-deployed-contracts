
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao set-extensions (list
			{ extension: 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-endpoint, enabled: false }
			{ extension: 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-endpoint-v1-01, enabled: false }
			{ extension: 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-rebase, enabled: false }
			{ extension: 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.rebase-1, enabled: false }
			{ extension: .lqstx-mint-endpoint-v1-02, enabled: true }			
			{ extension: .endpoint-whitelist-helper-v1-02, enabled: true }
		)))

		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx dao-set-name "LiSTX"))
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-lqstx dao-set-symbol "LiSTX"))
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx set-name "vLiSTX"))
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.token-vlqstx set-symbol "vLiSTX"))
		(print { notification: "what-is-LISA", payload: "LISA is the goddess of liquid stacking. Liberate your STX with LiSTX!"})

		;; Enable whitelist
		(try! (contract-call? .lqstx-mint-endpoint-v1-02 set-use-whitelist true))
		(try! (contract-call? .lqstx-mint-endpoint-v1-02 set-whitelisted-many 
			(list 
				'SP3BQ65DRM8DMTYDD5HWMN60EYC0JFS5NC2V5CWW7
				'SP2VZBR9GCVM33BN0WXA05VJP6QV7CJ3Z3SQKJ5HH
				'SP12BFYTH3NJ6N63KE0S50GHSYV0M91NGQND2B704
				'SPGAB1P3YV109E22KXFJYM63GK0G21BYX50CQ80B
				'SPFJVM9Y1A4KJ31T8ZBDESZH36YGPDAZ9WXEFC53
				'SPHFAXDZVFHMY8YR3P9J7ZCV6N89SBET203ZAY25
			)
			(list 
				true
				true
				true
				true
				true
				true
			)))
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-endpoint set-paused true))
		(try! (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lqstx-mint-endpoint-v1-01 set-paused true))
		(try! (contract-call? .lqstx-mint-endpoint-v1-02 set-paused false))		

		(try! (contract-call? .endpoint-whitelist-helper-v1-02 set-authorised-operator 'SP3BQ65DRM8DMTYDD5HWMN60EYC0JFS5NC2V5CWW7 true))		
		(try! (contract-call? .endpoint-whitelist-helper-v1-02 set-authorised-operator 'SP2VZBR9GCVM33BN0WXA05VJP6QV7CJ3Z3SQKJ5HH true))
		(try! (contract-call? .endpoint-whitelist-helper-v1-02 set-authorised-operator 'SP12BFYTH3NJ6N63KE0S50GHSYV0M91NGQND2B704 true))
		(try! (contract-call? .endpoint-whitelist-helper-v1-02 set-authorised-operator 'SPGAB1P3YV109E22KXFJYM63GK0G21BYX50CQ80B true))
		(try! (contract-call? .endpoint-whitelist-helper-v1-02 set-authorised-operator 'SPFJVM9Y1A4KJ31T8ZBDESZH36YGPDAZ9WXEFC53 true))
		(try! (contract-call? .endpoint-whitelist-helper-v1-02 set-authorised-operator 'SPHFAXDZVFHMY8YR3P9J7ZCV6N89SBET203ZAY25 true))

		(ok true)
	)
)
