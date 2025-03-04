;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant err-request-already-revoked (err u10000))
(define-constant err-request-already-finalized (err u10001))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
			(try! (revoke-request u2394))
			(ok true)))

(define-private (revoke-request (request-id uint))
	(let (
			(request (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 get-request-or-fail request-id)))
			(gross-amount (+ (get amount-net request) (get fee request) (get gas-fee request))))
			(asserts! (not (get revoked request)) err-request-already-revoked)
			(asserts! (not (get finalized request)) err-request-already-finalized)			
			(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc burn-fixed gross-amount 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01))
			(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed gross-amount (get requested-by request)))
		(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-request request-id (merge request { revoked: true }))))
