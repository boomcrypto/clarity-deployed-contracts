
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SM3KNVZS30WM7F89SXKVVFY4SN9RMPZZ9FX929N0V.public-pools-strategy-manager-v2 set-authorised-manager 'SP3TJ5YF08D4FSHM9ZYBBG3X76PW9257YE9SPFWA1 true))
		(ok true)
	)
)
