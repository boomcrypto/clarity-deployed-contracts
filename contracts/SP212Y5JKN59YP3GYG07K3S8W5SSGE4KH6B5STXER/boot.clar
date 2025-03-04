;; SPDX-License-Identifier: BUSL-1.1

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .executor-dao set-extensions (list
			{ extension: .operators, enabled: true }
		)))
		
		;; Set initial operators
		(try! (contract-call? .operators set-operators (list
			{ operator: 'SP37YF158E4MHZ6DNT66TXX4SVCKVR5Z5D4JSTXER, enabled: true }
			{ operator: 'SP2N8EM3C6WTZXAR19DPWKV78224EK85HB75Y8M84, enabled: true }
			{ operator: 'SPEJJMSNMD1F74RKVJSGPXJ1839STT5EVY0C64KZ, enabled: true }
			{ operator: 'SP2QJMS7XGHQSYQYBQSGRZ1QJJ0658G45H7PDM1KE, enabled: true }
			{ operator: 'SP3W1AF2V0S2SHA0F3WH3XKXDVVXFHV5WRYPJM1W, enabled: true }
		)))
		;; Set operator signal threshold, i.e. 3-of-5
		(try! (contract-call? .operators set-proposal-threshold 3))
		(ok true)
	)
)