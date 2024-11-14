;; Title: MemoBots Helper
;; Author: SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS
;; Created With Charisma
;; https://charisma.rocks

;; Description:
;; Every Giga Pepe has their trusted robot guardian Memo!

(use-trait cdk-trait .dao-traits-v4.cdk-trait)
(use-trait edk-trait .dao-traits-v4.edk-trait)

;; Define constants
(define-constant STX_PER_MINT u5000000) ;; 5 STX per MINT base cost
(define-constant ENERGY_DISCOUNT_RATE u1000) ;; 1000 energy = 1 STX discount
(define-constant MIN_STX_PRICE u1) ;; Minimum price of 1 STX

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_EDK (err u401))
(define-constant ERR_INVALID_CDK (err u402))
(define-constant ERR_ALREADY_CLAIMED (err u403))

;; Map to track which addresses have already claimed
(define-map claimed principal bool)

;; Whitelisted contract addresses
(define-map whitelisted-edks principal bool)
(define-map whitelisted-cdks principal bool)

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

(define-public (tap (land-id uint) (cdk-contract <cdk-trait>) (energy-out-max (optional uint)) (edk-contract <edk-trait>) (nfts-to-mint uint))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? edk-contract tap land-id cdk-contract energy-out-max)))
            (energy-spend (get energy tapped-out))
            (cost-before-discount (* STX_PER_MINT nfts-to-mint))
            (stx-discount (/ energy-spend ENERGY_DISCOUNT_RATE))
            (cost-after-discount (max (* MIN_STX_PRICE nfts-to-mint) (- cost-before-discount stx-discount)))
        )
        (asserts! (is-whitelisted-edk (contract-of edk-contract)) ERR_INVALID_EDK)
        (asserts! (is-whitelisted-cdk (contract-of cdk-contract)) ERR_INVALID_CDK)
        (unwrap-panic (contract-call? .memobots-guardians-of-the-gigaverse set-mint-cost-stx cost-after-discount))
        (contract-call? .memobots-guardians-of-the-gigaverse mint-multiple tx-sender nfts-to-mint)
    )
)

(define-read-only (is-gigapepe-owner)
    (ok (asserts! (> (contract-call? 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R.giga-pepe-v2 get-balance tx-sender) u0) ERR_UNAUTHORIZED))
)

(define-public (whitelist-mint)
    (begin
        (try! (is-gigapepe-owner))
        ;; Check if the recipient has already claimed
        (asserts! (is-none (map-get? claimed tx-sender)) ERR_ALREADY_CLAIMED)
        ;; Mark the recipient as having claimed
        (map-set claimed tx-sender true)
        (unwrap-panic (contract-call? .memobots-guardians-of-the-gigaverse set-mint-cost-stx u1))
        (contract-call? .memobots-guardians-of-the-gigaverse mint-multiple tx-sender u1)
    )
)

;; Utility function to get the minimum of two uints
(define-private (min (a uint) (b uint))
  (if (<= a b) a b)
)

;; Utility function to get the maximum of two uints
(define-private (max (a uint) (b uint))
  (if (>= a b) a b)
)