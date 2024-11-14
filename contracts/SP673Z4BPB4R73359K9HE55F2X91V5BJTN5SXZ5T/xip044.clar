;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
   (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
      { extension: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-in-endpoint-v2-01, enabled: false }
      { extension: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-in-endpoint-v2-02, enabled: false }	 	 
      { extension: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-peg-in-endpoint-v2-01, enabled: false }
      { extension: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-peg-in-endpoint-v2-02, enabled: false }			
      ;; { extension: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01, enabled: false }			
	 		{ extension: .btc-peg-in-endpoint-v2-03, enabled: false }
      { extension: .btc-peg-in-endpoint-v2-04, enabled: true }
      { extension: .meta-peg-in-endpoint-v2-02, enabled: false })))

		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-in-endpoint-v2-01 pause-peg-in true))
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-in-endpoint-v2-02 pause-peg-in true))		
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-peg-in-endpoint-v2-01 set-paused true))
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-peg-in-endpoint-v2-02 set-paused true))
		;; (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 pause true))
    (try! (contract-call? .btc-peg-in-endpoint-v2-03 pause-peg-in true))
		(try! (contract-call? .btc-peg-in-endpoint-v2-04 pause-peg-in false))
		(try! (contract-call? .meta-peg-in-endpoint-v2-02 pause true))

		(try! (contract-call? .btc-peg-in-endpoint-v2-04 set-peg-in-fee u250000))
		(try! (contract-call? .btc-peg-in-endpoint-v2-04 set-peg-in-min-fee u5000))
(ok true)))
