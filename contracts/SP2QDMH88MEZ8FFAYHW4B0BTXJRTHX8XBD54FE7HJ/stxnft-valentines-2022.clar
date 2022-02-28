;; stxnft-valentines-2022

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stxnft-valentines-2022 uint)

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

;; Internal variables
(define-data-var mint-limit uint u140)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qmeg5RSfHoCkLYMhenopbbASLP7Roz93rWYcsScyzkucWD/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)

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
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
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
      (unwrap! (nft-mint? stxnft-valentines-2022 next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (set-price (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set total-price price))))

(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? stxnft-valentines-2022 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stxnft-valentines-2022 token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
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
  (ok (nft-get-owner? stxnft-valentines-2022 token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

;; Non-custodial marketplace extras
(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? stxnft-valentines-2022 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? stxnft-valentines-2022 id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? stxnft-valentines-2022 id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))

;; Extra functionality required for mintpass
(define-public (toggle-sale-state)
  (let 
    (
      ;; (premint (not (var-get premint-enabled)))
      (sale (not (var-get sale-enabled)))
    )
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (var-set premint-enabled false)
    (var-set sale-enabled sale)
    (print { sale: sale })
    (ok true)))

(define-public (enable-premint)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled true))))

(define-public (disable-premint)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled false))))

(define-read-only (get-passes (caller principal))
  (default-to u0 (map-get? mint-passes caller)))

(define-read-only (get-premint-enabled)
  (ok (var-get premint-enabled)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))  

(map-set mint-passes 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 u1)
(map-set mint-passes 'SP343SNH3E14GAHSGGF2PH9PNN64DP5HFY9HT56AE u1)
(map-set mint-passes 'SP2712KCTX7220J3CQZM72BN13PAQ9ZEWGGFWCA2E u1)
(map-set mint-passes 'SP88THFXG9JJD7458F7N1KJ8516N2X75RAM6X7SZ u1)
(map-set mint-passes 'SPE46D0354YMDVR9BHX7SM2TW1380A0D6V4F5T4J u1)
(map-set mint-passes 'SP3H94JS77EWB2QY8148CP5BWXSFWJCSYZBSZSHVT u1)
(map-set mint-passes 'SP1W6GK034ADAWPHNZE1MDA68R7GY7F1V14NQ3NQX u1)
(map-set mint-passes 'SP1K6W1QST3KKJHM4KGG2BN2WZQTD86PC8H9STN1B u1)
(map-set mint-passes 'SP11ZZZN1ASC9QE01HJAAA2KX89RKEJF88BH53Y88 u1)
(map-set mint-passes 'SP32V5EAKRWZ66VVA67XGDK18VYMZM5NT7NP98M9 u1)
(map-set mint-passes 'SP2XV2G7H7DC97ESZGFKWADTYZWNQH1QHZWGDDVS1 u1)
(map-set mint-passes 'SP3HJBJ96EZ5XQ7J08GJM4M8ZY4NV1PRCKTWBDHF2 u1)
(map-set mint-passes 'SP2PJRW6HTS0YF5AKAY8V3XTX6X3G2FTD5DQGQ41C u1)
(map-set mint-passes 'SP1CA9W3C35F6WH2MH1D5Z1XQG9595Q1C3P7Z2NYY u1)
(map-set mint-passes 'SP3WA93XC9Z83F0NAB09ANK06BDDRNRHN0Q0RJCFB u1)
(map-set mint-passes 'SP3W5KN5XC7RQ5M0TMFGEZANE4P80Z7KQF1PJJB55 u1)
(map-set mint-passes 'SP293M874EPBS7H5EFF1DYAR3P5V1CNKVPK78GXG3 u1)
(map-set mint-passes 'SP3HXJJMJQ06GNAZ8XWDN1QM48JEDC6PP6W3YZPZJ u1)
(map-set mint-passes 'SP38ZXGQPE8NEN2PJFNMZ0W2EVBJZ8ND08CAHEC4M u1)
(map-set mint-passes 'SPXHVN0XJKNQX3R8P5KRRKDMBZ6CTFV18QFPWCAT u1)
(map-set mint-passes 'SP2HK7J6617VBSKXQGZWMXP2R64MMDX3S54M0S1Q6 u1)
(map-set mint-passes 'SP2XZXH4A7F82FJY2J98Y2V90S05Q4HYMNTNDS50G u1)
(map-set mint-passes 'SP39JZNFGS51ZSY6C59C10K9096HF586581KHMERW u1)
(map-set mint-passes 'SP2X9BM8MRG1YD5WXH3Z04BAZQNXD6AC6NTHNYVWK u1)
(map-set mint-passes 'SP1SXFE323XBDFEK6D5BV7P20BD3B4Y8W1RFN759H u1)
(map-set mint-passes 'SP3PG9CVB55NNSSASAC9P59EF437V4T0Q0MQ8XRE4 u1)
(map-set mint-passes 'SP1E4CF5N2KRQMNQDPM0SVQSD40JQKS5ZAWN829GH u1)
(map-set mint-passes 'SP1PJ6FG587CQK586VSZNHDK60H724F7XJY6SBBG3 u1)
(map-set mint-passes 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX u1)
(map-set mint-passes 'SP2D5JBKGE0ZAJXJ1VFZ1CB0DVV2SGJMWASM3KH2V u1)
(map-set mint-passes 'SP13NBGXGP730GRXRZMZMQDR00FEAQSZPDHA1APX0 u1)
(map-set mint-passes 'SP103ZFPKEB5B61ZEV7DW95XTBEWRP2NFE3YX2EFF u1)
(map-set mint-passes 'SP1ASNNR3P4B43P05HZ6WN7NQ354PMENH0CPNJC1G u1)
(map-set mint-passes 'SP2D6ZAQ5XPZRQMB54BZVDWA3JANJFG9DR238K47J u1)
(map-set mint-passes 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ u1)
(map-set mint-passes 'SP379J9E8GXX7KPFW8QVBFBRX9CM3P24VW9KNHENK u1)
(map-set mint-passes 'SPKSG77V3EGXED5RJ4H7P6G2H24TAWFJFR083A9B u1)
(map-set mint-passes 'SP164MRYJSPBPDK5CT6QDNQ73G4AHNK7G6PNK96NK u1)
(map-set mint-passes 'SP3VSH6NQX0N9Y1JFNFN4E3AG6HTP161CRW3XXD1B u1)
(map-set mint-passes 'SPDWJH7KYJXRXR3H1W8TFY4V8J1WRYJ3WTFT5JJR u1)
(map-set mint-passes 'SP16H5R1ZDFJQ7FE3ZYZKGFD8QTGPAGVEYWQXJMS5 u1)
(map-set mint-passes 'SPX8T06E8FJQ33CX8YVR9CC6D9DSTF6JE0Y8R7DS u1)
(map-set mint-passes 'SP1ZGZK3RCA7R0MH571R6ECZTXP8H2T3ZF6NDR5XJ u1)
(map-set mint-passes 'SPF53R3X4MZ9QT394M31HA900GXHD7DC0WE4032N u1)
(map-set mint-passes 'SP1G4Z5J9AYVKZCHZ8RVPH593FPWJX5P6QM6JEV27 u1)
(map-set mint-passes 'SP37S3Y98BDQ2BP2QMK017BHE4BW2SQVQZ605ESQN u1)
(map-set mint-passes 'SPPHJGQ8VA8069V6Q70YRB9VS08WS188AS65MHMQ u1)
(map-set mint-passes 'SP4HYPSYGZ0S48T4X0YTWHN0XKGQJRDHC7YGWR5T u1)
(map-set mint-passes 'SPJRW4D4JACQQQQ5DK09P1K7M2TE8PGZJ638HCW1 u1)
(map-set mint-passes 'SPD61CDVWXKFWYJM8P49E3920Q4YAQQQPXC6KBKX u1)
(map-set mint-passes 'SP3M05ETW09E98NNFMFHT1WND3ZRX9DV31TFC6DFW u1)
(map-set mint-passes 'SP1B6FGZWBJK2WJHJP76C2E4AW3HA4BVAR5DGK074 u1)
(map-set mint-passes 'SP1P7ENVNE7NRXJKCCRE646EW045AKEY8PP1KB00E u1)
(map-set mint-passes 'SP3N2Y3GX9T1166PKSYJJV1QQ5MEM3KE6YBPXWYWA u1)
(map-set mint-passes 'SPVDTWPB2AHT63385BT3JENEM68VNFMGWADVDKWD u1)
(map-set mint-passes 'SP3YB4SCQJDQZMH5SMNVMHXMRWX8RRNGA8ZFFYTT2 u1)
(map-set mint-passes 'SP197GKB5CMZK14MRW4QFA7WK2DT64MHP9J06V6FR u1)
(map-set mint-passes 'SP245G4Q1CEHSPSMQ7JXVDQ0M4WD0KFKHS2TF7N26 u1)
(map-set mint-passes 'SP16JC5P00ZWKMS1YYBTWA9VX8ZQD1750HPFF3MTX u1)
(map-set mint-passes 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3 u1)
(map-set mint-passes 'SP216DYNB9YQ4ZP6NS8VQM8PS8YMX9C61SW0KTK56 u1)
(map-set mint-passes 'SPZG26P6JJ665XD71Y979AMPDH7NJWFV27VPP7NQ u1)
(map-set mint-passes 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4 u1)
(map-set mint-passes 'SP2NR2625HB0YFFRFBD9VHVYESNY83VTMKZXMV6H0 u1)
(map-set mint-passes 'SP3XFN7YK7FQSG4BTH2YJJ4EMQXSTD2F8JWZY30V5 u1)
(map-set mint-passes 'SP3DKS2D22XS61VT4PTRKB20T64BXGGWTF0ZYTXP4 u1)
(map-set mint-passes 'SP3FF6G73VD2AXJ5A757THZAHEEB385Y36YR49Q12 u1)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u1)
(map-set mint-passes 'SP3FB19DMYA4G871FWD9Z311BERBRB1YXADGJJN9K u1)
(map-set mint-passes 'SPX8T06E8FJQ33CX8YVR9CC6D9DSTF6JE0Y8R7DS u1)
(map-set mint-passes 'SP1B3K5C6F0TKVVMTPCE4X53EJSJD467EY7FD36X8 u1)
(map-set mint-passes 'SP2H667JRMBHX0NRJ3ZMPPDR4R9TH6NM1ZFYW07S6 u1)
(map-set mint-passes 'SP1PJX5BM3MHCRD97YA3SJANNY1ZCY4G44XHA1H9Y u1)
(map-set mint-passes 'SP2HS73HXN7K5X4QJ5GK6S4MGDSPH24QWZ4NVRB3G u1)
(map-set mint-passes 'SP26SB34D9THJ8BMSPT6EJHW9JDGBHWMX74PVDFEN u1)
(map-set mint-passes 'SP2MMQN4BVGG9TYBTV0Y5WFAHRQPVMJMY8NB88QW7 u1)
(map-set mint-passes 'SP1AV2HX27BCGB7S91Q47J0K05NK334YBQ270TJJT u1)
(map-set mint-passes 'SP3B21BDG73P2CSD6VS37RNQR8MWQZ1Q78TDRTE5X u1)
(map-set mint-passes 'SP3D94FP5DBVC7B90KZQCM36C2BCKS635WWG6XBN3 u1)
(map-set mint-passes 'SP2AZQEX25ZH3DBATPXAEBZ7M642WWM4NQ4XZNVSY u1)
(map-set mint-passes 'SP1PKK6KJPM826D0X6AMCJ63KEH2M456M4T22WAPQ u1)
(map-set mint-passes 'SPPZ2SNVDBKSHZDQ2HBBVMB5HEHAXRC3T8CQ35EA u1)
(map-set mint-passes 'SP22MD17GPQY679VJMRPWYZ1M7RZ70AH77383QWHH u1)
(map-set mint-passes 'SP1FBDV7183BMRESDSKYAA712WVGZA9M95H06VG1W u1)
(map-set mint-passes 'SP1FW0F2ZYZHXT1BVV8HX8ZXG3MRM0ZVH73QE9VSV u1)
(map-set mint-passes 'SP3AXS4AS4DTT780FZRYSAJ732VJXRJMZG04A5ECD u1)
(map-set mint-passes 'SP1V681WYM8J4TC66EFQT8R9NE1FAX9TFK42BG1P1 u1)
(map-set mint-passes 'SP26XV519ZR9837VMM55PJ58VHDBNWAM1R7CZW4C3 u1)
(map-set mint-passes 'SPNBYP1MY456K29804XHT4PY5QKMSXNRBHGADTDY u1)
(map-set mint-passes 'SP267TMY9MTMP98AW05X8RFQ43JRMTPGDWFKFCPTH u1)
(map-set mint-passes 'SP1EXY5DZ7SQB278ZGH4JTN81A0JT1GAN7TXSPCRG u1)
(map-set mint-passes 'SP0DX5FR8DD6PFA2MXSRK9AKFCC5R8W8S9T95V9T u1)
(map-set mint-passes 'SP1FVMQ4268PGQFPRWAZWER940VNBMTFAS6EVK3B u1)
(map-set mint-passes 'SPRNZJPRWFGZWPBVC7WM44GKCNET6K1NZ735BHVQ u1)
(map-set mint-passes 'SPFAFWC9R23B04YAK50P27AVYESP33F6XXT30C9S u1)
(map-set mint-passes 'SP3AXS4AS4DTT780FZRYSAJ732VJXRJMZG04A5ECD u1)
(map-set mint-passes 'SP3Q6PY2FSG4R8VS4HDGCEAYTFSJGAE8TR7NCAKBC u1)
(map-set mint-passes 'SP26P62SQ0Z55H6AHB2PYQGT8FAPV9S7D55KZTRJP u1)
(map-set mint-passes 'SP1WP1GYZV50CRGV6T6AJ5408XV68VSS1WQNRMBXZ u1)
(map-set mint-passes 'SP13FR8MMY324T6D36VWF19AF7MHC42T77F6D5YMH u1)
(map-set mint-passes 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ u100)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
      (try! (nft-mint? stxnft-valentines-2022 (+ last-nft-id u0) 'SP132QXWFJ11WWXPW4JBTM9FP6XE8MZWB8AF206FX))
      (try! (nft-mint? stxnft-valentines-2022 (+ last-nft-id u1) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (try! (nft-mint? stxnft-valentines-2022 (+ last-nft-id u2) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (try! (nft-mint? stxnft-valentines-2022 (+ last-nft-id u3) 'SP1X6M947Z7E58CNE0H8YJVJTVKS9VW0PHD4Q0A5F))
      (try! (nft-mint? stxnft-valentines-2022 (+ last-nft-id u4) 'SP34XEPDJJFJKFPT87CCZQCPGXR4PJ8ERFVQETKZ4))
      (try! (nft-mint? stxnft-valentines-2022 (+ last-nft-id u5) 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA))
      (try! (nft-mint? stxnft-valentines-2022 (+ last-nft-id u6) 'SPGAKH27HF1T170QET72C727873H911BKNMPF8YB))
      (try! (nft-mint? stxnft-valentines-2022 (+ last-nft-id u7) 'SP2KB6KMN1M3YH4V8C0GKR89K0VD05QGR871CPP5Q))
      (try! (nft-mint? stxnft-valentines-2022 (+ last-nft-id u8) 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227))
      (try! (nft-mint? stxnft-valentines-2022 (+ last-nft-id u9) 'SP2FT1HQM6FF8DVDAB8B0RZNX3A76AR81A9T7DJJ))

      (var-set last-id (+ last-nft-id u10))
      (ok true))))