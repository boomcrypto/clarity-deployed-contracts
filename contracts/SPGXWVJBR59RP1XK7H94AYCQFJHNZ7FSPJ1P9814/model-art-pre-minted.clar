;; model-art-pre-minted
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token model-art-pre-minted uint)

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
(define-data-var artist-address principal 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814)
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
    (nft-burn? model-art-pre-minted token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? model-art-pre-minted token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? model-art-pre-minted token-id)))

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
    (unwrap! (nft-mint? model-art-pre-minted next-id tx-sender) next-id)
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
  (match (nft-transfer? model-art-pre-minted id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? model-art-pre-minted id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? model-art-pre-minted id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? model-art-pre-minted u1 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u1 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/1.json")
(try! (nft-mint? model-art-pre-minted u2 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u2 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/2.json")
(try! (nft-mint? model-art-pre-minted u3 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u3 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/3.json")
(try! (nft-mint? model-art-pre-minted u4 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u4 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/4.json")
(try! (nft-mint? model-art-pre-minted u5 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u5 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/5.json")
(try! (nft-mint? model-art-pre-minted u6 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u6 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/6.json")
(try! (nft-mint? model-art-pre-minted u7 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u7 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/7.json")
(try! (nft-mint? model-art-pre-minted u8 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u8 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/8.json")
(try! (nft-mint? model-art-pre-minted u9 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u9 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/9.json")
(try! (nft-mint? model-art-pre-minted u10 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u10 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/10.json")
(try! (nft-mint? model-art-pre-minted u11 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u11 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/11.json")
(try! (nft-mint? model-art-pre-minted u12 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u12 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/12.json")
(try! (nft-mint? model-art-pre-minted u13 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u13 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/13.json")
(try! (nft-mint? model-art-pre-minted u14 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u14 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/14.json")
(try! (nft-mint? model-art-pre-minted u15 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u15 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/15.json")
(try! (nft-mint? model-art-pre-minted u16 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u16 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/16.json")
(try! (nft-mint? model-art-pre-minted u17 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u17 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/17.json")
(try! (nft-mint? model-art-pre-minted u18 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u18 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/18.json")
(try! (nft-mint? model-art-pre-minted u19 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u19 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/19.json")
(try! (nft-mint? model-art-pre-minted u20 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u20 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/20.json")
(try! (nft-mint? model-art-pre-minted u21 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u21 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/21.json")
(try! (nft-mint? model-art-pre-minted u22 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u22 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/22.json")
(try! (nft-mint? model-art-pre-minted u23 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u23 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/23.json")
(try! (nft-mint? model-art-pre-minted u24 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u24 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/24.json")
(try! (nft-mint? model-art-pre-minted u25 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u25 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/25.json")
(try! (nft-mint? model-art-pre-minted u26 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u26 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/26.json")
(try! (nft-mint? model-art-pre-minted u27 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u27 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/27.json")
(try! (nft-mint? model-art-pre-minted u28 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u28 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/28.json")
(try! (nft-mint? model-art-pre-minted u29 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u29 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/29.json")
(try! (nft-mint? model-art-pre-minted u30 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u30 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/30.json")
(try! (nft-mint? model-art-pre-minted u31 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u31 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/31.json")
(try! (nft-mint? model-art-pre-minted u32 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u32 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/32.json")
(try! (nft-mint? model-art-pre-minted u33 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u33 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/33.json")
(try! (nft-mint? model-art-pre-minted u34 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u34 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/34.json")
(try! (nft-mint? model-art-pre-minted u35 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u35 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/35.json")
(try! (nft-mint? model-art-pre-minted u36 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u36 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/36.json")
(try! (nft-mint? model-art-pre-minted u37 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814))
(map-set token-count 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814 (+ (get-balance 'SPGXWVJBR59RP1XK7H94AYCQFJHNZ7FSPJ1P9814) u1))
(map-set cids u37 "QmdhkQisTbShs7mRabM5jHtpsVxwMCh5uoxPSi3awumrSS/json/37.json")
(var-set last-id u37)

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