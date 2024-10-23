;; Meme Engine Manager Contract
;;
;; This contract is a core component of the Charisma protocol, designed to coordinate
;; and manage multiple meme engines. It provides centralized control over shared
;; parameters and functionality used by all meme engines in the ecosystem.
;;
;; Key Functions:
;; 1. Threshold Management: Maintains and updates thresholds for balance integral calculations.
;; 2. Sample Point Generation: Provides functions to generate sample points for energy calculations.
;; 3. Client Management: Manages a list of authorized meme engines.
;;
;; Meme Engines in Charisma:
;; Meme engines calculate energy output based on users' token balance history using
;; integral calculus. Each engine typically corresponds to a specific token or asset.
;; This manager ensures consistency and efficiency across all engines by:
;; - Providing centralized calculation parameters (thresholds)
;; - Offering shared sample point generation functionality
;; - Managing authorization of meme engines
;;
;; Key Components:
;; - Thresholds: Determine the number of sample points for balance integral calculations
;; - Sample Point Generation: Functions for 2, 5, 9, 19, and 39-point calculations
;; - Client Management: Authorizes meme engines to interact with the Charisma ecosystem
;;
;; Usage in Charisma:
;; 1. Meme Engine Initialization: New engines are registered with this contract
;; 2. Energy Calculation: Engines call this contract to verify authorization, retrieve
;;    thresholds, and generate sample points
;; 3. Protocol Governance: Allows updates to thresholds and client authorizations
;;
;; Security and Efficiency:
;; - Ensures consistent application of parameters across all meme engines
;; - Reduces gas costs by centralizing parameter storage
;; - Simplifies governance of the meme engine ecosystem
;;
;; This contract is crucial for the scalable and efficient operation of Charisma's
;; energy generation mechanism, providing the necessary infrastructure for managing
;; multiple meme engines within the broader ecosystem.

;; Error codes
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INVALID_THRESHOLD (err u402))

;; Data Variables
(define-data-var threshold-5-point uint u10)
(define-data-var threshold-9-point uint u50)
(define-data-var threshold-19-point uint u500)
(define-data-var threshold-39-point uint u10000)

;; Maps
(define-map enabled-clients principal bool)

;; Authorization control
(define-private (is-authorized)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) 
        (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

;; Functions to manage enabled clients
(define-public (set-enabled-client (client-contract principal) (enabled bool))
  (begin
    (asserts! (is-authorized) ERR_UNAUTHORIZED)
    (ok (map-set enabled-clients client-contract enabled))
  )
)

(define-read-only (is-enabled-client (client-contract principal))
  (default-to false (map-get? enabled-clients client-contract))
)

;; Functions to update thresholds

(define-public (set-threshold-5-point (new-threshold uint))
  (begin
    (asserts! (is-authorized) ERR_UNAUTHORIZED)
    (asserts! (< new-threshold (var-get threshold-9-point)) ERR_INVALID_THRESHOLD)
    (ok (var-set threshold-5-point new-threshold))
  )
)

(define-public (set-threshold-9-point (new-threshold uint))
  (begin
    (asserts! (is-authorized) ERR_UNAUTHORIZED)
    (asserts! (and (> new-threshold (var-get threshold-5-point)) (< new-threshold (var-get threshold-19-point))) ERR_INVALID_THRESHOLD)
    (ok (var-set threshold-9-point new-threshold))
  )
)

(define-public (set-threshold-19-point (new-threshold uint))
  (begin
    (asserts! (is-authorized) ERR_UNAUTHORIZED)
    (asserts! (and (> new-threshold (var-get threshold-9-point)) (< new-threshold (var-get threshold-39-point))) ERR_INVALID_THRESHOLD)
    (ok (var-set threshold-19-point new-threshold))
  )
)

(define-public (set-threshold-39-point (new-threshold uint))
  (begin
    (asserts! (is-authorized) ERR_UNAUTHORIZED)
    (asserts! (> new-threshold (var-get threshold-19-point)) ERR_INVALID_THRESHOLD)
    (ok (var-set threshold-39-point new-threshold))
  )
)

;; Read-only functions to get current thresholds
(define-read-only (get-thresholds)
  (ok {
    threshold-5-point: (var-get threshold-5-point),
    threshold-9-point: (var-get threshold-9-point),
    threshold-19-point: (var-get threshold-19-point),
    threshold-39-point: (var-get threshold-39-point)
  })
)

;; Generate sample points for 39-point balance integral calculation
(define-read-only (generate-sample-points-39 (address principal) (start-block uint) (end-block uint))
    (let
        (
            (block-step (/ (- end-block start-block) u38))
        )
        (list
            { address: address, block: start-block }
            { address: address, block: (+ start-block (* block-step u1)) }
            { address: address, block: (+ start-block (* block-step u2)) }
            { address: address, block: (+ start-block (* block-step u3)) }
            { address: address, block: (+ start-block (* block-step u4)) }
            { address: address, block: (+ start-block (* block-step u5)) }
            { address: address, block: (+ start-block (* block-step u6)) }
            { address: address, block: (+ start-block (* block-step u7)) }
            { address: address, block: (+ start-block (* block-step u8)) }
            { address: address, block: (+ start-block (* block-step u9)) }
            { address: address, block: (+ start-block (* block-step u10)) }
            { address: address, block: (+ start-block (* block-step u11)) }
            { address: address, block: (+ start-block (* block-step u12)) }
            { address: address, block: (+ start-block (* block-step u13)) }
            { address: address, block: (+ start-block (* block-step u14)) }
            { address: address, block: (+ start-block (* block-step u15)) }
            { address: address, block: (+ start-block (* block-step u16)) }
            { address: address, block: (+ start-block (* block-step u17)) }
            { address: address, block: (+ start-block (* block-step u18)) }
            { address: address, block: (+ start-block (* block-step u19)) }
            { address: address, block: (+ start-block (* block-step u20)) }
            { address: address, block: (+ start-block (* block-step u21)) }
            { address: address, block: (+ start-block (* block-step u22)) }
            { address: address, block: (+ start-block (* block-step u23)) }
            { address: address, block: (+ start-block (* block-step u24)) }
            { address: address, block: (+ start-block (* block-step u25)) }
            { address: address, block: (+ start-block (* block-step u26)) }
            { address: address, block: (+ start-block (* block-step u27)) }
            { address: address, block: (+ start-block (* block-step u28)) }
            { address: address, block: (+ start-block (* block-step u29)) }
            { address: address, block: (+ start-block (* block-step u30)) }
            { address: address, block: (+ start-block (* block-step u31)) }
            { address: address, block: (+ start-block (* block-step u32)) }
            { address: address, block: (+ start-block (* block-step u33)) }
            { address: address, block: (+ start-block (* block-step u34)) }
            { address: address, block: (+ start-block (* block-step u35)) }
            { address: address, block: (+ start-block (* block-step u36)) }
            { address: address, block: (+ start-block (* block-step u37)) }
            { address: address, block: end-block }
        )
    )
)

;; Generate sample points for 19-point balance integral calculation
(define-read-only (generate-sample-points-19 (address principal) (start-block uint) (end-block uint))
    (let
        (
            (block-step (/ (- end-block start-block) u18))
        )
        (list
            { address: address, block: start-block }
            { address: address, block: (+ start-block (* block-step u1)) }
            { address: address, block: (+ start-block (* block-step u2)) }
            { address: address, block: (+ start-block (* block-step u3)) }
            { address: address, block: (+ start-block (* block-step u4)) }
            { address: address, block: (+ start-block (* block-step u5)) }
            { address: address, block: (+ start-block (* block-step u6)) }
            { address: address, block: (+ start-block (* block-step u7)) }
            { address: address, block: (+ start-block (* block-step u8)) }
            { address: address, block: (+ start-block (* block-step u9)) }
            { address: address, block: (+ start-block (* block-step u10)) }
            { address: address, block: (+ start-block (* block-step u11)) }
            { address: address, block: (+ start-block (* block-step u12)) }
            { address: address, block: (+ start-block (* block-step u13)) }
            { address: address, block: (+ start-block (* block-step u14)) }
            { address: address, block: (+ start-block (* block-step u15)) }
            { address: address, block: (+ start-block (* block-step u16)) }
            { address: address, block: (+ start-block (* block-step u17)) }
            { address: address, block: end-block }
        )
    )
)

;; Generate sample points for 9-point balance integral calculation
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

;; Generate sample points for 5-point balance integral calculation
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

;; Generate sample points for 2-point balance integral calculation
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