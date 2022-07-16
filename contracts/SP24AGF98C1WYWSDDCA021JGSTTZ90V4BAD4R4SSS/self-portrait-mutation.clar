;; self-portrait-mutation

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token self-portrait-mutation uint)

(define-constant DEPLOYER tx-sender)

(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INVALID-USER u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-NOT-FOUND u105)
(define-constant ERR-NFT-MINT u106)
(define-constant ERR-CONTRACT-LOCKED u107)

(define-data-var last-id uint u0)
(define-data-var artist-address principal 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS)
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
    (nft-burn? self-portrait-mutation token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? self-portrait-mutation token-id) false)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? self-portrait-mutation token-id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? self-portrait-mutation token-id)))

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
    (unwrap! (nft-mint? self-portrait-mutation next-id tx-sender) next-id)
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
  (match (nft-transfer? self-portrait-mutation id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? self-portrait-mutation id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? self-portrait-mutation id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? self-portrait-mutation u1 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u1 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/1.json")
(try! (nft-mint? self-portrait-mutation u2 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u2 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/2.json")
(try! (nft-mint? self-portrait-mutation u3 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u3 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/3.json")
(try! (nft-mint? self-portrait-mutation u4 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u4 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/4.json")
(try! (nft-mint? self-portrait-mutation u5 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u5 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/5.json")
(try! (nft-mint? self-portrait-mutation u6 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u6 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/6.json")
(try! (nft-mint? self-portrait-mutation u7 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u7 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/7.json")
(try! (nft-mint? self-portrait-mutation u8 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u8 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/8.json")
(try! (nft-mint? self-portrait-mutation u9 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u9 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/9.json")
(try! (nft-mint? self-portrait-mutation u10 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u10 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/10.json")
(try! (nft-mint? self-portrait-mutation u11 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u11 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/11.json")
(try! (nft-mint? self-portrait-mutation u12 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u12 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/12.json")
(try! (nft-mint? self-portrait-mutation u13 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u13 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/13.json")
(try! (nft-mint? self-portrait-mutation u14 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u14 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/14.json")
(try! (nft-mint? self-portrait-mutation u15 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u15 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/15.json")
(try! (nft-mint? self-portrait-mutation u16 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u16 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/16.json")
(try! (nft-mint? self-portrait-mutation u17 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u17 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/17.json")
(try! (nft-mint? self-portrait-mutation u18 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u18 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/18.json")
(try! (nft-mint? self-portrait-mutation u19 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u19 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/19.json")
(try! (nft-mint? self-portrait-mutation u20 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u20 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/20.json")
(try! (nft-mint? self-portrait-mutation u21 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u21 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/21.json")
(try! (nft-mint? self-portrait-mutation u22 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u22 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/22.json")
(try! (nft-mint? self-portrait-mutation u23 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u23 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/23.json")
(try! (nft-mint? self-portrait-mutation u24 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u24 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/24.json")
(try! (nft-mint? self-portrait-mutation u25 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS))
(map-set token-count 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS (+ (get-balance 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS) u1))
(map-set cids u25 "QmS86WkEfwVjoWghvbJSLponVbn6vCDggzeZA3hhfEdwcH/json/25.json")
(var-set last-id u25)