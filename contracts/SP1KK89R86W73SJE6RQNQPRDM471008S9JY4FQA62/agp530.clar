;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-data-var snapshot-block uint u1509640)
(define-data-var btc-rate uint u10273463917525) ;; 102,734.64 
(define-data-var stx-rate uint u67721865) ;; 0.67721865
(define-data-var usd-rate uint u100000000) ;; 1.00
(define-data-var btc-pct uint u25000000) ;; 25%
(define-data-var stx-pct uint u100000000) ;; 100%
(define-data-var usd-pct uint u9000000) ;; 9%

(define-public (execute (sender principal))
	(begin
		(try! (process-expired-balance { address: 'SP349TXSSB54EXQ2MXKTSR967TF68V513BHCRR8V5, cycle: u292, token-x-trait: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, token-y-trait: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlialex, factor: u5000000 }))
		(try! (process-expired-balance { address: 'SP349TXSSB54EXQ2MXKTSR967TF68V513BHCRR8V5, cycle: u292, token-x-trait: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2, token-y-trait: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wlqstx-v3, factor: u5000000 }))
		(ok true)))

(define-private (process-expired-balance (details (tuple (address principal) (cycle uint) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (factor uint))))
	(let (
			(snapshot-block-id (unwrap-panic (get-stacks-block-info? id-header-hash (var-get snapshot-block))))
			(address (get address details))
			(cycle (get cycle details))
			(token-x-trait (get token-x-trait details))
			(token-y-trait (get token-y-trait details))
			(factor (get factor details))			
			(token-x (contract-of token-x-trait))
			(token-y (contract-of token-y-trait))			
			(pool-id (get pool-id (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y factor))))			
			(snapshot-data (at-block snapshot-block-id
				(let (
						(pool-details (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y factor)))
						(total-supply (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-total-supply-fixed pool-id)))
						(user-farm-details 
							(match (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-user-id 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id address)
								some-value
								(contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-staker-at-cycle-or-default 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 pool-id cycle some-value)
								{ amount-staked: u0, to-return: u0 })))
					{ total-lp-balance: (+ (get amount-staked user-farm-details) (get to-return user-farm-details)), total-supply: total-supply, balance-x: (get balance-x pool-details), balance-y: (get balance-y pool-details), token-x: token-x, token-y: token-y })))
		  (expired-balance (merge { cycle: cycle } (calculate-distribution pool-id (get total-lp-balance snapshot-data) (get total-supply snapshot-data) (get balance-x snapshot-data) (get balance-y snapshot-data) (get token-x snapshot-data) (get token-y snapshot-data)))))
		(try! (send-native-balances address (get native-x-bal expired-balance) (get native-y-bal expired-balance) token-x-trait token-y-trait))
		(and (> (get usdc-total-bal expired-balance) u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt transfer-fixed (get usdc-total-bal expired-balance) tx-sender address none)))
		(print (merge expired-balance { address: address, dest: 0x, claimed: true }))
		(ok true)))

(define-private (send-native-balances (address principal) (native-x-bal uint) (native-y-bal uint) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>))
	(begin		
		(and
			(> native-x-bal u0)
			(if (is-eq (contract-of token-x-trait) 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc native-x-bal address))
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft token-x-trait native-x-bal address))))		
		(and
			(> native-y-bal u0)
			(if (is-eq (contract-of token-y-trait) 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc native-y-bal address))
				(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft token-y-trait native-y-bal address))))
	(ok true)))

(define-private (calculate-distribution (pool-id uint) (total-lp-balance uint) (total-supply uint) (balance-x uint) (balance-y uint) (token-x principal) (token-y principal))
	(let (
		(token-x-bal (if (is-eq total-supply u0) u0 (/ (* (/ (* total-lp-balance ONE_8) total-supply) balance-x) ONE_8)))
		(token-y-bal (if (is-eq total-supply u0) u0 (/ (* (/ (* total-lp-balance ONE_8) total-supply) balance-y) ONE_8)))
		(lost-x-bal (if (or (is-eq token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc) (is-eq token-x 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)) (mul-down token-x-bal (var-get btc-pct)) (if (is-eq token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2) (mul-down token-x-bal (var-get stx-pct)) (if (is-eq token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt) (mul-down token-x-bal (var-get usd-pct)) u0))))
		(lost-y-bal (if (or (is-eq token-y 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc) (is-eq token-y 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)) (mul-down token-y-bal (var-get btc-pct)) (if (is-eq token-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2) (mul-down token-y-bal (var-get stx-pct)) (if (is-eq token-y 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt) (mul-down token-y-bal (var-get usd-pct)) u0))))
		(native-x-bal (- token-x-bal lost-x-bal))
		(native-y-bal (- token-y-bal lost-y-bal))
		(usdc-x-bal (if (or (is-eq token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc) (is-eq token-x 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)) (mul-down lost-x-bal (var-get btc-rate)) (if (is-eq token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2) (mul-down lost-x-bal (var-get stx-rate)) (if (is-eq token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt) (mul-down lost-x-bal (var-get usd-rate)) u0))))
		(usdc-y-bal (if (or (is-eq token-y 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc) (is-eq token-y 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc)) (mul-down lost-y-bal (var-get btc-rate)) (if (is-eq token-y 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2) (mul-down lost-y-bal (var-get stx-rate)) (if (is-eq token-y 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt) (mul-down lost-y-bal (var-get usd-rate)) u0)))))
	{ pool-id: pool-id, total-lp-balance: total-lp-balance, token-x-bal: token-x-bal, token-y-bal: token-y-bal, native-x-bal: native-x-bal, native-y-bal: native-y-bal, usdc-x-bal: usdc-x-bal, usdc-y-bal: usdc-y-bal, usdc-total-bal: (+ usdc-x-bal usdc-y-bal) }))

(define-private (mul-down (a uint) (b uint))
	(/ (* a b) ONE_8))
