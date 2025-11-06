;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-constant ERR-MAP-SET-FAILED (err u1002))
(define-constant ERR-VAR-SET-FAILED (err u1003))
(define-constant ERR-INVALID-SUPPLY (err u1004))
(define-constant ERR-INVALID-TOKEN (err u1005))
(define-constant ERR-VAULT-BALANCE (err u1006))

(define-data-var snapshot-block uint u1509640)

(define-map accum-balance principal uint)

;; Main execute function with chunked processing
(define-public (execute (sender principal))
  (begin
(try! (process-burnt-liquidity { pool-id: u43, amount: u41205912528274700000000, token-x-trait: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex, token-y-trait: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo }))

    (ok true)))

(define-private (process-burnt-liquidity (details (tuple (pool-id uint) (amount uint) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>))))
	(let (
			(amount (get amount details))
			(pool-id (get pool-id details))
			(snapshot-block-id (unwrap-panic (get-stacks-block-info? id-header-hash (var-get snapshot-block))))			
			(snapshot-data (at-block snapshot-block-id
				(let (
						(pool-tokens (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id)))
						(pool-details (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x pool-tokens) (get token-y pool-tokens) (get factor pool-tokens)))))
					{ pool-tokens: pool-tokens, pool-details: pool-details })))
			(total-supply (get total-supply (get pool-details snapshot-data)))
			(balance-x (get balance-x (get pool-details snapshot-data)))
			(balance-y (get balance-y (get pool-details snapshot-data)))
			(token-x (get token-x (get pool-tokens snapshot-data)))
			(token-y (get token-y (get pool-tokens snapshot-data)))
			(factor (get factor (get pool-tokens snapshot-data)))
			(token-x-trait (get token-x-trait details))
			(token-y-trait (get token-y-trait details))
			(token-x-bal (if (is-eq total-supply u0) u0 (/ (* (/ (* amount ONE_8) total-supply) balance-x) ONE_8)))
			(token-y-bal (if (is-eq total-supply u0) u0 (/ (* (/ (* amount ONE_8) total-supply) balance-y) ONE_8)))
			(updated-pool-details (merge (get pool-details snapshot-data) { balance-x: token-x-bal, balance-y: token-y-bal, total-supply: amount }))
			(updated-accum-balance-x (+ (default-to u0 (map-get? accum-balance token-x)) token-x-bal))
			(updated-accum-balance-y (+ (default-to u0 (map-get? accum-balance token-y)) token-y-bal))
			(vault-balance-x (unwrap-panic (contract-call? token-x-trait get-balance-fixed 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01)))
			(vault-balance-y (unwrap-panic (contract-call? token-y-trait get-balance-fixed 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01)))
			(current-total-supply (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-total-supply-fixed pool-id))))
		(asserts! (<= updated-accum-balance-x vault-balance-x) ERR-VAULT-BALANCE)
		(asserts! (<= updated-accum-balance-y vault-balance-y) ERR-VAULT-BALANCE)
		(asserts! (is-eq current-total-supply u0) ERR-INVALID-SUPPLY)		
		(asserts! (is-eq token-x (contract-of token-x-trait)) ERR-INVALID-TOKEN)
		(asserts! (is-eq token-y (contract-of token-y-trait)) ERR-INVALID-TOKEN)
		(asserts! (map-set accum-balance token-x updated-accum-balance-x) ERR-VAR-SET-FAILED)
		(asserts! (map-set accum-balance token-y updated-accum-balance-y) ERR-VAR-SET-FAILED)
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 mint-fixed pool-id amount tx-sender))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 update-pool token-x token-y factor updated-pool-details))
		(print { pool-id: pool-id, updated-pool-details: updated-pool-details, ratio-x: (div-down updated-accum-balance-x vault-balance-x), ratio-y: (div-down updated-accum-balance-y vault-balance-y) })
		(ok true)))

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))
