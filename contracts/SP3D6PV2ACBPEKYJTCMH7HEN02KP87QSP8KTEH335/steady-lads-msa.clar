;; Steady Lads MSA NFT collection by Megapont.
;; Technical partner: Apollo Labs, Inc.
;; EXCLUSIVE COMMERCIAL RIGHTS WITH NO CREATOR RETENTION ("CBE-EXCLUSIVE")
;; https://zzttkwj3ferbc4svr43g6b6aehbajrfri7tfkha4oug5gbpa4fxq.arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/1
(impl-trait .nft-trait.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token Steady-Lads-MSA uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})
(define-map airdrop-claimed uint bool)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)

;; Errors
(define-constant ERR-WRONG-COMMISSION (err u301))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-LISTING (err u406))
(define-constant ERR-AIRDROP-CLAIMED (err u407))

(define-data-var last-id uint u1)
(define-data-var contract-uri (string-ascii 80) "ipfs://QmUJMq4oBDnDRyM9cmWRBiHMXWea4ToFkFDnPD7j6GXKuS")
(define-data-var base-uri (string-ascii 80) "ipfs://WAIT/{id}")

(define-read-only (get-balance (account principal))
    (default-to u0
        (map-get? token-count account)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? Steady-Lads-MSA id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-id)))

;; SIP009: Get the token URI
(define-read-only (get-token-uri (id uint))
    (ok (some (var-get base-uri))))

(define-read-only (get-contract-uri)
    (ok  (var-get contract-uri)))

(define-read-only (get-listing-in-ustx (id uint))
    (map-get? market id))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
    (match (nft-transfer? Steady-Lads-MSA id sender recipient)
        success
            (let
                ((sender-balance (get-balance sender))
                    (recipient-balance (get-balance recipient)))
                (map-set token-count sender (- sender-balance u1))
                (map-set token-count recipient (+ recipient-balance u1))
                (ok success))
        error
            (err error)))

(define-private (is-sender-owner (id uint))
    (let
        ((owner (unwrap! (nft-get-owner? Steady-Lads-MSA id) false)))
        (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
    (begin
        ;; Only the owner of the token can transfer it
        (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
        (asserts! (is-none (map-get? market id)) ERR-LISTING)
        (trnsfr id sender recipient)))

(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
    (let ((listing  {price: price, commission: (contract-of comm)}))
        (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
        (map-set market id listing)
        (print (merge listing {action: "list-in-ustx", id: id}))
        (ok true)))

(define-public (unlist-in-ustx (id uint))
    (begin
        (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
        (map-delete market id)
        (print {action: "unlist-in-ustx", id: id})
        (ok true)))

(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
    (let ((owner (unwrap! (nft-get-owner? Steady-Lads-MSA id) ERR-NOT-FOUND))
        (listing (unwrap! (map-get? market id) ERR-LISTING))
        (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {action: "buy-in-ustx", id: id})
    (ok true)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set base-uri new-base-uri)
        (ok true)))

(define-public (set-contract-uri (new-contract-uri (string-ascii 80)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set contract-uri new-contract-uri)
        (ok true)))

(define-public (airdrop (steady-lad-id uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (default-to false (map-get? airdrop-claimed steady-lad-id)) false) ERR-AIRDROP-CLAIMED)
        (let
            ((new-owner (unwrap-panic (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads get-owner steady-lad-id)))))
        (match (nft-mint? Steady-Lads-MSA steady-lad-id new-owner)
            success
                (let
                    ((current-balance (get-balance new-owner)))
                    (begin
                        (map-set token-count new-owner (+ current-balance u1))
                        (map-set airdrop-claimed steady-lad-id true)
                (ok true)))
            error (err (* error u10000))))))
