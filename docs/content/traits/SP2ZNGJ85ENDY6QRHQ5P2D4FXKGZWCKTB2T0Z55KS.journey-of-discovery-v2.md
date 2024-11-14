---
title: "Trait journey-of-discovery-v2"
draft: true
---
```
(define-constant err-unauthorized (err u401))

(define-data-var factor uint u100000)

;; Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) err-unauthorized))
)

;; Quest logic
(define-public (journey (creature-id uint))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .creatures-kit tap creature-id)))
            (ENERGY (get ENERGY tapped-out))
            (TOKENS (* (pow (log2 ENERGY) u2) (get-factor)))
			      (original-sender tx-sender)
        )
        (as-contract (contract-call? .experience mint TOKENS original-sender))
    )
)

(define-read-only (get-claimable-amount (creature-id uint))
    (let
        (
            (untapped-energy (unwrap-panic (contract-call? .creatures-kit get-untapped-amount creature-id tx-sender)))
            (amount (* (pow (log2 untapped-energy) u2) (get-factor)))
        )
        amount
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

;; Extension callback
(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
```
