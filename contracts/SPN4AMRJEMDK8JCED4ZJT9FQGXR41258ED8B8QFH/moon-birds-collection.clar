;; moon-birds-collection
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token moon-birds-collection uint)

(define-constant DEPLOYER tx-sender)

(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INVALID-USER u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-NOT-FOUND u105)
(define-constant ERR-NFT-MINT u106)
(define-constant ERR-CONTRACT-LOCKED u107)
(define-constant ERR-INVALID-PERCENTAGE u114)

(define-data-var last-id uint u0)
(define-data-var artist-address principal 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH)
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
    (nft-burn? moon-birds-collection token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? moon-birds-collection token-id) false)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? moon-birds-collection token-id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? moon-birds-collection token-id)))

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
    (unwrap! (nft-mint? moon-birds-collection next-id tx-sender) next-id)
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
  (match (nft-transfer? moon-birds-collection id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? moon-birds-collection id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? moon-birds-collection id) (err ERR-NOT-FOUND)))
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

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

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

(try! (nft-mint? moon-birds-collection u1 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u1 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/1.json")
(try! (nft-mint? moon-birds-collection u2 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u2 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/2.json")
(try! (nft-mint? moon-birds-collection u3 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u3 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/3.json")
(try! (nft-mint? moon-birds-collection u4 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u4 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/4.json")
(try! (nft-mint? moon-birds-collection u5 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u5 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/5.json")
(try! (nft-mint? moon-birds-collection u6 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u6 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/6.json")
(try! (nft-mint? moon-birds-collection u7 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u7 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/7.json")
(try! (nft-mint? moon-birds-collection u8 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u8 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/8.json")
(try! (nft-mint? moon-birds-collection u9 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u9 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/9.json")
(try! (nft-mint? moon-birds-collection u10 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u10 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/10.json")
(try! (nft-mint? moon-birds-collection u11 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u11 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/11.json")
(try! (nft-mint? moon-birds-collection u12 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u12 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/12.json")
(try! (nft-mint? moon-birds-collection u13 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u13 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/13.json")
(try! (nft-mint? moon-birds-collection u14 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u14 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/14.json")
(try! (nft-mint? moon-birds-collection u15 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH))
(map-set token-count 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH (+ (get-balance 'SPN4AMRJEMDK8JCED4ZJT9FQGXR41258ED8B8QFH) u1))
(map-set cids u15 "Qma9hWsX4Q3oBPb29rSkwK1kaUsZovbwmRFR21qU7RTW5n/json/15.json")
(var-set last-id u15)