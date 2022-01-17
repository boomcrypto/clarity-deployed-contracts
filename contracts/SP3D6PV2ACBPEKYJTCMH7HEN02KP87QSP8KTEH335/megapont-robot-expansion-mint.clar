;; Storage
(define-map claimed-apes uint bool)

;; Define error codes
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-ALREADY-CLAIMED (err u402))

;; Claimed apes
(define-read-only (ape-has-claimed (ape uint))
  (if (is-none (map-get? claimed-apes ape))
    (contract-call? .megapont-robot-mint ape-has-claimed ape)
    true))

;; Claim a Robot and Component NFTs
(define-public (claim-freebie (ape uint))
  (begin
      (asserts! (is-eq (ape-has-claimed ape) false) ERR-ALREADY-CLAIMED)
      ;; Check if the Ape claimed on the prior Robot contract
      (asserts! (is-eq false (contract-call? .megapont-robot-mint ape-has-claimed ape)) ERR-ALREADY-CLAIMED)
      (asserts! (is-eq tx-sender (unwrap-panic (unwrap-panic (contract-call? .megapont-ape-club-nft get-owner ape)))) ERR-NOT-AUTHORIZED)
      (map-set claimed-apes ape true)
      (freebie-mint tx-sender)))

;; Mints both a Robot and Component Crate
(define-private (freebie-mint (new-owner principal))
  (begin
    ;; These Apes needed to wait and because of this they get 2 component crates
    ;; or 10 components
    (try! (mint-freebie-component new-owner))
    (try! (mint-freebie-component new-owner))
    (try! (mint-robot new-owner))
    (ok true)))

;; Mint a Component NFT
(define-private (mint-component (new-owner principal))
  (contract-call? .megapont-robot-component-expansion-nft mint new-owner))

;; Claim a Component crate for holding an Ape this is
;; just syntax sugar for claiming five Component NFTs
(define-private (mint-freebie-component (new-owner principal))
  (begin
    (try! (contract-call? .megapont-robot-component-expansion-nft mint new-owner))
    (try! (contract-call? .megapont-robot-component-expansion-nft mint new-owner))
    (try! (contract-call? .megapont-robot-component-expansion-nft mint new-owner))
    (try! (contract-call? .megapont-robot-component-expansion-nft mint new-owner))
    (try! (contract-call? .megapont-robot-component-expansion-nft mint new-owner))
    (ok true)))

;; Mint a Robot NFT
(define-private (mint-robot (new-owner principal))
  (contract-call? .megapont-robot-expansion-nft mint new-owner))

(contract-call? .megapont-robot-expansion-nft approve-minter)
(contract-call? .megapont-robot-component-expansion-nft approve-minter)
