(impl-trait .sip009-nft-trait.sip009-nft-trait)

(define-non-fungible-token arkadroids uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant mint-limit u122)

(define-constant err-not-token-owner (err u101))
(define-constant err-mint-limit-reached (err u102));;
(define-constant err-non-admin-user (err u103))
(define-constant err-listed (err u105))
(define-constant err-listing-not-found (err u106))
(define-constant err-wrong-commission-implementation (err u107))
(define-constant err-token-not-found (err u108))
(define-constant err-metadata-frozen (err u111))

;; Internal variables
(define-data-var last-token-id uint u1)
(define-data-var curator-address principal 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR)
(define-data-var metadata-frozen bool false)
(define-data-var ipfs-root (string-ascii 80) "ipfs://QmWp6KZyebAoXqK4euKNagD1RVZRFvHvdGDD99c4DWo862/")

;; Maps
(define-map token-count principal uint)
(define-map market uint { price: uint, commission: principal })

;; Traits
(define-trait commission-trait 
  ((pay (uint uint) (response bool uint)))
)


;; Read-only
(define-read-only (get-last-token-id)
  (ok (- (var-get last-token-id) u1))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json")))
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? arkadroids token-id))
)

(define-read-only (get-balance (account principal))
  (default-to u0 (map-get? token-count account))
)

(define-read-only (get-listing-in-ustx (token-id uint))
  (map-get? market token-id)
)

;; Public

;; Non-Custodial
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-sender-owner token-id) err-not-token-owner)
    (asserts! (is-none (map-get? market token-id)) err-listed)
    (trnsfr token-id sender recipient)
  )
)

(define-public (mint)
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-admin-user tx-sender) err-non-admin-user)
    (asserts! (<= token-id mint-limit) err-mint-limit-reached)
    (mint-many (list true))
  )
)

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-sender-owner token-id) err-not-token-owner)
    (nft-burn? arkadroids token-id tx-sender)
  )
)

(define-public (list-in-ustx (token-id uint) (price uint) (commission-trait-implementation <commission-trait>))
  (let 
    (
      (listing  {price: price, commission: (contract-of commission-trait-implementation)})
    )
    (asserts! (is-sender-owner token-id) err-not-token-owner)
    (map-set market token-id listing)
    (print (merge listing {a: "list-in-ustx", token-id: token-id}))
    (ok true)
  )
)

(define-public (unlist-in-ustx (token-id uint))
  (begin
    (asserts! (is-sender-owner token-id) err-not-token-owner)
    (map-delete market token-id)
    (print { a: "unlist-in-ustx", token-id: token-id })
    (ok true)
  )
)

(define-public (buy-in-ustx (token-id uint) (commission-trait-implementation <commission-trait>))
  (let 
    (
      (owner (unwrap! (nft-get-owner? arkadroids token-id) err-token-not-found))
      (listing (unwrap! (map-get? market token-id) err-listing-not-found))
      (price (get price listing))
    )
    (asserts! (is-eq (contract-of commission-trait-implementation) (get commission listing)) err-wrong-commission-implementation)
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? commission-trait-implementation pay token-id price))
    (try! (trnsfr token-id owner tx-sender))
    (map-delete market token-id)
    (print { a: "buy-in-ustx", token-id: token-id })
    (ok true)
  )
)

;; Custodial
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-admin-user tx-sender) err-non-admin-user)
    (asserts! (not (var-get metadata-frozen)) err-metadata-frozen)
    (ok (var-set ipfs-root new-base-uri))
  )
)

(define-public (set-curator-address (address principal))
  (begin
    (asserts! (is-admin-user tx-sender) err-non-admin-user)
    (ok (var-set curator-address address))
  )
)

(define-public (freeze-metadata)
  (begin
    (asserts! (is-admin-user tx-sender) err-non-admin-user)
    (ok (var-set metadata-frozen true))
  )
)

(define-public (mint-all)
  (mint-many (list true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true true))
)

(define-public (mint-twenty)
  (mint-many (list true true true true true true true true true true true true true true true true true true true true))
)

;; Private
(define-private (is-sender-owner (token-id uint))
  (let 
    (
      (owner (unwrap! (nft-get-owner? arkadroids token-id) false))
    )
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))
  )
)

(define-private (is-admin-user (caller principal))
  (or (is-eq caller (var-get curator-address)) (is-eq caller contract-owner))
)

(define-private (mint-many (orders (list 120 bool)))
  (let 
    (
      (last-nft-id (var-get last-token-id))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (current-balance (get-balance tx-sender))
    )
    (asserts! (is-admin-user tx-sender) err-non-admin-user)
    (asserts! (< id-reached mint-limit) err-mint-limit-reached)
    (begin
      (var-set last-token-id id-reached)
      (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
    )
    (ok id-reached)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id mint-limit)
    (begin
      (unwrap! (nft-mint? arkadroids next-id tx-sender) next-id)
      (+ next-id u1)
    )
    next-id
  )
)

(define-private (trnsfr (token-id uint) (sender principal) (recipient principal))
  (match (nft-transfer? arkadroids token-id sender recipient)
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
