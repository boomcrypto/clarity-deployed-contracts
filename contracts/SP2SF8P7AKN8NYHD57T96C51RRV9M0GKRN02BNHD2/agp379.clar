;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant recipient 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV)
(define-constant token-id u38)
(define-constant supply u6432550133736461798475)
(define-constant cycles (list u208 u209 u210 u211 u212 u213 u214 u215 u216 u217 u218 u219 u220 u221 u222 u223 u224 u225 u226 u227 u228 u229 u230 u231 u232))
(define-constant threshold (* u34800 ONE_8))

(define-public (execute (sender principal))
	(let (
			(total-rewards (try! (fold claim-staking-reward-iter cycles (ok u0))))
			(balance (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 get-balance-fixed token-id tx-sender)))
			(positions (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-position-given-burn 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wplay ONE_8 supply)))			
			(excess (if (<= (get dx positions) threshold) u0 (- (get dx positions) threshold))))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 reduce-position 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wplay ONE_8 ONE_8))
(and (> excess u0) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex transfer-fixed excess tx-sender recipient none)))
(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wplay transfer-fixed (+ (get dy positions) total-rewards) tx-sender recipient none))
(print { notification: "agp378", total-rewards: total-rewards, alex: excess, play: (get dy positions) })

(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list { extension: .blocklist, enabled: true } )))
(try! (contract-call? .blocklist approve-updater 'SP1A6F9ABHQMVP92GH7T9ZBF029T1WG3SHPNMKT0D true))
  (ok true)))

(define-private (claim-staking-reward-iter (target-cycle uint) (prev-res (response uint uint)))
	(match prev-res
		ok-value
		(let (
				(details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.dual-farming claim-staking-reward 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 token-id 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wplay target-cycle))))
			(ok (+ ok-value (get entitled-dual details))))
		err-value (err err-value)))

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))
