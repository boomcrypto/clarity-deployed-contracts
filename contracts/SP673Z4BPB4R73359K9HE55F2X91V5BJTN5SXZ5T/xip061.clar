;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-token-mismatch (err u1001))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
    (try! (contract-call? .cross-router-v2-03 add-wrapped .token-wbtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc))
    (try! (contract-call? .cross-router-v2-03 add-wrapped .token-usdt 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt))
(ok true)))
