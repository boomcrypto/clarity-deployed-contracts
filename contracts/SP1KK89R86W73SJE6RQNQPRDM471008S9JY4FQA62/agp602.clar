;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant emissions (list 
	{ token-id: u13, amount: (* u141900 ONE_8) }
	{ token-id: u44, amount: (* u103200 ONE_8) }
	{ token-id: u104, amount: (* u283800 ONE_8) }
	{ token-id: u120, amount: (* u103200 ONE_8) }
	{ token-id: u43, amount: (* u10000 ONE_8) }
	{ token-id: u171, amount: (* u10000 ONE_8) }
))
(define-constant pool-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01)
(define-constant activation-block (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-activation-block-or-default pool-token u13))

(define-public (execute (sender principal))
	(begin
		(try! (fold set-farming-iter emissions (ok true)))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list 
		{ extension: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming, enabled: false } 
		{ extension: .alex-farming-v2, enabled: true } 
		)))		

		(ok true)))

(define-private (set-farming-iter (farm { token-id: uint, amount: uint }) (prior (response bool uint)))
	(match prior
		ok-value
		(begin
			(try! (contract-call? .alex-farming-v2 add-token pool-token (get token-id farm)))
			(try! (contract-call? .alex-farming-v2 set-activation-block pool-token (get token-id farm) activation-block))
			(try! (contract-call? .alex-farming-v2 set-coinbase-amount pool-token (get token-id farm) (get amount farm) (get amount farm) (get amount farm) (get amount farm) (/ (get amount farm) u2)))
			(print (merge farm { reward-cycle: (contract-call? .alex-farming-v2 get-reward-cycle pool-token (get token-id farm) tenure-height) }))
			(ok true))
		err-value (err err-value)))


