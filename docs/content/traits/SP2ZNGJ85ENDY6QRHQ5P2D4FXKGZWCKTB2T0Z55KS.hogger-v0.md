---
title: "Trait hogger-v0"
draft: true
---
```
;; hogger.clar - Represents Hogger as an NPC

(define-constant err-unauthorized (err u401))

(define-constant contract (as-contract tx-sender))

(define-data-var last-known-health uint u1000000)
(define-data-var last-health-update-block uint u0)
(define-data-var max-health uint u1000000)
(define-data-var regen-rate uint u100) ;; Health regenerated per block
(define-data-var is-currently-defeated bool false)
(define-data-var current-epoch uint u0)

;; Constants for health and regen rate increases
(define-constant health-increase-per-epoch u100000) ;; 10% of initial max health
(define-constant regen-rate-increase-per-epoch u10)

;; --- Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) 
        (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) err-unauthorized))
)

;; Calculate current health
(define-read-only (calculate-current-health)
    (if (var-get is-currently-defeated)
        u0
        (let
            (
                (blocks-passed (- block-height (var-get last-health-update-block)))
                (regen-amount (* blocks-passed (var-get regen-rate)))
                (health-with-regen (+ (var-get last-known-health) regen-amount))
            )
            (min health-with-regen (var-get max-health))
        )
    )
)

;; Damage Hogger
(define-public (take-damage (damage uint))
    (begin
        (try! (is-authorized))
        (print {event: "take-damage", damage: damage, current-health: (calculate-current-health)})
        (if (var-get is-currently-defeated)
            (ok u0)
            (let
                (
                    (current-health (calculate-current-health))
                    (new-health (if (> current-health damage) (- current-health damage) u0))
                )
                (var-set last-known-health new-health)
                (var-set last-health-update-block block-height)
                (if (is-eq new-health u0)
                    (var-set is-currently-defeated true)
                    false
                )
                (print {event: "damage-result", new-health: new-health, is-defeated: (is-eq new-health u0)})
                (ok new-health)
            )
        )
    )
)

;; Reset Hogger's health and increase stats (called at the start of a new epoch)
(define-public (reset-for-new-epoch)
    (begin
        (try! (is-authorized))
        (print {event: "reset-for-new-epoch", current-epoch: (var-get current-epoch)})
        (var-set current-epoch (+ (var-get current-epoch) u1))
        (var-set max-health (+ (var-get max-health) health-increase-per-epoch))
        (var-set regen-rate (+ (var-get regen-rate) regen-rate-increase-per-epoch))
        (var-set last-known-health (var-get max-health))
        (var-set last-health-update-block block-height)
        (var-set is-currently-defeated false)
        (print {event: "reset-complete", new-epoch: (var-get current-epoch), new-max-health: (var-get max-health), new-regen-rate: (var-get regen-rate)})
        (ok true)
    )
)

;; Getters
(define-read-only (get-health)
    (calculate-current-health)
)

(define-read-only (is-defeated)
    (var-get is-currently-defeated)
)

;; Util functions
(define-private (min (a uint) (b uint))
  (if (< a b) a b)
)
```
