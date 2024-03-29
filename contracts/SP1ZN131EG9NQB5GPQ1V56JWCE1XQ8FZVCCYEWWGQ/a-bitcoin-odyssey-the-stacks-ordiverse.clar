;; a-bitcoin-odyssey-the-stacks-ordiverse
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token a-bitcoin-odyssey-the-stacks-ordiverse uint)

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
(define-data-var artist-address principal 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ)
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
    (nft-burn? a-bitcoin-odyssey-the-stacks-ordiverse token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? a-bitcoin-odyssey-the-stacks-ordiverse token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? a-bitcoin-odyssey-the-stacks-ordiverse token-id)))

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
    (unwrap! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse next-id tx-sender) next-id)
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
  (match (nft-transfer? a-bitcoin-odyssey-the-stacks-ordiverse id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? a-bitcoin-odyssey-the-stacks-ordiverse id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? a-bitcoin-odyssey-the-stacks-ordiverse id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u1 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u1 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/1.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u2 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u2 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/2.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u3 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u3 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/3.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u4 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u4 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/4.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u5 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u5 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/5.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u6 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u6 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/6.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u7 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u7 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/7.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u8 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u8 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/8.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u9 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u9 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/9.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u10 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u10 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/10.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u11 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u11 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/11.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u12 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u12 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/12.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u13 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u13 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/13.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u14 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u14 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/14.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u15 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u15 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/15.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u16 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u16 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/16.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u17 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u17 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/17.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u18 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u18 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/18.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u19 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u19 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/19.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u20 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u20 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/20.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u21 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u21 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/21.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u22 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u22 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/22.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u23 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u23 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/23.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u24 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u24 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/24.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u25 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u25 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/25.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u26 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u26 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/26.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u27 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u27 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/27.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u28 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u28 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/28.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u29 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u29 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/29.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u30 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u30 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/30.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u31 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u31 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/31.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u32 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u32 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/32.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u33 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u33 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/33.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u34 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u34 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/34.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u35 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u35 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/35.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u36 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u36 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/36.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u37 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u37 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/37.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u38 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u38 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/38.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u39 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u39 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/39.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u40 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u40 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/40.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u41 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u41 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/41.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u42 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u42 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/42.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u43 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u43 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/43.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u44 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u44 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/44.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u45 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u45 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/45.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u46 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u46 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/46.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u47 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u47 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/47.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u48 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u48 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/48.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u49 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u49 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/49.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u50 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u50 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/50.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u51 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u51 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/51.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u52 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u52 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/52.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u53 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u53 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/53.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u54 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u54 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/54.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u55 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u55 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/55.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u56 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u56 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/56.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u57 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u57 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/57.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u58 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u58 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/58.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u59 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u59 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/59.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u60 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u60 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/60.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u61 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u61 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/61.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u62 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u62 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/62.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u63 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u63 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/63.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u64 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u64 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/64.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u65 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u65 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/65.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u66 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u66 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/66.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u67 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u67 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/67.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u68 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u68 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/68.json")
(try! (nft-mint? a-bitcoin-odyssey-the-stacks-ordiverse u69 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ))
(map-set token-count 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ (+ (get-balance 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ) u1))
(map-set cids u69 "QmYbaqSRjz7QSW5QVcZYLyFP1HGW96fWMXktupymBWrawn/json/69.json")
(var-set last-id u69)

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/0")
(define-data-var license-name (string-ascii 40) "PUBLIC")

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