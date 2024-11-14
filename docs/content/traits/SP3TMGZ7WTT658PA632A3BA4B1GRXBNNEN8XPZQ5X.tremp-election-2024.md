---
title: "Trait tremp-election-2024"
draft: true
---
```
;; Title: TREMP ELECTION 2024
;; Author: SP3TMGZ7WTT658PA632A3BA4B1GRXBNNEN8XPZQ5X
;; Created With Charisma
;; https://charisma.rocks

;; Description:
;; Each holder of a "TREMP WINS 2024" NFT will receive 100,000 TREMP IF Trump wins the election!

;; This contract implements the SIP-009 community-standard Non-Fungible Token trait
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Define the NFT's name
(define-non-fungible-token tremp-election-2024 uint)

;; Keep track of the last minted token ID
(define-data-var last-token-id uint u0)

;; Define constants
(define-constant COLLECTION_LIMIT u100) ;; Limit to series of 100
(define-constant ENERGY_PER_NFT u50) ;; 50 energy per NFT
(define-constant STX_PER_MINT u3000000) ;; 3 STX per MINT for DAO
(define-constant MAX_NFTS_PER_TX u4) ;; Maximum 4 NFTs per transaction
(define-constant OWNER 'SP3TMGZ7WTT658PA632A3BA4B1GRXBNNEN8XPZQ5X) ;; Collection creator
(define-constant CHA_AMOUNT (* u5 STX_PER_MINT)) ;; 15.000000 CHA per mint to creator

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_SOLD_OUT (err u300))
(define-constant ERR_INVALID_EDK (err u400))

(define-data-var base-uri (string-ascii 200) "https://charisma.rocks/api/v0/nfts/SP3TMGZ7WTT658PA632A3BA4B1GRXBNNEN8XPZQ5X.tremp-election-2024/{id}.json")

;; Whitelisted contract addresses
(define-map whitelisted-edks principal bool)

(define-trait edk-trait
	(
		(tap (uint) (response (tuple (type (string-ascii 256)) (land-id uint) (land-amount uint) (energy uint)) uint))
	)
)

;; Authorization check
(define-private (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
    (ok (asserts! (is-dao-or-extension) ERR_UNAUTHORIZED))
)

;; Whitelist functions
(define-public (set-whitelisted-edk (edk principal) (whitelisted bool))
    (begin
        (try! (is-authorized))
        (ok (map-set whitelisted-edks edk whitelisted))
    )
)

(define-read-only (is-whitelisted-edk (edk principal))
    (default-to false (map-get? whitelisted-edks edk))
)

;; SIP-009 function: Get the last minted token ID.
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

;; SIP-009 function: Get link where token metadata is hosted
(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get base-uri)))
)

;; Function to update the token URI
(define-public (set-token-uri (new-uri (string-ascii 200)))
  (begin
    (try! (is-authorized))
    (ok (var-set base-uri new-uri))
  )
)

;; SIP-009 function: Get the owner of a given token
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? tremp-election-2024 token-id))
)

;; SIP-009 function: Transfer NFT token to another owner.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    ;; #[filter(sender)]
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
    (nft-transfer? tremp-election-2024 token-id sender recipient)
  )
)

;; Mint a new NFT.
(define-private (mint (recipient principal))
  ;; Create the new token ID by incrementing the last minted ID.
  (let ((token-id (+ (var-get last-token-id) u1)))
    ;; Ensure the collection stays within the limit.
    (asserts! (< (var-get last-token-id) COLLECTION_LIMIT) ERR_SOLD_OUT)
    ;; Mint the NFT and send it to the given recipient.
    (try! (nft-mint? tremp-election-2024 token-id recipient))
    ;; 1 STX cost send to dungeon-master
    (try! (stx-transfer? STX_PER_MINT tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master))
    ;; Mint 1 governance token to the OWNER
    (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint CHA_AMOUNT OWNER))
    ;; Update the last minted token ID.
    (var-set last-token-id token-id)
    ;; Return the newly minted NFT ID.
    (ok token-id)
  )
)


;; Mint multiple NFTs based on the count (1 to 4)
(define-private (mint-multiple (recipient principal) (count uint))
  (if (is-eq count u1) (mint recipient)
  (if (is-eq count u2) (begin (try! (mint recipient)) (mint recipient))
  (if (is-eq count u3) (begin (try! (mint recipient)) (try! (mint recipient)) (mint recipient))
  (if (is-eq count u4) (begin (try! (mint recipient)) (try! (mint recipient)) (try! (mint recipient)) (mint recipient))
  (err u500)
)))))

;; Quest logic
(define-public (tap (land-id uint) (edk-contract <edk-trait>))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? edk-contract tap land-id)))
            (energy (get energy tapped-out))
            (nfts-to-mint (min (/ energy ENERGY_PER_NFT) MAX_NFTS_PER_TX))
        )
        (asserts! (is-whitelisted-edk (contract-of edk-contract)) ERR_INVALID_EDK)
        (mint-multiple tx-sender nfts-to-mint)
    )
)

(define-read-only (get-untapped-amount (land-id uint) (user principal))
    (let
        (
            (untapped-energy (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-untapped-amount land-id user)))
            (nfts-available (min (/ untapped-energy ENERGY_PER_NFT) MAX_NFTS_PER_TX))
        )
        nfts-available
    )
)

;; Utility function to get the minimum of two uints
(define-private (min (a uint) (b uint))
  (if (<= a b) a b)
)

```
