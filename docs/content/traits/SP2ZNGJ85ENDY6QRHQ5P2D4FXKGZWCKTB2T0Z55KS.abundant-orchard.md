---
title: "Trait abundant-orchard"
draft: true
---
```
;; Farmers produce two times more energy than other creature types in the tranquil orchard

(define-constant err-unauthorized (err u401))

(define-constant farmers u1)
(define-data-var factor uint u100000000)

;; Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) err-unauthorized))
)

(define-public (harvest (creature-id uint))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .creatures-kit tap creature-id)))
            (ENERGY (get ENERGY tapped-out))
            (apple-amount (* ENERGY (get-factor)))
            (TOKENS (if (is-eq creature-id farmers) (* apple-amount u2) apple-amount))
			      (original-sender tx-sender)
        )
        (as-contract (contract-call? .fuji-apples transfer TOKENS tx-sender original-sender none))
    )
)

(define-read-only (get-claimable-amount (creature-id uint))
    (let
        (
            (untapped-energy (unwrap-panic (contract-call? .creatures-kit get-untapped-amount creature-id tx-sender)))
            (apple-amount (* untapped-energy (get-factor)))
        )
        (if (is-eq creature-id farmers) (* apple-amount u2) apple-amount)
    )
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
```
