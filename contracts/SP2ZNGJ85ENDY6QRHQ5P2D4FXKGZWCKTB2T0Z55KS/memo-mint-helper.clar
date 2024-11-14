;; Title: MemoBots: Mint Helper
;; Author: SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS
;; Created With Charisma
;; https://charisma.rocks

;; Description:
;; Every Giga Pepe has their trusted robot guardian Memo!

;; Define constants
(define-constant STX_PER_NFT u5000000) ;; 5 STX per MINT base cost
(define-constant ENERGY_DISCOUNT_RATE u10) ;; 10 energy = 1 uSTX discount
(define-constant MIN_STX_PRICE u1) ;; Minimum price of 1 STX

(define-public (mint (land-id uint) (nfts-to-mint uint))
    (let
        (
            (tapped-out (unwrap-panic (contract-call? .edk-v0 tap land-id .land-helper-v3 (some (* (/ STX_PER_NFT ENERGY_DISCOUNT_RATE) nfts-to-mint)))))
            (energy-spend (get energy tapped-out))
            (stx-discount (* energy-spend ENERGY_DISCOUNT_RATE))
            (stx-discount-per-nft (/ stx-discount nfts-to-mint))
            (stx-cost-per-nft (max (- STX_PER_NFT stx-discount-per-nft) MIN_STX_PRICE))
        )
        (unwrap-panic (contract-call? .memobots-guardians-of-the-gigaverse set-mint-cost-stx stx-cost-per-nft))
        (contract-call? .memobots-guardians-of-the-gigaverse mint-multiple tx-sender nfts-to-mint)
    )
)

;; Utility function to get the maximum of two uints
(define-private (max (a uint) (b uint))
  (if (>= a b) a b)
)