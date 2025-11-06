;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant ERR-INVALID-SUPPLY (err u1004))
(define-constant ERR-INVALID-TOKEN (err u1005))

(define-constant snapshot-block u1509640)
(define-constant anchor-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2)

;; Main execute function with chunked processing
(define-public (execute (sender principal))
  (begin
(try! (process-burnt-liquidity { pool-id: u129, amount: u732680016821729588451, token-x-trait: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2, token-y-trait: 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wkapt }))

    (ok true)))

(define-private (process-burnt-liquidity (details (tuple (pool-id uint) (amount uint) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>))))
	(let (
			(amount (get amount details))
			(pool-id (get pool-id details))
			(snapshot-block-id (unwrap-panic (get-stacks-block-info? id-header-hash snapshot-block)))
			(snapshot-data (at-block snapshot-block-id
				(let (
						(pool-tokens (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id)))
						(pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x pool-tokens) (get token-y pool-tokens) (get factor pool-tokens)))))
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
			(vault-balance-x (unwrap-panic (contract-call? token-x-trait get-balance-fixed 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01)))
			(vault-balance-y (unwrap-panic (contract-call? token-y-trait get-balance-fixed 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01)))
			(updated-token-y-bal (min token-y-bal vault-balance-y))
			(updated-token-x-bal (div-down (mul-down token-x-bal updated-token-y-bal) token-y-bal))
			(current-pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y factor))))
		(asserts! (is-eq (get total-supply current-pool-details) u0) ERR-INVALID-SUPPLY)		
		(asserts! (is-eq token-x anchor-token) ERR-INVALID-TOKEN)		
		(asserts! (is-eq token-x (contract-of token-x-trait)) ERR-INVALID-TOKEN)
		(asserts! (is-eq token-y (contract-of token-y-trait)) ERR-INVALID-TOKEN)
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 transfer-ft token-y-trait updated-token-y-bal tx-sender))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 update-pool token-x token-y factor (merge current-pool-details { pool-owner: tx-sender, start-block: u0 })))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 add-to-position token-x-trait token-y-trait factor updated-token-x-bal (some updated-token-y-bal)))		
		(ok true)))

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (min (a uint) (b uint))
  (if (< a b) a b))
