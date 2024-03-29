;; the-grande-dames-last-dance
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token the-grande-dames-last-dance uint)

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
(define-data-var artist-address principal 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP)
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
    (nft-burn? the-grande-dames-last-dance token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? the-grande-dames-last-dance token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? the-grande-dames-last-dance token-id)))

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
    (unwrap! (nft-mint? the-grande-dames-last-dance next-id tx-sender) next-id)
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
  (match (nft-transfer? the-grande-dames-last-dance id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? the-grande-dames-last-dance id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? the-grande-dames-last-dance id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? the-grande-dames-last-dance u1 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u1 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/1.json")
(try! (nft-mint? the-grande-dames-last-dance u2 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u2 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/2.json")
(try! (nft-mint? the-grande-dames-last-dance u3 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u3 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/3.json")
(try! (nft-mint? the-grande-dames-last-dance u4 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u4 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/4.json")
(try! (nft-mint? the-grande-dames-last-dance u5 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u5 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/5.json")
(try! (nft-mint? the-grande-dames-last-dance u6 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u6 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/6.json")
(try! (nft-mint? the-grande-dames-last-dance u7 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u7 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/7.json")
(try! (nft-mint? the-grande-dames-last-dance u8 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u8 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/8.json")
(try! (nft-mint? the-grande-dames-last-dance u9 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u9 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/9.json")
(try! (nft-mint? the-grande-dames-last-dance u10 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u10 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/10.json")
(try! (nft-mint? the-grande-dames-last-dance u11 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u11 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/11.json")
(try! (nft-mint? the-grande-dames-last-dance u12 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u12 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/12.json")
(try! (nft-mint? the-grande-dames-last-dance u13 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u13 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/13.json")
(try! (nft-mint? the-grande-dames-last-dance u14 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u14 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/14.json")
(try! (nft-mint? the-grande-dames-last-dance u15 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u15 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/15.json")
(try! (nft-mint? the-grande-dames-last-dance u16 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u16 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/16.json")
(try! (nft-mint? the-grande-dames-last-dance u17 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u17 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/17.json")
(try! (nft-mint? the-grande-dames-last-dance u18 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u18 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/18.json")
(try! (nft-mint? the-grande-dames-last-dance u19 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u19 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/19.json")
(try! (nft-mint? the-grande-dames-last-dance u20 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u20 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/20.json")
(try! (nft-mint? the-grande-dames-last-dance u21 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u21 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/21.json")
(try! (nft-mint? the-grande-dames-last-dance u22 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u22 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/22.json")
(try! (nft-mint? the-grande-dames-last-dance u23 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u23 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/23.json")
(try! (nft-mint? the-grande-dames-last-dance u24 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u24 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/24.json")
(try! (nft-mint? the-grande-dames-last-dance u25 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u25 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/25.json")
(try! (nft-mint? the-grande-dames-last-dance u26 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u26 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/26.json")
(try! (nft-mint? the-grande-dames-last-dance u27 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u27 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/27.json")
(try! (nft-mint? the-grande-dames-last-dance u28 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u28 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/28.json")
(try! (nft-mint? the-grande-dames-last-dance u29 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u29 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/29.json")
(try! (nft-mint? the-grande-dames-last-dance u30 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u30 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/30.json")
(try! (nft-mint? the-grande-dames-last-dance u31 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u31 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/31.json")
(try! (nft-mint? the-grande-dames-last-dance u32 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u32 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/32.json")
(try! (nft-mint? the-grande-dames-last-dance u33 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u33 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/33.json")
(try! (nft-mint? the-grande-dames-last-dance u34 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u34 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/34.json")
(try! (nft-mint? the-grande-dames-last-dance u35 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u35 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/35.json")
(try! (nft-mint? the-grande-dames-last-dance u36 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u36 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/36.json")
(try! (nft-mint? the-grande-dames-last-dance u37 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u37 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/37.json")
(try! (nft-mint? the-grande-dames-last-dance u38 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u38 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/38.json")
(try! (nft-mint? the-grande-dames-last-dance u39 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u39 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/39.json")
(try! (nft-mint? the-grande-dames-last-dance u40 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u40 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/40.json")
(try! (nft-mint? the-grande-dames-last-dance u41 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u41 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/41.json")
(try! (nft-mint? the-grande-dames-last-dance u42 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u42 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/42.json")
(try! (nft-mint? the-grande-dames-last-dance u43 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u43 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/43.json")
(try! (nft-mint? the-grande-dames-last-dance u44 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u44 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/44.json")
(try! (nft-mint? the-grande-dames-last-dance u45 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u45 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/45.json")
(try! (nft-mint? the-grande-dames-last-dance u46 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u46 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/46.json")
(try! (nft-mint? the-grande-dames-last-dance u47 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u47 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/47.json")
(try! (nft-mint? the-grande-dames-last-dance u48 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u48 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/48.json")
(try! (nft-mint? the-grande-dames-last-dance u49 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u49 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/49.json")
(try! (nft-mint? the-grande-dames-last-dance u50 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u50 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/50.json")
(try! (nft-mint? the-grande-dames-last-dance u51 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u51 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/51.json")
(try! (nft-mint? the-grande-dames-last-dance u52 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u52 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/52.json")
(try! (nft-mint? the-grande-dames-last-dance u53 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u53 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/53.json")
(try! (nft-mint? the-grande-dames-last-dance u54 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u54 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/54.json")
(try! (nft-mint? the-grande-dames-last-dance u55 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u55 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/55.json")
(try! (nft-mint? the-grande-dames-last-dance u56 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u56 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/56.json")
(try! (nft-mint? the-grande-dames-last-dance u57 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u57 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/57.json")
(try! (nft-mint? the-grande-dames-last-dance u58 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u58 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/58.json")
(try! (nft-mint? the-grande-dames-last-dance u59 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u59 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/59.json")
(try! (nft-mint? the-grande-dames-last-dance u60 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u60 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/60.json")
(try! (nft-mint? the-grande-dames-last-dance u61 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u61 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/61.json")
(try! (nft-mint? the-grande-dames-last-dance u62 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u62 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/62.json")
(try! (nft-mint? the-grande-dames-last-dance u63 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u63 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/63.json")
(try! (nft-mint? the-grande-dames-last-dance u64 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u64 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/64.json")
(try! (nft-mint? the-grande-dames-last-dance u65 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u65 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/65.json")
(try! (nft-mint? the-grande-dames-last-dance u66 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u66 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/66.json")
(try! (nft-mint? the-grande-dames-last-dance u67 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u67 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/67.json")
(try! (nft-mint? the-grande-dames-last-dance u68 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u68 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/68.json")
(try! (nft-mint? the-grande-dames-last-dance u69 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
(map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
(map-set cids u69 "QmZVa7jR9CMAUc4cnNXwxHrQoMve2G5MA7yLSobkKbWYDT/json/69.json")
(var-set last-id u69)

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