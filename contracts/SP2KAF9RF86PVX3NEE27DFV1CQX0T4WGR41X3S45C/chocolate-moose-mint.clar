;; Storage
(define-map presale-count principal uint)

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SALE-NOT-ACTIVE (err u500))


;; Claim a new NFT
(define-public (claim)
    (public-mint tx-sender))

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal))
  (begin
    ;; (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (contract-call? .chocolate-moose-nft mint new-owner)))

(as-contract (contract-call? .chocolate-moose-nft set-mint-address))