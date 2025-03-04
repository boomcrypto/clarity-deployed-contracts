;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-public (execute (sender principal))
	(begin

(try! (contract-call? .self-listing-helper-v2-04 approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wpomboo true (* u40587174 ONE_8)))
(try! (contract-call? .self-listing-helper-v2-04 approve-token-x .token-wsbtc true u10000))
(try! (contract-call? .self-listing-helper-v2-04 approve-token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc true u10000))
(try! (contract-call? .self-listing-helper-v2-04 approve-token-y .token-wsbtc true))

		(ok true)))

