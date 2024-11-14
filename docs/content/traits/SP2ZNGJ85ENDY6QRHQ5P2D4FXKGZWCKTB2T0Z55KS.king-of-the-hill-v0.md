---
title: "Trait king-of-the-hill-v0"
draft: true
---
```
(define-constant err-unauthorized (err u401))
(define-constant err-invalid-edk (err u402))

;; Whitelisted Contract Addresses
(define-map whitelisted-edks principal bool)

;; Team Captains
(define-map team-captains uint principal)

;; Reward Amounts
(define-data-var first-place-reward uint  u40000000000) ;; 40000 CHA tokens
(define-data-var second-place-reward uint u20000000000) ;; 20000 CHA tokens
(define-data-var third-place-reward uint  u10000000000) ;; 10000 CHA tokens

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

;; Team Captain Functions
(define-public (set-team-captain (team-id uint) (captain principal))
    (begin
        (try! (is-authorized))
        (ok (map-set team-captains team-id captain))
    )
)

(define-read-only (get-team-captain (team-id uint))
    (default-to 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master (map-get? team-captains team-id))
)

;; Quest logic
(define-public (tap (land-id uint) (edk-contract <edk-trait>))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? edk-contract tap land-id)))
            (energy (get energy tapped-out))
			      (player tx-sender)
            (base-damage (contract-call? .combat-v1 calculate-damage energy player))
        )
        (asserts! (is-whitelisted-edk (contract-of edk-contract)) err-invalid-edk)
        (print {event: "attack-the-hill", player: player, land-id: land-id, points: base-damage})
        (try! (contract-call? .meme-mountain-v0 add-points land-id base-damage))
        (try! (contract-call? .experience mint u1000000 player))
        (ok {
          player: player,
          land-id: land-id, 
          points: base-damage
        })
    )
)

(define-public (distribute-rewards)
    (let
        (
            (leaderboard (contract-call? .meme-mountain-v0 get-leaderboard))
            (first-place-team (get team-id (get first leaderboard)))
            (second-place-team (get team-id (get second leaderboard)))
            (third-place-team (get team-id (get third leaderboard)))
            (first-place-captain (get-team-captain first-place-team))
            (second-place-captain (get-team-captain second-place-team))
            (third-place-captain (get-team-captain third-place-team))
        )
        (begin
            (try! (is-authorized))
            (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint (var-get first-place-reward) first-place-captain))
            (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint (var-get second-place-reward) second-place-captain))
            (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint (var-get third-place-reward) third-place-captain))
            (ok true)
        )
    )
)

(define-read-only (get-untapped-amount (land-id uint) (user principal))
    (let
        (
            (untapped-energy (unwrap-panic (contract-call? .lands get-untapped-amount land-id user)))
			      (player tx-sender)
            (base-damage (contract-call? .combat-v1 calculate-damage untapped-energy player))
        )
        base-damage
    )
)

;; Reward Amount Functions
(define-public (set-first-place-reward (amount uint))
    (begin
        (try! (is-authorized))
        (ok (var-set first-place-reward amount))
    )
)

(define-public (set-second-place-reward (amount uint))
    (begin
        (try! (is-authorized))
        (ok (var-set second-place-reward amount))
    )
)

(define-public (set-third-place-reward (amount uint))
    (begin
        (try! (is-authorized))
        (ok (var-set third-place-reward amount))
    )
)

(define-read-only (get-first-place-reward)
    (var-get first-place-reward)
)

(define-read-only (get-second-place-reward)
    (var-get second-place-reward)
)

(define-read-only (get-third-place-reward)
    (var-get third-place-reward)
)

```
