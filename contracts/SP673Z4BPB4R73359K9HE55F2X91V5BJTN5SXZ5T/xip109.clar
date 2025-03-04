
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
			{ extension: .cross-peg-out-v2-01-agg, enabled: false }
			{ extension: .btc-peg-in-v2-07a-agg, enabled: false }		
			{ extension: .cross-peg-out-v2-01a-agg, enabled: true }
			{ extension: .btc-peg-in-v2-07b-agg, enabled: true }
		)))
		(try! (contract-call? .cross-peg-out-v2-01-agg set-paused true))
		(try! (contract-call? .btc-peg-in-v2-07a-agg pause-peg-in true))
		(try! (contract-call? .cross-peg-out-v2-01a-agg set-paused false))
		(try! (contract-call? .btc-peg-in-v2-07b-agg pause-peg-in false))		
		(ok true)
	)
)
