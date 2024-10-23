(define-constant err-unauthorized (err u401))
(define-constant err-invalid-edk (err u402))

(define-data-var factor uint u100000)

;; Whitelisted Contract Addresses
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

;; Quest logic
(define-public (tap (land-id uint) (edk-contract <edk-trait>))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? edk-contract tap land-id)))
            (energy (get energy tapped-out))
            (tokens-out (energy-to-exp energy))
			      (original-sender tx-sender)
        )
        (asserts! (is-whitelisted-edk (contract-of edk-contract)) err-invalid-edk)
        (as-contract (contract-call? .experience mint tokens-out original-sender))
    )
)

(define-read-only (get-untapped-amount (land-id uint) (user principal))
    (let
        (
            (untapped-energy (unwrap-panic (contract-call? .lands get-untapped-amount land-id user)))
            (amount (energy-to-exp untapped-energy))
        )
        amount
    )
)

(define-private (energy-to-exp (energy uint))
    (* (pow (log2 energy) u2) (get-factor))
)

;; Getters
(define-read-only (get-factor)
    (var-get factor)
)

;; Setters
(define-public (set-factor (new-factor uint))
    (begin
        (try! (is-authorized))
        (ok (var-set factor new-factor))
    )
)