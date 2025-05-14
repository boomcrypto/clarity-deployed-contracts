---
title: "Trait farming-campaign-v2-01-helper"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant err-not-authorized (err u1000))
(define-constant err-get-block-info (err u1001))
(define-constant err-invalid-campaign-registration (err u1002))
(define-constant err-invalid-campaign-id (err u1003))
(define-constant err-registration-cutoff-passed (err u1004))
(define-constant err-stake-cutoff-passed (err u1005))
(define-constant err-campaign-not-ended (err u1006))
(define-constant err-token-mismatch (err u1007))
(define-constant err-invalid-input (err u1008))
(define-constant err-invalid-reward-token (err u1010))
(define-constant err-already-claimed (err u1011))
(define-constant err-stake-end-passed (err u1005))
(define-constant err-not-registered (err u1013))
(define-constant err-revoke-disabled (err u1014))

(define-constant ONE_8 u100000000)

(define-map campaign-pool-votes { campaign-id: uint, pool-id: uint } uint)
(define-map campaign-total-vote uint uint)

;; read-only calls

(define-read-only (is-dao-or-extension)
    (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) err-not-authorized)))


;; __IF_MAINNET__				
(define-read-only (block-timestamp)
  (ok (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) err-get-block-info)))
;; (define-data-var custom-timestamp (optional uint) none)
;; (define-public (set-custom-timestamp (new-timestamp (optional uint)))
;;     (begin
;;         (try! (is-dao-or-extension))
;;         (var-set custom-timestamp new-timestamp)
;;         (ok true)))
;; (define-read-only (block-timestamp)
;;     (match (var-get custom-timestamp)
;;         timestamp (ok timestamp)
;;         (ok (unwrap! (get-stacks-block-info? time (- stacks-block-height u1)) err-get-block-info))))
;; __ENDIF__

(define-public (unstake (pool-id uint) (campaign-id uint) (reward-token-trait <ft-trait>))
   (let (
			(sender tx-sender)
			(current-timestamp (try! (block-timestamp)))
			(campaign-details (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01 get-campaign-or-fail campaign-id)))
			(campaign-registration-details (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01 get-campaign-registration-by-id-or-fail campaign-id pool-id)))
			(staker-info (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01 get-campaign-staker-or-default campaign-id pool-id sender))
			(staker-stake (get amount staker-info))
			(reward (mul-down (div-down (get reward-amount campaign-registration-details) (get total-staked campaign-registration-details)) staker-stake))
			(pool-votes (default-to u0 (map-get? campaign-pool-votes { campaign-id: campaign-id, pool-id: pool-id })))
			(total-votes (default-to u0 (map-get? campaign-total-vote campaign-id)))
			(total-alex-reward-for-pool (if (is-eq total-votes u0) u0 (mul-down (div-down (get reward-amount campaign-details) total-votes) pool-votes)))
			(alex-reward (mul-down (div-down total-alex-reward-for-pool (get total-staked campaign-registration-details)) staker-stake)))
		(asserts! (< (get stake-end campaign-details) current-timestamp) err-campaign-not-ended)
		(asserts! (is-eq (contract-of reward-token-trait) (get reward-token campaign-registration-details)) err-token-mismatch)
		(asserts! (not (get claimed staker-info)) err-already-claimed)

		(and (> reward u0) (as-contract (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01 transfer-token reward-token-trait reward sender))))
		(and (> alex-reward u0) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex mint-fixed alex-reward sender)))

		(as-contract (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01 update-campaign-stakers campaign-id pool-id sender u0 true)))
		
		(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 burn-fixed pool-id staker-stake 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.farming-campaign-v2-01)))
		(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 mint-fixed pool-id staker-stake sender)))

		(print { notification: "unstake", payload: { sender: tx-sender, campaign-id: campaign-id, pool-id: pool-id, reward: reward, alex-reward: alex-reward, staker-stake: staker-stake }})
		(ok true)))

;; privileged calls
		
(define-public (set-campaign-pool-votes (key { campaign-id: uint, pool-id: uint }) (votes uint))
    (begin
        (try! (is-dao-or-extension))
        (ok (map-set campaign-pool-votes key votes))))

(define-public (set-campaign-total-vote (campaign-id uint) (total uint))
    (begin
        (try! (is-dao-or-extension))
        (ok (map-set campaign-total-vote campaign-id total))))

;; private calls

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (min (a uint) (b uint))
    (if (<= a b) a b))

(define-private (max (a uint) (b uint))
    (if (>= a b) a b))

```
