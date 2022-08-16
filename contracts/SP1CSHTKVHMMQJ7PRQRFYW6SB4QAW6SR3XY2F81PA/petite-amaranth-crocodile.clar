;; kitchen-sink

(impl-trait .nft-trait.nft-trait)
(impl-trait .mint-with-trait.mint-with-trait)
(use-trait ft-trait .ft-trait.ft-trait)

(define-non-fungible-token kitchen-sink uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u1000)
(define-constant COMM-ADDR 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)

;; Constants (errors)
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
(define-constant ERR-MINT-LIMIT u110)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-AIRDROP-CALLED u112)
(define-constant ERR-NO-MORE-MINTS u113)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-WRONG-TOKEN u115)
(define-constant ERR-UNSUPPORTED-TOKEN u500)

;; Internal variables
(define-data-var mint-limit uint u48)
(define-data-var last-id uint u0)
(define-data-var total-price uint u1000000)
(define-data-var artist-address principal 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmUTR2VmnF8bq1mC1mZr8AotiPP3HTDNo196CDfUpRs884/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool true)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

;; Maps
(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)
(define-map token-prices principal uint)

;; Read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? kitchen-sink token-id)))

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

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-mint-cap)
  (ok (var-get mint-cap)))

(define-read-only (get-airdrop-called)
  (ok (var-get airdrop-called)))

(define-read-only (get-premint-enabled)
  (ok (var-get premint-enabled)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))

(define-read-only (get-metadata-frozen)
  (ok (var-get metadata-frozen)))

(define-read-only (get-passes (caller principal))
  (default-to u0 (map-get? mint-passes caller)))

;; MINT WITH ANY FUNGIBLE TOKEN
(define-public (mint-many-with (orders uint) (token <ft-trait>))
  (let 
    (
      (passes (get-passes tx-sender))
      (art-addr (var-get artist-address))
      (token-price (unwrap! (map-get? token-prices (contract-of token)) (err ERR-UNSUPPORTED-TOKEN)))
      (price (* token-price orders))
      (total-commission (/ (* price COMM) u10000))
      (total-artist (- price total-commission))
      (current-balance (get-balance tx-sender))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes orders) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes orders))
      )
      (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
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

(define-private (mint-with (token <ft-trait>))  
  (let 
    (
      (next-id (+ (var-get last-id) u1))
      (enabled (asserts! (<= next-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
    )
    (try! (nft-mint? kitchen-sink next-id tx-sender))
    (var-set last-id next-id)
    (ok next-id)))

(define-public (claim)
  (mint-many u1))

(define-public (mint-many (orders uint)) 
  (let 
    (
      (passes (get-passes tx-sender))
      (art-addr (var-get artist-address))
      (price (* (var-get total-price) orders))
      (total-commission (/ (* price COMM) u10000))
      (total-artist (- price total-commission))
      (current-balance (get-balance tx-sender))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes orders) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes orders))
      )
      (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
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

;; Mintpass Minting
(define-private (mint)
  (let 
    (
      (next-id (+ (var-get last-id) u1))
      (enabled (asserts! (<= next-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
    )
    (try! (nft-mint? kitchen-sink next-id tx-sender))
    (var-set last-id next-id)
    (ok next-id)))

(define-public (set-token-price (token <ft-trait>) (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (map-set token-prices (contract-of token) price)
    (ok true)))

(map-set token-prices .blob-token u1000)

(define-public (remove-token-price (token <ft-trait>))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (map-delete token-prices (contract-of token)))))

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

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? kitchen-sink token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? kitchen-sink token-id) false)))

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

;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; Non-custodial marketplace extras
(use-trait commission-trait .commission-trait.commission-trait)
(use-trait ft-commission-trait .ft-commission-trait.ft-commission-trait)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint, token: (optional principal)})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? kitchen-sink id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? kitchen-sink id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? kitchen-sink id) (err ERR-NOT-FOUND)))
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
  (let ((owner (unwrap! (nft-get-owner? kitchen-sink id) (err ERR-NOT-FOUND)))
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

;; Extra functionality required for mintpass
(define-public (toggle-sale-state)
  (let 
    (
      ;; (premint (not (var-get premint-enabled)))
      (sale (not (var-get sale-enabled)))
    )
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set premint-enabled false)
    (var-set sale-enabled sale)
    (print { sale: sale })
    (ok true)))

(define-public (enable-premint)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled true))))

(define-public (disable-premint)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled false))))

(map-set mint-passes 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA u3)
(map-set mint-passes 'SP2MGXXTN1V4E1N07X2MRZ6CTNFV5ZV9VGN71BT33 u3)
(map-set mint-passes 'SP3BVZ44BGYS0VM277KET4M5T8EDKN5PN03FDC2AK u3)
(map-set mint-passes 'SP2RHM23Z2HKKRYBZPTTFZZ63BTPP0YTT6CY8B64B u3)
(map-set mint-passes 'SPK9FCNG823TEH0JD64RKQXMQMAZ0K69TF83CQXS u3)
(map-set mint-passes 'SP1B9MPJCA78KRFP2M312N8KFFGZR33HB6EJH1NHQ u3)

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? kitchen-sink (+ last-nft-id u0) 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA))
      (map-set token-count 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA (+ (get-balance 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA) u1))
      (try! (nft-mint? kitchen-sink (+ last-nft-id u1) 'SP2MGXXTN1V4E1N07X2MRZ6CTNFV5ZV9VGN71BT33))
      (map-set token-count 'SP2MGXXTN1V4E1N07X2MRZ6CTNFV5ZV9VGN71BT33 (+ (get-balance 'SP2MGXXTN1V4E1N07X2MRZ6CTNFV5ZV9VGN71BT33) u1))
      (try! (nft-mint? kitchen-sink (+ last-nft-id u2) 'SP3BVZ44BGYS0VM277KET4M5T8EDKN5PN03FDC2AK))
      (map-set token-count 'SP3BVZ44BGYS0VM277KET4M5T8EDKN5PN03FDC2AK (+ (get-balance 'SP3BVZ44BGYS0VM277KET4M5T8EDKN5PN03FDC2AK) u1))
      (try! (nft-mint? kitchen-sink (+ last-nft-id u3) 'SP2RHM23Z2HKKRYBZPTTFZZ63BTPP0YTT6CY8B64B))
      (map-set token-count 'SP2RHM23Z2HKKRYBZPTTFZZ63BTPP0YTT6CY8B64B (+ (get-balance 'SP2RHM23Z2HKKRYBZPTTFZZ63BTPP0YTT6CY8B64B) u1))
      (try! (nft-mint? kitchen-sink (+ last-nft-id u4) 'SPK9FCNG823TEH0JD64RKQXMQMAZ0K69TF83CQXS))
      (map-set token-count 'SPK9FCNG823TEH0JD64RKQXMQMAZ0K69TF83CQXS (+ (get-balance 'SPK9FCNG823TEH0JD64RKQXMQMAZ0K69TF83CQXS) u1))
      (try! (nft-mint? kitchen-sink (+ last-nft-id u5) 'SP1B9MPJCA78KRFP2M312N8KFFGZR33HB6EJH1NHQ))
      (map-set token-count 'SP1B9MPJCA78KRFP2M312N8KFFGZR33HB6EJH1NHQ (+ (get-balance 'SP1B9MPJCA78KRFP2M312N8KFFGZR33HB6EJH1NHQ) u1))

      (var-set last-id (+ last-nft-id u6))
      (var-set airdrop-called true)
      (ok true))))