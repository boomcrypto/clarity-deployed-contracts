
;; use the SIP009 interface
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)


(define-non-fungible-token dsa uint)

;; Define errors
(define-constant ERR_NOT_ENOUGH_STX (err u0))
(define-constant ERR_TOKEN_ID (err u1))
(define-constant ERR_SOLD_OUT (err u2))
(define-constant ERR_TRANSFER_FAIL (err u3))
(define-constant ERR_OWNER_ONLY (err u4))
(define-constant ERR_NOT_AUTHORIZED (err u5))
(define-constant ERR_LISTING (err u6))
(define-constant ERR_NO_OWNER (err u7))
(define-constant ERR_NOT_OWNER (err u8))
(define-constant ERR_WRONG_COMM (err u9))
(define-constant ERR_MAX_MINTED (err u10))
(define-constant ERR_MINT_PAUSED (err u11))
(define-constant ERR_FROZEN (err u12))

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
;; testnet
(define-constant LMNFT 'SPRTNMT0HRZC1JXK6YV9ZW2Q7X9B50G6QWNNG9E9)

;; Maps
(define-map market uint {price: uint, commission: principal})
(define-map token-count principal uint)

;; Define variables
(define-data-var last-id uint u0)
(define-data-var base-uri (string-ascii 80) "/")
(define-data-var mint-price uint u100000)
;; Percent u100 = 1%
(define-data-var royalty-percent uint u0)
(define-data-var mint-limit uint u5)
(define-data-var max-supply uint u1)
(define-data-var mint-paused bool true)
(define-data-var metadata-frozen bool false)



;; Mint a new NFT
(define-public (mint)
    (let 
    (
      (next-id (+ u1 (var-get last-id)))
      (fee (/ (var-get mint-price) u40))
      (mint-pay ( - (var-get mint-price) fee ))
      (current-balance (get-balance tx-sender))
    )
        (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender CONTRACT_OWNER)) ERR_MINT_PAUSED)
        (asserts! (< (var-get last-id) (var-get max-supply)) ERR_SOLD_OUT)
        (asserts! (< current-balance (var-get mint-limit)) ERR_MAX_MINTED)
        (asserts! (>=  (stx-get-balance tx-sender) (var-get mint-price) ) ERR_NOT_ENOUGH_STX)
        (asserts! (var-set last-id next-id) ERR_TOKEN_ID)
        (begin 
          (unwrap! (stx-transfer? mint-pay tx-sender CONTRACT_OWNER) ERR_TRANSFER_FAIL)
          (unwrap! (stx-transfer? fee tx-sender LMNFT) ERR_TRANSFER_FAIL)
          (try! (nft-mint? dsa next-id tx-sender))
          (map-set token-count tx-sender (+ current-balance u1))
        (ok next-id)
        )
    )
)

;; Airdrop mint
(define-public (airdrop (recipient principal))
    (let 
    (
      (next-id (+ u1 (var-get last-id)))
      (fee (/ (var-get mint-price) u40))
      (current-balance (get-balance tx-sender))
    )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
        (asserts! (< (var-get last-id) (var-get max-supply)) ERR_SOLD_OUT)
        (asserts! (>=  (stx-get-balance tx-sender) fee ) ERR_NOT_ENOUGH_STX)
        (asserts! (var-set last-id next-id) ERR_TOKEN_ID)
        (begin
          (unwrap! (stx-transfer? fee tx-sender LMNFT) ERR_TRANSFER_FAIL)
          (try! (nft-mint? dsa next-id recipient))
          (map-set token-count recipient (+ current-balance u1))
        (ok next-id)
        )
    )
)

;; SIP009: Transfer token to a specified principal
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
     (asserts! (is-eq tx-sender sender) ERR_NOT_AUTHORIZED)
     (asserts! (is-none (map-get? market id)) ERR_LISTING)
     (trnsfr id sender recipient)
  )
)

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? dsa id sender recipient)
        success
          (let
            (
              (sender-balance (get-balance sender))
              (recipient-balance (get-balance recipient))
            )
              (map-set token-count sender (- sender-balance u1))
              (map-set token-count recipient (+ recipient-balance u1))
              (ok success)
          )
        error (err error)
    )
)


;; Set functions

(define-public (set-price (price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (ok (var-set mint-price price))
  )
)

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (ok (var-set mint-limit limit))
  )
)

(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (ok (var-set mint-paused (not (var-get mint-paused))))
  )
)

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (asserts! (not (var-get metadata-frozen)) ERR_FROZEN)
    (ok (var-set base-uri new-base-uri))
  )
)

(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (ok (var-set metadata-frozen true))
  )
)

(define-public (launch (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (asserts! (not (var-get metadata-frozen)) ERR_FROZEN)
    (var-set base-uri new-base-uri)
    (var-set mint-paused false)
    (ok true)
  )
)

;; Read functions

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? dsa id))
)

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
    (ok (some (concat "ipfs://" (concat (concat (var-get base-uri) (uint-to-ascii id)) ".json"))))
)

(define-read-only (get-base-uri)
  (ok (var-get base-uri))
)

(define-read-only (get-mint-price)
  (ok (var-get mint-price))
)

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit))
)

(define-read-only (get-max-supply)
  (ok (var-get max-supply))
)

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent))
)

(define-read-only (get-mint-paused)
  (ok (var-get mint-paused))
)

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)
  )
)


;; Marketplace functions

(define-private (is-sender-owner (id uint))
  (let 
    (
      (owner (unwrap! (nft-get-owner? dsa id) false))
    )
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))
  )
)

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id)
)

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let 
    (
      (listing  {price: price, commission: (contract-of comm-trait)})
    )
    (asserts! (is-sender-owner id) ERR_NOT_AUTHORIZED)
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)
  )
)

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR_NOT_AUTHORIZED)
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)
  )
)

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let 
    (
      (owner (unwrap! (nft-get-owner? dsa id) ERR_NO_OWNER))
      (listing (unwrap! (map-get? market id) ERR_LISTING))
      (price (get price listing))
      (royalties (/ (* price  (var-get royalty-percent)) u10000 ))
      (pay-price (- price royalties))
    )
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR_WRONG_COMM)
    (try! (stx-transfer? pay-price tx-sender owner))
    (try! (pay-royalty royalties))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)
  )
)

(define-private (pay-royalty (royalties uint))
  (let 
    (
      (royalties-amount royalties)
    )
    (if (> (var-get royalty-percent) u0)
      (try! (stx-transfer? royalties-amount tx-sender CONTRACT_OWNER))
      (print false)
    )
    (ok true)
  )
)


;; Helpers

(define-private (uint-to-ascii (value uint))
  (if (<= value u9)
    (unwrap-panic (element-at "0123456789" value))
    (get r (fold uint-to-ascii-inner
      0x000000000000000000000000000000000000000000000000000000000000000000000000000000
      {v: value, r: ""}
    ))
  )
)

(define-private (uint-to-ascii-inner (i (buff 1)) (d {v: uint, r: (string-ascii 39)}))
  (if (> (get v d) u0)
    { 
      v: (/ (get v d) u10),
      r: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get v d) u10))) (get r d)) u39))
    }
    d
  )
)
