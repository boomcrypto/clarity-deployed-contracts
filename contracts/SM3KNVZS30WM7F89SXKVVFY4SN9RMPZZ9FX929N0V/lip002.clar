
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? .li-stx-mint-nft mint u2 u0 'SP3BQ65DRM8DMTYDD5HWMN60EYC0JFS5NC2V5CWW7))
		(try! (contract-call? .li-stx-mint-nft mint u3 u0 'SP3BQ65DRM8DMTYDD5HWMN60EYC0JFS5NC2V5CWW7))
		(try! (contract-call? .li-stx-mint-nft mint u4 u0 'SPFJVM9Y1A4KJ31T8ZBDESZH36YGPDAZ9WXEFC53))
		(try! (contract-call? .li-stx-mint-nft mint u5 u0 'SP2VZBR9GCVM33BN0WXA05VJP6QV7CJ3Z3SQKJ5HH))
		(ok true)
	)
)
