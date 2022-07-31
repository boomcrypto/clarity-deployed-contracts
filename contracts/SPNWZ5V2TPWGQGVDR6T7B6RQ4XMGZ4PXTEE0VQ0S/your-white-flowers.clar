;; your-white-flowers

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token your-white-flowers uint)

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
(define-data-var mint-limit uint u50)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmbMQ1v15waNH6QR67Y1NKLxBYaPj1hP9DTtGim5266Wok/json/")
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
      (unwrap! (nft-mint? your-white-flowers next-id tx-sender) next-id)
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
    (nft-burn? your-white-flowers token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? your-white-flowers token-id) false)))

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
  (ok (nft-get-owner? your-white-flowers token-id)))

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
  (match (nft-transfer? your-white-flowers id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? your-white-flowers id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? your-white-flowers id) (err ERR-NOT-FOUND)))
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

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

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
      (try! (nft-mint? your-white-flowers (+ last-nft-id u0) 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX))
      (map-set token-count 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX (+ (get-balance 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u1) 'SP34CGPP646BN5RBEC0GK1BSWWY9G1HW1HKJ1PRGZ))
      (map-set token-count 'SP34CGPP646BN5RBEC0GK1BSWWY9G1HW1HKJ1PRGZ (+ (get-balance 'SP34CGPP646BN5RBEC0GK1BSWWY9G1HW1HKJ1PRGZ) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u2) 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G))
      (map-set token-count 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G (+ (get-balance 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u3) 'SPZ5DJGRVZHXEEEYYGWEX84KQB8P69GC715ZRNW1))
      (map-set token-count 'SPZ5DJGRVZHXEEEYYGWEX84KQB8P69GC715ZRNW1 (+ (get-balance 'SPZ5DJGRVZHXEEEYYGWEX84KQB8P69GC715ZRNW1) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u4) 'SP2AZQEX25ZH3DBATPXAEBZ7M642WWM4NQ4XZNVSY))
      (map-set token-count 'SP2AZQEX25ZH3DBATPXAEBZ7M642WWM4NQ4XZNVSY (+ (get-balance 'SP2AZQEX25ZH3DBATPXAEBZ7M642WWM4NQ4XZNVSY) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u5) 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6))
      (map-set token-count 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 (+ (get-balance 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u6) 'SP3MCBTS2V2AJCKBAHZSMJM16RF0TEQBZMRWSSK3Q))
      (map-set token-count 'SP3MCBTS2V2AJCKBAHZSMJM16RF0TEQBZMRWSSK3Q (+ (get-balance 'SP3MCBTS2V2AJCKBAHZSMJM16RF0TEQBZMRWSSK3Q) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u7) 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y))
      (map-set token-count 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y (+ (get-balance 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u8) 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0))
      (map-set token-count 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 (+ (get-balance 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u9) 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8))
      (map-set token-count 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8 (+ (get-balance 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u10) 'SP1NFRJJFQAA5AB4R8RDA3F0WEBZHK0HQSKW1PPNY))
      (map-set token-count 'SP1NFRJJFQAA5AB4R8RDA3F0WEBZHK0HQSKW1PPNY (+ (get-balance 'SP1NFRJJFQAA5AB4R8RDA3F0WEBZHK0HQSKW1PPNY) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u11) 'SP30R5X0EC0TTW2YE3HWW5NZ8NSWBD0QFHMQTDE1B))
      (map-set token-count 'SP30R5X0EC0TTW2YE3HWW5NZ8NSWBD0QFHMQTDE1B (+ (get-balance 'SP30R5X0EC0TTW2YE3HWW5NZ8NSWBD0QFHMQTDE1B) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u12) 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ))
      (map-set token-count 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ (+ (get-balance 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u13) 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ))
      (map-set token-count 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ (+ (get-balance 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u14) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u15) 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27))
      (map-set token-count 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27 (+ (get-balance 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u16) 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G))
      (map-set token-count 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G (+ (get-balance 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u17) 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X))
      (map-set token-count 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X (+ (get-balance 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u18) 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0))
      (map-set token-count 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 (+ (get-balance 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u19) 'SP21728T40XTN7EV3PZXXZDHVT8GJH1JPKDEC8WGX))
      (map-set token-count 'SP21728T40XTN7EV3PZXXZDHVT8GJH1JPKDEC8WGX (+ (get-balance 'SP21728T40XTN7EV3PZXXZDHVT8GJH1JPKDEC8WGX) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u20) 'SP2NBCT6WVMD8PX46VTNRT4ENTQBZZ8ZYYYZY65RB))
      (map-set token-count 'SP2NBCT6WVMD8PX46VTNRT4ENTQBZZ8ZYYYZY65RB (+ (get-balance 'SP2NBCT6WVMD8PX46VTNRT4ENTQBZZ8ZYYYZY65RB) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u21) 'SP1XAR0A0J2AFWXQXCJ07SPV3TSZV2BCQQAQ6H5B5))
      (map-set token-count 'SP1XAR0A0J2AFWXQXCJ07SPV3TSZV2BCQQAQ6H5B5 (+ (get-balance 'SP1XAR0A0J2AFWXQXCJ07SPV3TSZV2BCQQAQ6H5B5) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u22) 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7))
      (map-set token-count 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 (+ (get-balance 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u23) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u24) 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ))
      (map-set token-count 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ (+ (get-balance 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u25) 'SP2NBCT6WVMD8PX46VTNRT4ENTQBZZ8ZYYYZY65RB))
      (map-set token-count 'SP2NBCT6WVMD8PX46VTNRT4ENTQBZZ8ZYYYZY65RB (+ (get-balance 'SP2NBCT6WVMD8PX46VTNRT4ENTQBZZ8ZYYYZY65RB) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u26) 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH))
      (map-set token-count 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH (+ (get-balance 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u27) 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7))
      (map-set token-count 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 (+ (get-balance 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u28) 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X))
      (map-set token-count 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X (+ (get-balance 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u29) 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N))
      (map-set token-count 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N (+ (get-balance 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u30) 'SPSEBFRZZEZSHGRKRR1Z55RX5AWHER3CYM0H9BMW))
      (map-set token-count 'SPSEBFRZZEZSHGRKRR1Z55RX5AWHER3CYM0H9BMW (+ (get-balance 'SPSEBFRZZEZSHGRKRR1Z55RX5AWHER3CYM0H9BMW) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u31) 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX))
      (map-set token-count 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX (+ (get-balance 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u32) 'SP1FZKAJ5V0QSV19RB5T2DG1PJQ6R6MKSB5ZJF5A5))
      (map-set token-count 'SP1FZKAJ5V0QSV19RB5T2DG1PJQ6R6MKSB5ZJF5A5 (+ (get-balance 'SP1FZKAJ5V0QSV19RB5T2DG1PJQ6R6MKSB5ZJF5A5) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u33) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u34) 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87))
      (map-set token-count 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87 (+ (get-balance 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u35) 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF))
      (map-set token-count 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF (+ (get-balance 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u36) 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3))
      (map-set token-count 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3 (+ (get-balance 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u37) 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5))
      (map-set token-count 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 (+ (get-balance 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u38) 'SP1YT6QRRHPGJVDKQY89MSGGFHYAETD4FKVTBRH1P))
      (map-set token-count 'SP1YT6QRRHPGJVDKQY89MSGGFHYAETD4FKVTBRH1P (+ (get-balance 'SP1YT6QRRHPGJVDKQY89MSGGFHYAETD4FKVTBRH1P) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u39) 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S))
      (map-set token-count 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S (+ (get-balance 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u40) 'SP3XCPRFXWG6GK954XX78QBN7GAM94GGDRD4J49F1))
      (map-set token-count 'SP3XCPRFXWG6GK954XX78QBN7GAM94GGDRD4J49F1 (+ (get-balance 'SP3XCPRFXWG6GK954XX78QBN7GAM94GGDRD4J49F1) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u41) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u42) 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W))
      (map-set token-count 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W (+ (get-balance 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u43) 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N))
      (map-set token-count 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N (+ (get-balance 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u44) 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW))
      (map-set token-count 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW (+ (get-balance 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u45) 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0))
      (map-set token-count 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0 (+ (get-balance 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u46) 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0))
      (map-set token-count 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0 (+ (get-balance 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u47) 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF))
      (map-set token-count 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF (+ (get-balance 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u48) 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6))
      (map-set token-count 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 (+ (get-balance 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6) u1))
      (try! (nft-mint? your-white-flowers (+ last-nft-id u49) 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6))
      (map-set token-count 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 (+ (get-balance 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6) u1))

      (var-set last-id (+ last-nft-id u50))
      (var-set airdrop-called true)
      (ok true))))