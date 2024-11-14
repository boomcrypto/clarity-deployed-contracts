---
title: "Trait test-memo-1"
draft: true
---
```
;; Title: MemoBots: Guardians of the Gigaverse
;; Author: SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS
;; Created With Charisma
;; https://charisma.rocks

;; Description:
;; Every Giga Pepe has their trusted robot guardian Memo!

;; This contract implements the SIP-009 community-standard Non-Fungible Token trait
(impl-trait .dao-traits-v2.nft-trait)

;; Define the NFT's name
(define-non-fungible-token memobots-guardians-of-the-gigaverse uint)

;; Keep track of the last minted token ID
(define-data-var last-token-id uint u0)

;; Keep track of the mint price globally
(define-data-var mint-cost-stx uint u5000000)

;; Define constants
(define-constant COLLECTION_LIMIT u1300) ;; Limit to series of 1300
(define-constant STX_PER_MINT u5000000) ;; 5 STX per MINT base cost
(define-constant MAX_NFTS_PER_TX u4) ;; Maximum 4 NFTs per transaction
(define-constant OWNER 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R) ;; Collection creator
(define-constant CHA_AMOUNT (* u5 STX_PER_MINT)) ;; 25.000000 CHA per mint to creator
(define-constant ENERGY_DISCOUNT_RATE u1000) ;; 1000 energy = 1 STX discount
(define-constant MIN_STX_PRICE u1) ;; Minimum price of 1 STX

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u200))
(define-constant ERR_SOLD_OUT (err u300))
(define-constant ERR_INVALID_EDK (err u400))
(define-constant ERR_INVALID_CDK (err u500))
(define-constant ERR_ALREADY_CLAIMED (err u600))

(define-data-var base-uri (string-ascii 200) "https://charisma.rocks/api/v0/nfts/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.memobots-guardians-of-the-gigaverse/{id}.json")

;; Map to track which addresses have already claimed
(define-map claimed principal bool)

;; Whitelisted contract addresses
(define-map whitelisted-edks principal bool)
(define-map whitelisted-cdks principal bool)

;; New map to keep track of NFT balances
(define-map token-balances principal uint)


(define-trait cdk-trait
	(
		(tap (uint) (response (tuple (type (string-ascii 256)) (land-id uint) (land-amount uint) (energy uint)) uint))
	)
)

(define-trait edk-trait
	(
		(tap (uint <cdk-trait> (optional uint)) (response (tuple (type (string-ascii 256)) (land-id uint) (land-amount uint) (energy uint)) uint))
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

(define-public (set-whitelisted-cdk (cdk principal) (whitelisted bool))
    (begin
        (try! (is-authorized))
        (ok (map-set whitelisted-cdks cdk whitelisted))
    )
)

(define-read-only (is-whitelisted-cdk (cdk principal))
    (default-to false (map-get? whitelisted-cdks cdk))
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
  (ok (nft-get-owner? memobots-guardians-of-the-gigaverse token-id))
)

(define-private (is-owner (id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? memobots-guardians-of-the-gigaverse id) false))
)

(define-public (burn (id uint))
  	(begin 
    	(asserts! (is-owner id tx-sender) ERR_NOT_TOKEN_OWNER)
    	(nft-burn? memobots-guardians-of-the-gigaverse id tx-sender)
	)
)

;; New function to get the balance of NFTs for a principal
(define-read-only (get-balance (account principal))
  (ok (default-to u0 (map-get? token-balances account)))
)

;; SIP-009 function: Transfer NFT token to another owner.
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
    (match (nft-transfer? memobots-guardians-of-the-gigaverse token-id sender recipient)
      success
        (begin
          (map-set token-balances sender (- (default-to u0 (map-get? token-balances sender)) u1))
          (map-set token-balances recipient (+ (default-to u0 (map-get? token-balances recipient)) u1))
          (ok success)
        )
      error (err error)
    )
  )
)

;; Mint a new NFT.
(define-private (mint (recipient principal))
  ;; Create the new token ID by incrementing the last minted ID.
  (let ((token-id (+ (var-get last-token-id) u1)))
    ;; Ensure the collection stays within the limit.
    (asserts! (< (var-get last-token-id) COLLECTION_LIMIT) ERR_SOLD_OUT)
    ;; Mint the NFT and send it to the given recipient.
    (try! (nft-mint? memobots-guardians-of-the-gigaverse token-id recipient))
    ;; 1 STX cost send to dungeon-master
    (try! (stx-transfer? (var-get mint-cost-stx) tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master))
    ;; Mint 1 governance token to the OWNER
    (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint CHA_AMOUNT OWNER))
    ;; Update the last minted token ID.
    (var-set last-token-id token-id)
    ;; Update the balance for the recipient
    (map-set token-balances recipient (+ (default-to u0 (map-get? token-balances recipient)) u1))
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

;; (define-public (tap (land-id uint) (cdk-contract <cdk-trait>) (energy-out-max (optional uint)) (edk-contract <edk-trait>) (nfts-to-mint uint))
;;     (let
;;         (
;;             (tapped-out (unwrap-panic (contract-call? edk-contract tap land-id cdk-contract energy-out-max)))
;;             (energy-spend (get energy tapped-out))
;;             (cost-before-discount (* STX_PER_MINT nfts-to-mint))
;;             (safe-energy-spend (min (* cost-before-discount ENERGY_DISCOUNT_RATE) energy-spend))
;;             (stx-discount (/ safe-energy-spend ENERGY_DISCOUNT_RATE))
;;             (cost-after-discount (max (* MIN_STX_PRICE nfts-to-mint) (- cost-before-discount stx-discount)))
;;         )
;;         (asserts! (is-whitelisted-edk (contract-of edk-contract)) ERR_INVALID_EDK)
;;         (asserts! (is-whitelisted-cdk (contract-of cdk-contract)) ERR_INVALID_CDK)
;;         (var-set mint-cost-stx cost-after-discount)
;;         (mint-multiple tx-sender nfts-to-mint)
;;     )
;; )

;; (define-read-only (is-gigapepe-owner)
;;     (ok (asserts! (> u0 (unwrap-panic (contract-call? 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R.giga-pepe-v2 get-balance tx-sender))) ERR_UNAUTHORIZED))
;; )

;; (define-public (whitelist-mint)
;;     (begin
;;         (try! (is-gigapepe-owner))
;;         ;; Check if the recipient has already claimed
;;         (asserts! (is-none (map-get? claimed tx-sender)) ERR_ALREADY_CLAIMED)
;;         ;; Mark the recipient as having claimed
;;         (map-set claimed tx-sender true)
;;         ;; Create the new token ID by incrementing the last minted ID.
;;         (let ((token-id (+ (var-get last-token-id) u1)))
;;             ;; Ensure the collection stays within the limit.
;;             (asserts! (< (var-get last-token-id) COLLECTION_LIMIT) ERR_SOLD_OUT)
;;             ;; Mint the NFT and send it to the given recipient.
;;             (try! (nft-mint? memobots-guardians-of-the-gigaverse token-id tx-sender))
;;             ;; Mint 1 governance token to the OWNER
;;             (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint u1000000 OWNER))
;;             ;; Update the last minted token ID.
;;             (var-set last-token-id token-id)
;;             ;; Update the balance for the recipient
;;             (map-set token-balances tx-sender (+ (default-to u0 (map-get? token-balances tx-sender)) u1))
;;             ;; Return the newly minted NFT ID.
;;             (ok token-id)
;;         )
;;     )
;; )

;; Utility function to get the minimum of two uints
(define-private (min (a uint) (b uint))
  (if (<= a b) a b)
)

;; Utility function to get the maximum of two uints
(define-private (max (a uint) (b uint))
  (if (>= a b) a b)
)
```
