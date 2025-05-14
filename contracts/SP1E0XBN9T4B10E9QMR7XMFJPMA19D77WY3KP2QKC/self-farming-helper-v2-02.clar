;; SPDX-License-Identifier: BUSL-1.1

;; This contract acts as a helper for self-service farming pool setup.
;; It allows pool owners (or the DAO) to register a pool for dual-farming rewards
;; in a permissionless way, provided they meet certain requirements.

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

;; Error codes for various failure conditions
(define-constant err-not-authorised (err u1000))
(define-constant err-token-not-approved (err u1001))
(define-constant err-total-cycles (err u1002))
(define-constant err-rewards-per-cycle (err u1003))

;; ========== Read-only calls ==========

;; Checks if the sender is the DAO or an approved extension
(define-read-only (is-dao-or-extension)
    (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao)
                      (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller))
                  err-not-authorised)))

;; ========== Public calls ==========

;; Allows a pool owner (or DAO) to request a new dual-farming campaign for their pool.
;; - token-x, token-y: The pool's token pair
;; - factor: The pool's factor (for AMM math)
;; - rewards-token-trait: The reward token contract trait
;; - total-rewards-in-fixed: Total reward tokens to distribute
;; - total-cycles: Over how many cycles to distribute rewards
(define-public (request (token-x principal) (token-y principal) (factor uint) (rewards-token-trait <ft-trait>) (total-rewards-in-fixed uint) (total-cycles uint))
    (let (
        ;; Get pool details from the AMM contract
        (pool-details (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-pool-details token-x token-y factor)))
        ;; Get the current reward cycle from the staking contract
        (current-cycle (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 get-reward-cycle tenure-height)))
        ;; Calculate rewards per cycle
        (rewards-per-cycle (/ total-rewards-in-fixed total-cycles))
        ;; Check if the pool is already registered for dual-farming
        (user-nonce (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming get-registered-users-nonce-or-default 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01 (get pool-id pool-details))))
        ;; Only the pool owner or DAO/extension can call this
        (asserts! (or (is-eq tx-sender (get pool-owner pool-details)) (is-ok (is-dao-or-extension))) err-not-authorised)
        ;; The reward token must be approved in the vault
        (asserts! (< u0 (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-vault-v2-01 get-reserve (contract-of rewards-token-trait))) err-token-not-approved)
        ;; Must have at least one cycle
        (asserts! (< u0 total-cycles) err-total-cycles)
        ;; Must have a positive reward per cycle
        (asserts! (< u0 rewards-per-cycle) err-rewards-per-cycle)
        
        ;; If the pool is not registered, add it to the farming contract
        (and (is-eq user-nonce u0)
             (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming add-token
                                                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01
                                                (get pool-id pool-details)))))
        ;; Set the activation block for the pool in the farming contract
        (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-activation-block
                                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01
                                           (get pool-id pool-details)
                                           u46601)))
        ;; Set the apower multiplier (default 0)
        (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-apower-multiplier-in-fixed
                                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01
                                           (get pool-id pool-details)
                                           u0)))
        ;; Set the coinbase amounts (default values)
        (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-farming set-coinbase-amount
                                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01
                                           (get pool-id pool-details)
                                           u100000000 u100000000 u100000000 u100000000 u100000000)))
        ;; Register the reward token and schedule in the dual-farming contract
        (as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.dual-farming add-token
                                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-amm-pool-v2-01
                                           (get pool-id pool-details)
                                           (contract-of rewards-token-trait)
                                           rewards-per-cycle
                                           (+ current-cycle u1)
                                           (+ current-cycle total-cycles))))
        ;; Transfer the total reward tokens from the sender to the dual-farming contract
        (try! (contract-call? rewards-token-trait transfer-fixed total-rewards-in-fixed tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.dual-farming none))
        ;; Log the request
        (print { notification: "request", payload: { start-cycle: (+ current-cycle u1), end-cycle: (+ current-cycle total-cycles), rewards-per-cycle: rewards-per-cycle } })
        (ok true)))

;; ========== Privileged and Governance calls ==========

;; (none in this contract)

;; ========== Private calls ==========
