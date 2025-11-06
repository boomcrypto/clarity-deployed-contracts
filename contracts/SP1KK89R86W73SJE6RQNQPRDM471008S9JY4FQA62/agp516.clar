;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant MAX_UINT u18446744073709551615)
(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant pool-ids (list u154))

(define-public (execute (sender principal))
	(begin
		(map set-start-block-iter pool-ids)
		(ok true)))

(define-private (set-start-block-iter (pool-id uint))
	(let (
			(pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details-by-id pool-id))))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-start-block (get token-x pool-details) (get token-y pool-details) (get factor pool-details) MAX_UINT))
		(print { notification: "set-start-block", payload: { pool-id: pool-id, start-block: MAX_UINT }})
		(ok true)))
