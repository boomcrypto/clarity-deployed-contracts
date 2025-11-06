;; SPDX-License-Identifier: BUSL-1.1
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant MAX_UINT u340282366920938463463374607431768211455)

(define-constant ERR-INVALID-POOL-STATE (err u1001)
)
(define-constant pool-ids (list u13))

;; Main execute function with chunked processing
(define-public (execute (sender principal))
  (begin
(try! (fold reopen-pool-iter pool-ids (ok true)))
    (ok true)))

(define-private (reopen-pool-iter (pool-id uint) (prior (response bool uint)))
	(let (
			(pool-tokens (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id)))
			(pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x pool-tokens) (get token-y pool-tokens) (get factor pool-tokens))))
			(updated-pool-details (merge pool-details { start-block: u0, pool-owner: tx-sender })))
		(asserts! (> (get total-supply pool-details) u0) ERR-INVALID-POOL-STATE)
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 update-pool (get token-x pool-tokens) (get token-y pool-tokens) (get factor pool-tokens) updated-pool-details))
		(print { pool-id: pool-id, pool-tokens: pool-tokens, pool-details: (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details (get token-x pool-tokens) (get token-y pool-tokens) (get factor pool-tokens))) })
		(ok true)))

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))
