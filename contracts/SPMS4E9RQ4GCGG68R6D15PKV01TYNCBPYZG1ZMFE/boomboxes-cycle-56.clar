;; Boombox 52

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait .boombox-trait.boombox-trait)

(define-non-fungible-token b-56 uint)

;; constants
;;
(define-constant deployer tx-sender)
(define-data-var royalty-percent uint u250)
(define-data-var artist-address principal 'SP20PH0DGKC576ERKCR2VT21NRP5YPK291N2X93MX)
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; err constants
(define-constant err-not-authorized (err u403))
(define-constant err-not-found (err u404))
(define-constant err-invalid-stacks-tip (err u608))
(define-constant err-airdrop-called (err u701))

;; Stackerspool added errors constants
(define-constant error (err u1000))
(define-constant err-listing (err u103))
(define-constant err-wrong-commission (err u104))

;; data maps and vars
;;
(define-data-var last-id uint u0)
(define-data-var boombox-admin principal 'SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE.boombox-admin-v5)

;; boombox-admin contract : boombox id
(define-map boombox-id principal uint)
;; approval maps
(define-map approvals {owner: principal, operator: principal, id: uint} bool)
(define-map approvals-all {owner: principal, operator: principal} bool)

;; private functions
(define-private (is-approved-with-owner (id uint) (operator principal) (owner principal))
  (or
    (is-eq owner operator)
    (default-to (default-to
      false
        (map-get? approvals-all {owner: owner, operator: operator}))
          (map-get? approvals {owner: owner, operator: operator, id: id}))))

(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

;; public functions
;;
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
    (let
      ((sender-balance (get-balance sender))
      (recipient-balance (get-balance recipient)))
        (try! (nft-transfer? b-56 id sender recipient))
        (map-set token-count
          sender
          (- sender-balance u1))
        (map-set token-count
          recipient
          (+ recipient-balance u1))
        (ok true)))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? b-56 id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
    (asserts! (is-sender-owner id) err-not-authorized)
    (map-set market id listing)
    (print {  notification: "nft-listing",
              payload: (merge listing {
                id: id,
                action: "list-in-ustx" })})
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) err-not-authorized)
    (map-delete market id)
    (print {  notification: "nft-listing",
              payload: {
                id: id,
                action: "unlist-in-ustx" }})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? b-56 id) err-not-found))
      (listing (unwrap! (map-get? market id) err-listing))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) err-wrong-commission)
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalties price))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {  notification: "nft-listing",
              payload: {
                id: id,
                action: "buy-in-ustx" }})
    (ok true)))

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-private (pay-royalties (price uint))
  (let (
    (royalty (/ (* price (var-get royalty-percent)) u10000))
  )
  (if (> (var-get royalty-percent) u0)
    (try! (stx-transfer? royalty tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))

;; transfer functions
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (let ((owner (unwrap! (nft-get-owner? b-56 id) err-not-found)))
    (asserts! (is-none (map-get? market id)) err-listing)
    (asserts! (is-approved-with-owner id contract-caller owner) err-not-authorized)
    (nft-transfer? b-56 id sender recipient)))

(define-public (transfer-memo (id uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin
    (try! (transfer id sender recipient))
    (print memo)
    (ok true)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? b-56 id)))

(define-read-only (get-owner-at-block (id uint) (stacks-tip uint))
  (match (get-block-info? id-header-hash stacks-tip)
    ihh (ok (at-block ihh (nft-get-owner? b-56 id)))
    err-invalid-stacks-tip))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (id uint))
  (ok (some "ipfs://bafkreidgzdhb2yhe7vplc5ntkyj7ifr5d6mgow2kuahphooh5njt6lclbi")))

;; can only be called by boombox admin
(define-public (mint (bb-id uint) (stacker principal) (amount-ustx uint) (pox-addr {version: (buff 1), hashbytes: (buff 20)}) (locking-period uint))
  (let ((next-id (+ u1 (var-get last-id))))
    (asserts! (is-eq bb-id (unwrap! (map-get? boombox-id contract-caller) err-not-authorized)) err-not-authorized)
    (var-set last-id next-id)
    (try! (nft-mint? b-56 next-id stacker))
    (map-set token-count stacker (+ u1 (get-balance stacker)))
    (ok next-id)))

;; can only be called by boombox admin
(define-public (set-boombox-id (bb-id uint))
  (begin
    (asserts! (is-eq contract-caller (var-get boombox-admin)) err-not-authorized)
    (map-set boombox-id contract-caller bb-id)
    (ok true)))

;; can only be called by deployer
(define-public (set-boombox-admin (admin principal))
  (begin
    (asserts! (is-eq contract-caller deployer) err-not-authorized)
    (var-set boombox-admin admin)
    (ok true)))

