;; glitched-crash-punks

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
;;(impl-trait .nft-trait.nft-trait)

(define-non-fungible-token glitched-crash-punks uint)

(define-constant DEPLOYER tx-sender)

(define-constant ERR-NOT-AUTHORIZED u101)
(define-constant ERR-INVALID-USER u102)
(define-constant ERR-LISTING u103)
(define-constant ERR-WRONG-COMMISSION u104)
(define-constant ERR-NOT-FOUND u105)
(define-constant ERR-NFT-MINT u106)
(define-constant ERR-CONTRACT-LOCKED u107)

(define-data-var last-id uint u0)
(define-data-var artist-address principal 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN)
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
    (nft-burn? glitched-crash-punks token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? glitched-crash-punks token-id) false)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? glitched-crash-punks token-id sender recipient)))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? glitched-crash-punks token-id)))

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
    (unwrap! (nft-mint? glitched-crash-punks next-id tx-sender) next-id)
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
  (match (nft-transfer? glitched-crash-punks id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? glitched-crash-punks id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? glitched-crash-punks id) (err ERR-NOT-FOUND)))
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

(try! (nft-mint? glitched-crash-punks u1 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u1 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/1.json")
(try! (nft-mint? glitched-crash-punks u2 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u2 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/2.json")
(try! (nft-mint? glitched-crash-punks u3 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u3 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/3.json")
(try! (nft-mint? glitched-crash-punks u4 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u4 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/4.json")
(try! (nft-mint? glitched-crash-punks u5 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u5 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/5.json")
(try! (nft-mint? glitched-crash-punks u6 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u6 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/6.json")
(try! (nft-mint? glitched-crash-punks u7 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u7 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/7.json")
(try! (nft-mint? glitched-crash-punks u8 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u8 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/8.json")
(try! (nft-mint? glitched-crash-punks u9 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u9 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/9.json")
(try! (nft-mint? glitched-crash-punks u10 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u10 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/10.json")
(try! (nft-mint? glitched-crash-punks u11 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u11 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/11.json")
(try! (nft-mint? glitched-crash-punks u12 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u12 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/12.json")
(try! (nft-mint? glitched-crash-punks u13 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u13 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/13.json")
(try! (nft-mint? glitched-crash-punks u14 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u14 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/14.json")
(try! (nft-mint? glitched-crash-punks u15 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u15 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/15.json")
(try! (nft-mint? glitched-crash-punks u16 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u16 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/16.json")
(try! (nft-mint? glitched-crash-punks u17 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u17 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/17.json")
(try! (nft-mint? glitched-crash-punks u18 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u18 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/18.json")
(try! (nft-mint? glitched-crash-punks u19 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u19 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/19.json")
(try! (nft-mint? glitched-crash-punks u20 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN))
(map-set token-count 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN (+ (get-balance 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN) u1))
(map-set cids u20 "QmNwwdqSas9oSSBcq46QjoYuNScXhCWUM5Z1XrVzcQ7BEQ/json/20.json")
(var-set last-id u20)