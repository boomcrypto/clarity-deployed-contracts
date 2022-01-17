;; Constants
(define-constant mint-price u0)
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-SALE-NOT-ACTIVE (err u500))

;; Variables
(define-data-var sale-active bool false)

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
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (contract-call? .stockings mint new-owner)))

;; Set public sale flag
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    ;; Disable the Mintpass sale
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

;; Register this contract as allowed to mint
(as-contract (contract-call? .stockings set-mint-address))
