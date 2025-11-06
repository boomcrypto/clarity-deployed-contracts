;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ERR-INVALID-TOTAL-SUPPLY (err u1000))

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant nasty-pool-id u98)
(define-constant holders (list 
  'SP11M99GX0YGHMBFCA7W4952AHFQTT9XEX33BFQSZ
  'SP2DJ2V487DP7REYSDGA4DWA2TQ38X1X13ZSHZK3C
  'SPN3AV2KQ8HYFHGKC34SGVSS9TNMJXG56GXRSR70))
(define-constant factor (pow ONE_8 u1)) ;;1e8

(define-private (sum-balance-fixed (holder principal) (acc uint))
		(+ acc (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance-fixed nasty-pool-id holder))))

(define-private (burn-balance-fixed (holder principal) (acc uint))
	(let (
			(balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance-fixed nasty-pool-id holder)))
			(new-balance (/ balance factor))
			(burn-balance (- balance new-balance)))
		(print { balance: balance, new-balance: new-balance, burn-balance: burn-balance })
		(and (> burn-balance u0) (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 burn-fixed nasty-pool-id burn-balance holder)))
		(+ acc new-balance)))

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

		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-start-block 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wwsbtc ONE_8 u0))
		(print (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wwsbtc ONE_8)))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-start-block 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnakamoto ONE_8 u0))
		(print (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnakamoto ONE_8)))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 set-start-block 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wall ONE_8 u0))
		(print (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wall ONE_8)))
		(ok true)))

