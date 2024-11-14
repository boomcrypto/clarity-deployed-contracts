---
title: "Trait pontis-bridge-fee-manager-btc"
draft: true
---
```
(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-data-var contract-owner principal tx-sender)
(define-data-var proposed-owner principal tx-sender)

(define-constant ERR-NOT-AUTHORIZED (err u10000))
(define-constant ERR-FEE-TOO-HIGH (err u10001))
(define-constant ERR-MIN-TOO-HIGH (err u10002))
(define-constant ERR-SAME-OWNER (err u10003))
(define-constant ERR-RUNES-FEE-TOO-HIGH (err u10004))
(define-constant ERR-ORDINALS-FEE-TOO-HIGH (err u10005))
(define-constant ERR-ORDINALS-ADDITIONAL-FEE-TOO-HIGH (err u10006))

;; Max possible fee is 0.001 BTC
(define-constant MAX-FUNGIBLE-FEE u100000)
;; Max possible ordinals fee is 0.0002 BTC
(define-constant MAX-ORDINALS-FEE u20000)
;; Max possible percent fee is 1%
(define-constant MAX-PERCENT-FEE u10000000)
(define-constant PERCENT-FEE-DIVIDER u1000000000)

;; default fee is 0.25%
(define-data-var btc-percent-fee uint u2500000)
;; default fee is 0.25%
(define-data-var runes-percent-fee uint u2500000)

;; default min bridge is 0.0005 BTC or 50000 Rune in absolute value
(define-data-var min-btc-bridge uint u50000)
(define-data-var min-runes-bridge uint u50000)

(define-map custom-rune-tokens-min-bridge (buff 26) uint)

;; maximum possible for min bridge is 0.005 BTC
(define-constant MAX-BTC-BRIDGE-MINIMUM u500000)

;; maximum possible for min bridge is 1 Rune token considering 18 decimals
(define-constant MAX-RUNE-BRIDGE-MINIMUM u1000000000000000000)

;; network name -> fee configuration to bridge to this network
(define-map network-fee (buff 12) {
	btc-base-fee: uint,
	runes-base-fee: uint,
	ordinals-base-fee: uint,
	ordinals-additional-one-nft-fee: uint,
})

(define-data-var fee-recipient (buff 64) 0x)

(define-read-only (get-contract-owner)
	(ok (var-get contract-owner))
)

(define-public (propose-contract-owner (owner principal))
	(begin
		(try! (check-is-owner))
		(ok (var-set proposed-owner owner))
	)
)

(define-public (claim-ownership)
	(begin
		(try! (check-and-compare-proposed-owner))
		(ok (var-set contract-owner contract-caller))
	)
)

(define-private (check-is-owner)
	(ok (asserts! (is-eq contract-caller (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-and-compare-proposed-owner)
	(begin 
		(asserts! (is-eq contract-caller (var-get proposed-owner)) ERR-NOT-AUTHORIZED)
		(ok (asserts! (not (is-eq (var-get contract-owner) (var-get proposed-owner))) ERR-SAME-OWNER))
	)
)

(define-read-only (get-network-config (network (buff 12))) 
	(ok {
		network-fee: (map-get? network-fee network),
		btc-percent-fee: (var-get btc-percent-fee),
		runes-percent-fee: (var-get runes-percent-fee),
		min-btc-bridge: (var-get min-btc-bridge),
		fee-recipient: (var-get fee-recipient)
	})
)

(define-read-only (get-min-runes-bridge (rune (buff 26)))
	(ok (default-to (var-get min-runes-bridge) (map-get? custom-rune-tokens-min-bridge rune)))
)

(define-public (set-network-config
 	(network (buff 12))
	(btc-base-fee uint)
	(runes-base-fee uint)
	(ordinals-base-fee uint)
	(ordinals-additional-one-nft-fee uint)
)
	(begin
		(try! (check-is-owner))
		(asserts! (<= btc-base-fee MAX-FUNGIBLE-FEE) ERR-FEE-TOO-HIGH)
		(asserts! (<= runes-base-fee MAX-FUNGIBLE-FEE) ERR-RUNES-FEE-TOO-HIGH)
		(asserts! (<= ordinals-base-fee MAX-ORDINALS-FEE) ERR-ORDINALS-FEE-TOO-HIGH)
		(asserts! (<= ordinals-additional-one-nft-fee MAX-ORDINALS-FEE) ERR-ORDINALS-ADDITIONAL-FEE-TOO-HIGH)

		(map-set network-fee network {
			btc-base-fee: btc-base-fee,
			runes-base-fee: runes-base-fee,
			ordinals-base-fee: ordinals-base-fee,
			ordinals-additional-one-nft-fee: ordinals-additional-one-nft-fee
		})
		(ok true)
	)
)

(define-public (delete-network-config (network (buff 12)))
 (begin 
		(try! (check-is-owner))
		(ok (map-delete network-fee network))
	)
)

(define-public (set-btc-percent-fee (new-fee uint))
	(begin
		(try! (check-is-owner))
		(asserts! (<= new-fee MAX-PERCENT-FEE) ERR-FEE-TOO-HIGH)
		(var-set btc-percent-fee new-fee)
		(ok true)
	)
)

(define-public (set-runes-percent-fee (new-fee uint))
	(begin
		(try! (check-is-owner))
		(asserts! (<= new-fee MAX-PERCENT-FEE) ERR-FEE-TOO-HIGH)
		(var-set runes-percent-fee new-fee)
		(ok true)
	)
)

(define-public (set-min-btc-bridge (min-bridge uint))
	(begin
		(try! (check-is-owner))
		(asserts! (<= min-bridge MAX-BTC-BRIDGE-MINIMUM) ERR-MIN-TOO-HIGH)
		(var-set min-btc-bridge min-bridge)
		(ok true)
	)
)

(define-public (set-min-runes-bridge (min-bridge uint))
	(begin
		(try! (check-is-owner))
		(asserts! (<= min-bridge MAX-RUNE-BRIDGE-MINIMUM) ERR-MIN-TOO-HIGH)
		(var-set min-runes-bridge min-bridge)
		(ok true)
	)
)

(define-public (set-custom-min-runes-bridge (rune (buff 26)) (min-bridge uint))
	(begin
		(try! (check-is-owner))
		(asserts! (<= min-bridge MAX-RUNE-BRIDGE-MINIMUM) ERR-MIN-TOO-HIGH)
		(map-set custom-rune-tokens-min-bridge rune min-bridge)
		(ok true)
	)
)

(define-public (set-fee-recipient (new-fee-recipient (buff 64)))
	(begin
		(try! (check-is-owner))
		(var-set fee-recipient new-fee-recipient)
		(ok true)
	)
)

```
