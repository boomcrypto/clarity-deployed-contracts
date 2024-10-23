;; wanted-hogger.clar - Quest logic for Wanted: Hogger

(define-constant err-unauthorized (err u401))
(define-constant err-hogger-defeated (err u402))
(define-constant err-insufficient-energy (err u403))
(define-constant err-invalid-edk (err u404))

(define-constant contract (as-contract tx-sender))

(define-data-var blocks-per-epoch uint u14) ;; Roughly daily epochs (assuming 10-minute blocks)
(define-data-var last-reset-block uint u0)
(define-data-var current-epoch uint u0)

(define-map player-damage principal uint)
(define-data-var player-list (list 200 principal) (list))

;; Whitelisted Contract Addresses
(define-map whitelisted-edks principal bool)

(define-trait edk-trait
	(
		(tap (uint) (response (tuple (type (string-ascii 256)) (land-id uint) (land-amount uint) (energy uint)) uint))
	)
)

;; --- Authorization check
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
            (is-reset (try-reset))
        )
        (asserts! (is-whitelisted-edk (contract-of edk-contract)) err-invalid-edk)
        (asserts! (not (contract-call? .hogger-v0 is-defeated)) err-hogger-defeated)

        (print {event: "attack-hogger", player: player, energy-spent: energy, epoch-reset: is-reset})
        
        ;; Tap energy and calculate damage
        (let 
            (
                (damage (contract-call? .combat-v0 calculate-damage energy player))
                (new-hogger-health (unwrap-panic (contract-call? .hogger-v0 take-damage damage)))
            )
            
            ;; Update player's damage and add to player list if not already present
            (try! (record-player-damage player damage))
            
            ;; Check if Hogger is defeated
            (and (is-eq new-hogger-health u0) (unwrap-panic (distribute-rewards)))

            (print {event: "attack-result", player: player, damage-dealt: damage, new-hogger-health: new-hogger-health, hogger-defeated: (is-eq new-hogger-health u0)})
            (ok {
              land-id: land-id,
              energy-spent: energy,
              damage: damage,
              hogger-health: new-hogger-health
            })
        )
    )
)

;; Helper function to check if an epoch has passed
(define-private (epoch-passed)
    (> (- block-height (var-get last-reset-block)) (var-get blocks-per-epoch))
)

;; Reset the epoch if it has passed
(define-private (try-reset)
    (if (epoch-passed)
        (begin
            (var-set current-epoch (+ (var-get current-epoch) u1))
            (var-set last-reset-block block-height)
            (unwrap-panic (contract-call? .hogger-v0 reset-for-new-epoch))
            (clear-player-data)
            true
        )
        false
    )
)

(define-private (remove-player-damage (player principal))
    (map-delete player-damage player)
)

(define-public (try-reset-epoch)
    (let ((reset-result (try-reset)))
        (print {event: "result-epoch", reset-occurred: reset-result, new-epoch: (var-get current-epoch)})
        (ok reset-result)
    )
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
            (total-damage (fold + (map get-player-damage players) u0))
            (total-experience (pow u10 u9)) ;; 1000 experience in total
            (total-cha (pow u10 u9)) ;; 1000 sCHA in total
            (damage (get-player-damage player))
            (experience-share (/ (* total-experience damage) total-damage))
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
    (begin
        (map-set player-damage player (+ (get-player-damage player) damage))
        (var-set player-list (unwrap! (as-max-len? (append (var-get player-list) player) u200) (err u404)))
        (ok true)
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

;; Utility functions

(define-read-only (get-blocks-until-next-epoch)
    (let
        (
            (blocks-since-last-reset (- block-height (var-get last-reset-block)))
            (blocks-in-current-epoch (mod blocks-since-last-reset (var-get blocks-per-epoch)))
        )
        (- (var-get blocks-per-epoch) blocks-in-current-epoch)
    )
)

(define-read-only (get-epoch-progress)
    (let
        (
            (blocks-since-last-reset (- block-height (var-get last-reset-block)))
            (blocks-in-current-epoch (mod blocks-since-last-reset (var-get blocks-per-epoch)))
        )
        (/ (* blocks-in-current-epoch u100) (var-get blocks-per-epoch))
    )
)