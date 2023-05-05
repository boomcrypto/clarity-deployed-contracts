;; bns-10v4
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token bns-10v4 uint)

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
(define-data-var artist-address principal 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9)
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
    (nft-burn? bns-10v4 token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? bns-10v4 token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? bns-10v4 token-id)))

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
    (unwrap! (nft-mint? bns-10v4 next-id tx-sender) next-id)
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
  (match (nft-transfer? bns-10v4 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? bns-10v4 id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? bns-10v4 id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? bns-10v4 u1 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u1 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/1.json")
(try! (nft-mint? bns-10v4 u2 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u2 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/2.json")
(try! (nft-mint? bns-10v4 u3 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u3 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/3.json")
(try! (nft-mint? bns-10v4 u4 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u4 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/4.json")
(try! (nft-mint? bns-10v4 u5 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u5 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/5.json")
(try! (nft-mint? bns-10v4 u6 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u6 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/6.json")
(try! (nft-mint? bns-10v4 u7 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u7 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/7.json")
(try! (nft-mint? bns-10v4 u8 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u8 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/8.json")
(try! (nft-mint? bns-10v4 u9 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u9 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/9.json")
(try! (nft-mint? bns-10v4 u10 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u10 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/10.json")
(try! (nft-mint? bns-10v4 u11 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u11 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/11.json")
(try! (nft-mint? bns-10v4 u12 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u12 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/12.json")
(try! (nft-mint? bns-10v4 u13 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u13 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/13.json")
(try! (nft-mint? bns-10v4 u14 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u14 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/14.json")
(try! (nft-mint? bns-10v4 u15 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u15 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/15.json")
(try! (nft-mint? bns-10v4 u16 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u16 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/16.json")
(try! (nft-mint? bns-10v4 u17 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u17 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/17.json")
(try! (nft-mint? bns-10v4 u18 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u18 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/18.json")
(try! (nft-mint? bns-10v4 u19 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u19 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/19.json")
(try! (nft-mint? bns-10v4 u20 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u20 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/20.json")
(try! (nft-mint? bns-10v4 u21 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u21 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/21.json")
(try! (nft-mint? bns-10v4 u22 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u22 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/22.json")
(try! (nft-mint? bns-10v4 u23 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u23 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/23.json")
(try! (nft-mint? bns-10v4 u24 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u24 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/24.json")
(try! (nft-mint? bns-10v4 u25 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u25 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/25.json")
(try! (nft-mint? bns-10v4 u26 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u26 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/26.json")
(try! (nft-mint? bns-10v4 u27 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u27 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/27.json")
(try! (nft-mint? bns-10v4 u28 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u28 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/28.json")
(try! (nft-mint? bns-10v4 u29 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u29 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/29.json")
(try! (nft-mint? bns-10v4 u30 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u30 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/30.json")
(try! (nft-mint? bns-10v4 u31 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u31 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/31.json")
(try! (nft-mint? bns-10v4 u32 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u32 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/32.json")
(try! (nft-mint? bns-10v4 u33 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u33 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/33.json")
(try! (nft-mint? bns-10v4 u34 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u34 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/34.json")
(try! (nft-mint? bns-10v4 u35 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u35 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/35.json")
(try! (nft-mint? bns-10v4 u36 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u36 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/36.json")
(try! (nft-mint? bns-10v4 u37 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u37 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/37.json")
(try! (nft-mint? bns-10v4 u38 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u38 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/38.json")
(try! (nft-mint? bns-10v4 u39 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u39 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/39.json")
(try! (nft-mint? bns-10v4 u40 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u40 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/40.json")
(try! (nft-mint? bns-10v4 u41 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u41 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/41.json")
(try! (nft-mint? bns-10v4 u42 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u42 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/42.json")
(try! (nft-mint? bns-10v4 u43 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u43 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/43.json")
(try! (nft-mint? bns-10v4 u44 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u44 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/44.json")
(try! (nft-mint? bns-10v4 u45 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u45 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/45.json")
(try! (nft-mint? bns-10v4 u46 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u46 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/46.json")
(try! (nft-mint? bns-10v4 u47 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u47 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/47.json")
(try! (nft-mint? bns-10v4 u48 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u48 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/48.json")
(try! (nft-mint? bns-10v4 u49 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u49 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/49.json")
(try! (nft-mint? bns-10v4 u50 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u50 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/50.json")
(try! (nft-mint? bns-10v4 u51 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u51 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/51.json")
(try! (nft-mint? bns-10v4 u52 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u52 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/52.json")
(try! (nft-mint? bns-10v4 u53 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u53 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/53.json")
(try! (nft-mint? bns-10v4 u54 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u54 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/54.json")
(try! (nft-mint? bns-10v4 u55 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u55 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/55.json")
(try! (nft-mint? bns-10v4 u56 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u56 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/56.json")
(try! (nft-mint? bns-10v4 u57 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u57 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/57.json")
(try! (nft-mint? bns-10v4 u58 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u58 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/58.json")
(try! (nft-mint? bns-10v4 u59 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u59 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/59.json")
(try! (nft-mint? bns-10v4 u60 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u60 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/60.json")
(try! (nft-mint? bns-10v4 u61 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u61 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/61.json")
(try! (nft-mint? bns-10v4 u62 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u62 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/62.json")
(try! (nft-mint? bns-10v4 u63 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u63 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/63.json")
(try! (nft-mint? bns-10v4 u64 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u64 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/64.json")
(try! (nft-mint? bns-10v4 u65 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u65 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/65.json")
(try! (nft-mint? bns-10v4 u66 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u66 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/66.json")
(try! (nft-mint? bns-10v4 u67 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u67 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/67.json")
(try! (nft-mint? bns-10v4 u68 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u68 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/68.json")
(try! (nft-mint? bns-10v4 u69 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u69 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/69.json")
(try! (nft-mint? bns-10v4 u70 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u70 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/70.json")
(try! (nft-mint? bns-10v4 u71 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u71 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/71.json")
(try! (nft-mint? bns-10v4 u72 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u72 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/72.json")
(try! (nft-mint? bns-10v4 u73 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u73 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/73.json")
(try! (nft-mint? bns-10v4 u74 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u74 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/74.json")
(try! (nft-mint? bns-10v4 u75 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u75 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/75.json")
(try! (nft-mint? bns-10v4 u76 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u76 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/76.json")
(try! (nft-mint? bns-10v4 u77 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u77 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/77.json")
(try! (nft-mint? bns-10v4 u78 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u78 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/78.json")
(try! (nft-mint? bns-10v4 u79 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u79 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/79.json")
(try! (nft-mint? bns-10v4 u80 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u80 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/80.json")
(try! (nft-mint? bns-10v4 u81 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u81 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/81.json")
(try! (nft-mint? bns-10v4 u82 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u82 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/82.json")
(try! (nft-mint? bns-10v4 u83 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u83 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/83.json")
(try! (nft-mint? bns-10v4 u84 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u84 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/84.json")
(try! (nft-mint? bns-10v4 u85 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u85 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/85.json")
(try! (nft-mint? bns-10v4 u86 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u86 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/86.json")
(try! (nft-mint? bns-10v4 u87 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u87 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/87.json")
(try! (nft-mint? bns-10v4 u88 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u88 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/88.json")
(try! (nft-mint? bns-10v4 u89 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u89 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/89.json")
(try! (nft-mint? bns-10v4 u90 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u90 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/90.json")
(try! (nft-mint? bns-10v4 u91 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u91 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/91.json")
(try! (nft-mint? bns-10v4 u92 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u92 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/92.json")
(try! (nft-mint? bns-10v4 u93 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u93 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/93.json")
(try! (nft-mint? bns-10v4 u94 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u94 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/94.json")
(try! (nft-mint? bns-10v4 u95 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u95 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/95.json")
(try! (nft-mint? bns-10v4 u96 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u96 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/96.json")
(try! (nft-mint? bns-10v4 u97 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u97 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/97.json")
(try! (nft-mint? bns-10v4 u98 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u98 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/98.json")
(try! (nft-mint? bns-10v4 u99 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u99 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/99.json")
(try! (nft-mint? bns-10v4 u100 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9))
(map-set token-count 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9 (+ (get-balance 'SP3XDGEE0DTABYJB7TR41Z68M5VAKXTBMS3CSWMB9) u1))
(map-set cids u100 "QmX8RgUV4fbzuSR8UdGe6dorDxpBNTjTEn9SnDPE23LM1K/json/100.json")
(var-set last-id u100)

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