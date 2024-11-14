---
title: "Trait wanted-hogger-v2"
draft: true
---
```
;; wanted-hogger.clar - Quest logic for Wanted: Hogger

(define-constant err-unauthorized (err u401))
(define-constant err-hogger-defeated (err u402))
(define-constant err-invalid-edk (err u403))
(define-constant err-hogger-not-defeated (err u404))
(define-constant err-cooldown-not-complete (err u405))

(define-data-var last-reset-block uint u0)
(define-data-var current-epoch uint u0)

(define-data-var hogger-defeat-block uint u0)
(define-constant COOLDOWN_BLOCKS u10)

(define-map player-damage principal uint)
(define-data-var player-list (list 200 principal) (list))

;; Whitelisted Contract Addresses
(define-map whitelisted-edks principal bool)

(define-trait edk-trait
	(
		(tap (uint) (response (tuple (type (string-ascii 256)) (land-id uint) (land-amount uint) (energy uint)) uint))
	)
)

;; Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) 
        (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
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

;; Attack Hogger function
(define-public (tap (land-id uint) (edk-contract <edk-trait>))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? edk-contract tap land-id)))
            (energy (get energy tapped-out))
            (player tx-sender)
            (block-in-epoch (- block-height (var-get last-reset-block)))
        )
        (asserts! (is-whitelisted-edk (contract-of edk-contract)) err-invalid-edk)
        (asserts! (not (contract-call? .hogger-v0 is-defeated)) err-hogger-defeated)

        (print {event: "attack-hogger", player: player, energy-spent: energy, block-in-epoch: block-in-epoch})
        
        ;; Tap energy and calculate damage
        (let 
            (
                (base-damage (contract-call? .combat-v1 calculate-damage energy player))
                (damage (if (<= block-in-epoch u0)
                            (/ (* base-damage u10) u100)  ;; 90% reduction
                            (if (is-eq block-in-epoch u1)
                                (/ (* base-damage u40) u100)  ;; 60% reduction
                                (if (is-eq block-in-epoch u2)
                                    (/ (* base-damage u70) u100)  ;; 30% reduction
                                    base-damage))))  ;; No reduction
                (new-hogger-health (unwrap-panic (contract-call? .hogger-v0 take-damage damage)))
            )
            
            ;; Update player's damage and add to player list if not already present
            (try! (record-player-damage player damage))

            (print {event: "attack-result", player: player, damage-dealt: damage, new-hogger-health: new-hogger-health, hogger-defeated: (is-eq new-hogger-health u0)})
            
            ;; Check if Hogger is defeated and reset the epoch if so
            (if (is-eq new-hogger-health u0)
                (begin
                    (unwrap-panic (distribute-rewards))
                    (var-set hogger-defeat-block block-height)
                )
                true
            )
            
            (ok {
              land-id: land-id,
              energy-spent: energy,
              damage: damage,
              hogger-health: new-hogger-health
            })
        )
    )
)

(define-public (start-new-epoch)
    (begin
        (asserts! (contract-call? .hogger-v0 is-defeated) err-hogger-not-defeated)
        (asserts! (>= (- block-height (var-get hogger-defeat-block)) COOLDOWN_BLOCKS) err-cooldown-not-complete)
        
        (var-set current-epoch (+ (var-get current-epoch) u1))
        (var-set last-reset-block block-height)
        (unwrap-panic (contract-call? .hogger-v0 reset-for-new-epoch))
        (clear-player-data)
        
        (print {event: "new-epoch-started", epoch: (var-get current-epoch)})
        (ok true)
    )
)

(define-read-only (can-start-new-epoch)
    (and 
        (contract-call? .hogger-v0 is-defeated)
        (>= (- block-height (var-get hogger-defeat-block)) COOLDOWN_BLOCKS)
    )
)

(define-read-only (get-epoch-info)
    (ok {
        current-epoch: (var-get current-epoch),
        last-reset-block: (var-get last-reset-block),
        hogger-defeat-block: (var-get hogger-defeat-block),
        can-start-new-epoch: (can-start-new-epoch)
    })
)

(define-private (remove-player-damage (player principal))
    (map-delete player-damage player)
)

;; Helper function to get player damage
(define-private (get-player-damage (player principal))
    (default-to u0 (map-get? player-damage player))
)

;; Distribute rewards when Hogger is defeated
(define-private (distribute-rewards)
    (begin
        (map distribute-player-reward (var-get player-list))
        (ok true)
    )
)

(define-private (distribute-player-reward (player principal))
    (let
        (
            (players (var-get player-list))
            (player-count (len players))
            (total-damage (fold + (map get-player-damage players) u0))
            (total-experience (pow u10 u8)) ;; 100 experience in total
            (total-cha (pow u10 u9)) ;; 1000 sCHA in total
            (damage (get-player-damage player))
            (experience-share (/ total-experience player-count))
            (cha-share (/ (* total-cha damage) total-damage))
        )
        (begin
            (print {event: "distributing-rewards", total-players: (len players), total-damage: total-damage})
            (try! (contract-call? .experience mint experience-share player))
            (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint cha-share player))
            (print {event: "rewards-distributed", player: player, experience: experience-share, cha-amount: cha-share})
            (ok true)
        )
    )
)

;; Utility function to add a player to the list and record their damage
(define-private (record-player-damage (player principal) (damage uint))
    (let
        (
            (current-player-list (var-get player-list))
            (player-exists (index-of current-player-list player))
        )
        (begin
            (map-set player-damage player (+ (get-player-damage player) damage))
            (if (is-none player-exists)
                (var-set player-list (unwrap! (as-max-len? (append current-player-list player) u200) (err u404)))
                true
            )
            (ok true)
        )
    )
)

;; Clear player data after rewards distribution
(define-private (clear-player-data)
    (begin
        (map delete-player-damage (var-get player-list))
        (var-set player-list (list))
    )
)

(define-private (delete-player-damage (player principal))
    (map-delete player-damage player)
)

;; Getters
(define-read-only (get-hogger-health)
    (contract-call? .hogger-v0 get-health)
)

(define-read-only (get-current-epoch)
    (var-get current-epoch)
)
```
