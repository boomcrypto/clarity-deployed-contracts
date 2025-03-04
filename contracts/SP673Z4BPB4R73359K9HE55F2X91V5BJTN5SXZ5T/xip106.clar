;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-token-mismatch (err u1001))
(define-constant err-request-already-revoked (err u10000))
(define-constant err-request-already-finalized (err u10001))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
{ extension: .btc-peg-in-v2-05-launchpad-3b, enabled: false }
{ extension: .cross-peg-in-v2-04-launchpad-3b, enabled: false }
{ extension: .btc-peg-in-v2-05-launchpad-3c, enabled: true }
{ extension: .cross-peg-in-v2-04-launchpad-3c, enabled: true })))
	
(try! (contract-call? .btc-peg-in-v2-05-launchpad-3c set-fee-to-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao))
(try! (contract-call? .btc-peg-in-v2-05-launchpad-3c set-peg-in-fee u0))
(try! (contract-call? .btc-peg-in-v2-05-launchpad-3c set-peg-in-min-fee u0))
(try! (contract-call? .btc-peg-in-v2-05-launchpad-3c pause-peg-in false))

(try! (contract-call? .cross-peg-in-v2-04-launchpad-3a set-paused true))
(try! (contract-call? .cross-peg-in-v2-04-launchpad-3b set-paused true))
(try! (contract-call? .cross-peg-in-v2-04-launchpad-3c set-paused false))

(try! (revoke-request u1166))
(try! (revoke-request u1167))
(try! (revoke-request u1168))
(try! (revoke-request u1169))
(try! (revoke-request u1170))

(ok true)))

(define-private (revoke-request (request-id uint))
	(let (
			(request (try! (contract-call? .meta-bridge-registry-v2-04 get-request-or-fail request-id)))
			(gross-amount (+ (get amount-net request) (get fee request) (get gas-fee request)))
			(updated-request (merge request { revoked: true })))			
			(asserts! (not (get revoked request)) err-request-already-revoked)
			(asserts! (not (get finalized request)) err-request-already-finalized)			
			;; (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc burn-fixed gross-amount 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01))
			;; (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed gross-amount (get requested-by request)))
		(print { action: "revoke-request", request-id: request-id, updated-request: updated-request })
		(contract-call? .meta-bridge-registry-v2-04 set-request request-id updated-request)))
