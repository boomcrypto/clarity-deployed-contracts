;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-constant abtc-burn u2499984)
(define-constant ausd-burn u257807697882)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc burn-fixed abtc-burn 'SP1N6SYQHVBMKR62RR8JXCBFFX45EPGXEW8NQJV7E))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt burn-fixed ausd-burn 'SP1N6SYQHVBMKR62RR8JXCBFFX45EPGXEW8NQJV7E))
			(ok true)))
