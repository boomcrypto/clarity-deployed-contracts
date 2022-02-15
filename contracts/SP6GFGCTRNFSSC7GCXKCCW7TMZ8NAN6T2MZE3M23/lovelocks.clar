(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; lovelocks
(define-non-fungible-token lovelocks uint)

;; constants
(define-constant CREATOR tx-sender)
(define-constant LOCKS_PER_GRID_BLOCK u8)
(define-constant GRID_COLUMNS_COUNT u2)
(define-constant GRID_ROWS_COUNT u108)
(define-constant ERROR_NOT_ALLOWED (err u1))
(define-constant ERROR_INSUFFICIENT_FUNDS (err u2))
(define-constant ERROR_FAILED_STX_TRANSFER (err u3))
(define-constant ERROR_FAILED_MINT (err u4))
(define-constant ERROR_NOT_FOUND (err u5))
(define-constant ERROR_LISTING (err u6))
;; LOCKS_PER_GRID_BLOCK * GRID_COLUMNS_COUNT * GRID_ROWS_COUNT
(define-constant MAX_LOCKS u1728)

;; data maps and vars
(define-data-var current-lock-id uint u0)
(define-data-var mint-price uint u10000000)
(define-data-var sale-commission-percentage uint u10)
(define-data-var can-mint-and-claim bool false)
(define-data-var is-sale-open bool false)
(define-data-var max-mints uint u0)
(define-data-var mint-payout-address principal 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
(define-data-var listing-payout-address principal 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
(define-map locks
    uint
    {
      names: (list 2 (string-utf8 40)),
      public: bool,
      quote: (string-utf8 140),
      media: (string-ascii 256),
      claimed: bool,
    }
)
(define-map listings
    uint
    { price: uint }
)

(define-public (mint-lovelock-and-claim (names (list 2 (string-utf8 40))) (quote (string-utf8 140)) (media (string-ascii 256)))
  (let ((next-lock-id (+ (var-get current-lock-id) u1)))
    (try! (can-mint next-lock-id))
    (asserts! (var-get can-mint-and-claim) ERROR_FAILED_MINT)
    (var-set current-lock-id next-lock-id)
    (try! (stx-transfer? (var-get mint-price) tx-sender (var-get mint-payout-address)))
    (try! (nft-mint? lovelocks next-lock-id tx-sender))
    (try! (claim-lock next-lock-id names quote media))
    (ok next-lock-id)
  )
)

(define-public (mint-lovelock)
  (let ((next-lock-id (+ (var-get current-lock-id) u1)))
    (try! (can-mint next-lock-id))
    (var-set current-lock-id next-lock-id)
    (try! (stx-transfer? (var-get mint-price) tx-sender (var-get mint-payout-address)))
    (try! (nft-mint? lovelocks next-lock-id tx-sender))
    (ok next-lock-id)
  )
)

(define-public (claim-lock (lock-id uint) (names (list 2 (string-utf8 40))) (quote (string-utf8 140)) (media (string-ascii 256)))
  (let
    (
      (owner (unwrap! (nft-get-owner? lovelocks lock-id) ERROR_NOT_FOUND))
      (is-claimed (default-to false (get claimed (map-get? locks lock-id))))
    )
    (asserts! (is-eq tx-sender owner) ERROR_NOT_ALLOWED)
    (asserts! (is-eq false is-claimed) ERROR_NOT_ALLOWED)
    (print { names: names, public: true, quote: quote, media: media, claimed: true })
    (ok
      (map-set locks lock-id { names: names, public: true, quote: quote, media: media, claimed: true })
    )
  )
)

(define-private (can-mint (next-lock-id uint))
  (begin
    (asserts! (var-get is-sale-open) ERROR_FAILED_MINT)
    (asserts! (<= next-lock-id (var-get max-mints)) ERROR_FAILED_MINT)
    (asserts! (<= next-lock-id MAX_LOCKS) ERROR_FAILED_MINT)
    (ok true)
  )
)

(define-private (is-sender-owner (lock-id uint))
  (let ((owner (unwrap! (nft-get-owner? lovelocks lock-id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))
  )
)

(define-public (burn-lock (lock-id uint))
  (let
    ((owner (unwrap! (nft-get-owner? lovelocks lock-id) ERROR_NOT_FOUND)))
    (asserts! (is-eq tx-sender owner) ERROR_NOT_ALLOWED)
    (map-delete listings lock-id)
    (try! (nft-burn? lovelocks lock-id tx-sender))
    (ok true)
  )
)

(define-public (list-in-ustx (lock-id uint) (price uint))
  (let ((listing { price: price }))
    (asserts! (is-sender-owner lock-id) ERROR_NOT_ALLOWED)
    (map-set listings lock-id listing)
    (print { event: "list-in-ustx", id: lock-id })
    (ok true)
  )
)

(define-public (unlist-in-ustx (lock-id uint))
  (begin
    (asserts! (is-sender-owner lock-id) ERROR_NOT_ALLOWED)
    (map-delete listings lock-id)
    (print { event: "unlist-in-ustx", id: lock-id })
    (ok true)
  )
)

(define-public (buy-in-ustx (lock-id uint))
  (let
    (
      (owner (unwrap! (nft-get-owner? lovelocks lock-id) ERROR_NOT_FOUND))
      (lock (unwrap! (map-get? locks lock-id) ERROR_NOT_FOUND))
      (listing (unwrap! (map-get? listings lock-id) ERROR_NOT_FOUND))
      (price (get price listing))
    )
    (try! (stx-transfer? price tx-sender owner))
    (try! (transfer lock-id owner tx-sender))
    (map-delete listings lock-id)
    (map-set locks lock-id (merge lock { claimed: false }))
    (print { event: "buy-in-ustx", id: lock-id })
    (ok true)
  )
)

(define-public (set-lock-public-state (lock-id uint))
  (begin
    (asserts! (is-sender-owner lock-id) ERROR_NOT_ALLOWED)
    (let
      (
        (lock (unwrap! (map-get? locks lock-id) ERROR_NOT_FOUND))
        (public (not (get public lock)))
      )
      (ok
        (map-set locks lock-id (merge lock { public: public }))
      )
    )
  )
)

(define-public (update-mint-price (new-mint-price uint))
  (begin
    (asserts! (is-eq CREATOR tx-sender) ERROR_NOT_ALLOWED)
    (ok (var-set mint-price new-mint-price))
  )
)

(define-public (update-mint-payout-address (new-mint-payout-address principal))
  (begin
    (asserts! (is-eq CREATOR tx-sender) ERROR_NOT_ALLOWED)
    (ok (var-set mint-payout-address new-mint-payout-address))
  )
)

(define-public (update-listing-payout-address (new-listing-payout-address principal))
  (begin
    (asserts! (is-eq CREATOR tx-sender) ERROR_NOT_ALLOWED)
    (ok (var-set listing-payout-address new-listing-payout-address))
  )
)

(define-public (set-can-mint-and-claim (is-mint-and-claim bool))
  (begin
    (asserts! (is-eq CREATOR tx-sender) ERROR_NOT_ALLOWED)
    (var-set can-mint-and-claim is-mint-and-claim)
    (ok true)
  )
)

(define-public (set-sale-open (is-open bool))
  (begin
    (asserts! (is-eq CREATOR tx-sender) ERROR_NOT_ALLOWED)
    (ok
      (var-set is-sale-open is-open)
    )
  )
)

(define-public (set-max-mints (max-mints-count uint))
  (begin
    (asserts! (is-eq CREATOR tx-sender) ERROR_NOT_ALLOWED)
    (asserts! (and (<= max-mints-count MAX_LOCKS) (> max-mints-count (var-get current-lock-id))) ERROR_NOT_ALLOWED)
    (ok
      (var-set max-mints max-mints-count)
    )
  )
)

(define-read-only (get-lock (lock-id uint))
  (ok (unwrap! (map-get? locks lock-id) ERROR_NOT_FOUND))
)

(define-read-only (get-sale-open-status)
  (ok (var-get is-sale-open))
)

(define-read-only (get-max-mints)
  (ok (var-get max-mints))
)

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get current-lock-id))
)

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (lock-id uint))
  (ok (nft-get-owner? lovelocks lock-id))
)

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (id uint))
  (ok (some "https://getlovelocks.com"))
)

;; ;; SIP009: Transfer token to a specified principal
(define-public (transfer (lock-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERROR_NOT_ALLOWED)
    (asserts! (is-none (map-get? listings lock-id)) ERROR_LISTING)
    (try! (nft-transfer? lovelocks lock-id sender recipient))
    (ok true)
  )
)
