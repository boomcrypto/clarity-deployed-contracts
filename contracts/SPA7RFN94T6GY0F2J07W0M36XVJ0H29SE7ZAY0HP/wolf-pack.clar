;; wolf-pack
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token wolf-pack uint)

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
(define-data-var artist-address principal 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP)
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
    (nft-burn? wolf-pack token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? wolf-pack token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? wolf-pack token-id)))

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
    (unwrap! (nft-mint? wolf-pack next-id tx-sender) next-id)
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
  (match (nft-transfer? wolf-pack id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? wolf-pack id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? wolf-pack id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? wolf-pack u1 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u1 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/1.json")
(try! (nft-mint? wolf-pack u2 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u2 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/2.json")
(try! (nft-mint? wolf-pack u3 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u3 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/3.json")
(try! (nft-mint? wolf-pack u4 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u4 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/4.json")
(try! (nft-mint? wolf-pack u5 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u5 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/5.json")
(try! (nft-mint? wolf-pack u6 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u6 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/6.json")
(try! (nft-mint? wolf-pack u7 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u7 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/7.json")
(try! (nft-mint? wolf-pack u8 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u8 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/8.json")
(try! (nft-mint? wolf-pack u9 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u9 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/9.json")
(try! (nft-mint? wolf-pack u10 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u10 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/10.json")
(try! (nft-mint? wolf-pack u11 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u11 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/11.json")
(try! (nft-mint? wolf-pack u12 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u12 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/12.json")
(try! (nft-mint? wolf-pack u13 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u13 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/13.json")
(try! (nft-mint? wolf-pack u14 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u14 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/14.json")
(try! (nft-mint? wolf-pack u15 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u15 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/15.json")
(try! (nft-mint? wolf-pack u16 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u16 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/16.json")
(try! (nft-mint? wolf-pack u17 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u17 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/17.json")
(try! (nft-mint? wolf-pack u18 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u18 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/18.json")
(try! (nft-mint? wolf-pack u19 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u19 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/19.json")
(try! (nft-mint? wolf-pack u20 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u20 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/20.json")
(try! (nft-mint? wolf-pack u21 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u21 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/21.json")
(try! (nft-mint? wolf-pack u22 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u22 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/22.json")
(try! (nft-mint? wolf-pack u23 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u23 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/23.json")
(try! (nft-mint? wolf-pack u24 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP))
(map-set token-count 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP (+ (get-balance 'SPA7RFN94T6GY0F2J07W0M36XVJ0H29SE7ZAY0HP) u1))
(map-set cids u24 "QmXTje5N1bAyMSfMoR1zArVmTmz1qyo2NXyyqwkN6pB5CK/json/24.json")
(var-set last-id u24)

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/2")
(define-data-var license-name (string-ascii 40) "COMMERCIAL")

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