(define-constant err-unauthorized (err u401))
(define-constant err-invalid-edk (err u402))

;; Constants for fixed-point arithmetic
(define-constant PRECISION u1000000) ;; 6 decimal places

;; Map to store token bonuses for specific land-ids
(define-map token-bonuses uint uint)

(define-data-var factor uint u1)
(define-data-var exp-out uint u1000000)

;; Whitelisted contract addresses
(define-map whitelisted-edks principal bool)

(define-trait edk-trait
    (
        (tap (uint) (response (tuple (type (string-ascii 256)) (land-id uint) (land-amount uint) (energy uint)) uint))
    )
)

;; Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) err-unauthorized))
)

;; Whitelist Functions
(define-public (set-whitelisted-edk (edk principal) (whitelisted bool))
    (begin
        (try! (is-authorized))
        (ok (map-set whitelisted-edks edk whitelisted))
    )
)

(define-read-only (is-whitelisted-edk (edk principal))
    (default-to false (map-get? whitelisted-edks edk))
)

;; Calculate linear experience bonus
(define-private (calculate-exp-bonus (exp-balance uint))
    ;; 1k exp => 1% bonus
    ;; 1.010000x as 1010000
    ;; 1k exp = 1000 000000
    ;; 1000 000000 / 100000 = 10000
    ;; 1000000 + 10000 = 1010000
    (+ PRECISION (/ exp-balance u10000))
)

;; Calculate charisma token amount
(define-private (calculate-cha-token-amount (energy uint))
    (/ (* energy (get-factor)) PRECISION)
)

;; Quest logic
(define-public (tap (land-id uint) (edk-contract <edk-trait>))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? edk-contract tap land-id)))
            (energy (get energy tapped-out))
            (exp-balance (unwrap-panic (contract-call? .experience get-balance tx-sender)))
            (token-bonus (get-token-bonus land-id))
            (exp-bonus (calculate-exp-bonus exp-balance))
            (energy-with-bonuses (/ (/ (* (* energy token-bonus) exp-bonus) PRECISION) PRECISION))
            (cha-token-amount (calculate-cha-token-amount energy-with-bonuses))
            (event {
              event: "harvest-apple-farm", 
              cha-token-amount: cha-token-amount,
              exp-bonus: exp-bonus,
              token-bonus: token-bonus,
              energy: energy
            })
        )
        (print event)
        (asserts! (is-whitelisted-edk (contract-of edk-contract)) err-invalid-edk)
        (try! (contract-call? .experience mint (var-get exp-out) tx-sender))
        (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint cha-token-amount tx-sender))
        (ok event)
    )
)

(define-read-only (get-untapped-amount (land-id uint) (user principal))
    (let
        (
            (untapped-energy (unwrap-panic (contract-call? .lands get-untapped-amount land-id user)))
            (exp-balance (unwrap-panic (contract-call? .experience get-balance user)))
            (token-bonus (get-token-bonus land-id))
            (exp-bonus (calculate-exp-bonus exp-balance))
            (energy-with-bonuses (/ (/ (* (* untapped-energy token-bonus) exp-bonus) PRECISION) PRECISION))
            (cha-token-amount (calculate-cha-token-amount energy-with-bonuses))
        )
        (ok cha-token-amount)
    )
)

;; Getters
(define-read-only (get-token-bonus (land-id uint))
    (default-to PRECISION (map-get? token-bonuses land-id))
)

(define-read-only (get-factor)
    (var-get factor)
)

(define-read-only (get-exp-out)
    (var-get exp-out)
)

;; Setters
(define-public (set-token-bonus (land-id uint) (token-bonus uint))
    (begin
        (try! (is-authorized))
        (ok (map-set token-bonuses land-id token-bonus))
    )
)

(define-public (set-factor (new-factor uint))
    (begin
        (try! (is-authorized))
        (ok (var-set factor new-factor))
    )
)

(define-public (set-exp-out (new-exp-out uint))
    (begin
        (try! (is-authorized))
        (ok (var-set exp-out new-exp-out))
    )
)