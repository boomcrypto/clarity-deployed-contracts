;; coconut-milk
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token coconut-milk uint)

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
(define-data-var mint-limit uint u58)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmeRtKiijwnpAbhTcGtccAkxkxhgrz6SNyGvrMJYDUxWgD/")
(define-data-var mint-paused bool true)
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
      (unwrap! (nft-mint? coconut-milk next-id tx-sender) next-id)
      (unwrap! (nft-transfer? coconut-milk next-id tx-sender recipient) next-id)
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
      (unwrap! (nft-mint? coconut-milk next-id tx-sender) next-id)
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
    (nft-burn? coconut-milk token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? coconut-milk token-id) false)))

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
  (ok (nft-get-owner? coconut-milk token-id)))

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
  (match (nft-transfer? coconut-milk id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? coconut-milk id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? coconut-milk id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? coconut-milk (+ last-nft-id u0) 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79))
      (map-set token-count 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79 (+ (get-balance 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u1) 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5))
      (map-set token-count 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 (+ (get-balance 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u2) 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7))
      (map-set token-count 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 (+ (get-balance 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u3) 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1))
      (map-set token-count 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 (+ (get-balance 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u4) 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P))
      (map-set token-count 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P (+ (get-balance 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u5) 'SP1ASZF73C1N45CP2AR2MKCSGB49MBYKAG2392KGV))
      (map-set token-count 'SP1ASZF73C1N45CP2AR2MKCSGB49MBYKAG2392KGV (+ (get-balance 'SP1ASZF73C1N45CP2AR2MKCSGB49MBYKAG2392KGV) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u6) 'SP1BS33ES5PWDG7J5HD70GEXD163Z6C55S22YXG62))
      (map-set token-count 'SP1BS33ES5PWDG7J5HD70GEXD163Z6C55S22YXG62 (+ (get-balance 'SP1BS33ES5PWDG7J5HD70GEXD163Z6C55S22YXG62) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u7) 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87))
      (map-set token-count 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87 (+ (get-balance 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u8) 'SP1GBEAR5NZGV5PAQ9KTFRR4ZSH3AQBV93GN363AK))
      (map-set token-count 'SP1GBEAR5NZGV5PAQ9KTFRR4ZSH3AQBV93GN363AK (+ (get-balance 'SP1GBEAR5NZGV5PAQ9KTFRR4ZSH3AQBV93GN363AK) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u9) 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH))
      (map-set token-count 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH (+ (get-balance 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u10) 'SP1SX5YDFDYWW16SMD1PQ5KS1QV3XK5S27PJPJMTG))
      (map-set token-count 'SP1SX5YDFDYWW16SMD1PQ5KS1QV3XK5S27PJPJMTG (+ (get-balance 'SP1SX5YDFDYWW16SMD1PQ5KS1QV3XK5S27PJPJMTG) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u11) 'SP1W737P6K96B72D518QM1247W0M19KRYHTS3SARM))
      (map-set token-count 'SP1W737P6K96B72D518QM1247W0M19KRYHTS3SARM (+ (get-balance 'SP1W737P6K96B72D518QM1247W0M19KRYHTS3SARM) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u12) 'SP1X6M947Z7E58CNE0H8YJVJTVKS9VW0PHD4Q0A5F))
      (map-set token-count 'SP1X6M947Z7E58CNE0H8YJVJTVKS9VW0PHD4Q0A5F (+ (get-balance 'SP1X6M947Z7E58CNE0H8YJVJTVKS9VW0PHD4Q0A5F) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u13) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u14) 'SP1ZTC41HNC5PS8A7K444GBHN4104JXJ5EWRHTDM8))
      (map-set token-count 'SP1ZTC41HNC5PS8A7K444GBHN4104JXJ5EWRHTDM8 (+ (get-balance 'SP1ZTC41HNC5PS8A7K444GBHN4104JXJ5EWRHTDM8) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u15) 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K))
      (map-set token-count 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K (+ (get-balance 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u16) 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G))
      (map-set token-count 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G (+ (get-balance 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u17) 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X))
      (map-set token-count 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X (+ (get-balance 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u18) 'SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1))
      (map-set token-count 'SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1 (+ (get-balance 'SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u19) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u20) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u21) 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ))
      (map-set token-count 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ (+ (get-balance 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u22) 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A))
      (map-set token-count 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A (+ (get-balance 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u23) 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH))
      (map-set token-count 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH (+ (get-balance 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u24) 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ))
      (map-set token-count 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ (+ (get-balance 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u25) 'SP2M5SJ3DC7Z8ZF5JAVB9DEARDVTEE3CVPJ403EAG))
      (map-set token-count 'SP2M5SJ3DC7Z8ZF5JAVB9DEARDVTEE3CVPJ403EAG (+ (get-balance 'SP2M5SJ3DC7Z8ZF5JAVB9DEARDVTEE3CVPJ403EAG) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u26) 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX))
      (map-set token-count 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX (+ (get-balance 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u27) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u28) 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W))
      (map-set token-count 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W (+ (get-balance 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u29) 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G))
      (map-set token-count 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G (+ (get-balance 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u30) 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG))
      (map-set token-count 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG (+ (get-balance 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u31) 'SP32V5EAKRWZ66VVA67XGDK18VYMZM5NT7NP98M9))
      (map-set token-count 'SP32V5EAKRWZ66VVA67XGDK18VYMZM5NT7NP98M9 (+ (get-balance 'SP32V5EAKRWZ66VVA67XGDK18VYMZM5NT7NP98M9) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u32) 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0))
      (map-set token-count 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 (+ (get-balance 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u33) 'SP35X0JGSJ6A0E7SXX51Z8MQ6NZ13DXYH6V8TNAPM))
      (map-set token-count 'SP35X0JGSJ6A0E7SXX51Z8MQ6NZ13DXYH6V8TNAPM (+ (get-balance 'SP35X0JGSJ6A0E7SXX51Z8MQ6NZ13DXYH6V8TNAPM) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u34) 'SP372CXPM7H0ADG71W1MMMC5FYHZ3KYKXXF9884PT))
      (map-set token-count 'SP372CXPM7H0ADG71W1MMMC5FYHZ3KYKXXF9884PT (+ (get-balance 'SP372CXPM7H0ADG71W1MMMC5FYHZ3KYKXXF9884PT) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u35) 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6))
      (map-set token-count 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 (+ (get-balance 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u36) 'SP3BK1NNSWN719Z6KDW05RBGVS940YCN6X84STYPR))
      (map-set token-count 'SP3BK1NNSWN719Z6KDW05RBGVS940YCN6X84STYPR (+ (get-balance 'SP3BK1NNSWN719Z6KDW05RBGVS940YCN6X84STYPR) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u37) 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
      (map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u38) 'SP3F50PNGA4PY5PVB590SKY4WE8NHZEYQKRDBSJX8))
      (map-set token-count 'SP3F50PNGA4PY5PVB590SKY4WE8NHZEYQKRDBSJX8 (+ (get-balance 'SP3F50PNGA4PY5PVB590SKY4WE8NHZEYQKRDBSJX8) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u39) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u40) 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB))
      (map-set token-count 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB (+ (get-balance 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u41) 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W))
      (map-set token-count 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W (+ (get-balance 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u42) 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR))
      (map-set token-count 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR (+ (get-balance 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u43) 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4))
      (map-set token-count 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4 (+ (get-balance 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u44) 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW))
      (map-set token-count 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW (+ (get-balance 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u45) 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV))
      (map-set token-count 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV (+ (get-balance 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u46) 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8))
      (map-set token-count 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8 (+ (get-balance 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u47) 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7))
      (map-set token-count 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7 (+ (get-balance 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u48) 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227))
      (map-set token-count 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227 (+ (get-balance 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u49) 'SPBFZ5MRGDMEKWNQTJ57W2PA2GC0765ZFC5BY0KP))
      (map-set token-count 'SPBFZ5MRGDMEKWNQTJ57W2PA2GC0765ZFC5BY0KP (+ (get-balance 'SPBFZ5MRGDMEKWNQTJ57W2PA2GC0765ZFC5BY0KP) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u50) 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558))
      (map-set token-count 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558 (+ (get-balance 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u51) 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB))
      (map-set token-count 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB (+ (get-balance 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u52) 'SPGAKH27HF1T170QET72C727873H911BKNMPF8YB))
      (map-set token-count 'SPGAKH27HF1T170QET72C727873H911BKNMPF8YB (+ (get-balance 'SPGAKH27HF1T170QET72C727873H911BKNMPF8YB) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u53) 'SPHDN375JDERBEBKSZ61D4J677FQNQ6VSAER51H6))
      (map-set token-count 'SPHDN375JDERBEBKSZ61D4J677FQNQ6VSAER51H6 (+ (get-balance 'SPHDN375JDERBEBKSZ61D4J677FQNQ6VSAER51H6) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u54) 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR))
      (map-set token-count 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR (+ (get-balance 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u55) 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP))
      (map-set token-count 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP (+ (get-balance 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u56) 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ))
      (map-set token-count 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ (+ (get-balance 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ) u1))
      (try! (nft-mint? coconut-milk (+ last-nft-id u57) 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68))
      (map-set token-count 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68 (+ (get-balance 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68) u1))

      (var-set last-id (+ last-nft-id u58))
      (var-set airdrop-called true)
      (ok true))))