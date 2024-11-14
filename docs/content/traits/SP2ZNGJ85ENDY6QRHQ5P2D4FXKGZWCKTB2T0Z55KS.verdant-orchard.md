---
title: "Trait verdant-orchard"
draft: true
---
```
;; Title: Verdant Orchard
;; Author: rozar.btc
;; Synopsis:
;; Farmers produce two times more energy than other creature types in the verdant orchard.
;; Apples begin to rot after 1 million energy, so make sure to harvest them by then.

(impl-trait .dao-traits-v2.extension-trait)

(define-constant err-unauthorized (err u401))
(define-constant contract (as-contract tx-sender))
(define-constant farmers u1)

(define-data-var factor uint u100000000)
(define-data-var max-energy uint u1000000)

;; --- Authorization check

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

(define-read-only (get-factor)
	(var-get factor)
)

(define-public (set-factor (new-factor uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set factor new-factor))
	)
)

(define-read-only (get-max-energy)
	(var-get max-energy)
)

(define-public (set-max-energy (new-max-energy uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set max-energy new-max-energy))
	)
)

(define-public (harvest (creature-id uint))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .creatures-energy tap creature-id)))
            (ENERGY (get ENERGY tapped-out))
            (max-energy-amount (get-max-energy))
            (energy-amount (if (> ENERGY max-energy-amount) max-energy-amount ENERGY))
            (fuji-amount (* ENERGY (get-factor)))
            (TOKENS (if (is-eq creature-id farmers) (* fuji-amount u2) fuji-amount))
            (sender tx-sender)
        )
        (as-contract (mint TOKENS sender))
    )
)

(define-read-only (get-claimable-amount (creature-id uint))
    (let
        (
            (untapped-energy (unwrap-panic (contract-call? .creatures-energy get-untapped-amount creature-id tx-sender)))
            (max-energy-amount (get-max-energy))
            (energy-amount (if (> untapped-energy max-energy-amount) max-energy-amount untapped-energy))
            (fuji-amount (* energy-amount (get-factor)))
        )
        (if (is-eq creature-id farmers) (* fuji-amount u2) fuji-amount)
    )
)

(define-public (mint (amount uint) (recipient principal))
    (begin
        (try! (is-dao-or-extension))
        (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint amount contract))
        (try! (contract-call? .liquid-staked-charisma stake amount))
        (let 
            (
                (scha-amount (unwrap-panic (contract-call? .liquid-staked-charisma get-balance contract)))
                (index-input (/ scha-amount u2))
            )
            (try! (contract-call? .fuji-apples add-liquidity index-input))
        )
        (let 
            (
                (fuji-amount (unwrap-panic (contract-call? .fuji-apples get-balance contract)))
            )
            (try! (contract-call? .fuji-apples transfer fuji-amount contract recipient none))
        )
        (ok {
            type: "mint-fuji-apples",
            amount: amount,
            recipient: recipient
        })
    )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
```
