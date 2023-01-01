(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token custom-plates uint)

(define-constant ERR-NOT-DEPLOYER (err u100))
(define-constant ERR-NOT-OWNER (err u101))
(define-constant ERR-STX-TRANSFER (err u102))
(define-constant ERR-NOT-BURNED (err u103))
(define-constant ERR-PLATE-NOT-FOUND (err u104))
(define-constant ERR-PLATE-CLAIMED (err u105))
(define-constant ERR-LISTING (err u106))
(define-constant ERR-WRONG-COMMISSION (err u107))
(define-constant ERR-INVALID-ROYALTY (err u108))
(define-constant ERR-NFT-MINT (err u109))
(define-constant ERR-PAUSED (err u110))
(define-constant DEPLOYER tx-sender)
(define-constant BASE-PRICE u10000000)
(define-data-var last-token-id uint u0)
(define-data-var is-paused bool false)
(define-map uris uint (string-ascii 46))
(define-map attributes uint { text: (string-ascii 25), text-color: (string-ascii 6), background-color: (string-ascii 6), border-color: (string-ascii 6) })
(define-map claimed-plates (string-ascii 25) uint)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? custom-plates token-id)))

(define-read-only (get-token-uri (token-id uint)) 
  (ok (some (concat "ipfs://ipfs/" (unwrap-panic (map-get? uris token-id))))))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-OWNER)
    (asserts! (is-none (map-get? market id)) ERR-LISTING)
    (trnsfr id sender recipient)))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) ERR-NOT-OWNER)
    (asserts! (is-none (map-get? market token-id)) ERR-LISTING)
    (nft-burn? custom-plates token-id tx-sender)))

(define-public (mint (uri (string-ascii 46)) (text (string-ascii 25)) (text-color (string-ascii 6)) (background-color (string-ascii 6)) (border-color (string-ascii 6)) (owned-tokens (list 10 uint)))
  (let 
    (            
      (burned (fold burn-iter owned-tokens true))
      (token-id (+ (var-get last-token-id) u1))
      (number-of-tokens (len owned-tokens))
      (current-balance (get-balance tx-sender))
    )
    (asserts! burned ERR-NOT-BURNED)
    (asserts! (not (is-claimed text)) ERR-PLATE-CLAIMED)
    (asserts! (or (not (var-get is-paused)) (is-eq tx-sender DEPLOYER)) ERR-PAUSED)
    (map-set uris token-id uri)
    (map-set attributes token-id {text: text, text-color: text-color, background-color: background-color, border-color: border-color })
    (map-set claimed-plates text token-id)
    (var-set last-token-id token-id)
    (map-set token-count tx-sender (+ current-balance u1))
    (unwrap! (nft-mint? custom-plates token-id tx-sender) ERR-NFT-MINT)
    (if (or (is-eq tx-sender DEPLOYER) (is-eq (- BASE-PRICE number-of-tokens) u0000000))
      (ok token-id)
      (begin
        (try! (stx-transfer? (- BASE-PRICE (* number-of-tokens u1000000)) tx-sender DEPLOYER))
        (ok token-id)))))

(define-private (burn-iter (owned-token-id uint) (last-token-owned bool))
    (if last-token-owned
        (begin
            (unwrap! (contract-call? .stxplates burn owned-token-id) false)
            true
        )
        false))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? custom-plates token-id) false)))

(define-read-only (get-attributes (token-id uint))
  (map-get? attributes token-id))

(define-read-only (get-text (token-id uint))
  (let 
    (
      (attr (unwrap! (get-attributes token-id) ERR-PLATE-NOT-FOUND))
      (text (get text attr))
    )
    (ok text)))

(define-read-only (get-text-color (token-id uint))
  (let 
    (
      (attr (unwrap! (get-attributes token-id) ERR-PLATE-NOT-FOUND))
      (text-color (get text-color attr))
    )
    (ok text-color)))

(define-read-only (get-background-color (token-id uint))
  (let 
    (
      (attr (unwrap! (get-attributes token-id) ERR-PLATE-NOT-FOUND))
      (background-color (get background-color attr))
    )
    (ok background-color)))

(define-read-only (get-border-color (token-id uint))
  (let 
    (
      (attr (unwrap! (get-attributes token-id) ERR-PLATE-NOT-FOUND))
      (border-color (get border-color attr))
    )
    (ok border-color)))

(define-read-only (get-claimed-plate (text (string-ascii 25)))
  (default-to
    u0
    (map-get? claimed-plates text)))

(define-read-only (is-claimed (text (string-ascii 25)))
  (let 
    (
      (index (get-claimed-plate text))
    )
    (if (is-eq index u0) false true)))

(define-public (set-uri (uri (string-ascii 46)) (token-id uint))
  (begin
    (asserts! (is-owner token-id tx-sender) ERR-NOT-OWNER)
    (map-set uris token-id uri)
    (ok true)))

(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-DEPLOYER))
    (ok (var-set is-paused (not (var-get is-paused))))))

(define-read-only (get-paused)
  (ok (var-get is-paused)))

;; Non-custodial marketplace
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? custom-plates id sender recipient)
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

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? custom-plates id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
    (asserts! (is-sender-owner id) ERR-NOT-OWNER)
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) ERR-NOT-OWNER)
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? custom-plates id) ERR-PLATE-NOT-FOUND))
      (listing (unwrap! (map-get? market id) ERR-LISTING))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) ERR-WRONG-COMMISSION)
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price royalty))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))
    
(define-data-var royalty-percent uint u500)

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) ERR-NOT-DEPLOYER)
    (asserts! (and (>= royalty u0) (<= royalty u1000)) ERR-INVALID-ROYALTY)
    (ok (var-set royalty-percent royalty))))

(define-private (pay-royalty (price uint) (royalty uint))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (and (> royalty-amount u0) (not (is-eq tx-sender DEPLOYER)))
    (try! (stx-transfer? royalty-amount tx-sender DEPLOYER))
    (print false)
  )
  (ok true)))