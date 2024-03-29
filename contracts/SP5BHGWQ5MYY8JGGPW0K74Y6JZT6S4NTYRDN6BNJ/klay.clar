;; klay
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token klay uint)

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
(define-data-var artist-address principal 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ)
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
    (nft-burn? klay token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? klay token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? klay token-id)))

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
    (unwrap! (nft-mint? klay next-id tx-sender) next-id)
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
  (match (nft-transfer? klay id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? klay id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? klay id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? klay u1 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u1 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/1.json")
(try! (nft-mint? klay u2 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u2 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/2.json")
(try! (nft-mint? klay u3 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u3 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/3.json")
(try! (nft-mint? klay u4 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u4 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/4.json")
(try! (nft-mint? klay u5 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u5 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/5.json")
(try! (nft-mint? klay u6 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u6 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/6.json")
(try! (nft-mint? klay u7 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u7 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/7.json")
(try! (nft-mint? klay u8 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u8 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/8.json")
(try! (nft-mint? klay u9 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u9 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/9.json")
(try! (nft-mint? klay u10 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u10 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/10.json")
(try! (nft-mint? klay u11 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u11 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/11.json")
(try! (nft-mint? klay u12 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u12 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/12.json")
(try! (nft-mint? klay u13 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u13 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/13.json")
(try! (nft-mint? klay u14 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u14 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/14.json")
(try! (nft-mint? klay u15 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u15 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/15.json")
(try! (nft-mint? klay u16 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u16 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/16.json")
(try! (nft-mint? klay u17 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u17 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/17.json")
(try! (nft-mint? klay u18 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u18 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/18.json")
(try! (nft-mint? klay u19 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u19 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/19.json")
(try! (nft-mint? klay u20 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u20 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/20.json")
(try! (nft-mint? klay u21 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u21 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/21.json")
(try! (nft-mint? klay u22 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u22 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/22.json")
(try! (nft-mint? klay u23 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u23 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/23.json")
(try! (nft-mint? klay u24 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u24 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/24.json")
(try! (nft-mint? klay u25 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u25 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/25.json")
(try! (nft-mint? klay u26 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u26 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/26.json")
(try! (nft-mint? klay u27 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u27 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/27.json")
(try! (nft-mint? klay u28 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u28 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/28.json")
(try! (nft-mint? klay u29 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u29 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/29.json")
(try! (nft-mint? klay u30 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u30 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/30.json")
(try! (nft-mint? klay u31 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u31 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/31.json")
(try! (nft-mint? klay u32 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u32 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/32.json")
(try! (nft-mint? klay u33 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u33 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/33.json")
(try! (nft-mint? klay u34 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u34 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/34.json")
(try! (nft-mint? klay u35 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u35 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/35.json")
(try! (nft-mint? klay u36 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u36 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/36.json")
(try! (nft-mint? klay u37 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u37 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/37.json")
(try! (nft-mint? klay u38 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u38 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/38.json")
(try! (nft-mint? klay u39 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u39 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/39.json")
(try! (nft-mint? klay u40 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u40 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/40.json")
(try! (nft-mint? klay u41 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u41 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/41.json")
(try! (nft-mint? klay u42 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u42 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/42.json")
(try! (nft-mint? klay u43 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u43 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/43.json")
(try! (nft-mint? klay u44 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u44 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/44.json")
(try! (nft-mint? klay u45 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u45 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/45.json")
(try! (nft-mint? klay u46 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u46 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/46.json")
(try! (nft-mint? klay u47 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u47 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/47.json")
(try! (nft-mint? klay u48 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u48 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/48.json")
(try! (nft-mint? klay u49 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u49 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/49.json")
(try! (nft-mint? klay u50 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u50 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/50.json")
(try! (nft-mint? klay u51 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u51 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/51.json")
(try! (nft-mint? klay u52 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u52 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/52.json")
(try! (nft-mint? klay u53 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u53 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/53.json")
(try! (nft-mint? klay u54 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u54 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/54.json")
(try! (nft-mint? klay u55 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u55 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/55.json")
(try! (nft-mint? klay u56 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u56 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/56.json")
(try! (nft-mint? klay u57 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u57 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/57.json")
(try! (nft-mint? klay u58 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u58 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/58.json")
(try! (nft-mint? klay u59 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u59 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/59.json")
(try! (nft-mint? klay u60 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u60 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/60.json")
(try! (nft-mint? klay u61 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u61 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/61.json")
(try! (nft-mint? klay u62 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u62 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/62.json")
(try! (nft-mint? klay u63 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u63 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/63.json")
(try! (nft-mint? klay u64 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u64 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/64.json")
(try! (nft-mint? klay u65 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u65 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/65.json")
(try! (nft-mint? klay u66 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u66 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/66.json")
(try! (nft-mint? klay u67 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u67 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/67.json")
(try! (nft-mint? klay u68 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u68 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/68.json")
(try! (nft-mint? klay u69 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u69 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/69.json")
(try! (nft-mint? klay u70 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u70 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/70.json")
(try! (nft-mint? klay u71 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u71 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/71.json")
(try! (nft-mint? klay u72 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u72 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/72.json")
(try! (nft-mint? klay u73 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u73 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/73.json")
(try! (nft-mint? klay u74 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u74 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/74.json")
(try! (nft-mint? klay u75 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u75 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/75.json")
(try! (nft-mint? klay u76 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u76 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/76.json")
(try! (nft-mint? klay u77 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u77 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/77.json")
(try! (nft-mint? klay u78 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u78 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/78.json")
(try! (nft-mint? klay u79 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u79 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/79.json")
(try! (nft-mint? klay u80 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u80 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/80.json")
(try! (nft-mint? klay u81 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u81 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/81.json")
(try! (nft-mint? klay u82 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u82 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/82.json")
(try! (nft-mint? klay u83 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u83 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/83.json")
(try! (nft-mint? klay u84 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u84 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/84.json")
(try! (nft-mint? klay u85 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u85 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/85.json")
(try! (nft-mint? klay u86 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u86 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/86.json")
(try! (nft-mint? klay u87 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u87 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/87.json")
(try! (nft-mint? klay u88 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u88 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/88.json")
(try! (nft-mint? klay u89 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u89 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/89.json")
(try! (nft-mint? klay u90 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u90 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/90.json")
(try! (nft-mint? klay u91 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u91 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/91.json")
(try! (nft-mint? klay u92 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u92 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/92.json")
(try! (nft-mint? klay u93 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u93 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/93.json")
(try! (nft-mint? klay u94 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u94 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/94.json")
(try! (nft-mint? klay u95 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u95 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/95.json")
(try! (nft-mint? klay u96 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u96 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/96.json")
(try! (nft-mint? klay u97 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u97 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/97.json")
(try! (nft-mint? klay u98 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u98 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/98.json")
(try! (nft-mint? klay u99 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u99 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/99.json")
(try! (nft-mint? klay u100 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u100 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/100.json")
(try! (nft-mint? klay u101 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u101 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/101.json")
(try! (nft-mint? klay u102 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u102 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/102.json")
(try! (nft-mint? klay u103 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u103 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/103.json")
(try! (nft-mint? klay u104 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u104 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/104.json")
(try! (nft-mint? klay u105 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u105 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/105.json")
(try! (nft-mint? klay u106 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u106 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/106.json")
(try! (nft-mint? klay u107 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u107 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/107.json")
(try! (nft-mint? klay u108 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u108 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/108.json")
(try! (nft-mint? klay u109 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u109 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/109.json")
(try! (nft-mint? klay u110 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u110 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/110.json")
(try! (nft-mint? klay u111 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ))
(map-set token-count 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ (+ (get-balance 'SP5BHGWQ5MYY8JGGPW0K74Y6JZT6S4NTYRDN6BNJ) u1))
(map-set cids u111 "QmXoBmnFfKia55iWzhjtV81Jh8f3dBWEBXjywNRUapR8Kq/json/111.json")
(var-set last-id u111)

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/0")
(define-data-var license-name (string-ascii 40) "PUBLIC")

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