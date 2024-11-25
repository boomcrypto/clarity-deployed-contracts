;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ERR-INVALID-TOTAL-SUPPLY (err u1000))

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant nasty-pool-id u98)
(define-constant holders (list 
  'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v2-03))
(define-constant factor (pow ONE_8 u2)) ;;1e16

(define-constant locked-id (list u98 u89 u101 u86))

(define-constant locked-liquidity (list 
	{ owner: 'SP1K8Y1JDM3MX9HNBS4MGYERRZSADVMZWASAPHPK3, pool-id: u89, amount: u1712000000000000000, end-burn-block: u896366 }
	{ owner: 'SP2360CKXRD856PFJH4KRGJ5WJARM1ES5KASN2Y89, pool-id: u101, amount: u28909778400000000000, end-burn-block: u896850 }
	{ owner: 'SPX7Z21BD3HR8VXQE6NS38KX6PY7V184KDVVYMZW, pool-id: u86, amount: u18000000000000000000, end-burn-block: u895563 }
	{ owner: 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT, pool-id: u98, amount: u937500000000, end-burn-block: u896707 }))

(define-constant burnt-liquidity (list 
	{ pool-id: u83, burnt-liquidity: u2040000000000000000000 }
	{ pool-id: u87, burnt-liquidity: u6591579831158855764 }
	{ pool-id: u93, burnt-liquidity: u26133867615531523318 }
	{ pool-id: u99, burnt-liquidity: u177479511232 }))

(define-private (sum-balance-fixed (holder principal) (acc uint))
		(+ acc (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance-fixed nasty-pool-id holder))))

(define-private (burn-balance-fixed (holder principal) (acc uint))
	(let (
			(balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance-fixed nasty-pool-id holder)))
			(new-balance (/ balance factor))
			(burn-balance (- balance new-balance)))
		(and (> burn-balance u0) (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 burn-fixed nasty-pool-id burn-balance holder)))
		(+ acc new-balance)))

(define-private (transfer-liquidity (pool-id uint))
	(let (
			(balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance-fixed pool-id 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v2-03))))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 burn-fixed pool-id balance 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.self-listing-helper-v2-03))
		(contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 mint-fixed pool-id balance .liquidity-locker)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-public (execute (sender principal))
	(let (
			(total-balance (fold sum-balance-fixed holders u0))
			(total-supply (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-total-supply-fixed nasty-pool-id)))
			(pool-id-map (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id nasty-pool-id)))
			(pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details (get token-x pool-id-map) (get token-y pool-id-map) (get factor pool-id-map))))
			(new-total-balance (fold burn-balance-fixed holders u0))
			(new-total-supply (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-total-supply-fixed nasty-pool-id))))
		(asserts! (is-eq total-balance total-supply) ERR-INVALID-TOTAL-SUPPLY)
		(asserts! (is-eq total-balance (get total-supply pool-details)) ERR-INVALID-TOTAL-SUPPLY)
		(asserts! (is-eq new-total-balance new-total-supply) ERR-INVALID-TOTAL-SUPPLY)
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 update-pool (get token-x pool-id-map) (get token-y pool-id-map) (get factor pool-id-map) (merge pool-details { total-supply: new-total-supply })))
		
		(try! (fold check-err (map transfer-liquidity locked-id) (ok true)))
		(try! (contract-call? .liquidity-locker set-locked-liquidity locked-liquidity))
		(try! (contract-call? .liquidity-locker set-burnt-liquidity burnt-liquidity))

		(try! (contract-call? .self-listing-helper-v2-03 reject-request u17 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex (some (unwrap-panic (to-consensus-buff? "please resubmit your request")))))

		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list 
			{ extension: 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.self-listing-helper-v2-01, enabled: false }
			{ extension: .self-listing-helper-v2-03, enabled: false }
			{ extension: .self-listing-helper-v2-04, enabled: true })))
		(try! (contract-call? .self-listing-helper-v2-04 approve-token-x 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc true u1000000))
		(try! (contract-call? .self-listing-helper-v2-04 approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex true u1000000000000))
		(try! (contract-call? .self-listing-helper-v2-04 approve-token-x 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 true u180000000000))		

		(ok true)))

