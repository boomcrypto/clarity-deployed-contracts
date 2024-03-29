;; this-is-art
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token this-is-art uint)

(define-constant DEPLOYER tx-sender)

(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INVALID-USER u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-NOT-FOUND u105)
(define-constant ERR-NFT-MINT u106)
(define-constant ERR-CONTRACT-LOCKED u107)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-INVALID-PERCENTAGE u114)

(define-data-var last-id uint u0)
(define-data-var artist-address principal 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7)
(define-data-var locked bool false)
(define-data-var metadata-frozen bool false)

(define-map cids uint (string-ascii 64))

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market token-id)) (err ERR-LISTING))
    (nft-burn? this-is-art token-id tx-sender)))

(define-public (set-token-uri (hash (string-ascii 64)) (token-id uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (print { notification: "token-metadata-update", payload: { token-class: "nft", token-ids: (list token-id), contract-id: (as-contract tx-sender) }})
    (map-set cids token-id hash)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? this-is-art token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? this-is-art token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat "ipfs://" (unwrap-panic (map-get? cids token-id))))))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-public (claim (uris (list 25 (string-ascii 64))))
  (mint-many uris))

(define-private (mint-many (uris (list 25 (string-ascii 64))))
  (let 
    (
      (token-id (+ (var-get last-id) u1))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter uris token-id))
      (current-balance (get-balance tx-sender))
    )
    (asserts! (or (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
    (var-set last-id (- id-reached u1))
    (map-set token-count tx-sender (+ current-balance (- id-reached token-id)))    
    (ok id-reached)))

(define-private (mint-many-iter (hash (string-ascii 64)) (next-id uint))
  (begin
    (unwrap! (nft-mint? this-is-art next-id tx-sender) next-id)
    (map-set cids next-id hash)      
    (+ next-id u1)))

;; NON-CUSTODIAL FUNCTIONS START
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? this-is-art id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? this-is-art id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? this-is-art id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
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
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

(define-private (pay-royalty (price uint) (royalty uint))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (and (> royalty-amount u0) (not (is-eq tx-sender (var-get artist-address))))
    (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))

;; NON-CUSTODIAL FUNCTIONS END

(try! (nft-mint? this-is-art u1 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u1 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/1.json")
(try! (nft-mint? this-is-art u2 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u2 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/2.json")
(try! (nft-mint? this-is-art u3 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u3 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/3.json")
(try! (nft-mint? this-is-art u4 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u4 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/4.json")
(try! (nft-mint? this-is-art u5 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u5 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/5.json")
(try! (nft-mint? this-is-art u6 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u6 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/6.json")
(try! (nft-mint? this-is-art u7 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u7 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/7.json")
(try! (nft-mint? this-is-art u8 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u8 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/8.json")
(try! (nft-mint? this-is-art u9 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u9 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/9.json")
(try! (nft-mint? this-is-art u10 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u10 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/10.json")
(try! (nft-mint? this-is-art u11 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u11 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/11.json")
(try! (nft-mint? this-is-art u12 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u12 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/12.json")
(try! (nft-mint? this-is-art u13 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u13 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/13.json")
(try! (nft-mint? this-is-art u14 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u14 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/14.json")
(try! (nft-mint? this-is-art u15 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u15 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/15.json")
(try! (nft-mint? this-is-art u16 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u16 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/16.json")
(try! (nft-mint? this-is-art u17 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u17 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/17.json")
(try! (nft-mint? this-is-art u18 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u18 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/18.json")
(try! (nft-mint? this-is-art u19 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u19 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/19.json")
(try! (nft-mint? this-is-art u20 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u20 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/20.json")
(try! (nft-mint? this-is-art u21 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u21 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/21.json")
(try! (nft-mint? this-is-art u22 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u22 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/22.json")
(try! (nft-mint? this-is-art u23 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u23 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/23.json")
(try! (nft-mint? this-is-art u24 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u24 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/24.json")
(try! (nft-mint? this-is-art u25 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u25 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/25.json")
(try! (nft-mint? this-is-art u26 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u26 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/26.json")
(try! (nft-mint? this-is-art u27 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u27 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/27.json")
(try! (nft-mint? this-is-art u28 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u28 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/28.json")
(try! (nft-mint? this-is-art u29 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u29 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/29.json")
(try! (nft-mint? this-is-art u30 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u30 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/30.json")
(try! (nft-mint? this-is-art u31 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u31 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/31.json")
(try! (nft-mint? this-is-art u32 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u32 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/32.json")
(try! (nft-mint? this-is-art u33 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u33 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/33.json")
(try! (nft-mint? this-is-art u34 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u34 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/34.json")
(try! (nft-mint? this-is-art u35 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u35 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/35.json")
(try! (nft-mint? this-is-art u36 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u36 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/36.json")
(try! (nft-mint? this-is-art u37 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u37 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/37.json")
(try! (nft-mint? this-is-art u38 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u38 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/38.json")
(try! (nft-mint? this-is-art u39 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u39 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/39.json")
(try! (nft-mint? this-is-art u40 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u40 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/40.json")
(try! (nft-mint? this-is-art u41 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u41 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/41.json")
(try! (nft-mint? this-is-art u42 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u42 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/42.json")
(try! (nft-mint? this-is-art u43 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u43 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/43.json")
(try! (nft-mint? this-is-art u44 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u44 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/44.json")
(try! (nft-mint? this-is-art u45 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u45 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/45.json")
(try! (nft-mint? this-is-art u46 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u46 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/46.json")
(try! (nft-mint? this-is-art u47 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u47 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/47.json")
(try! (nft-mint? this-is-art u48 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u48 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/48.json")
(try! (nft-mint? this-is-art u49 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u49 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/49.json")
(try! (nft-mint? this-is-art u50 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u50 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/50.json")
(try! (nft-mint? this-is-art u51 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u51 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/51.json")
(try! (nft-mint? this-is-art u52 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u52 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/52.json")
(try! (nft-mint? this-is-art u53 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u53 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/53.json")
(try! (nft-mint? this-is-art u54 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u54 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/54.json")
(try! (nft-mint? this-is-art u55 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u55 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/55.json")
(try! (nft-mint? this-is-art u56 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u56 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/56.json")
(try! (nft-mint? this-is-art u57 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u57 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/57.json")
(try! (nft-mint? this-is-art u58 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u58 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/58.json")
(try! (nft-mint? this-is-art u59 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u59 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/59.json")
(try! (nft-mint? this-is-art u60 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u60 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/60.json")
(try! (nft-mint? this-is-art u61 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u61 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/61.json")
(try! (nft-mint? this-is-art u62 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u62 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/62.json")
(try! (nft-mint? this-is-art u63 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u63 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/63.json")
(try! (nft-mint? this-is-art u64 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u64 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/64.json")
(try! (nft-mint? this-is-art u65 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u65 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/65.json")
(try! (nft-mint? this-is-art u66 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u66 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/66.json")
(try! (nft-mint? this-is-art u67 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u67 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/67.json")
(try! (nft-mint? this-is-art u68 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u68 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/68.json")
(try! (nft-mint? this-is-art u69 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7))
(map-set token-count 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7 (+ (get-balance 'SP358JBH8FRAF33V83010X1FAFFRK7W3ANJY6HPQ7) u1))
(map-set cids u69 "QmYQLdPWsu5CReTXRFqapuKQcaih9EHCRHk9F2TrPACi5G/json/69.json")
(var-set last-id u69)

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/5")
(define-data-var license-name (string-ascii 40) "PERSONAL-NO-HATE")

(define-read-only (get-license-uri)
  (ok (var-get license-uri)))
  
(define-read-only (get-license-name)
  (ok (var-get license-name)))
  
(define-public (set-license-uri (uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-uri uri))))
    
(define-public (set-license-name (name (string-ascii 40)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-name name))))