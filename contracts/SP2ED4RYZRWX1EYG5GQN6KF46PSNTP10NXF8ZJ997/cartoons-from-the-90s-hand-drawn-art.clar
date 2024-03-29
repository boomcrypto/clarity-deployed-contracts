;; cartoons-from-the-90s-hand-drawn-art
;; contractType: continuous

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token cartoons-from-the-90s-hand-drawn-art uint)

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
(define-data-var artist-address principal 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997)
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
    (nft-burn? cartoons-from-the-90s-hand-drawn-art token-id tx-sender)))

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
    (is-eq user (unwrap! (nft-get-owner? cartoons-from-the-90s-hand-drawn-art token-id) false)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? cartoons-from-the-90s-hand-drawn-art token-id)))

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
    (unwrap! (nft-mint? cartoons-from-the-90s-hand-drawn-art next-id tx-sender) next-id)
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
  (match (nft-transfer? cartoons-from-the-90s-hand-drawn-art id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? cartoons-from-the-90s-hand-drawn-art id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? cartoons-from-the-90s-hand-drawn-art id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u1 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u1 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/1.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u2 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u2 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/2.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u3 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u3 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/3.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u4 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u4 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/4.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u5 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u5 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/5.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u6 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u6 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/6.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u7 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u7 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/7.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u8 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u8 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/8.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u9 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u9 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/9.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u10 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u10 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/10.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u11 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u11 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/11.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u12 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u12 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/12.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u13 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u13 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/13.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u14 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u14 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/14.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u15 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u15 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/15.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u16 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u16 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/16.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u17 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u17 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/17.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u18 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u18 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/18.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u19 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u19 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/19.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u20 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u20 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/20.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u21 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u21 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/21.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u22 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u22 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/22.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u23 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u23 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/23.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u24 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u24 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/24.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u25 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u25 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/25.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u26 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u26 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/26.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u27 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u27 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/27.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u28 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u28 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/28.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u29 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u29 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/29.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u30 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u30 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/30.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u31 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u31 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/31.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u32 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u32 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/32.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u33 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u33 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/33.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u34 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u34 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/34.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u35 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u35 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/35.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u36 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u36 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/36.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u37 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u37 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/37.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u38 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u38 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/38.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u39 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u39 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/39.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u40 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u40 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/40.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u41 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u41 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/41.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u42 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u42 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/42.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u43 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u43 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/43.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u44 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u44 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/44.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u45 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u45 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/45.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u46 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u46 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/46.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u47 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u47 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/47.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u48 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u48 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/48.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u49 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u49 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/49.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u50 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u50 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/50.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u51 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u51 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/51.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u52 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u52 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/52.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u53 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u53 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/53.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u54 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u54 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/54.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u55 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u55 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/55.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u56 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u56 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/56.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u57 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u57 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/57.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u58 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u58 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/58.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u59 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u59 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/59.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u60 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u60 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/60.json")
(try! (nft-mint? cartoons-from-the-90s-hand-drawn-art u61 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997))
(map-set token-count 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997 (+ (get-balance 'SP2ED4RYZRWX1EYG5GQN6KF46PSNTP10NXF8ZJ997) u1))
(map-set cids u61 "QmNsvsYb65jjpdBES3LJJNsfM38ZTXoDemueHs7d8Ww8YJ/json/61.json")
(var-set last-id u61)

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