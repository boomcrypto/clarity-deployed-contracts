;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-constant abtc-locked-1 u730000000)
(define-constant abtc-burnt-1 u600000000)
(define-constant abtc-burnt-2 u3465082482)
(define-constant ausd-locked-1 u101698200000000)
(define-constant ausd-burnt-1 u58032697784601)

(define-public (execute (sender principal))
	(begin
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc mint-fixed (+ abtc-locked-1 abtc-burnt-1 abtc-burnt-2) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt mint-fixed (+ ausd-locked-1 ausd-burnt-1) 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01))
			(ok true)))
