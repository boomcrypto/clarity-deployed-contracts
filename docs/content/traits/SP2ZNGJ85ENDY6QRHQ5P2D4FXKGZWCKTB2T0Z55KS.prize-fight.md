---
title: "Trait prize-fight"
draft: true
---
```
;; Title: Prize Fight
;; Author: SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS
;; Created With Charisma
;; https://charisma.rocks
;; Description:
;; An auction-style bid war for NFTs.

;; Prize Fight Contract
;; This contract manages an auction system where creatures bid for NFTs with energy.

;; Constants
(define-constant err-unauthorized (err u401))
(define-constant err-invalid-token (err u402))
(define-constant err-invalid-cdk (err u403))
(define-constant err-invalid-nft (err u404))
(define-constant contract (as-contract tx-sender))
(define-constant deployer tx-sender)

;; Data Variables
(define-data-var quest-uri (string-utf8 256) u"https://charisma.rocks/api/quests/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.prize-fight.json")
(define-data-var specialized-creature-id uint u0)
(define-data-var creature-bonus uint u1)
(define-data-var scaling-factor uint u1)
(define-data-var blocks-per-epoch uint u10)
(define-data-var last-reset-epoch uint u0)
(define-data-var current-epoch uint u0)

;; Whitelisted Contract Addresses
(define-map whitelisted-cdks principal bool)

;; Storage Maps
(define-map bids {bidder: principal, epoch: uint} {price: uint})
(define-map highest-bidder uint principal)
(define-map highest-bid uint uint)
(define-map bid-count uint uint)
(define-map prize-claimed uint bool)
(define-map epoch-nft-data uint {nft-id: uint, nft-contract: principal})

;; Traits
(define-trait nft-trait
  (
    (transfer (uint principal principal) (response bool uint))
  )
)

(define-trait cdk-trait
	(
		(get-untapped-amount (uint principal) (response uint uint))
		(tap (uint) (response (tuple (type (string-ascii 256)) (creature-id uint) (creature-amount uint) (ENERGY uint)) uint))
	)
)

;; Authorization Functions

(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) 
        (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) err-unauthorized))
)

;; Whitelist Functions

(define-public (set-whitelisted-cdk (cdk principal) (whitelisted bool))
    (begin
        (try! (is-authorized))
        (ok (map-set whitelisted-cdks cdk whitelisted))
    )
)

(define-read-only (is-whitelisted-cdk (cdk principal))
    (default-to false (map-get? whitelisted-cdks cdk))
)

;; Bidding Functions

(define-private (bid (new-price uint))
    (let
        (
            (existing-bid (default-to u0 (get price (map-get? bids {bidder: tx-sender, epoch: (get-current-epoch)}))))
            (updated-bid (+ new-price existing-bid))
            (current-highest-bid (default-to u0 (map-get? highest-bid (get-current-epoch))))
            (current-highest-bidder (default-to deployer (map-get? highest-bidder (get-current-epoch))))
        )
        ;; Update highest bidder and bid if necessary
        (if (> updated-bid current-highest-bid)
            (begin
                (map-set highest-bidder (get-current-epoch) tx-sender)
                (map-set highest-bid (get-current-epoch) updated-bid)
            )
            true
        )
        ;; Update bid and bid count
        (map-set bids {bidder: tx-sender, epoch: (get-current-epoch)} {price: updated-bid})
        (map-set bid-count (get-current-epoch) (+ (default-to u0 (map-get? bid-count (get-current-epoch))) u1))
        (print {
            notification: "updated-bid",
            payload: {
                bidder: tx-sender,
                price: updated-bid,
                bid-count: (map-get? bid-count (get-current-epoch)),
            }
        })
        (ok (map-get? bid-count (get-current-epoch)))
    )
)

;; NFT Management Functions

(define-public (set-epoch-nft-data (epoch uint) (nft-id uint) (nft-contract principal))
    (begin
        (try! (is-authorized))
        (ok (map-set epoch-nft-data epoch {nft-id: nft-id, nft-contract: nft-contract}))
    )
)

(define-read-only (get-epoch-nft-data (epoch uint))
    (map-get? epoch-nft-data epoch)
)

;; Epoch Management Functions

(define-private (epoch-passed)
    (> (- block-height (var-get last-reset-epoch)) (var-get blocks-per-epoch))
)

(define-private (reset-epoch (nft-contract <nft-trait>))
    (if (epoch-passed)
        (let
            (
                (last-epoch (var-get current-epoch))
                (nft-data (unwrap! (get-epoch-nft-data last-epoch) err-invalid-nft))
                (nft-id (get nft-id nft-data))
                (nft-contract-principal (get nft-contract nft-data))
            )
            (asserts! (is-eq nft-contract-principal (contract-of nft-contract)) err-invalid-nft)
            (var-set current-epoch (+ last-epoch u1))
            (var-set last-reset-epoch block-height)
            (print {
                notification: "epoch-reset",
                payload: {
                    epoch: (var-get current-epoch),
                    last-epoch: last-epoch,
                    last-reset-block: (var-get last-reset-epoch),
                    block-height: block-height,
                    winner: (get-winner last-epoch),
                    highest-bid: (get-highest-bid last-epoch),
                    nft-contract: nft-contract-principal,
                    nft-id: nft-id,
                }
            })
            (try! (as-contract (contract-call? nft-contract transfer nft-id contract (get-winner last-epoch))))
            (ok true)
        )
        (ok false)
    )
)

;; Tap Creatures Function

(define-public (tap-creatures (creature-id uint) (nft-contract <nft-trait>) (cdk-contract <cdk-trait>))
    (begin
        (asserts! (is-whitelisted-cdk (contract-of cdk-contract)) err-invalid-cdk)
        (let
            (
                (tapped-out (unwrap-panic (contract-call? cdk-contract tap creature-id)))
                (ENERGY (get ENERGY tapped-out))
                (bid-amount (* ENERGY (get-scaling-factor)))
                (AMOUNT (if (is-eq creature-id (get-specialized-creature-id)) (* bid-amount (get-creature-bonus)) bid-amount))
                (is-reset (try! (reset-epoch nft-contract)))
            )
            (bid AMOUNT)
        )
    )
)

;; Getter Functions

(define-read-only (get-quest-uri)
  	(var-get quest-uri)
)

(define-read-only (get-specialized-creature-id)
    (var-get specialized-creature-id)
)

(define-read-only (get-creature-bonus)
    (var-get creature-bonus)
)

(define-read-only (get-highest-bid (epoch uint))
    (map-get? highest-bid epoch)
)

(define-read-only (get-highest-bidder (epoch uint))
    (map-get? highest-bidder epoch)
)

(define-read-only (get-latest-bid-of (bidder principal) (epoch uint))
    (default-to u0 (get price (map-get? bids {bidder: bidder, epoch: epoch})))
)

(define-read-only (get-winner (epoch uint))
    (default-to deployer (map-get? highest-bidder epoch))
)

(define-read-only (get-scaling-factor)
    (var-get scaling-factor)
)

(define-read-only (get-blocks-per-epoch)
    (var-get blocks-per-epoch)
)

(define-read-only (get-last-reset-epoch)
    (var-get last-reset-epoch)
)

(define-read-only (get-current-epoch)
    (var-get current-epoch)
)

;; Setter Functions

(define-public (set-quest-uri (new-uri (string-utf8 256)))
	(begin
		(try! (is-authorized))
		(ok (var-set quest-uri new-uri))
	)
)

(define-public (set-specialized-creature-id (new-specialized-creature-id uint))
    (begin
        (try! (is-authorized))
        (ok (var-set specialized-creature-id new-specialized-creature-id))
    )
)

(define-public (set-creature-bonus (new-bonus uint))
    (begin
        (try! (is-authorized))
        (ok (var-set creature-bonus new-bonus))
    )
)

(define-public (set-scaling-factor (new-scaling-factor uint))
    (begin
        (try! (is-authorized))
        (ok (var-set scaling-factor new-scaling-factor))
    )
)

(define-public (set-blocks-per-epoch (new-blocks-per-epoch uint))
    (begin
        (try! (is-authorized))
        (ok (var-set blocks-per-epoch new-blocks-per-epoch))
    )
)

;; Utility Functions

(define-read-only (get-blocks-until-next-epoch)
    (let
        (
            (blocks-since-last-reset (- block-height (var-get last-reset-epoch)))
            (blocks-in-current-epoch (mod blocks-since-last-reset (var-get blocks-per-epoch)))
        )
        (- (var-get blocks-per-epoch) blocks-in-current-epoch)
    )
)

(define-read-only (get-epoch-progress)
    (let
        (
            (blocks-since-last-reset (- block-height (var-get last-reset-epoch)))
            (blocks-in-current-epoch (mod blocks-since-last-reset (var-get blocks-per-epoch)))
        )
        (/ (* blocks-in-current-epoch u100) (var-get blocks-per-epoch))
    )
)

(define-read-only (get-current-epoch-nft-data)
    (get-epoch-nft-data (get-current-epoch))
)

;; Configuration

(begin
    (map-set epoch-nft-data u0 {nft-id: u3632, nft-contract: 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.bitgear-genesis})
    (map-set epoch-nft-data u1 {nft-id: u9, nft-contract: 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.odins-raven})
    (map-set epoch-nft-data u2 {nft-id: u3720, nft-contract: 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.bitgear-genesis})
    (map-set epoch-nft-data u3 {nft-id: u235, nft-contract: 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.welsh-punk})
    (ok true)
)

```
