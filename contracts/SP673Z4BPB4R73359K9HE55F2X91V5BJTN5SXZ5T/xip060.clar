;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-token-mismatch (err u1001))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-constant finalize-list (list 
	{ id: u268, endpoint: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 }
	{ id: u275, endpoint: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 }
	{ id: u556, endpoint: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 }
	{ id: u587, endpoint: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 }
	{ id: u596, endpoint: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 }
	{ id: u595, endpoint: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 }
	{ id: u598, endpoint: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 }
	{ id: u599, endpoint: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 }

	{ id: u605, endpoint: .meta-peg-out-endpoint-v2-03 }
	{ id: u611, endpoint: .meta-peg-out-endpoint-v2-03 }
	{ id: u612, endpoint: .meta-peg-out-endpoint-v2-03 }
))
(define-private (finalize-request (request { id: uint, endpoint: principal }))
	(let (
			(request-details (try! (contract-call? .meta-bridge-registry-v2-03 get-request-or-fail (get id request))))
			(updated-details (merge request-details { finalized: true })))
		(asserts! (is-eq 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog (get token request-details)) err-token-mismatch)
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog burn-fixed (+ (get amount-net request-details) (get fee request-details)) (get endpoint request)))
		(try! (contract-call? .meta-bridge-registry-v2-03 set-request (get id request) updated-details))
		(ok true)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior ok-value result err-value (err err-value)))

(define-public (execute (sender principal))
	(begin

		(try! (fold check-err (map finalize-request finalize-list) (ok true)))

   	(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
      { extension: 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01, enabled: false }			
      { extension: .btc-peg-in-endpoint-v2-04, enabled: false }
			{ extension: .btc-peg-in-endpoint-v2-05, enabled: true }
      { extension: .cross-peg-in-endpoint-v2-03, enabled: false }
			{ extension: .cross-peg-in-endpoint-v2-04, enabled: true }
			)))

		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 pause true))
    (try! (contract-call? .btc-peg-in-endpoint-v2-04 pause-peg-in true))
		(try! (contract-call? .btc-peg-in-endpoint-v2-05 pause-peg-in false))
		(try! (contract-call? .cross-peg-in-endpoint-v2-03 set-paused true))
		(try! (contract-call? .cross-peg-in-endpoint-v2-04 set-paused false))		

		(try! (contract-call? .btc-peg-in-endpoint-v2-05 set-peg-in-fee u250000))
		(try! (contract-call? .btc-peg-in-endpoint-v2-05 set-peg-in-min-fee u5000))

		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 transfer-all-to .meta-peg-out-endpoint-v2-04 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot))
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.meta-bridge-endpoint-v2-01 transfer-all-to .meta-peg-out-endpoint-v2-04 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi))
		(try! (contract-call? .meta-peg-out-endpoint-v2-03 transfer-all-to .meta-peg-out-endpoint-v2-04 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot))
		(try! (contract-call? .meta-peg-out-endpoint-v2-03 transfer-all-to .meta-peg-out-endpoint-v2-04 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.runes-dog))
(ok true)))
