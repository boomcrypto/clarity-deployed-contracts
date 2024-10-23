;; Title: Charisma Core Contributer Dev Faucet

(define-constant err-unauthorized (err u3100))
(define-constant err-insufficient-balance (err u3102))

(define-data-var drip-amount uint u5000000)
(define-data-var last-claim uint block-height)
(define-data-var total-issued uint u0)

;; --- Authorization checks

(define-public (is-dao-or-extension)
    (ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

(define-public (is-owner)
    (ok (asserts! (is-eq tx-sender 'SPAQN4FQ9FY58RCZG1GEP5Q3RSDS7PSW3QXA6XZV) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (set-drip-amount (amount uint))
    (begin
        (try! (is-dao-or-extension))
        (ok (var-set drip-amount amount))
    )
)

;; --- Public functions

(define-public (claim)
    (let
        (
            (sender tx-sender)
      (tokens-available (* (var-get drip-amount) (- block-height (var-get last-claim))))
        )
        (try! (is-owner))
    (asserts! (> tokens-available u0) err-insufficient-balance)
    (var-set last-claim block-height)
    (var-set total-issued (+ (var-get total-issued) tokens-available))        
    (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint tokens-available sender))
    )
)

(define-read-only (get-drip-amount)
    (ok (var-get drip-amount))
)

(define-read-only (get-last-claim)
    (ok (var-get last-claim))
)

(define-read-only (get-total-issued)
    (ok (var-get total-issued))
)