;; Powered Swap
;;
;; This contract provides energy consequences for token swaps 
;; through a system of encouraged and discouraged pairs.
;;
;; When users swap tokens:
;; - Allowed pairs grant energy tokens (minimum 10)
;; - Disallowed or unknown pairs consume energy tokens (minimum 10)
;; - All energy amounts scale linearly with swap size

;; Traits
(use-trait ft-trait .dao-traits-v4.sip010-ft-trait)
(use-trait share-fee-to-trait .dao-traits-v4.share-fee-to-trait)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INSUFFICIENT_ENERGY (err u402))
(define-constant ERR_UNVERIFIED (err u403))
(define-constant ERR_ALREADY_OWNER (err u404))
(define-constant ERR_NOT_OWNER (err u405))
(define-constant BASE_ENERGY_COST u1) ;; 0.000001 energy per supply ratio
(define-constant BASE_ENERGY_BOOST u1) ;; 0.000001 energy per supply ratio

;; Maps
(define-map contract-owners principal bool)
(define-map allowed-pairs 
    {token-in: principal, token-out: principal} 
    {factor: uint, enabled: bool})

;; Initialize deployer as first owner
(map-set contract-owners DEPLOYER true)

;; Initialize default pairs
(map-set allowed-pairs 
    {token-in: .wstx, token-out: .charisma-token} 
    {factor: u10000000, enabled: true})
(map-set allowed-pairs 
    {token-in: .charisma-token, token-out: .wstx} 
    {factor: u10000000, enabled: false})

;; Owner Management Functions

(define-private (is-owner (caller principal))
    (default-to false (map-get? contract-owners caller)))

;; Add a new owner with authentication
(define-public (add-owner (new-owner principal))
    (begin
        (asserts! (is-owner tx-sender) ERR_UNAUTHORIZED)
        (asserts! (not (is-owner new-owner)) ERR_ALREADY_OWNER)
        (ok (map-set contract-owners new-owner true))))

;; Remove an owner with authentication
(define-public (remove-owner (owner principal))
    (begin
        (asserts! (is-owner tx-sender) ERR_UNAUTHORIZED)
        (asserts! (is-owner owner) ERR_NOT_OWNER)
        (asserts! (not (is-eq owner DEPLOYER)) ERR_UNAUTHORIZED)
        (ok (map-set contract-owners owner false))))

;; Check if an address is an owner
(define-read-only (check-is-owner (address principal))
    (ok (is-owner address)))

;; List all owners (read-only function)
(define-read-only (get-owner-status (address principal))
    (default-to false (map-get? contract-owners address)))

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

;; Configure allowed token pair with energy boost (owner only)
(define-public (configure-pair 
    (token-in principal)
    (token-out principal)
    (energy-boost uint)
    (enabled bool))
    (begin
        (asserts! (is-owner tx-sender) ERR_UNAUTHORIZED)
        (ok (map-set allowed-pairs 
            {token-in: token-in, token-out: token-out}
            {factor: energy-boost, enabled: enabled}))))

;; Remove pair configuration (owner only)
(define-public (remove-pair-config
    (token-in principal)
    (token-out principal))
    (begin
        (asserts! (is-owner tx-sender) ERR_UNAUTHORIZED)
        (ok (map-delete allowed-pairs 
            {token-in: token-in, token-out: token-out}))))

;; Public Functions

;; Main swap function with energy mechanics
(define-public (do-token-swap
    (amount uint)
    (token-in <ft-trait>)
    (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>))
    (let (
        (pair-config (map-get? allowed-pairs {token-in: (contract-of token-in), token-out: (contract-of token-out)})))
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
                            (match (contract-call? .dungeon-keeper-rc6 energize 
                                    (scale-energy (get factor config) amount token-in)
                                    tx-sender)
                                boost-success (ok success)
                                boost-error (ok success)) ;; Still return swap success even if boost fails
                            ;; Exhaust scaled energy for disabled pair
                            (match (contract-call? .dungeon-keeper-rc6 exhaust 
                                    (scale-energy (get factor config) amount token-in)
                                    tx-sender)
                                exhaust-success (ok success)
                                exhaust-error ERR_INSUFFICIENT_ENERGY))
                    ;; Exhaust scaled energy for unconfigured pair
                    (match (contract-call? .dungeon-keeper-rc6 exhaust 
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