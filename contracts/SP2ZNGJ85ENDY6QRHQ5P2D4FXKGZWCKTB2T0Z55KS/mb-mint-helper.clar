;; Title: MemoBots: Mint Helper
;; Author: SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS
;; Created With Charisma
;; https://charisma.rocks

;; Description:
;; Every Giga Pepe has their trusted robot guardian Memo!

;; Define constants
(define-constant STX_PER_NFT u5000000) ;; 5 STX per MINT base cost
(define-constant ENERGY_DISCOUNT_RATE u10) ;; 1 energy = 10 uSTX discount
(define-constant MIN_STX_PRICE u1) ;; Minimum price of 1 STX

(define-public (mint (land-id uint) (nfts-to-mint uint) (energy-max-out (optional uint)))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .edk-v1 tap land-id .land-helper-v3 energy-max-out)))
            (energy-spend (get energy tapped-out))
            (stx-discount (* energy-spend ENERGY_DISCOUNT_RATE))
            (stx-discount-per-nft (/ stx-discount nfts-to-mint))
            (stx-cost-per-nft (max (- STX_PER_NFT stx-discount-per-nft) MIN_STX_PRICE))
        )
        (print {a: tapped-out, b: energy-spend, c: stx-discount, d: stx-discount-per-nft, e: stx-cost-per-nft})
        (unwrap-panic (contract-call? .memobots-guardians-of-the-gigaverse set-mint-cost-stx stx-cost-per-nft))
        (contract-call? .memobots-guardians-of-the-gigaverse mint-multiple tx-sender nfts-to-mint)
    )
)

(define-public (test-a (land-id uint) (nfts-to-mint uint) (energy-max-out (optional uint)))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .edk-v1 tap land-id .land-helper-v3 energy-max-out)))
            (energy-spend (get energy tapped-out))
            (stx-discount (* energy-spend ENERGY_DISCOUNT_RATE))
            (stx-discount-per-nft (/ stx-discount nfts-to-mint))
            (stx-cost-per-nft (max (- STX_PER_NFT stx-discount-per-nft) MIN_STX_PRICE))
        )
        (print {a: tapped-out, b: energy-spend, c: stx-discount, d: stx-discount-per-nft, e: stx-cost-per-nft})
        (ok true)
    )
)

(define-public (test-b (land-id uint) (nfts-to-mint uint) (energy-max-out (optional uint)))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .edk-v0 tap land-id .land-helper-v3 energy-max-out)))
            (energy-spend (get energy tapped-out))
            (stx-discount (* energy-spend ENERGY_DISCOUNT_RATE))
            (stx-discount-per-nft (/ stx-discount nfts-to-mint))
            (stx-cost-per-nft (max (- STX_PER_NFT stx-discount-per-nft) MIN_STX_PRICE))
        )
        (print {a: tapped-out, b: energy-spend, c: stx-discount, d: stx-discount-per-nft, e: stx-cost-per-nft})
        (ok true)
    )
)

;; Utility function to get the maximum of two uints
(define-private (max (a uint) (b uint))
  (if (>= a b) a b)
)