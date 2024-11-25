;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant err-pool-balance-mismatch (err u1001))

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant whitelisted (list u7 u10 u11 u12 u16 u17 u18 u22 u23 u24 u25 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u41 u42 u43 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100 u101 u102 u103 u105 u106 u107 u108 u109 u111 u112 u113 u114))

(define-public (execute (sender principal))
	(let (
		(pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt .token-wusdh ONE_8)))
		(pool-id (get pool-id pool-details))
		(pool-owner (get pool-owner pool-details))
		(pool-bal (get amount (contract-call? .liquidity-locker get-locked-liquidity-or-default .self-listing-helper-v2-04 pool-id)))
		(pool-total-bal (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance-fixed pool-id .liquidity-locker))))
		(asserts! (is-eq pool-bal pool-total-bal) err-pool-balance-mismatch)
		(asserts! (is-eq pool-bal (get total-supply pool-details)) err-pool-balance-mismatch)
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 burn-fixed pool-id pool-bal .liquidity-locker))
		(try! (contract-call? .liquidity-locker set-locked-liquidity (list { owner: .self-listing-helper-v2-04, pool-id: pool-id, amount: u0, end-burn-block: u0 })))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 mint-fixed pool-id pool-bal pool-owner))
		(try! (contract-call? .farming-campaign-v1-01 whitelist-pools whitelisted))

		(try! (contract-call? .self-listing-helper-v2-04 approve-request u13 .token-wusdh none))
		(ok true)))

