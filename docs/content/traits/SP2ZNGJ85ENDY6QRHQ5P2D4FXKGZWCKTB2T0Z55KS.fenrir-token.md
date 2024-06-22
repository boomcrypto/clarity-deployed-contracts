---
title: "Trait fenrir-token"
draft: true
---
```
;; Title: Fenrir Token
;; Author: rozar.btc

;; In the mystical realm of Asgard, there lived a colossal creature named Fenrir, feared by the gods and prophesied to bring about the end of the world. 
;; However, Fenrir was not a fearsome wolf but a massive Welsh Corgi with an insatiable appetite for adventure and mischief. 
;; This unexpected revelation came to light when Odin, the All-Father, embarked on a quest to find and confront Fenrir. 
;; Instead of a terrifying beast, he discovered a playful and mischievous Corgi eager to join his adventure.
;;
;; News of Fenrir's true nature spread throughout Asgard, and the gods were left in awe of the unlikely duo. 
;; The prophecy of Ragnarok was averted, not through force or violence, but through the power of friendship. 
;; And so, the mighty Fenrir, the feared harbinger of doom, was revealed to be nothing more than a massive Welsh Corgi, forever changing the course of Norse mythology.

(impl-trait .dao-traits-v0.sip010-ft-trait)
(impl-trait .dao-traits-v0.extension-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-not-token-owner (err u4))

(define-constant supply-weight-w u10) ;; WELSH 10B total supply
(define-constant supply-weight-o u21) ;; ODIN 21B total supply

(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places

(define-constant contract (as-contract tx-sender))

(define-fungible-token fenrir)

(define-data-var token-name (string-ascii 32) "Fenrir, Corgi of Ragnarok")
(define-data-var token-symbol (string-ascii 10) "FENRIR")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/fenrir.json"))
(define-data-var token-decimals uint u6)

(define-data-var craft-reward-factor uint u0)
(define-data-var salvage-reward-factor uint u0)
(define-data-var transfer-reward-factor uint u0)

(define-data-var craft-fee-percent uint u100) ;; 0.01%
(define-data-var salvage-fee-percent uint u100) ;; 0.01%
(define-data-var transfer-fee-percent uint u100) ;; 0.01%

;; --- Authorization check

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-name new-name))
	)
)

(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-symbol new-symbol))
	)
)

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-decimals new-decimals))
	)
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-dao-or-extension))
		(var-set token-uri new-uri)
		(ok 
			(print {
				notification: "token-metadata-update",
				payload: {
					token-class: "ft",
					contract-id: (as-contract tx-sender)
				}
			})
		)
	)
)

(define-public (set-craft-reward-factor (new-craft-reward-factor uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set craft-reward-factor new-craft-reward-factor))
	)
)

(define-public (set-salvage-reward-factor (new-salvage-reward-factor uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set salvage-reward-factor new-salvage-reward-factor))
	)
)

(define-public (set-transfer-reward-factor (new-transfer-reward-factor uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set transfer-reward-factor new-transfer-reward-factor))
	)
)

(define-public (set-craft-fee-percent (new-craft-fee-percent uint))
	(begin
		(try! (is-dao-or-extension))
        (asserts! (<= new-craft-fee-percent u100) err-unauthorized)
		(ok (var-set craft-fee-percent new-craft-fee-percent))
	)
)

(define-public (set-salvage-fee-percent (new-salvage-fee-percent uint))
	(begin
		(try! (is-dao-or-extension))
        (asserts! (<= new-salvage-fee-percent u100) err-unauthorized)
		(ok (var-set salvage-fee-percent new-salvage-fee-percent))
	)
)

(define-public (set-transfer-fee-percent (new-transfer-fee-percent uint))
	(begin
		(try! (is-dao-or-extension))
        (asserts! (<= new-transfer-fee-percent u100) err-unauthorized)
		(ok (var-set transfer-fee-percent new-transfer-fee-percent))
	)
)

;; --- Public functions

(define-public (craft (amount uint) (recipient principal))
    (let
        (
            (craft-reward (/ (* amount (var-get craft-reward-factor)) ONE_6))
            (craft-fee (/ (* amount (var-get craft-fee-percent)) ONE_6))
            (craft-fee-lsw (/ (* (* craft-fee supply-weight-w) (get-exchange-rate-a)) ONE_6))
            (craft-fee-lso (/ (* (* craft-fee supply-weight-o) (get-exchange-rate-b)) ONE_6))
            (sender tx-sender)
        )
        ;; if craft-fee is greater than 0 then burn base tokens
        (and (> craft-fee u0) 
            (begin
                (print {craft-fee: craft-fee, craft-fee-lsw: craft-fee-lsw, craft-fee-lso: craft-fee-lso})
                (try! (contract-call? .liquid-staked-welsh-v2 deflate craft-fee-lsw))
                (try! (contract-call? .liquid-staked-odin deflate craft-fee-lso))
            )
        )
        ;; if craft reward is greater than 0 then mint to the sender
        (and (> craft-reward u0)
            (begin
                (print {craft-reward: craft-reward})
                (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint craft-reward sender)))
            )
        )
        (join amount recipient)
    )
    
)

(define-public (salvage (amount uint) (recipient principal))
    (let
        (
            (salvage-reward (/ (* amount (var-get salvage-reward-factor)) ONE_6))
            (salvage-fee (/ (* amount (var-get salvage-fee-percent)) ONE_6))
            (sender tx-sender)
        )
        ;; if salvage-fee is greater than 0 then burn the fee
        (and (> salvage-fee u0) 
            (begin
                (print {salvage-fee: salvage-fee})
                (try! (burn salvage-fee))
            )
        )
        ;; if salvage reward is greater than 0 then mint to the sender
        (and (> salvage-reward u0)
            (begin
                (print {salvage-reward: salvage-reward})
                (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint salvage-reward sender)))
            )
        )
        (split amount recipient)
    )
)

(define-public (burn (amount uint))
    (ft-burn? fenrir amount tx-sender)
)

(define-read-only (get-craft-reward-factor)
	(ok (var-get craft-reward-factor))
)

(define-read-only (get-salvage-reward-factor)
	(ok (var-get salvage-reward-factor))
)

(define-read-only (get-transfer-reward-factor)
	(ok (var-get transfer-reward-factor))
)

(define-read-only (get-craft-fee-percent)
	(ok (var-get craft-fee-percent))
)

(define-read-only (get-salvage-fee-percent)
	(ok (var-get salvage-fee-percent))
)

(define-read-only (get-transfer-fee-percent)
	(ok (var-get transfer-fee-percent))
)

;; sip010-ft-trait

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(let
        (
            (transfer-reward (/ (* amount (var-get transfer-reward-factor)) ONE_6))
            (transfer-fee (/ (* amount (var-get transfer-fee-percent)) ONE_6))
        )
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
        ;; if transfer-fee is greater than 0 then deflate the fee
        (and (> transfer-fee u0)
            (begin
                (print {tx-fee: transfer-fee})
                (try! (burn transfer-fee))
            )
        )
        ;; if transfer reward is greater than 0 then mint to the sender
        (and (> transfer-reward u0)
            (begin
                (print {transfer-reward: transfer-reward})
                (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint transfer-reward sender)))
            )
        )
		(ft-transfer? fenrir amount sender recipient)
	)
)

(define-read-only (get-name)
	(ok (var-get token-name))
)

(define-read-only (get-symbol)
	(ok (var-get token-symbol))
)

(define-read-only (get-decimals)
	(ok (var-get token-decimals))
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance fenrir who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply fenrir))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

;; --- Liquid staking

(define-read-only (get-total-in-pool-a)
	(unwrap-panic (contract-call? .liquid-staked-welsh-v2 get-balance contract))
)

(define-read-only (get-total-in-pool-b)
	(unwrap-panic (contract-call? .liquid-staked-odin get-balance contract))
)

(define-read-only (get-exchange-rate-a)
	(/ (* (get-total-in-pool-a) ONE_6) (ft-get-supply fenrir))
)

(define-read-only (get-exchange-rate-b)
	(/ (* (get-total-in-pool-b) ONE_6) (ft-get-supply fenrir))
)

(define-read-only (get-inverse-rate-a)
	(/ (* (ft-get-supply fenrir) ONE_6) (get-total-in-pool-a))
)

(define-read-only (get-inverse-rate-b)
	(/ (* (ft-get-supply fenrir) ONE_6) (get-total-in-pool-b))
)

;; --- Private functions

(define-private (join (amount uint) (recipient principal))
    (let
        (
            (amount-lsw (/ (* (* amount supply-weight-w) (get-inverse-rate-a)) ONE_6))
            (amount-lso (/ (* (* amount supply-weight-o) (get-inverse-rate-b)) ONE_6))
        )
        (try! (contract-call? .liquid-staked-welsh-v2 transfer amount-lsw tx-sender contract none))
        (try! (contract-call? .liquid-staked-odin transfer amount-lso tx-sender contract none))
        (try! (ft-mint? fenrir amount recipient))
        (ok true)
    )
)

(define-private (split (amount uint) (recipient principal))
    (let
        (
            (amount-lsw (/ (* (* amount supply-weight-w) (get-exchange-rate-a)) ONE_6))
            (amount-lso (/ (* (* amount supply-weight-o) (get-exchange-rate-b)) ONE_6))
        )
        (try! (ft-burn? fenrir amount tx-sender))
        (try! (contract-call? .liquid-staked-welsh-v2 transfer amount-lsw contract recipient none))
        (try! (contract-call? .liquid-staked-odin transfer amount-lso contract recipient none))
        (ok true)
    )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

;; --- Init

(ft-mint? fenrir u1 contract)
```
