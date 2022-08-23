;; public-009
;; contractType: public
;; version: 0
;; versionDate: 20220815
;; versionSummary: Add mint-with, list-in-token functionality via ft-trait

(impl-trait .nft-trait.nft-trait)
(impl-trait .mint-with-trait.mint-with-trait)
(use-trait ft-trait .ft-trait.ft-trait)

(define-non-fungible-token public-009 uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
(define-constant COMM-ADDR 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-NOT-ENOUGH-PASSES u101)
(define-constant ERR-PUBLIC-SALE-DISABLED u102)
(define-constant ERR-CONTRACT-INITIALIZED u103)
(define-constant ERR-NOT-AUTHORIZED u104)
(define-constant ERR-INVALID-USER u105)
(define-constant ERR-LISTING u106)
(define-constant ERR-WRONG-COMMISSION u107)
(define-constant ERR-NOT-FOUND u108)
(define-constant ERR-PAUSED u109)
(define-constant ERR-COLLECTION-SIZE u110)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-AIRDROP-CALLED u112)
(define-constant ERR-NO-MORE-MINTS u113)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-WRONG-TOKEN u116)
(define-constant ERR-UNSUPPORTED-TOKEN u500)

;; Internal variables
(define-data-var collection-size uint u10)
(define-data-var last-id uint u0)
(define-data-var total-price uint u1000000)
(define-data-var artist-address principal 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmbsrWpPUum3waxqRLAAFaj9fJeuHizZuxEmR1nJ64Dgo1/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)
(define-map token-prices principal uint)

(define-public (claim)
  (mint-many u1))

;; Default Minting
(define-public (mint-many (orders uint)) 
  (let 
    (
      (art-addr (var-get artist-address))
      (price (* (var-get total-price) orders))
      (total-commission (/ (* price COMM) u10000))
      (total-artist (- price total-commission))
      (current-balance (get-balance tx-sender))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ orders user-mints))) (err ERR-NO-MORE-MINTS))
    (try! (if (<= u1 orders) (mint) (ok u0)))
    (try! (if (<= u2 orders) (mint) (ok u0)))
    (try! (if (<= u3 orders) (mint) (ok u0)))
    (try! (if (<= u4 orders) (mint) (ok u0)))
    (try! (if (<= u5 orders) (mint) (ok u0)))
    (try! (if (<= u6 orders) (mint) (ok u0)))
    (try! (if (<= u7 orders) (mint) (ok u0)))
    (try! (if (<= u8 orders) (mint) (ok u0)))
    (try! (if (<= u9 orders) (mint) (ok u0)))
    (try! (if (<= u10 orders) (mint) (ok u0)))
    (try! (if (<= u11 orders) (mint) (ok u0)))
    (try! (if (<= u12 orders) (mint) (ok u0)))
    (try! (if (<= u13 orders) (mint) (ok u0)))
    (try! (if (<= u14 orders) (mint) (ok u0)))
    (try! (if (<= u15 orders) (mint) (ok u0)))
    (try! (if (<= u16 orders) (mint) (ok u0)))
    (try! (if (<= u17 orders) (mint) (ok u0)))
    (try! (if (<= u18 orders) (mint) (ok u0)))
    (try! (if (<= u19 orders) (mint) (ok u0)))
    (try! (if (<= u20 orders) (mint) (ok u0)))
    (try! (if (<= u21 orders) (mint) (ok u0)))
    (try! (if (<= u22 orders) (mint) (ok u0)))
    (try! (if (<= u23 orders) (mint) (ok u0)))
    (try! (if (<= u24 orders) (mint) (ok u0)))
    (try! (if (<= u25 orders) (mint) (ok u0)))
    (map-set mints-per-user tx-sender (+ orders user-mints))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER) (is-eq (var-get total-price) u0000000))
      (begin
        (map-set token-count tx-sender (+ current-balance orders))
      )
      (begin
        (map-set token-count tx-sender (+ current-balance orders))
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM-ADDR))
      )    
    )
    (ok true)))
    
(define-public (mint-many-with (orders uint) (token <ft-trait>))
  (let 
    (
      (art-addr (var-get artist-address))
      (token-price (unwrap! (map-get? token-prices (contract-of token)) (err ERR-UNSUPPORTED-TOKEN)))
      (price (* token-price orders))
      (total-commission (/ (* price COMM) u10000))
      (total-artist (- price total-commission))
      (current-balance (get-balance tx-sender))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ orders user-mints))) (err ERR-NO-MORE-MINTS))
    (try! (if (<= u1 orders) (mint-with token) (ok u0)))
    (try! (if (<= u2 orders) (mint-with token) (ok u0)))
    (try! (if (<= u3 orders) (mint-with token) (ok u0)))
    (try! (if (<= u4 orders) (mint-with token) (ok u0)))
    (try! (if (<= u5 orders) (mint-with token) (ok u0)))
    (try! (if (<= u6 orders) (mint-with token) (ok u0)))
    (try! (if (<= u7 orders) (mint-with token) (ok u0)))
    (try! (if (<= u8 orders) (mint-with token) (ok u0)))
    (try! (if (<= u9 orders) (mint-with token) (ok u0)))
    (try! (if (<= u10 orders) (mint-with token) (ok u0)))
    (try! (if (<= u11 orders) (mint-with token) (ok u0)))
    (try! (if (<= u12 orders) (mint-with token) (ok u0)))
    (try! (if (<= u13 orders) (mint-with token) (ok u0)))
    (try! (if (<= u14 orders) (mint-with token) (ok u0)))
    (try! (if (<= u15 orders) (mint-with token) (ok u0)))
    (try! (if (<= u16 orders) (mint-with token) (ok u0)))
    (try! (if (<= u17 orders) (mint-with token) (ok u0)))
    (try! (if (<= u18 orders) (mint-with token) (ok u0)))
    (try! (if (<= u19 orders) (mint-with token) (ok u0)))
    (try! (if (<= u20 orders) (mint-with token) (ok u0)))
    (try! (if (<= u21 orders) (mint-with token) (ok u0)))
    (try! (if (<= u22 orders) (mint-with token) (ok u0)))
    (try! (if (<= u23 orders) (mint-with token) (ok u0)))
    (try! (if (<= u24 orders) (mint-with token) (ok u0)))
    (try! (if (<= u25 orders) (mint-with token) (ok u0)))
    (map-set mints-per-user tx-sender (+ orders user-mints))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER) (is-eq (var-get total-price) u0000000))
      (begin
        (map-set token-count tx-sender (+ current-balance orders))
      )
      (begin
        (map-set token-count tx-sender (+ current-balance orders))
        (try! (contract-call? token transfer total-artist tx-sender (var-get artist-address) none))
        (try! (contract-call? token transfer total-commission tx-sender COMM-ADDR none))
      )    
    )
    (ok true)))

(define-private (mint)
  (let 
    (
      (next-id (+ (var-get last-id) u1))
      (enabled (asserts! (<= next-id (var-get collection-size)) (err ERR-NO-MORE-NFTS)))
    )
    (try! (nft-mint? public-009 next-id tx-sender))
    (var-set last-id next-id)
    (ok next-id)))

(define-private (mint-with (token <ft-trait>))  
  (let 
    (
      (next-id (+ (var-get last-id) u1))
      (enabled (asserts! (<= next-id (var-get collection-size)) (err ERR-NO-MORE-NFTS)))
    )
    (try! (nft-mint? public-009 next-id tx-sender))
    (var-set last-id next-id)
    (ok next-id)))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (set-price (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price price))))

(define-public (toggle-pause)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-public (set-collection-size (size uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (< size (var-get collection-size)) (err ERR-COLLECTION-SIZE))
    (asserts! (var-get metadata-frozen) (err ERR-METADATA-FROZEN))
    (ok (var-set collection-size size))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? public-009 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? public-009 token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? public-009 token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mint-price-in (token <ft-trait>))
  (ok (unwrap! (map-get? token-prices (contract-of token)) (err ERR-UNSUPPORTED-TOKEN))))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-collection-size)
  (ok (var-get collection-size)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-mint-cap)
  (ok (var-get mint-cap)))

(define-read-only (get-airdrop-called)
  (ok (var-get airdrop-called)))

(define-read-only (get-metadata-frozen)
  (ok (var-get metadata-frozen)))

;; Non-custodial marketplace
(use-trait commission-trait .commission-trait.commission-trait)
(use-trait ft-commission-trait .ft-commission-trait.ft-commission-trait)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint, token: (optional principal)})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? public-009 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? public-009 id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent), token: none}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (list-in-token (id uint) (price uint) (comm-trait <ft-commission-trait>) (token <ft-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent), token: (some (contract-of token))}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-set market id listing)
    (print (merge listing {a: "list-in-token", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? public-009 id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-none (get token listing)) (err ERR-WRONG-TOKEN))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalty price royalty))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-token (id uint) (comm-trait <ft-commission-trait>) (token-trait <ft-trait>))
  (let ((owner (unwrap! (nft-get-owner? public-009 id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing))
      (royalty (get royalty listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (asserts! (is-eq (contract-of token-trait) (unwrap! (get token listing) (err ERR-WRONG-TOKEN))) (err ERR-WRONG-TOKEN))
    (try! (contract-call? token-trait transfer price tx-sender owner none))
    (try! (pay-royalty-in-token price royalty token-trait))
    (try! (contract-call? comm-trait pay-in-token id price token-trait))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-token", id: id})
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
  (if (> royalty-amount u0)
    (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))

(define-private (pay-royalty-in-token (price uint) (royalty uint) (token <ft-trait>))
  (let (
    (royalty-amount (/ (* price royalty) u10000))
  )
  (if (> royalty-amount u0)
    ;; (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
    (try! (contract-call? token transfer royalty-amount tx-sender (var-get artist-address) none))
    (print false)
  )
  (ok true)))


