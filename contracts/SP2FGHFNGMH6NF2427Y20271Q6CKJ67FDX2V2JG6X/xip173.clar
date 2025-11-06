;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant err-unauthorised (err u1000))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin			
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
{ extension: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-peg-in-v2-04b-swap, enabled: false }
{ extension: .cross-peg-in-v2-04c-swap, enabled: true })))
(try! (contract-call? 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.cross-peg-in-v2-04b-swap set-paused true))
(try! (contract-call? .cross-peg-in-v2-04c-swap set-paused false))
(ok true)))
