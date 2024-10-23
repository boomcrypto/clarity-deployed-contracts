;; Charisma Energy Generator
;;
;; Purpose:
;; This contract implements the core energy generation mechanism of the Charisma protocol.
;; It calculates energy output based on users' token balance history, utilizing integral
;; calculus for accurate and fair representation of token holding over time. The contract
;; incorporates dynamic multipliers to adjust energy generation based on token-specific
;; factors and protocol incentives.
;;
;; Key Features:
;; 1. Balance Integral Calculation: Computes the time-weighted average of token holdings
;;    using the trapezoidal rule approximation of integral calculus.
;; 2. Dynamic Multipliers: Applies quality scores and incentive scores to adjust energy output.
;; 3. Supply Normalization: Accounts for differences in token supplies across various assets.
;; 4. Retroactive Calculation: Allows for fair energy computation without active staking.
;; 5. Security-Enhanced: Users retain full control of their tokens while participating.
;;
;; This contract interacts with:
;; - SIP-010 token contracts for balance checking
;; - Arcana contract for quality scores and circulating supply information
;; - Aura contract for incentive scores
;;
;; The energy generated through this contract can be utilized in various aspects of the
;; Charisma ecosystem, including governance, rewards, GameFi mechanics, and other
;; decentralized applications built on top of the Charisma protocol.

(use-trait sip10-trait .dao-traits-v4.sip010-ft-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_THRESHOLD (err u402))
(define-constant ERR_INVALID_CLIENT (err u403))

;; Data Variables
(define-data-var threshold-5-point uint u10)
(define-data-var threshold-9-point uint u50)

;; (define-constant deploy-block stacks-block-height)
(define-constant deploy-block block-height)

;; Maps
(define-map last-tap-block principal uint)
(define-map enabled-clients principal bool)

;; Authorization controls

;; Check if the caller is the DAO or an authorized extension
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

;; Enable or disable a client contract
(define-public (set-enabled-client (client-contract principal) (enabled bool))
  (begin
    (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
    (ok (map-set enabled-clients client-contract enabled))
  )
)

;; Check if a client contract is enabled
(define-read-only (is-enabled-client (client-contract principal))
  (default-to false (map-get? enabled-clients client-contract))
)

;; Hold-to-Earn functions

;; Get the balance of an address at a specific block
(define-private (get-balance (data { address: principal, block: uint }))
    (let
        (
            (block-hash (unwrap-panic (get-block-info? id-header-hash (get block data))))
        )
        (at-block block-hash (unwrap-panic (contract-call? .charisma-token get-balance (get address data))))
    )
)

;; Generate sample points for balance integral calculation
(define-read-only (generate-sample-points-9 (address principal) (start-block uint) (end-block uint))
    (let
        (
            (block-step (/ (- end-block start-block) u8))
        )
        (list
            { address: address, block: start-block }
            { address: address, block: (+ start-block block-step) }
            { address: address, block: (+ start-block (* block-step u2)) }
            { address: address, block: (+ start-block (* block-step u3)) }
            { address: address, block: (+ start-block (* block-step u4)) }
            { address: address, block: (+ start-block (* block-step u5)) }
            { address: address, block: (+ start-block (* block-step u6)) }
            { address: address, block: (+ start-block (* block-step u7)) }
            { address: address, block: end-block }
        )
    )
)

;; Calculate areas for the trapezoidal rule in balance integral
(define-private (calculate-trapezoid-areas-9 (balances (list 9 uint)) (dx uint))
    (list
        (/ (* (+ (unwrap-panic (element-at balances u0)) (unwrap-panic (element-at balances u1))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u1)) (unwrap-panic (element-at balances u2))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u2)) (unwrap-panic (element-at balances u3))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u3)) (unwrap-panic (element-at balances u4))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u4)) (unwrap-panic (element-at balances u5))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u5)) (unwrap-panic (element-at balances u6))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u6)) (unwrap-panic (element-at balances u7))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u7)) (unwrap-panic (element-at balances u8))) dx) u2)
    )
)

;; Calculate the balance integral for a given address and block range
(define-private (calculate-balance-integral-9 (address principal) (start-block uint) (end-block uint))
    (let
        (
            (sample-points (generate-sample-points-9 address start-block end-block))
            (balances (map get-balance sample-points))
            (dx (/ (- end-block start-block) u8))
            (areas (calculate-trapezoid-areas-9 balances dx))
        )
        (fold + areas u0)
    )
)

;; Generate sample points for balance integral calculation
(define-read-only (generate-sample-points-5 (address principal) (start-block uint) (end-block uint))
    (let
        (
            (block-step (/ (- end-block start-block) u4))
        )
        (list
            { address: address, block: start-block }
            { address: address, block: (+ start-block block-step) }
            { address: address, block: (+ start-block (* block-step u2)) }
            { address: address, block: (+ start-block (* block-step u3)) }
            { address: address, block: end-block }
        )
    )
)

;; Calculate areas for the trapezoidal rule in balance integral
(define-private (calculate-trapezoid-areas-5 (balances (list 5 uint)) (dx uint))
    (list
        (/ (* (+ (unwrap-panic (element-at balances u0)) (unwrap-panic (element-at balances u1))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u1)) (unwrap-panic (element-at balances u2))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u2)) (unwrap-panic (element-at balances u3))) dx) u2)
        (/ (* (+ (unwrap-panic (element-at balances u3)) (unwrap-panic (element-at balances u4))) dx) u2)
    )
)

;; Calculate the balance integral for a given address and block range
(define-private (calculate-balance-integral-5 (address principal) (start-block uint) (end-block uint))
    (let
        (
            (sample-points (generate-sample-points-5 address start-block end-block))
            (balances (map get-balance sample-points))
            (dx (/ (- end-block start-block) u4))
            (areas (calculate-trapezoid-areas-5 balances dx))
        )
        (fold + areas u0)
    )
)

;; Generate sample points for balance integral calculation
(define-read-only (generate-sample-points-2 (address principal) (start-block uint) (end-block uint))
    (let
        (
            (block-step (/ (- end-block start-block) u1))
        )
        (list
            { address: address, block: start-block }
            { address: address, block: end-block }
        )
    )
)

;; Calculate areas for the trapezoidal rule in balance integral
(define-private (calculate-trapezoid-areas-2 (balances (list 2 uint)) (dx uint))
    (list
        (/ (* (+ (unwrap-panic (element-at balances u0)) (unwrap-panic (element-at balances u1))) dx) u2)
    )
)

;; Calculate the balance integral for a given address and block range
(define-private (calculate-balance-integral-2 (address principal) (start-block uint) (end-block uint))
    (let
        (
            (sample-points (generate-sample-points-2 address start-block end-block))
            (balances (map get-balance sample-points))
            (dx (/ (- end-block start-block) u1))
            (areas (calculate-trapezoid-areas-2 balances dx))
        )
        (fold + areas u0)
    )
)

;; Get the last block where a user tapped for energy
(define-read-only (get-last-tap-block (address principal))
    ;; (default-to deploy-block (map-get? last-tap-block address))
    (default-to deploy-block (map-get? last-tap-block address))
)

;; Select the appropriate balance integral calculation method based on block range
(define-private (calculate-balance-integral (address principal) (start-block uint) (end-block uint))
    (let
        (
            (block-difference (- end-block start-block))
            (threshold-5 (var-get threshold-5-point))
            (threshold-9 (var-get threshold-9-point))
        )
        (if (>= block-difference threshold-9)
            (calculate-balance-integral-9 address start-block end-block)
            (if (>= block-difference threshold-5)
                (calculate-balance-integral-5 address start-block end-block)
                (calculate-balance-integral-2 address start-block end-block)
            )
        )
    )
)

;; Main function to calculate and claim energy
(define-public (tap)
  (let
    (
    ;;   (end-block stacks-block-height)
      (end-block block-height)
      (start-block (get-last-tap-block tx-sender))
      (balance-integral (calculate-balance-integral tx-sender start-block end-block))
      (quality-score (contract-call? .arcana get-quality-score .charisma-token))
      (incentive-score (contract-call? .aura get-incentive-score .charisma-token))
      (circulating-supply (contract-call? .arcana get-circulating-supply .charisma-token))
      (energy-output (/ (* (* balance-integral quality-score) incentive-score) circulating-supply))
    )
    (asserts! (is-enabled-client contract-caller) ERR_INVALID_CLIENT)
    (map-set last-tap-block tx-sender end-block)
    (ok energy-output)
  )
)

;; Functions to update thresholds

(define-public (set-threshold-5-point (new-threshold uint))
  (begin
    (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
    (asserts! (< new-threshold (var-get threshold-9-point)) ERR_INVALID_THRESHOLD)
    (ok (var-set threshold-5-point new-threshold))
  )
)

(define-public (set-threshold-9-point (new-threshold uint))
  (begin
    (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED)
    (asserts! (> new-threshold (var-get threshold-5-point)) ERR_INVALID_THRESHOLD)
    (ok (var-set threshold-9-point new-threshold))
  )
)

;; Read-only functions to get current thresholds

(define-read-only (get-threshold-5-point)
  (ok (var-get threshold-5-point))
)

(define-read-only (get-threshold-9-point)
  (ok (var-get threshold-9-point))
)