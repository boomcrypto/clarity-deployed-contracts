---
title: "Trait fork-n-knife-fools-initiates-badge"
draft: true
---
```
;; fork-n-knife-fools-initiates-badge
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token fork-n-knife-fools-initiates-badge uint)

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
(define-data-var artist-address principal 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG)
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
    (nft-burn? fork-n-knife-fools-initiates-badge token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? fork-n-knife-fools-initiates-badge token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? fork-n-knife-fools-initiates-badge token-id)))

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
    (unwrap! (nft-mint? fork-n-knife-fools-initiates-badge next-id tx-sender) next-id)
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
  (match (nft-transfer? fork-n-knife-fools-initiates-badge id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? fork-n-knife-fools-initiates-badge id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? fork-n-knife-fools-initiates-badge id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? fork-n-knife-fools-initiates-badge u1 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u1 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/1.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u2 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u2 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/2.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u3 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u3 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/3.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u4 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u4 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/4.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u5 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u5 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/5.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u6 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u6 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/6.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u7 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u7 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/7.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u8 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u8 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/8.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u9 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u9 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/9.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u10 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u10 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/10.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u11 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u11 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/11.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u12 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u12 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/12.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u13 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u13 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/13.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u14 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u14 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/14.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u15 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u15 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/15.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u16 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u16 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/16.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u17 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u17 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/17.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u18 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u18 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/18.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u19 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u19 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/19.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u20 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u20 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/20.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u21 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u21 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/21.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u22 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u22 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/22.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u23 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u23 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/23.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u24 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u24 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/24.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u25 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u25 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/25.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u26 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u26 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/26.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u27 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u27 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/27.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u28 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u28 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/28.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u29 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u29 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/29.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u30 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u30 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/30.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u31 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u31 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/31.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u32 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u32 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/32.json")
(try! (nft-mint? fork-n-knife-fools-initiates-badge u33 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG))
(map-set token-count 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG (+ (get-balance 'SP13MQ92X6HP6H50ZN6C68R4A05XAY5PRWJQ57XGG) u1))
(map-set cids u33 "QmRA5WcXR57ScHPkrZXXMUks5mbdgjG4CG2ASEJtDeYzys/json/33.json")
(var-set last-id u33)

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/4")
(define-data-var license-name (string-ascii 40) "PERSONAL")

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
```
