;; clown-world

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token clown-world uint)

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

;; Internal variables
(define-data-var mint-limit uint u210)
(define-data-var last-id uint u1)
(define-data-var total-price uint u21000000)
(define-data-var artist-address principal 'SP1BS33ES5PWDG7J5HD70GEXD163Z6C55S22YXG62)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmXw3tkcNVHCZWAkqm1uQsM2aFF5Dthu3J6A7aFUdawNCC/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
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
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? clown-world next-id tx-sender) next-id)
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
    (nft-burn? clown-world token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? clown-world token-id) false)))

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
  (ok (nft-get-owner? clown-world token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

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
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? clown-world id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? clown-world id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? clown-world id) (err ERR-NOT-FOUND)))
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
  

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? clown-world (+ last-nft-id u0) 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9))
      (map-set token-count 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9 (+ (get-balance 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u1) 'SP1DRW8GY74R0SAZ82HGFJJMT4CX0ZX6P309AR8ND))
      (map-set token-count 'SP1DRW8GY74R0SAZ82HGFJJMT4CX0ZX6P309AR8ND (+ (get-balance 'SP1DRW8GY74R0SAZ82HGFJJMT4CX0ZX6P309AR8ND) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u2) 'SP355N7XZRWPV0AT7Y0ZY3VBHQK1W5Z8337JMZY7Z))
      (map-set token-count 'SP355N7XZRWPV0AT7Y0ZY3VBHQK1W5Z8337JMZY7Z (+ (get-balance 'SP355N7XZRWPV0AT7Y0ZY3VBHQK1W5Z8337JMZY7Z) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u3) 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ))
      (map-set token-count 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ (+ (get-balance 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u4) 'SP2BZQ48MADDN62X044NNJCNXF5BA33C3BFQ3TZJW))
      (map-set token-count 'SP2BZQ48MADDN62X044NNJCNXF5BA33C3BFQ3TZJW (+ (get-balance 'SP2BZQ48MADDN62X044NNJCNXF5BA33C3BFQ3TZJW) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u5) 'SP12KK5K4W7G60PGQJF7X674JWXWWF0M7S483EY5G))
      (map-set token-count 'SP12KK5K4W7G60PGQJF7X674JWXWWF0M7S483EY5G (+ (get-balance 'SP12KK5K4W7G60PGQJF7X674JWXWWF0M7S483EY5G) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u6) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u7) 'SP3ZTTRW93D37AAEYQPAR1QQ8H8CQ7N1QCQ6KXW6V))
      (map-set token-count 'SP3ZTTRW93D37AAEYQPAR1QQ8H8CQ7N1QCQ6KXW6V (+ (get-balance 'SP3ZTTRW93D37AAEYQPAR1QQ8H8CQ7N1QCQ6KXW6V) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u8) 'SP262CK3VPG6PDF4S96TTXFBVV9Y9Z75F51A6G83N))
      (map-set token-count 'SP262CK3VPG6PDF4S96TTXFBVV9Y9Z75F51A6G83N (+ (get-balance 'SP262CK3VPG6PDF4S96TTXFBVV9Y9Z75F51A6G83N) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u9) 'SP1C6WQ9KTV3769S8X8YNAWBXKDG2Y65P5EEDRWR6))
      (map-set token-count 'SP1C6WQ9KTV3769S8X8YNAWBXKDG2Y65P5EEDRWR6 (+ (get-balance 'SP1C6WQ9KTV3769S8X8YNAWBXKDG2Y65P5EEDRWR6) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u10) 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP))
      (map-set token-count 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP (+ (get-balance 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u11) 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V))
      (map-set token-count 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V (+ (get-balance 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u12) 'SPWPT6SMVEMJC0FYXNDNCPQGCPKH68Q9CDAM88A3))
      (map-set token-count 'SPWPT6SMVEMJC0FYXNDNCPQGCPKH68Q9CDAM88A3 (+ (get-balance 'SPWPT6SMVEMJC0FYXNDNCPQGCPKH68Q9CDAM88A3) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u13) 'SPD4A8PA4ZB0N4P4AV1A5T1HDTG272KXPPQ39KX2))
      (map-set token-count 'SPD4A8PA4ZB0N4P4AV1A5T1HDTG272KXPPQ39KX2 (+ (get-balance 'SPD4A8PA4ZB0N4P4AV1A5T1HDTG272KXPPQ39KX2) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u14) 'SP23B3GJ1AZ95NAGZ38P6RJ6P78MFPGQE3BP8EEW4))
      (map-set token-count 'SP23B3GJ1AZ95NAGZ38P6RJ6P78MFPGQE3BP8EEW4 (+ (get-balance 'SP23B3GJ1AZ95NAGZ38P6RJ6P78MFPGQE3BP8EEW4) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u15) 'SP2WHH9C91GGEY6NA1XF5WWWMZC0V8QGYPMVPQ6A0))
      (map-set token-count 'SP2WHH9C91GGEY6NA1XF5WWWMZC0V8QGYPMVPQ6A0 (+ (get-balance 'SP2WHH9C91GGEY6NA1XF5WWWMZC0V8QGYPMVPQ6A0) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u16) 'SP13W5C496FSFEXJV4BG1A51TVZVZ0R27ZHYA51TK))
      (map-set token-count 'SP13W5C496FSFEXJV4BG1A51TVZVZ0R27ZHYA51TK (+ (get-balance 'SP13W5C496FSFEXJV4BG1A51TVZVZ0R27ZHYA51TK) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u17) 'SP2YGM4CWMEY3T4TG5PHQMEVQGAF7JTPN0NTHR0H4))
      (map-set token-count 'SP2YGM4CWMEY3T4TG5PHQMEVQGAF7JTPN0NTHR0H4 (+ (get-balance 'SP2YGM4CWMEY3T4TG5PHQMEVQGAF7JTPN0NTHR0H4) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u18) 'SP1REJV8JZ0JWDB210FTAVQFK1NRTWSFFY3Q7BTK9))
      (map-set token-count 'SP1REJV8JZ0JWDB210FTAVQFK1NRTWSFFY3Q7BTK9 (+ (get-balance 'SP1REJV8JZ0JWDB210FTAVQFK1NRTWSFFY3Q7BTK9) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u19) 'SP5RSZQ4VJQN852EYXN7M7P2TTSRFGNGH3KBRHPZ))
      (map-set token-count 'SP5RSZQ4VJQN852EYXN7M7P2TTSRFGNGH3KBRHPZ (+ (get-balance 'SP5RSZQ4VJQN852EYXN7M7P2TTSRFGNGH3KBRHPZ) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u20) 'SP5B592P5JMSPN6FB08BJZ81XSBZYV72BQZ9DM5K))
      (map-set token-count 'SP5B592P5JMSPN6FB08BJZ81XSBZYV72BQZ9DM5K (+ (get-balance 'SP5B592P5JMSPN6FB08BJZ81XSBZYV72BQZ9DM5K) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u21) 'SP2E852RZJ5QX4ASNGT1N1Q1A7Z3Y1MZWSHQK0MEB))
      (map-set token-count 'SP2E852RZJ5QX4ASNGT1N1Q1A7Z3Y1MZWSHQK0MEB (+ (get-balance 'SP2E852RZJ5QX4ASNGT1N1Q1A7Z3Y1MZWSHQK0MEB) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u22) 'SP3KR11F3CJ0Z19AKRTECKF21B9PKYTN761EZ237W))
      (map-set token-count 'SP3KR11F3CJ0Z19AKRTECKF21B9PKYTN761EZ237W (+ (get-balance 'SP3KR11F3CJ0Z19AKRTECKF21B9PKYTN761EZ237W) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u23) 'SP2A0BKYWEF6R02BQ2ZCHT58G01796EY94RXP2AR1))
      (map-set token-count 'SP2A0BKYWEF6R02BQ2ZCHT58G01796EY94RXP2AR1 (+ (get-balance 'SP2A0BKYWEF6R02BQ2ZCHT58G01796EY94RXP2AR1) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u24) 'SPQMRER1ZGA40PGWM8PEZ218VX05P818BWNESQK))
      (map-set token-count 'SPQMRER1ZGA40PGWM8PEZ218VX05P818BWNESQK (+ (get-balance 'SPQMRER1ZGA40PGWM8PEZ218VX05P818BWNESQK) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u25) 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69))
      (map-set token-count 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69 (+ (get-balance 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u26) 'SP26ZSXREMGCD8M71Y4FVA17QBC42EV0VM3HPVXYQ))
      (map-set token-count 'SP26ZSXREMGCD8M71Y4FVA17QBC42EV0VM3HPVXYQ (+ (get-balance 'SP26ZSXREMGCD8M71Y4FVA17QBC42EV0VM3HPVXYQ) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u27) 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1))
      (map-set token-count 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 (+ (get-balance 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u28) 'SP6Y9FQ6HE0HZ4G5XVT9PG0XZJJM2WWN0SXCY8YV))
      (map-set token-count 'SP6Y9FQ6HE0HZ4G5XVT9PG0XZJJM2WWN0SXCY8YV (+ (get-balance 'SP6Y9FQ6HE0HZ4G5XVT9PG0XZJJM2WWN0SXCY8YV) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u29) 'SP2EFHG2729NAJ0YAMVKXTQV22HJ5ZW5SC9BVWHJ0))
      (map-set token-count 'SP2EFHG2729NAJ0YAMVKXTQV22HJ5ZW5SC9BVWHJ0 (+ (get-balance 'SP2EFHG2729NAJ0YAMVKXTQV22HJ5ZW5SC9BVWHJ0) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u30) 'SP2P3GN0NS1MQVXDSQ0NK1FD4MWMPXWFVE3VNADJA))
      (map-set token-count 'SP2P3GN0NS1MQVXDSQ0NK1FD4MWMPXWFVE3VNADJA (+ (get-balance 'SP2P3GN0NS1MQVXDSQ0NK1FD4MWMPXWFVE3VNADJA) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u31) 'SP2AEY9QJD5MGDEEYYTNYBVVS7S97W2S0302HQ7S1))
      (map-set token-count 'SP2AEY9QJD5MGDEEYYTNYBVVS7S97W2S0302HQ7S1 (+ (get-balance 'SP2AEY9QJD5MGDEEYYTNYBVVS7S97W2S0302HQ7S1) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u32) 'SPY914WERKVS8B46P6BDKY1V0J1HTKH8EPWETJSE))
      (map-set token-count 'SPY914WERKVS8B46P6BDKY1V0J1HTKH8EPWETJSE (+ (get-balance 'SPY914WERKVS8B46P6BDKY1V0J1HTKH8EPWETJSE) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u33) 'SP10F5W11YT4HH62VSKA7R9TY1PAXC2JPKNN8ZD5A))
      (map-set token-count 'SP10F5W11YT4HH62VSKA7R9TY1PAXC2JPKNN8ZD5A (+ (get-balance 'SP10F5W11YT4HH62VSKA7R9TY1PAXC2JPKNN8ZD5A) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u34) 'SP39C3KQ6M679DHGD434ZMTKWDNZXD43KCZC71GXW))
      (map-set token-count 'SP39C3KQ6M679DHGD434ZMTKWDNZXD43KCZC71GXW (+ (get-balance 'SP39C3KQ6M679DHGD434ZMTKWDNZXD43KCZC71GXW) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u35) 'SP1A86KRVMMXD3QFXRWHWKNAEW07A6KTDX21SK40F))
      (map-set token-count 'SP1A86KRVMMXD3QFXRWHWKNAEW07A6KTDX21SK40F (+ (get-balance 'SP1A86KRVMMXD3QFXRWHWKNAEW07A6KTDX21SK40F) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u36) 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE))
      (map-set token-count 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE (+ (get-balance 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u37) 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68))
      (map-set token-count 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68 (+ (get-balance 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u38) 'SP32ZWKMXDMQGZ9WFHWM7C6BNGP9MS1VPG7HQ6G8K))
      (map-set token-count 'SP32ZWKMXDMQGZ9WFHWM7C6BNGP9MS1VPG7HQ6G8K (+ (get-balance 'SP32ZWKMXDMQGZ9WFHWM7C6BNGP9MS1VPG7HQ6G8K) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u39) 'SPYQW63PYXA8DFQS34GRMT5DPNRA6WR0TN19RY9F))
      (map-set token-count 'SPYQW63PYXA8DFQS34GRMT5DPNRA6WR0TN19RY9F (+ (get-balance 'SPYQW63PYXA8DFQS34GRMT5DPNRA6WR0TN19RY9F) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u40) 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ))
      (map-set token-count 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ (+ (get-balance 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u41) 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ))
      (map-set token-count 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ (+ (get-balance 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u42) 'SP2F0DP9Z3KSS0DABDBJN0DA0SHMCVWHXPVTH3PJJ))
      (map-set token-count 'SP2F0DP9Z3KSS0DABDBJN0DA0SHMCVWHXPVTH3PJJ (+ (get-balance 'SP2F0DP9Z3KSS0DABDBJN0DA0SHMCVWHXPVTH3PJJ) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u43) 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E))
      (map-set token-count 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E (+ (get-balance 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E) u1))
      (try! (nft-mint? clown-world (+ last-nft-id u44) 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E))
      (map-set token-count 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E (+ (get-balance 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E) u1))

      (var-set last-id (+ last-nft-id u45))
      (var-set airdrop-called true)
      (ok true))))