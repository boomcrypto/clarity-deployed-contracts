;; Storage
(define-map claimed-apes uint bool)

;; Define Constants
(define-constant mint-price u20000000)

;; Define error codes
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-ALREADY-CLAIMED (err u402))
(define-constant ERR-SALE-NOT-ACTIVE (err u500))

;; Define Variables
(define-data-var sale-active bool false)

;; Sender has a robot
(define-private (has-robot)
  (asserts! (> (contract-call? .megapont-robot-nft get-balance tx-sender) u0) false))

;; Claimed apes
(define-read-only (ape-has-claimed (ape uint))
  (default-to false
    (map-get? claimed-apes ape)))

;; Claim a Robot and Component NFTs
(define-public (claim-freebie (ape uint))
  (begin
      (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
      (asserts! (is-eq (ape-has-claimed ape) false) ERR-ALREADY-CLAIMED)
      (asserts! (is-eq tx-sender (unwrap-panic (unwrap-panic (contract-call? .megapont-ape-club-nft get-owner ape)))) ERR-NOT-AUTHORIZED)
      (map-set claimed-apes ape true)
      (freebie-mint tx-sender)))

;; Claim a Component crate, which is just syntax sugar for claiming
;; five Component NFTs
(define-public (claim)
  (begin
    (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
    (asserts! (is-eq (has-robot) true) ERR-NOT-AUTHORIZED)
    (try! (mint-component tx-sender))
    (try! (mint-component tx-sender))
    (try! (mint-component tx-sender))
    (try! (mint-component tx-sender))
    (try! (mint-component tx-sender))
    (ok true)))

(define-public (claim-two)
  (begin
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-three)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-four)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-five)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-six)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-seven)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-eight)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-nine)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))

(define-public (claim-ten)
  (begin
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (try! (claim))
    (ok true)))


;; Mints both a Robot and Component Crate
(define-private (freebie-mint (new-owner principal))
  (begin
    (try! (mint-freebie-component new-owner))
    (try! (mint-robot new-owner))
    (ok true)))

;; Mint a Component NFT
(define-private (mint-component (new-owner principal))
  (contract-call? .megapont-robot-component-nft mint new-owner))

;; Claim a Component crate for holding an Ape this is
;; just syntax sugar for claiming five Component NFTs
(define-private (mint-freebie-component (new-owner principal))
  (begin
    (try! (contract-call? .megapont-robot-component-nft freebie-mint new-owner))
    (try! (contract-call? .megapont-robot-component-nft freebie-mint new-owner))
    (try! (contract-call? .megapont-robot-component-nft freebie-mint new-owner))
    (try! (contract-call? .megapont-robot-component-nft freebie-mint new-owner))
    (try! (contract-call? .megapont-robot-component-nft freebie-mint new-owner))
    (ok true)))

;; Mint a Robot NFT
(define-private (mint-robot (new-owner principal))
  (contract-call? .megapont-robot-nft mint new-owner))

;; Set the sale flag
(define-public (flip-sale)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set sale-active (not (var-get sale-active)))
    (ok (var-get sale-active))))

;; Set the mint address for both Robot and Component NFTs
(as-contract (contract-call? .megapont-robot-nft set-mint-address))
(as-contract (contract-call? .megapont-robot-component-nft set-mint-address))
