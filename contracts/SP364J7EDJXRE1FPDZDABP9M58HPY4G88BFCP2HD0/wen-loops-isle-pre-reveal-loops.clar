;; wen-loops-isle-pre-reveal-loops
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token wen-loops-isle-pre-reveal-loops uint)

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
(define-data-var artist-address principal 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G)
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
    (nft-burn? wen-loops-isle-pre-reveal-loops token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? wen-loops-isle-pre-reveal-loops token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? wen-loops-isle-pre-reveal-loops token-id)))

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
    (unwrap! (nft-mint? wen-loops-isle-pre-reveal-loops next-id tx-sender) next-id)
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
  (match (nft-transfer? wen-loops-isle-pre-reveal-loops id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? wen-loops-isle-pre-reveal-loops id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? wen-loops-isle-pre-reveal-loops id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? wen-loops-isle-pre-reveal-loops u1 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u1 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/1.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u2 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u2 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/2.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u3 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u3 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/3.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u4 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u4 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/4.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u5 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u5 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/5.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u6 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u6 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/6.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u7 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u7 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/7.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u8 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u8 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/8.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u9 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u9 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/9.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u10 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u10 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/10.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u11 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u11 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/11.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u12 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u12 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/12.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u13 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u13 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/13.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u14 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u14 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/14.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u15 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u15 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/15.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u16 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u16 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/16.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u17 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u17 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/17.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u18 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u18 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/18.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u19 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u19 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/19.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u20 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u20 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/20.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u21 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u21 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/21.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u22 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u22 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/22.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u23 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u23 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/23.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u24 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u24 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/24.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u25 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u25 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/25.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u26 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u26 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/26.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u27 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u27 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/27.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u28 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u28 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/28.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u29 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u29 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/29.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u30 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u30 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/30.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u31 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u31 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/31.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u32 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u32 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/32.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u33 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u33 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/33.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u34 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u34 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/34.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u35 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u35 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/35.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u36 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u36 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/36.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u37 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u37 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/37.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u38 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u38 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/38.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u39 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u39 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/39.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u40 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u40 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/40.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u41 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u41 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/41.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u42 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u42 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/42.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u43 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u43 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/43.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u44 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u44 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/44.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u45 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u45 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/45.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u46 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u46 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/46.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u47 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u47 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/47.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u48 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u48 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/48.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u49 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u49 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/49.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u50 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u50 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/50.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u51 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u51 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/51.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u52 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u52 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/52.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u53 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u53 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/53.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u54 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u54 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/54.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u55 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u55 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/55.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u56 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u56 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/56.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u57 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u57 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/57.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u58 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u58 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/58.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u59 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u59 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/59.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u60 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u60 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/60.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u61 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u61 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/61.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u62 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u62 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/62.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u63 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u63 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/63.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u64 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u64 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/64.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u65 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u65 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/65.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u66 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u66 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/66.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u67 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u67 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/67.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u68 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u68 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/68.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u69 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u69 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/69.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u70 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u70 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/70.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u71 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u71 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/71.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u72 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u72 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/72.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u73 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u73 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/73.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u74 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u74 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/74.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u75 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u75 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/75.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u76 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u76 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/76.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u77 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u77 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/77.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u78 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u78 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/78.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u79 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u79 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/79.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u80 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u80 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/80.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u81 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u81 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/81.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u82 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u82 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/82.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u83 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u83 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/83.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u84 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u84 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/84.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u85 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u85 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/85.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u86 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u86 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/86.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u87 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u87 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/87.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u88 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u88 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/88.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u89 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u89 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/89.json")
(try! (nft-mint? wen-loops-isle-pre-reveal-loops u90 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
(map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
(map-set cids u90 "QmdpBvoBDMoyuSdgdJBP7mBoX2AHLZ3sMExQxKDaC4xyHd/json/90.json")
(var-set last-id u90)

(define-data-var license-uri (string-ascii 80) "")
(define-data-var license-name (string-ascii 40) "")

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