;; anon-de-picasso
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token anon-de-picasso uint)

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
(define-data-var artist-address principal 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5)
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
    (nft-burn? anon-de-picasso token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? anon-de-picasso token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? anon-de-picasso token-id)))

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
    (unwrap! (nft-mint? anon-de-picasso next-id tx-sender) next-id)
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
  (match (nft-transfer? anon-de-picasso id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? anon-de-picasso id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? anon-de-picasso id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? anon-de-picasso u1 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u1 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/1.json")
(try! (nft-mint? anon-de-picasso u2 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u2 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/2.json")
(try! (nft-mint? anon-de-picasso u3 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u3 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/3.json")
(try! (nft-mint? anon-de-picasso u4 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u4 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/4.json")
(try! (nft-mint? anon-de-picasso u5 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u5 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/5.json")
(try! (nft-mint? anon-de-picasso u6 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u6 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/6.json")
(try! (nft-mint? anon-de-picasso u7 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u7 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/7.json")
(try! (nft-mint? anon-de-picasso u8 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u8 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/8.json")
(try! (nft-mint? anon-de-picasso u9 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u9 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/9.json")
(try! (nft-mint? anon-de-picasso u10 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u10 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/10.json")
(try! (nft-mint? anon-de-picasso u11 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u11 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/11.json")
(try! (nft-mint? anon-de-picasso u12 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u12 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/12.json")
(try! (nft-mint? anon-de-picasso u13 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u13 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/13.json")
(try! (nft-mint? anon-de-picasso u14 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u14 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/14.json")
(try! (nft-mint? anon-de-picasso u15 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u15 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/15.json")
(try! (nft-mint? anon-de-picasso u16 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u16 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/16.json")
(try! (nft-mint? anon-de-picasso u17 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u17 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/17.json")
(try! (nft-mint? anon-de-picasso u18 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u18 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/18.json")
(try! (nft-mint? anon-de-picasso u19 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u19 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/19.json")
(try! (nft-mint? anon-de-picasso u20 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u20 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/20.json")
(try! (nft-mint? anon-de-picasso u21 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u21 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/21.json")
(try! (nft-mint? anon-de-picasso u22 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u22 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/22.json")
(try! (nft-mint? anon-de-picasso u23 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u23 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/23.json")
(try! (nft-mint? anon-de-picasso u24 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u24 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/24.json")
(try! (nft-mint? anon-de-picasso u25 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u25 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/25.json")
(try! (nft-mint? anon-de-picasso u26 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u26 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/26.json")
(try! (nft-mint? anon-de-picasso u27 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u27 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/27.json")
(try! (nft-mint? anon-de-picasso u28 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u28 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/28.json")
(try! (nft-mint? anon-de-picasso u29 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u29 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/29.json")
(try! (nft-mint? anon-de-picasso u30 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u30 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/30.json")
(try! (nft-mint? anon-de-picasso u31 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u31 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/31.json")
(try! (nft-mint? anon-de-picasso u32 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u32 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/32.json")
(try! (nft-mint? anon-de-picasso u33 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u33 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/33.json")
(try! (nft-mint? anon-de-picasso u34 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u34 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/34.json")
(try! (nft-mint? anon-de-picasso u35 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u35 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/35.json")
(try! (nft-mint? anon-de-picasso u36 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u36 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/36.json")
(try! (nft-mint? anon-de-picasso u37 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u37 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/37.json")
(try! (nft-mint? anon-de-picasso u38 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u38 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/38.json")
(try! (nft-mint? anon-de-picasso u39 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u39 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/39.json")
(try! (nft-mint? anon-de-picasso u40 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u40 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/40.json")
(try! (nft-mint? anon-de-picasso u41 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u41 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/41.json")
(try! (nft-mint? anon-de-picasso u42 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u42 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/42.json")
(try! (nft-mint? anon-de-picasso u43 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u43 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/43.json")
(try! (nft-mint? anon-de-picasso u44 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u44 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/44.json")
(try! (nft-mint? anon-de-picasso u45 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u45 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/45.json")
(try! (nft-mint? anon-de-picasso u46 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u46 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/46.json")
(try! (nft-mint? anon-de-picasso u47 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u47 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/47.json")
(try! (nft-mint? anon-de-picasso u48 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u48 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/48.json")
(try! (nft-mint? anon-de-picasso u49 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u49 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/49.json")
(try! (nft-mint? anon-de-picasso u50 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u50 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/50.json")
(try! (nft-mint? anon-de-picasso u51 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u51 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/51.json")
(try! (nft-mint? anon-de-picasso u52 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u52 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/52.json")
(try! (nft-mint? anon-de-picasso u53 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u53 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/53.json")
(try! (nft-mint? anon-de-picasso u54 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u54 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/54.json")
(try! (nft-mint? anon-de-picasso u55 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u55 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/55.json")
(try! (nft-mint? anon-de-picasso u56 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u56 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/56.json")
(try! (nft-mint? anon-de-picasso u57 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u57 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/57.json")
(try! (nft-mint? anon-de-picasso u58 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u58 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/58.json")
(try! (nft-mint? anon-de-picasso u59 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u59 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/59.json")
(try! (nft-mint? anon-de-picasso u60 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u60 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/60.json")
(try! (nft-mint? anon-de-picasso u61 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u61 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/61.json")
(try! (nft-mint? anon-de-picasso u62 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u62 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/62.json")
(try! (nft-mint? anon-de-picasso u63 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u63 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/63.json")
(try! (nft-mint? anon-de-picasso u64 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u64 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/64.json")
(try! (nft-mint? anon-de-picasso u65 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u65 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/65.json")
(try! (nft-mint? anon-de-picasso u66 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u66 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/66.json")
(try! (nft-mint? anon-de-picasso u67 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u67 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/67.json")
(try! (nft-mint? anon-de-picasso u68 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u68 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/68.json")
(try! (nft-mint? anon-de-picasso u69 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u69 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/69.json")
(try! (nft-mint? anon-de-picasso u70 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u70 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/70.json")
(try! (nft-mint? anon-de-picasso u71 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u71 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/71.json")
(try! (nft-mint? anon-de-picasso u72 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u72 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/72.json")
(try! (nft-mint? anon-de-picasso u73 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u73 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/73.json")
(try! (nft-mint? anon-de-picasso u74 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u74 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/74.json")
(try! (nft-mint? anon-de-picasso u75 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u75 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/75.json")
(try! (nft-mint? anon-de-picasso u76 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u76 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/76.json")
(try! (nft-mint? anon-de-picasso u77 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u77 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/77.json")
(try! (nft-mint? anon-de-picasso u78 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u78 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/78.json")
(try! (nft-mint? anon-de-picasso u79 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u79 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/79.json")
(try! (nft-mint? anon-de-picasso u80 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u80 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/80.json")
(try! (nft-mint? anon-de-picasso u81 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u81 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/81.json")
(try! (nft-mint? anon-de-picasso u82 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u82 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/82.json")
(try! (nft-mint? anon-de-picasso u83 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u83 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/83.json")
(try! (nft-mint? anon-de-picasso u84 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u84 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/84.json")
(try! (nft-mint? anon-de-picasso u85 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u85 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/85.json")
(try! (nft-mint? anon-de-picasso u86 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u86 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/86.json")
(try! (nft-mint? anon-de-picasso u87 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u87 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/87.json")
(try! (nft-mint? anon-de-picasso u88 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u88 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/88.json")
(try! (nft-mint? anon-de-picasso u89 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u89 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/89.json")
(try! (nft-mint? anon-de-picasso u90 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u90 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/90.json")
(try! (nft-mint? anon-de-picasso u91 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u91 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/91.json")
(try! (nft-mint? anon-de-picasso u92 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u92 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/92.json")
(try! (nft-mint? anon-de-picasso u93 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u93 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/93.json")
(try! (nft-mint? anon-de-picasso u94 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u94 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/94.json")
(try! (nft-mint? anon-de-picasso u95 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u95 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/95.json")
(try! (nft-mint? anon-de-picasso u96 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u96 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/96.json")
(try! (nft-mint? anon-de-picasso u97 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u97 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/97.json")
(try! (nft-mint? anon-de-picasso u98 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u98 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/98.json")
(try! (nft-mint? anon-de-picasso u99 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u99 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/99.json")
(try! (nft-mint? anon-de-picasso u100 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5))
(map-set token-count 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5 (+ (get-balance 'SP1FKT6GCXXZQ8KGWK9G6ZCEQNN8DFDFPWS1AYNB5) u1))
(map-set cids u100 "QmU8FdYuur2BkQ4kxiMYUUxvGxCJCWbjJLT9S8rxqxu8WX/json/100.json")
(var-set last-id u100)

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