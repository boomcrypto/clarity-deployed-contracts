;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SALE-NOT-ACTIVE (err u500))


;; Claim a new NFT
(define-public (claim)
    (public-mint tx-sender))

(define-public (claim-two)
  (begin
    (try! (claim))
    (try! (claim))
    (ok true)))

;; Internal - Mint public sale NFT
(define-private (public-mint (new-owner principal))
  (begin
    ;; (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (contract-call? .steady-lads mint new-owner)))

(as-contract (contract-call? .steady-lads set-mint-address))