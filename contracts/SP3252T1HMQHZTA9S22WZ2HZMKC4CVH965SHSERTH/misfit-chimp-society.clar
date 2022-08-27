;; misfit-chimp-society
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token misfit-chimp-society uint)

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

;; Internal variables
(define-data-var mint-limit uint u200)
(define-data-var last-id uint u1)
(define-data-var total-price uint u40000000)
(define-data-var artist-address principal 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmZuuQjXeEcrjKHZoCpJucMWsxRiimyjVkE5PiQsX9qUPd/json/")
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

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-six) (mint (list true true true true true true)))

(define-public (claim-seven) (mint (list true true true true true true true)))

(define-public (claim-eight) (mint (list true true true true true true true true)))

(define-public (claim-nine) (mint (list true true true true true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

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
      (unwrap! (nft-mint? misfit-chimp-society next-id tx-sender) next-id)
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
    (nft-burn? misfit-chimp-society token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? misfit-chimp-society token-id) false)))

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
  (ok (nft-get-owner? misfit-chimp-society token-id)))

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
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? misfit-chimp-society id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? misfit-chimp-society id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? misfit-chimp-society id) (err ERR-NOT-FOUND)))
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
  

;; Alt Minting Default
(define-data-var total-price-mega uint u500)

(define-read-only (get-price-mega)
  (ok (var-get total-price-mega)))

(define-public (set-price-mega (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-mega price))))

(define-public (claim-mega)
  (mint-mega (list true)))

(define-public (claim-two-mega) (mint-mega (list true true)))

(define-public (claim-three-mega) (mint-mega (list true true true)))

(define-public (claim-four-mega) (mint-mega (list true true true true)))

(define-public (claim-five-mega) (mint-mega (list true true true true true)))

(define-public (claim-six-mega) (mint-mega (list true true true true true true)))

(define-public (claim-seven-mega) (mint-mega (list true true true true true true true)))

(define-public (claim-eight-mega) (mint-mega (list true true true true true true true true)))

(define-public (claim-nine-mega) (mint-mega (list true true true true true true true true true)))

(define-public (claim-ten-mega) (mint-mega (list true true true true true true true true true true)))


(define-private (mint-mega (orders (list 25 bool)))
  (mint-many-mega orders))

(define-private (mint-many-mega (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-mega) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u0) 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9))
      (map-set token-count 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9 (+ (get-balance 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u1) 'SP2DW9RTN82J2MR2FHQXY5EE0Y616JJ076RYG8PTY))
      (map-set token-count 'SP2DW9RTN82J2MR2FHQXY5EE0Y616JJ076RYG8PTY (+ (get-balance 'SP2DW9RTN82J2MR2FHQXY5EE0Y616JJ076RYG8PTY) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u2) 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ))
      (map-set token-count 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ (+ (get-balance 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u3) 'SP38VV4YM3MEDRCDF77HANWTGVJ5G4MNEDTF951QS))
      (map-set token-count 'SP38VV4YM3MEDRCDF77HANWTGVJ5G4MNEDTF951QS (+ (get-balance 'SP38VV4YM3MEDRCDF77HANWTGVJ5G4MNEDTF951QS) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u4) 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB))
      (map-set token-count 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB (+ (get-balance 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u5) 'SP3MB74HT9SDNGENKFDA3AKZEXEMBZWB1FTFSHWBJ))
      (map-set token-count 'SP3MB74HT9SDNGENKFDA3AKZEXEMBZWB1FTFSHWBJ (+ (get-balance 'SP3MB74HT9SDNGENKFDA3AKZEXEMBZWB1FTFSHWBJ) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u6) 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0))
      (map-set token-count 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0 (+ (get-balance 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u7) 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85))
      (map-set token-count 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 (+ (get-balance 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u8) 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P))
      (map-set token-count 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P (+ (get-balance 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u9) 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB))
      (map-set token-count 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB (+ (get-balance 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u10) 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G))
      (map-set token-count 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G (+ (get-balance 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u11) 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV))
      (map-set token-count 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV (+ (get-balance 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u12) 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y))
      (map-set token-count 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y (+ (get-balance 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u13) 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR))
      (map-set token-count 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR (+ (get-balance 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u14) 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1))
      (map-set token-count 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1 (+ (get-balance 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u15) 'SP18V7NZHXPQKRNBYAF5WGBV79PDY6XMDNHMZSW4R))
      (map-set token-count 'SP18V7NZHXPQKRNBYAF5WGBV79PDY6XMDNHMZSW4R (+ (get-balance 'SP18V7NZHXPQKRNBYAF5WGBV79PDY6XMDNHMZSW4R) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u16) 'SP1W7F05KJZEY3WQ4ECHVGWKQR6G6YHZYEE6NXH24))
      (map-set token-count 'SP1W7F05KJZEY3WQ4ECHVGWKQR6G6YHZYEE6NXH24 (+ (get-balance 'SP1W7F05KJZEY3WQ4ECHVGWKQR6G6YHZYEE6NXH24) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u17) 'SP12ZTNXCQY2Q09JQP6991SDHK6P0J6AG8QDCBMJ0))
      (map-set token-count 'SP12ZTNXCQY2Q09JQP6991SDHK6P0J6AG8QDCBMJ0 (+ (get-balance 'SP12ZTNXCQY2Q09JQP6991SDHK6P0J6AG8QDCBMJ0) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u18) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u19) 'SPV5GYRXDQRYQKZW7FFAZDNRRNVFS41P3YZWXFGD))
      (map-set token-count 'SPV5GYRXDQRYQKZW7FFAZDNRRNVFS41P3YZWXFGD (+ (get-balance 'SPV5GYRXDQRYQKZW7FFAZDNRRNVFS41P3YZWXFGD) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u20) 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106))
      (map-set token-count 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106 (+ (get-balance 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u21) 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0))
      (map-set token-count 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0 (+ (get-balance 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u22) 'SP2RKVC8PYANWJ40VSRCK2K935HSN4H0AHTVHD73D))
      (map-set token-count 'SP2RKVC8PYANWJ40VSRCK2K935HSN4H0AHTVHD73D (+ (get-balance 'SP2RKVC8PYANWJ40VSRCK2K935HSN4H0AHTVHD73D) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u23) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u24) 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16))
      (map-set token-count 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 (+ (get-balance 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u25) 'SP28AE5NFQKQWN3YKP6SX5TSK2QZGZ6586EJGFBYV))
      (map-set token-count 'SP28AE5NFQKQWN3YKP6SX5TSK2QZGZ6586EJGFBYV (+ (get-balance 'SP28AE5NFQKQWN3YKP6SX5TSK2QZGZ6586EJGFBYV) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u26) 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5))
      (map-set token-count 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 (+ (get-balance 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u27) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u28) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u29) 'SP42P1FYPB1G7FR9HV5W0AVP56R0SYMTFG7N1MX7))
      (map-set token-count 'SP42P1FYPB1G7FR9HV5W0AVP56R0SYMTFG7N1MX7 (+ (get-balance 'SP42P1FYPB1G7FR9HV5W0AVP56R0SYMTFG7N1MX7) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u30) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u31) 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27))
      (map-set token-count 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27 (+ (get-balance 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u32) 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0))
      (map-set token-count 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0 (+ (get-balance 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u33) 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB))
      (map-set token-count 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB (+ (get-balance 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u34) 'SP12YGGACNA4R43DB1HAQ3AE03PKPJGXZ1BX96CYB))
      (map-set token-count 'SP12YGGACNA4R43DB1HAQ3AE03PKPJGXZ1BX96CYB (+ (get-balance 'SP12YGGACNA4R43DB1HAQ3AE03PKPJGXZ1BX96CYB) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u35) 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG))
      (map-set token-count 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG (+ (get-balance 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u36) 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S))
      (map-set token-count 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S (+ (get-balance 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u37) 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20))
      (map-set token-count 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 (+ (get-balance 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u38) 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY))
      (map-set token-count 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY (+ (get-balance 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u39) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u40) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u41) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u42) 'SP1XAR0A0J2AFWXQXCJ07SPV3TSZV2BCQQAQ6H5B5))
      (map-set token-count 'SP1XAR0A0J2AFWXQXCJ07SPV3TSZV2BCQQAQ6H5B5 (+ (get-balance 'SP1XAR0A0J2AFWXQXCJ07SPV3TSZV2BCQQAQ6H5B5) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u43) 'SPK8785ECMV8E8Q94KQF94JVZ50TH8FTS5TMQV7Y))
      (map-set token-count 'SPK8785ECMV8E8Q94KQF94JVZ50TH8FTS5TMQV7Y (+ (get-balance 'SPK8785ECMV8E8Q94KQF94JVZ50TH8FTS5TMQV7Y) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u44) 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR))
      (map-set token-count 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR (+ (get-balance 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u45) 'SP3H0DJMGJFXJ6HP30B74YGK19ADYMD9H13ECSPZJ))
      (map-set token-count 'SP3H0DJMGJFXJ6HP30B74YGK19ADYMD9H13ECSPZJ (+ (get-balance 'SP3H0DJMGJFXJ6HP30B74YGK19ADYMD9H13ECSPZJ) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u46) 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR))
      (map-set token-count 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR (+ (get-balance 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u47) 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH))
      (map-set token-count 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH (+ (get-balance 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u48) 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA))
      (map-set token-count 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA (+ (get-balance 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u49) 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2))
      (map-set token-count 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2 (+ (get-balance 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u50) 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE))
      (map-set token-count 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE (+ (get-balance 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u51) 'SP6K8CTMC52XBCNG9TRCF3JBE76S2BFYS985DANQ))
      (map-set token-count 'SP6K8CTMC52XBCNG9TRCF3JBE76S2BFYS985DANQ (+ (get-balance 'SP6K8CTMC52XBCNG9TRCF3JBE76S2BFYS985DANQ) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u52) 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X))
      (map-set token-count 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X (+ (get-balance 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u53) 'SP1VRHC4B8M5QSEA005GBQ3MXRP68RNG097SKEXHS))
      (map-set token-count 'SP1VRHC4B8M5QSEA005GBQ3MXRP68RNG097SKEXHS (+ (get-balance 'SP1VRHC4B8M5QSEA005GBQ3MXRP68RNG097SKEXHS) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u54) 'SP24F3T8VFGKGR6MQ5R0K65GZJ9NFY41XM97KH1E4))
      (map-set token-count 'SP24F3T8VFGKGR6MQ5R0K65GZJ9NFY41XM97KH1E4 (+ (get-balance 'SP24F3T8VFGKGR6MQ5R0K65GZJ9NFY41XM97KH1E4) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u55) 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K))
      (map-set token-count 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K (+ (get-balance 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u56) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? misfit-chimp-society (+ last-nft-id u57) 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF))
      (map-set token-count 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF (+ (get-balance 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF) u1))

      (var-set last-id (+ last-nft-id u58))
      (var-set airdrop-called true)
      (ok true))))