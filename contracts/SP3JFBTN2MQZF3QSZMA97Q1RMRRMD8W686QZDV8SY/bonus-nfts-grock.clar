;; bonus-nfts-grock
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token bonus-nfts-grock uint)

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
(define-constant ERR-MINT-LIMIT u110)
(define-constant ERR-METADATA-FROZEN u111)
(define-constant ERR-AIRDROP-CALLED u112)
(define-constant ERR-NO-MORE-MINTS u113)
(define-constant ERR-INVALID-PERCENTAGE u114)
(define-constant ERR-CONTRACT-LOCKED u115)

;; Internal variables
(define-data-var mint-limit uint u20)
(define-data-var last-id uint u1)
(define-data-var total-price uint u25000000)
(define-data-var artist-address principal 'SP3JFBTN2MQZF3QSZMA97Q1RMRRMD8W686QZDV8SY)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmUoMAwMZRrPokeqtgLLaL6MkkJhG127gJDYXdzodpGW55/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)
(define-data-var locked bool false)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-public (claim) 
  (mint (list true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-public (mint-for-many (recipients (list 25 principal)))
  (let
    (
      (next-id (var-get last-id))
      (id-reached (fold mint-for-many-iter recipients next-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (var-set last-id id-reached)
      (ok id-reached))))

(define-private (mint-for-many-iter (recipient principal) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? bonus-nfts-grock next-id tx-sender) next-id)
      (unwrap! (nft-transfer? bonus-nfts-grock next-id tx-sender recipient) next-id)
      (map-set token-count recipient (+ (get-balance recipient) u1))      
      (+ next-id u1)
    )
    next-id))

(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (or (is-eq (var-get mint-limit) u0) (<= last-nft-id (var-get mint-limit))) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ (len orders) user-mints))) (err ERR-NO-MORE-MINTS))
    (map-set mints-per-user tx-sender (+ (len orders) user-mints))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER) (is-eq (var-get total-price) u0000000))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM-ADDR))
      )    
    )
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (or (is-eq (var-get mint-limit) u0) (<= next-id (var-get mint-limit)))
    (begin
      (unwrap! (nft-mint? bonus-nfts-grock next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id))

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
    (nft-burn? bonus-nfts-grock token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? bonus-nfts-grock token-id) false)))

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

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? bonus-nfts-grock token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get ipfs-root))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

;; Non-custodial marketplace extras
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? bonus-nfts-grock id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? bonus-nfts-grock id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? bonus-nfts-grock id) (err ERR-NOT-FOUND)))
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
  (if (> royalty-amount u0)
    (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))
  

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u0) 'SPZ7Q5J0NE9PSD7MNRGQ6QR61N9YZRET1S7RH1DT))
      (map-set token-count 'SPZ7Q5J0NE9PSD7MNRGQ6QR61N9YZRET1S7RH1DT (+ (get-balance 'SPZ7Q5J0NE9PSD7MNRGQ6QR61N9YZRET1S7RH1DT) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u1) 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW))
      (map-set token-count 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW (+ (get-balance 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u2) 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5))
      (map-set token-count 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 (+ (get-balance 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u3) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u4) 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0))
      (map-set token-count 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0 (+ (get-balance 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u5) 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0))
      (map-set token-count 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0 (+ (get-balance 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u6) 'SPA8T6C81Z4MV6M9NSFBRHZV4WXN9PASXCQVBNBP))
      (map-set token-count 'SPA8T6C81Z4MV6M9NSFBRHZV4WXN9PASXCQVBNBP (+ (get-balance 'SPA8T6C81Z4MV6M9NSFBRHZV4WXN9PASXCQVBNBP) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u7) 'SP3BCKC9STZKCVBJRB3EFK86JEWVEJWYH7JRXG9Q))
      (map-set token-count 'SP3BCKC9STZKCVBJRB3EFK86JEWVEJWYH7JRXG9Q (+ (get-balance 'SP3BCKC9STZKCVBJRB3EFK86JEWVEJWYH7JRXG9Q) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u8) 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6))
      (map-set token-count 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 (+ (get-balance 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u9) 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW))
      (map-set token-count 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW (+ (get-balance 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u10) 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5))
      (map-set token-count 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 (+ (get-balance 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u11) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u12) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u13) 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0))
      (map-set token-count 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0 (+ (get-balance 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u14) 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0))
      (map-set token-count 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0 (+ (get-balance 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u15) 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ))
      (map-set token-count 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ (+ (get-balance 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u16) 'SP129SXC2YE4VM9ZXWXF1WSRT8M5BGAEZ0PQK685D))
      (map-set token-count 'SP129SXC2YE4VM9ZXWXF1WSRT8M5BGAEZ0PQK685D (+ (get-balance 'SP129SXC2YE4VM9ZXWXF1WSRT8M5BGAEZ0PQK685D) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u17) 'SPJ52DQFJVJACKHY0QX5DRE559MBCXWTSGNBN76V))
      (map-set token-count 'SPJ52DQFJVJACKHY0QX5DRE559MBCXWTSGNBN76V (+ (get-balance 'SPJ52DQFJVJACKHY0QX5DRE559MBCXWTSGNBN76V) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u18) 'SP262H5HJMEY1MAC7X3K5K28VQARC8CB4NVHXR6T7))
      (map-set token-count 'SP262H5HJMEY1MAC7X3K5K28VQARC8CB4NVHXR6T7 (+ (get-balance 'SP262H5HJMEY1MAC7X3K5K28VQARC8CB4NVHXR6T7) u1))
      (try! (nft-mint? bonus-nfts-grock (+ last-nft-id u19) 'SP2XV2G7H7DC97ESZGFKWADTYZWNQH1QHZWGDDVS1))
      (map-set token-count 'SP2XV2G7H7DC97ESZGFKWADTYZWNQH1QHZWGDDVS1 (+ (get-balance 'SP2XV2G7H7DC97ESZGFKWADTYZWNQH1QHZWGDDVS1) u1))

      (var-set last-id (+ last-nft-id u20))
      (var-set airdrop-called true)
      (ok true))))