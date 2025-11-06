;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? .alex-launchpad-v2-03d add-approved-operator 'SP17JDRQ402PC603JJK5YH9N0XRP9RBRGQ91RJHA3))
(try! (contract-call? .alex-launchpad-v2-03d add-approved-operator 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao))	
		(ok true)))

