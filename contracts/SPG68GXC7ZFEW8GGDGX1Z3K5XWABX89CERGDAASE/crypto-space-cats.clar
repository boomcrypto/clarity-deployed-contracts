;; crypto-space-cats
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token crypto-space-cats uint)

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
(define-data-var artist-address principal 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY)
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
    (nft-burn? crypto-space-cats token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? crypto-space-cats token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? crypto-space-cats token-id)))

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
    (unwrap! (nft-mint? crypto-space-cats next-id tx-sender) next-id)
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
  (match (nft-transfer? crypto-space-cats id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? crypto-space-cats id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? crypto-space-cats id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? crypto-space-cats u1 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u1 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/1.json")
(try! (nft-mint? crypto-space-cats u2 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u2 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/2.json")
(try! (nft-mint? crypto-space-cats u3 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u3 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/3.json")
(try! (nft-mint? crypto-space-cats u4 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u4 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/4.json")
(try! (nft-mint? crypto-space-cats u5 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u5 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/5.json")
(try! (nft-mint? crypto-space-cats u6 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u6 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/6.json")
(try! (nft-mint? crypto-space-cats u7 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u7 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/7.json")
(try! (nft-mint? crypto-space-cats u8 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u8 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/8.json")
(try! (nft-mint? crypto-space-cats u9 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u9 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/9.json")
(try! (nft-mint? crypto-space-cats u10 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u10 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/10.json")
(try! (nft-mint? crypto-space-cats u11 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u11 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/11.json")
(try! (nft-mint? crypto-space-cats u12 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u12 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/12.json")
(try! (nft-mint? crypto-space-cats u13 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u13 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/13.json")
(try! (nft-mint? crypto-space-cats u14 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u14 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/14.json")
(try! (nft-mint? crypto-space-cats u15 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u15 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/15.json")
(try! (nft-mint? crypto-space-cats u16 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY))
(map-set token-count 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY (+ (get-balance 'SPSMBFPF90R5A0REWQF18B19Z4AQ24AHCTEVHJHY) u1))
(map-set cids u16 "QmW7MpY3B1JqWbrVVK7SMACEduv8WeLNPiDG1Mfhc5sCiB/json/16.json")
(var-set last-id u16)

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/3")
(define-data-var license-name (string-ascii 40) "COMMERCIAL-NO-HATE")

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