;; the-guests-elderman

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token the-guests-elderman uint)

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
(define-data-var mint-limit uint u50)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qmcdv7dQPWegUm8e5MRPaZuho836ErZCXsm5rHTTo3APZZ/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

;; Mintpass Minting
(define-private (mint (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many orders)
      )
    )))

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
      (unwrap! (nft-mint? the-guests-elderman next-id tx-sender) next-id)
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
    (nft-burn? the-guests-elderman token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? the-guests-elderman token-id) false)))

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
  (ok (nft-get-owner? the-guests-elderman token-id)))

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
  (match (nft-transfer? the-guests-elderman id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? the-guests-elderman id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? the-guests-elderman id) (err ERR-NOT-FOUND)))
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

(define-read-only (get-passes (caller principal))
  (default-to u0 (map-get? mint-passes caller)))

(define-read-only (get-premint-enabled)
  (ok (var-get premint-enabled)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))  

(map-set mint-passes 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG u1)
(map-set mint-passes 'SPV5GYRXDQRYQKZW7FFAZDNRRNVFS41P3YZWXFGD u1)
(map-set mint-passes 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH u1)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u1)
(map-set mint-passes 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 u1)
(map-set mint-passes 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF u1)
(map-set mint-passes 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA u1)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u1)
(map-set mint-passes 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ u1)
(map-set mint-passes 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX u1)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u1)
(map-set mint-passes 'SP1VRHC4B8M5QSEA005GBQ3MXRP68RNG097SKEXHS u1)
(map-set mint-passes 'SP18KN2HDVMD2J7VDYPGGPFDWJFRKPQ7N1CN6VXXC u1)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u1)
(map-set mint-passes 'SP0DKPNHR7FW183BQQHABN5CEJHPG93FR0Z41FH2 u1)
(map-set mint-passes 'SP28AE5NFQKQWN3YKP6SX5TSK2QZGZ6586EJGFBYV u1)
(map-set mint-passes 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W u1)
(map-set mint-passes 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN u1)
(map-set mint-passes 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY u1)
(map-set mint-passes 'SP18V7NZHXPQKRNBYAF5WGBV79PDY6XMDNHMZSW4R u1)
(map-set mint-passes 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR u1)
(map-set mint-passes 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 u1)
(map-set mint-passes 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ u1)
(map-set mint-passes 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10 u1)
(map-set mint-passes 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0 u1)
(map-set mint-passes 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1 u1)
(map-set mint-passes 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u1)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u1)
(map-set mint-passes 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106 u1)
(map-set mint-passes 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV u1)
(map-set mint-passes 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9 u1)
(map-set mint-passes 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79 u1)
(map-set mint-passes 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0 u1)
(map-set mint-passes 'SP2DW9RTN82J2MR2FHQXY5EE0Y616JJ076RYG8PTY u2)
(map-set mint-passes 'SP38VV4YM3MEDRCDF77HANWTGVJ5G4MNEDTF951QS u2)
(map-set mint-passes 'SPS2FZ3K6N2CZPBM4BSQCEQV23V2334E7MJ4CHZT u1)
(map-set mint-passes 'SP3MB74HT9SDNGENKFDA3AKZEXEMBZWB1FTFSHWBJ u1)
(map-set mint-passes 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3 u1)
(map-set mint-passes 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K u1)
(map-set mint-passes 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y u1)
(map-set mint-passes 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1 u1)
(map-set mint-passes 'SP24F3T8VFGKGR6MQ5R0K65GZJ9NFY41XM97KH1E4 u1)
(map-set mint-passes 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27 u1)
(map-set mint-passes 'SP2RKVC8PYANWJ40VSRCK2K935HSN4H0AHTVHD73D u1)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u1)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u2)
(map-set mint-passes 'SP3BD0TTPWQ5E5163TD3WVFWS4FVTY3DEPZG5KEBB u1)
