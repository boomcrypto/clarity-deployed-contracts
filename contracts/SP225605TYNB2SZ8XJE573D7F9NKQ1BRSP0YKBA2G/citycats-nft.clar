(impl-trait .sip-009-nft-trait-standard.nft-trait)
(use-trait commission-trait .commission-trait.commission)

(define-non-fungible-token CityCats uint)

;; Storage
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; Define Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant CITYCATS-LIMIT u2050)

;; Define error codes
(define-constant ERR-SOLD-OUT (err u100))
(define-constant ERR-WRONG-COMMISSION (err u102))
(define-constant ERR-NOT-AUTHORIZED (err u103))
(define-constant ERR-NOT-FOUND (err u104))
(define-constant ERR-METADATA-FROZEN (err u105))
(define-constant ERR-MINT-ALREADY-SET (err u106))
(define-constant ERR-LISTING (err u107))
(define-constant ERR-FAILED-TO-TRANSFER-STX (err u108))
(define-constant ERR-NOT-OWNER (err u109))

;; Withdraw wallets
;; Citycats 1 3%
(define-constant WALLET_1 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
;; Citycats 2 97%
(define-constant WALLET_2 'SP30AYNXCNBTMANSZHZ0FVVGM7W5WF5BJZDX7NW3)

;; Define Variables
(define-data-var last-id uint u0)
(define-data-var metadata-frozen bool false)

;; Store the root token uri used to query metadata
(define-data-var base-token-uri (string-ascii 210) "ipfs://Qmdy9aXsXJpZNrNaDtqKdFQecJkXMeWa2XhcSmWkdk9t51/")

;; Store the mint address allowed to trigger minting
(define-map mint-address bool principal)

;; Token count for account
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? CityCats id sender recipient)
        success
          (let
            ((sender-balance (get-balance sender))
            (recipient-balance (get-balance recipient)))
              (map-set token-count
                    sender
                    (- sender-balance u1))
              (map-set token-count
                    recipient
                    (+ recipient-balance u1))
              (ok success))
        error (err error)))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  ;; Make sure to replace Citycats
  (ok (nft-get-owner? CityCats id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get base-token-uri) (uint-to-string token-id)) ".json"))))

;; Mint new NFT - can only be called from the mint address
(define-public (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) CITYCATS-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? CityCats next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (try! (stx-transfer? u1500000 tx-sender WALLET_1)) ;; 3 %
            (try! (stx-transfer? u48500000 tx-sender WALLET_2)) ;; 97 %
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))))

(define-public (treasure-mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
      (asserts! (called-from-mint) ERR-NOT-AUTHORIZED)
      (asserts! (< (var-get last-id) CITYCATS-LIMIT) ERR-SOLD-OUT)
      (match (nft-mint? CityCats next-id new-owner)
        success
        (let
        ((current-balance (get-balance new-owner)))
          (begin
            (var-set last-id next-id)
            (map-set token-count
              new-owner
              (+ current-balance u1)
            )
            (ok true)))
        error (err (* error u10000)))))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? CityCats id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

;; Marketplace function
(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

;; Marketplace function
(define-public (list-in-ustx (id uint) (price uint) (comm <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm)}))
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

;; Marketplace function
(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-AUTHORIZED)
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

;; Marketplace function
(define-public (buy-in-ustx (id uint) (comm <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? CityCats id) ERR-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; Manage function
(define-public (burn (id uint))
    (let ((owner (unwrap! (nft-get-owner? CityCats id) ERR-NOT-AUTHORIZED)))
        (asserts! (is-eq owner contract-caller) ERR-NOT-OWNER)
        (map-delete market id)
        (nft-burn? CityCats id contract-caller)
    )
)

;; Set base token uri
(define-public (set-base-token-uri (new-base-token-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get metadata-frozen)) ERR-METADATA-FROZEN)
    (var-set base-token-uri new-base-token-uri)
    (ok true)))

;; Reveal
(define-public (reveal (reveal-uri (string-ascii 80)))
  (begin
    (try! (set-base-token-uri reveal-uri))
    (ok true)))

;; Freeze metadata
(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set metadata-frozen true)
    (ok true)))

;; Manage the Mint
(define-private (called-from-mint)
  (let ((the-mint
          (unwrap! (map-get? mint-address true)
                    false)))
    (is-eq contract-caller the-mint)))

;; Set mint address - can only be called once
(define-public (set-mint-address)
  (let ((the-mint (map-get? mint-address true)))
    (asserts! (and (is-none the-mint)
              (map-insert mint-address true tx-sender))
                ERR-MINT-ALREADY-SET)
    (ok tx-sender)))

;; Utils to convert an uint to string
;; Clarity doesn't support uint-to-string natively for now
;; Code for uint to string
(define-constant LIST_40 (list
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
  true true true true true true true true true true
))

(define-read-only (uint-to-string (value uint))
  (get return (fold uint-to-string-clojure LIST_40 {value: value, return: ""}))
)

(define-read-only (uint-to-string-clojure (i bool) (data {value: uint, return: (string-ascii 40)}))
  (if (> (get value data) u0)
    {
      value: (/ (get value data) u10),
      return: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get value data) u10))) (get return data)) u40))
    }
    data
  )
)