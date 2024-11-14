---
title: "Trait powered-swap-v0"
draft: true
---
```
;; Powered Swap
;;
;; This contract provides energy consequences for token swaps 
;; through a system of encouraged and discouraged pairs.
;;
;; When users swap tokens:
;; - Allowed pairs grant energy tokens (minimum 1)
;; - Disallowed or unknown pairs consume energy tokens (minimum 1)
;; - All energy amounts scale linearly with swap size
;;
;; Key Features:
;; 1. Energy Scaling:
;;    - Base amount: Token's total supply
;;    - All energy costs/rewards scale proportionally 
;;    - Minimum impact of 1 energy (never 0)
;;    - Example: 0.01% of supply trade = 0.0001x energy impact (minimum 1)
;;
;; 2. Pair Configuration:
;;    - Each token pair can be enabled/disabled
;;    - Custom energy factor per pair
;;    - Defaults:
;;      * STX->CHA: Rewards 0.000001 energy per total-supply ratio
;;      * CHA->STX: Costs 10 energy per total-supply ratio
;;      * All others: Cost 0.000001 energy per total-supply ratio
;;
;; 3. Security:
;;    - Owner controls pair configuration 
;;    - Only verified interactions can execute swaps
;;    - Rulebook integration for energy/auth
;;
;; Example Usage:
;; STX->CHA (default configuration):
;; - 1% of supply trade = 1 energy reward
;; - 0.001% of supply trade = 1 energy reward (minimum)
;; - 10% of supply trade = 10 energy reward
;;
;; Integration Points:
;; - Rulebook (.charisma-traits-v0.rulebook-trait)
;;   * Authorization
;;   * Energy operations
;;   * Interaction verification
;; - UniV2 (.univ2-path2)
;;   * Token swaps
;;   * Fee distribution
;; - Token Contracts
;;   * Total supply lookups
;;   * Dynamic base amount calculation

;; Traits
(use-trait rulebook-trait .charisma-traits-v0.rulebook-trait)
(use-trait ft-trait .dao-traits-v4.sip010-ft-trait)
(use-trait share-fee-to-trait .dao-traits-v4.share-fee-to-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INSUFFICIENT_ENERGY (err u402))
(define-constant ERR_UNVERIFIED (err u403))
(define-constant BASE_ENERGY_COST u1) ;; 0.000001 energy per supply ratio
(define-constant BASE_ENERGY_BOOST u1) ;; 0.000001 energy per supply ratio

;; Token Pair Configuration
(define-map allowed-pairs 
    {token-in: principal, token-out: principal} 
    {factor: uint, enabled: bool})

;; Initialize default pairs
(map-set allowed-pairs 
    {token-in: .wstx, token-out: .charisma-token} 
    {factor: u10000000, enabled: true})
(map-set allowed-pairs 
    {token-in: .charisma-token, token-out: .wstx} 
    {factor: u10000000, enabled: false})

;; Helper Functions

;; Ensure minimum of 10 energy
(define-private (min-energy (amount uint))
    (if (> amount u0) amount u1000000))

;; Get token's total supply
(define-private (get-total-supply (token <ft-trait>))
    (contract-call? token get-total-supply))

;; Calculate scaled energy based on amount and token supply
(define-private (scale-energy (factor uint) (amount uint) (token <ft-trait>))
    (match (get-total-supply token)
        supply (min-energy (/ (* factor amount) supply))
        error u1000000)) ;; Fallback to minimum if supply lookup fails

;; Admin Functions

;; Configure allowed token pair with energy boost
(define-public (configure-pair 
    (rulebook <rulebook-trait>)
    (token-in principal)
    (token-out principal)
    (energy-boost uint)
    (enabled bool))
  (begin
    (unwrap! (contract-call? rulebook is-owner tx-sender) ERR_UNAUTHORIZED)
    (ok (map-set allowed-pairs 
        {token-in: token-in, token-out: token-out}
        {factor: energy-boost, enabled: enabled}))))

;; Public Functions

;; Main swap function with energy mechanics
(define-public (do-token-swap
    (rulebook <rulebook-trait>)
    (amount uint)
    (token-in <ft-trait>)
    (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>))
    (let (
        (pair-config (map-get? allowed-pairs {token-in: (contract-of token-in), token-out: (contract-of token-out)})))
        ;; Verify interaction is authorized
        (unwrap! (contract-call? rulebook is-verified-interaction contract-caller) ERR_UNVERIFIED)
        ;; Try the swap first
        (match (contract-call? .univ2-path2 do-swap 
                amount
                token-in 
                token-out
                share-fee-to)
            success ;; If swap succeeds, handle energy
                (match pair-config
                    config ;; If pair is configured
                        (if (get enabled config)
                            ;; Grant scaled energy boost for allowed pair
                            (match (contract-call? rulebook energize 
                                    (scale-energy (get factor config) amount token-in)
                                    tx-sender)
                                boost-success (ok success)
                                boost-error (ok success)) ;; Still return swap success even if boost fails
                            ;; Exhaust scaled energy for disabled pair
                            (match (contract-call? rulebook exhaust 
                                    (scale-energy (get factor config) amount token-in)
                                    tx-sender)
                                exhaust-success (ok success)
                                exhaust-error ERR_INSUFFICIENT_ENERGY))
                    ;; Exhaust scaled energy for unconfigured pair
                    (match (contract-call? rulebook exhaust 
                            (scale-energy BASE_ENERGY_COST amount token-in)
                            tx-sender)
                        exhaust-success (ok success)
                        exhaust-error ERR_INSUFFICIENT_ENERGY))
            error (err error)))) ;; If swap fails, return the error

;; Read Functions

;; Get configuration for a token pair
(define-read-only (get-pair-config (token-in principal) (token-out principal))
    (ok (map-get? allowed-pairs {token-in: token-in, token-out: token-out})))

;; Get base energy config
(define-read-only (get-energy-config)
    (ok {
        base-energy-cost: BASE_ENERGY_COST,
        base-energy-boost: BASE_ENERGY_BOOST
    }))
```
