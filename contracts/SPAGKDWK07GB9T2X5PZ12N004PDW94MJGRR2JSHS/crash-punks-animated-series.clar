;; crash-punks-animated-series

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token crash-punks-animated-series uint)

(define-constant DEPLOYER tx-sender)

(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INVALID-USER u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-NOT-FOUND u105)
(define-constant ERR-NFT-MINT u106)
(define-constant ERR-CONTRACT-LOCKED u107)

(define-data-var last-id uint u0)
(define-data-var artist-address principal 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS)
(define-data-var locked bool false)

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
    (nft-burn? crash-punks-animated-series token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? crash-punks-animated-series token-id) false)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? crash-punks-animated-series token-id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? crash-punks-animated-series token-id)))

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
    (unwrap! (nft-mint? crash-punks-animated-series next-id tx-sender) next-id)
    (map-set cids next-id hash)      
    (+ next-id u1)))

;; NON-CUSTODIAL FUNCTIONS START
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? crash-punks-animated-series id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? crash-punks-animated-series id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
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
  (let ((owner (unwrap! (nft-get-owner? crash-punks-animated-series id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))
    
(define-data-var royalty-percent uint u500)

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-private (pay-royalty (price uint))
  (let (
    (royalty (/ (* price (var-get royalty-percent)) u10000))
  )
  (if (> (var-get royalty-percent) u0)
    (try! (stx-transfer? royalty tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))

;; NON-CUSTODIAL FUNCTIONS END

(try! (nft-mint? crash-punks-animated-series u1 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS))
(map-set token-count 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS (+ (get-balance 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS) u1))
(map-set cids u1 "QmadAX2yLvYTpkzGk3n8jLX7qoyVjqqrYLxZgv61z4rUBt/json/1.json")
(try! (nft-mint? crash-punks-animated-series u2 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS))
(map-set token-count 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS (+ (get-balance 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS) u1))
(map-set cids u2 "QmadAX2yLvYTpkzGk3n8jLX7qoyVjqqrYLxZgv61z4rUBt/json/2.json")
(try! (nft-mint? crash-punks-animated-series u3 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS))
(map-set token-count 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS (+ (get-balance 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS) u1))
(map-set cids u3 "QmadAX2yLvYTpkzGk3n8jLX7qoyVjqqrYLxZgv61z4rUBt/json/3.json")
(try! (nft-mint? crash-punks-animated-series u4 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS))
(map-set token-count 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS (+ (get-balance 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS) u1))
(map-set cids u4 "QmadAX2yLvYTpkzGk3n8jLX7qoyVjqqrYLxZgv61z4rUBt/json/4.json")
(try! (nft-mint? crash-punks-animated-series u5 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS))
(map-set token-count 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS (+ (get-balance 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS) u1))
(map-set cids u5 "QmadAX2yLvYTpkzGk3n8jLX7qoyVjqqrYLxZgv61z4rUBt/json/5.json")
(try! (nft-mint? crash-punks-animated-series u6 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS))
(map-set token-count 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS (+ (get-balance 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS) u1))
(map-set cids u6 "QmadAX2yLvYTpkzGk3n8jLX7qoyVjqqrYLxZgv61z4rUBt/json/6.json")
(try! (nft-mint? crash-punks-animated-series u7 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS))
(map-set token-count 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS (+ (get-balance 'SPAGKDWK07GB9T2X5PZ12N004PDW94MJGRR2JSHS) u1))
(map-set cids u7 "QmadAX2yLvYTpkzGk3n8jLX7qoyVjqqrYLxZgv61z4rUBt/json/7.json")
(var-set last-id u7)