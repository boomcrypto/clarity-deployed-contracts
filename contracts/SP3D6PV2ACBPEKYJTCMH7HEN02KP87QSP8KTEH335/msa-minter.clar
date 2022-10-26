;; Storage
(define-map airdrop-completed uint bool)

;; Constants
(define-constant MINT-PRICE u50000000)

;; Errors
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-AIRDROP-DONE (err u402))
(define-constant ERR-SALE-NOT-ACTIVE (err u500))

;; Variables
(define-data-var sale-active bool false)

(define-read-only (has-airdrop-completed (id uint))
    (default-to false (map-get? airdrop-completed id)))

(define-private (mnt (new-owner principal) (orders (list 50 principal)))
    (contract-call? .msa-nft mint-many new-owner orders))

(define-public (flip-sale)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set sale-active (not (var-get sale-active)))
        (ok (var-get sale-active))))

(define-public (airdrop (id uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (is-none (map-get? airdrop-completed id)) ERR-AIRDROP-DONE)
        (contract-call? .msa-nft airdrop
            (unwrap-panic (unwrap-panic (contract-call? .megapont-ape-club-nft get-owner id))) id)))

(define-public (mint)
    (begin
        (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
        (try! (mnt tx-sender (list tx-sender)))
        (ok true)))

;; mint two
(define-public (mint-two)
    (begin
        (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
        (try! (mnt tx-sender (list tx-sender tx-sender)))
        (ok true)))

;; mint five
(define-public (mint-five)
    (begin
        (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
        (try! (mnt tx-sender (list tx-sender tx-sender tx-sender tx-sender tx-sender)))
        (ok true)))

;; mint ten
(define-public (mint-ten)
    (begin
        (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
        (try! (mnt tx-sender (list tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender)))
        (ok true)))

;; mint twenty
(define-public (mint-twenty)
    (begin
        (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
        (try! (mnt tx-sender (list tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender)))
        (ok true)))

;; mint fifty
(define-public (mint-fifty)
    (begin
        (asserts! (var-get sale-active) ERR-SALE-NOT-ACTIVE)
        (try! (mnt tx-sender (list tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender
            tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender
            tx-sender tx-sender tx-sender tx-sender tx-sender tx-sender)))
        (ok true)))

(as-contract (contract-call? .msa-nft set-mint-address))
