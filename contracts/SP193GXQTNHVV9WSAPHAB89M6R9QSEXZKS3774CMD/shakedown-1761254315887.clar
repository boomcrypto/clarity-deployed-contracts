;; RIMAY AUDIO NFT CONTRACT
;; SHAKEDOWN Audio NFT

(define-non-fungible-token SHAKEDOWN uint)

;; Commission trait for marketplace functionality
(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-constant DEPLOYER tx-sender)
(define-constant BUILDER-ADDRESS 'SP7FM7445TXTJEJ54GBCV2GJPCJF887NXJW2BE78)
(define-constant BUILDER-FEE u100) ;; 1%

(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INVALID-USER u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-NOT-FOUND u105)
(define-constant ERR-NFT-MINT u106)
(define-constant ERR-CONTRACT-LOCKED u107)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-INVALID-PERCENTAGE u114)

(define-data-var last-id uint u1) ;; Start at 1 since token 1 is pre-minted
(define-data-var artist-address principal DEPLOYER)
(define-data-var locked bool false)
(define-data-var metadata-frozen bool false)
(define-data-var royalty-percent uint u500) ;; 5% default royalty

(define-map cids uint (string-ascii 256))
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

;; Initialize contract with first NFT minted to deployer
(begin
  (unwrap! (nft-mint? SHAKEDOWN u1 DEPLOYER) (err ERR-NFT-MINT))
  (map-set cids u1 "QmbX9yAAUgDh3RgEqVCHCba1n4yRfju6FgLZvBf4yS3zDc")
  (map-set token-count DEPLOYER u1)
)

;; Contract management functions (only artist)
(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get artist-address)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get locked)) (err ERR-CONTRACT-LOCKED))
    (ok (var-set artist-address address))))

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (is-eq tx-sender (var-get artist-address)) (err ERR-NOT-AUTHORIZED))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

;; Update metadata for any token (only artist can update)
(define-public (set-token-uri (token-id uint) (metadata-cid (string-ascii 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get artist-address)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (asserts! (is-some (nft-get-owner? SHAKEDOWN token-id)) (err ERR-NOT-FOUND))
    (ok (map-set cids token-id metadata-cid))))

;; Additional minting function (for future NFTs)
(define-public (mint-additional (metadata-cid (string-ascii 256)))
  (let ((token-id (+ (var-get last-id) u1)))
    (asserts! (not (var-get locked)) (err ERR-CONTRACT-LOCKED))
    (try! (nft-mint? SHAKEDOWN token-id tx-sender))
    (map-set cids token-id metadata-cid)
    (map-set token-count tx-sender (+ (get-balance tx-sender) u1))
    (var-set last-id token-id)
    (ok token-id)))

;; Lock functions
(define-public (lock-contract)
  (begin
    (asserts! (is-eq tx-sender (var-get artist-address)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set locked true))))

(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender (var-get artist-address)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set metadata-frozen true))))

;; NFT functions
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; Read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? SHAKEDOWN token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (map-get? cids token-id)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-read-only (get-balance (account principal))
  (default-to u0 (map-get? token-count account)))


;; Get listing in satoshis
(define-read-only (get-listing-in-sat (id uint))
  (map-get? market id))


;; Marketplace functions (now in satoshis)
(define-public (list-in-sat (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
    (asserts! (is-owner id tx-sender) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (ok (print listing))))

(define-public (unlist-in-sat (id uint))
  (begin
    (asserts! (is-owner id tx-sender) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (ok (print {a: "unlist-in-sat", id: id}))))

(define-public (buy-in-sat (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? SHAKEDOWN id) (err ERR-NOT-FOUND)))
        (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
        (price (get price listing))
        (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price royalty))
    (try! (pay-builder-fee price))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (ok (print {a: "buy-in-sat", id: id}))))

;; Private functions
(define-private (is-owner (token-id uint) (user principal))
  (is-eq user (unwrap! (nft-get-owner? SHAKEDOWN token-id) false)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? SHAKEDOWN id sender recipient)
    success
      (begin
        (map-set token-count sender (- (get-balance sender) u1))
        (map-set token-count recipient (+ (get-balance recipient) u1))
        (ok success))
    error (err error)))

(define-private (pay-royalty (price uint) (royalty uint))
  (let ((royalty-amount (/ (* price royalty) u10000)))
    (if (and (> royalty-amount u0) (not (is-eq tx-sender (var-get artist-address))))
      (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
      true)
    (ok true)))

(define-private (pay-builder-fee (price uint))
  (let ((fee-amount (/ (* price BUILDER-FEE) u10000)))
    (if (and (> fee-amount u0) (not (is-eq tx-sender BUILDER-ADDRESS)))
      (try! (stx-transfer? fee-amount tx-sender BUILDER-ADDRESS))
      true)
    (ok true)))