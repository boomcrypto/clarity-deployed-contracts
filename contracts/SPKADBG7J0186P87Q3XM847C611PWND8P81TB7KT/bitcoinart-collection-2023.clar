;; bitcoinart-collection-2023
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token bitcoinart-collection-2023 uint)

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
(define-data-var artist-address principal 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT)
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
    (nft-burn? bitcoinart-collection-2023 token-id tx-sender)))

(define-public (set-token-uri (hash (string-ascii 64)) (token-id uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (map-set cids token-id hash)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? bitcoinart-collection-2023 token-id) false)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? bitcoinart-collection-2023 token-id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? bitcoinart-collection-2023 token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat "ipfs://" (unwrap-panic (map-get? cids token-id))))))

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
    (unwrap! (nft-mint? bitcoinart-collection-2023 next-id tx-sender) next-id)
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
  (match (nft-transfer? bitcoinart-collection-2023 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? bitcoinart-collection-2023 id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? bitcoinart-collection-2023 id) (err ERR-NOT-FOUND)))
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
  (if (> royalty-amount u0)
    (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))

;; NON-CUSTODIAL FUNCTIONS END

(try! (nft-mint? bitcoinart-collection-2023 u1 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u1 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/1.json")
(try! (nft-mint? bitcoinart-collection-2023 u2 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u2 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/2.json")
(try! (nft-mint? bitcoinart-collection-2023 u3 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u3 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/3.json")
(try! (nft-mint? bitcoinart-collection-2023 u4 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u4 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/4.json")
(try! (nft-mint? bitcoinart-collection-2023 u5 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u5 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/5.json")
(try! (nft-mint? bitcoinart-collection-2023 u6 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u6 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/6.json")
(try! (nft-mint? bitcoinart-collection-2023 u7 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u7 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/7.json")
(try! (nft-mint? bitcoinart-collection-2023 u8 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u8 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/8.json")
(try! (nft-mint? bitcoinart-collection-2023 u9 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u9 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/9.json")
(try! (nft-mint? bitcoinart-collection-2023 u10 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u10 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/10.json")
(try! (nft-mint? bitcoinart-collection-2023 u11 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u11 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/11.json")
(try! (nft-mint? bitcoinart-collection-2023 u12 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u12 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/12.json")
(try! (nft-mint? bitcoinart-collection-2023 u13 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u13 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/13.json")
(try! (nft-mint? bitcoinart-collection-2023 u14 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u14 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/14.json")
(try! (nft-mint? bitcoinart-collection-2023 u15 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u15 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/15.json")
(try! (nft-mint? bitcoinart-collection-2023 u16 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u16 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/16.json")
(try! (nft-mint? bitcoinart-collection-2023 u17 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u17 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/17.json")
(try! (nft-mint? bitcoinart-collection-2023 u18 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u18 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/18.json")
(try! (nft-mint? bitcoinart-collection-2023 u19 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u19 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/19.json")
(try! (nft-mint? bitcoinart-collection-2023 u20 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u20 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/20.json")
(try! (nft-mint? bitcoinart-collection-2023 u21 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u21 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/21.json")
(try! (nft-mint? bitcoinart-collection-2023 u22 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u22 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/22.json")
(try! (nft-mint? bitcoinart-collection-2023 u23 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u23 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/23.json")
(try! (nft-mint? bitcoinart-collection-2023 u24 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u24 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/24.json")
(try! (nft-mint? bitcoinart-collection-2023 u25 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u25 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/25.json")
(try! (nft-mint? bitcoinart-collection-2023 u26 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u26 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/26.json")
(try! (nft-mint? bitcoinart-collection-2023 u27 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u27 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/27.json")
(try! (nft-mint? bitcoinart-collection-2023 u28 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u28 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/28.json")
(try! (nft-mint? bitcoinart-collection-2023 u29 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT))
(map-set token-count 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT (+ (get-balance 'SPKADBG7J0186P87Q3XM847C611PWND8P81TB7KT) u1))
(map-set cids u29 "QmPGBkjzbHMoqiQ1UdJL1xibiu5HeCvA8bURBepxydLwxy/json/29.json")
(var-set last-id u29)