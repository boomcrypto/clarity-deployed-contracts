;; SPDX-License-Identifier: BUSL-1.1
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

;; error codes
(define-constant err-not-authorized (err u1000))
(define-constant err-get-block-info (err u1001))
(define-constant err-invalid-campaign-registration (err u1002))
(define-constant err-invalid-campaign-id (err u1003))
(define-constant err-campaign-not-ended (err u1006))
(define-constant err-already-distributed (err u1015))
(define-constant err-already-claimed (err u1011))

(define-constant ONE_8 u100000000)

;; storage
(define-map campaign-total-vote uint uint) ;; campaign-id -> total-votes
(define-map campaign-pool-votes-for-alex-reward { campaign-id: uint, pool-id: uint } uint) ;; Tracks total votes per pool for ALEX reward distribution

;; read-only functions
(define-read-only (is-dao-or-extension)
    (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) 
                      (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) 
                  err-not-authorized)))

(define-read-only (block-timestamp)
  (contract-call? .farming-campaign-v2-02 block-timestamp))

(define-public (unstake (pool-id uint) (campaign-id uint))
    (let (
        (sender tx-sender)
        (current-timestamp (try! (block-timestamp)))
        (campaign-details (try! (contract-call? .farming-campaign-v2-02 get-campaign-or-fail campaign-id)))
        (campaign-registration-details (try! (contract-call? .farming-campaign-v2-02 get-campaign-registration-by-id-or-fail campaign-id pool-id)))
        (staker-info (contract-call? .farming-campaign-v2-02 get-campaign-staker-or-default campaign-id pool-id sender))
        (staker-stake (get amount staker-info))
        (pool-votes (default-to u0 (map-get? campaign-pool-votes-for-alex-reward { campaign-id: campaign-id, pool-id: pool-id })))
        (total-votes (default-to u0 (map-get? campaign-total-vote campaign-id)))
        (total-alex-reward-for-pool (if (is-eq total-votes u0) 
                                      u0 
                                      (div-down (mul-down (get reward-amount campaign-details) pool-votes) total-votes)))
        (alex-reward (mul-down (div-down staker-stake (get total-staked campaign-registration-details)) total-alex-reward-for-pool)))
        
        (asserts! (< (get stake-end campaign-details) current-timestamp) err-campaign-not-ended)
        (asserts! (not (get claimed staker-info)) err-already-claimed)
        
        (and (> alex-reward u0) 
             (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex mint-fixed alex-reward sender)))
        
        (as-contract (try! (contract-call? .farming-campaign-v2-02 update-campaign-stakers campaign-id pool-id sender staker-stake true)))
        
        (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 burn-fixed pool-id staker-stake .farming-campaign-v2-02)))
        (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 mint-fixed pool-id staker-stake sender)))
        
        (print { notification: "unstake", 
                 payload: { sender: tx-sender, 
                           campaign-id: campaign-id, 
                           pool-id: pool-id, 
                           alex-reward: alex-reward, 
                           staker-stake: staker-stake }})
        (ok true)))

;; governance functions
(define-public (set-campaign-pool-votes-for-alex-reward (campaign-id uint) (pool-id uint) (votes uint))
    (begin
        (try! (is-dao-or-extension))
        (ok (map-set campaign-pool-votes-for-alex-reward 
            { campaign-id: campaign-id, pool-id: pool-id } 
            votes))
    )
)

(define-public (set-campaign-total-vote (campaign-id uint) (total uint))
    (begin
        (try! (is-dao-or-extension))
        (ok (map-set campaign-total-vote campaign-id total))
    )
)

;; private functions
(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
    (if (is-eq a u0) u0 (/ (* a ONE_8) b)))
