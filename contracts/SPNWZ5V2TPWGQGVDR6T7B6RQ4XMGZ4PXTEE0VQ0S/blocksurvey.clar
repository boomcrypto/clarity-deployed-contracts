;; blocksurvey

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token blocksurvey uint)

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
(define-data-var mint-limit uint u100)
(define-data-var last-id uint u1)
(define-data-var total-price uint u99000000)
(define-data-var artist-address principal 'SP1FQ3G3MYSXW68CWPY4GW342T3Y9HQCCXXCKENPH)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmVhigJJBRvNQqe9fnu2F65vY2EbzF7F4xaUQEjbMmv2ix/")
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

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-seven) (mint (list true true true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

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
      (unwrap! (nft-mint? blocksurvey next-id tx-sender) next-id)
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
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? blocksurvey token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? blocksurvey token-id) false)))

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
  (ok (nft-get-owner? blocksurvey token-id)))

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
  (match (nft-transfer? blocksurvey id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? blocksurvey id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? blocksurvey id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SPM4JKECG23CJGXC93BDXX7579WVH5NR7E2XVC5H u7)
(map-set mint-passes 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 u7)
(map-set mint-passes 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27 u7)
(map-set mint-passes 'SP1K8RG4PV202FHT8J9023G1WJRPFTSZXN9TPNEJX u7)
(map-set mint-passes 'SP38REZNW2QD8CSSQ3PZKWJZ84TTBTXDJDD20GKW4 u7)
(map-set mint-passes 'SP3AWE771HSHKVAWXJKEFRFP79SB8FK3H8E6YMSRZ u7)
(map-set mint-passes 'SPSV4TXVP768KRDHRHZBDHENG29M920A9G30R4BX u7)
(map-set mint-passes 'SPNHHXG9Y6C4WCC0SS874ZQ3HK1QJA91NBX6M2EP u7)
(map-set mint-passes 'SP1X2SMRF92WDERBDSTY3HZ95RH80P2JBTXZVKE0E u7)
(map-set mint-passes 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G u7)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u7)
(map-set mint-passes 'SPGM4RBXP6GM6M2FDCPVZYCKPK1FXYH1767XR7FC u7)
(map-set mint-passes 'SP1E7DEJG95E0EBZFFGEFGE0QX6Y0CR5V79615FB2 u7)
(map-set mint-passes 'SPW1MN5C4HG2B3V5GBPHAFDDE88YNCX35ECVX4B u7)
(map-set mint-passes 'SP3NPM49B0MNKWYH05DP567H5NJ1QN91PEF4E2Z2D u7)
(map-set mint-passes 'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B u7)
(map-set mint-passes 'SP3M7YP0F9V0F57VPCHJ0EF5CYNA3BT5R7K761KT1 u7)
(map-set mint-passes 'SP1VFFSHJ22KJTKW15WRKZK07Z19Y7P4DV48103YK u7)
(map-set mint-passes 'SP1G9PZMQSFRQ7Q98XP7JMNE2C22RXK1W61RXTNKP u7)
(map-set mint-passes 'SP3GD9W8CX9V7CVY01WNTHT94H6K07EDFHRC89QP u7)
(map-set mint-passes 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR u7)
(map-set mint-passes 'SPH8E2KWKMD2ZZCTQTGH40AGFRCX50ZKFFF7W3FX u7)
(map-set mint-passes 'SPPQPQ1BAJR1H5YR59J4PE8HN6GZZ6Q0305F8ZV3 u7)
(map-set mint-passes 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X u7)
(map-set mint-passes 'SPTFC3GCEYR8S824D3SC5P5VXVPWJXNJBBPBWFWA u7)
(map-set mint-passes 'SP9MANP57C4QHVMNHR9HEAX6D5BAA4JN9KC8N4J8 u7)
(map-set mint-passes 'SP3NDX6RVFBYW97BTKK0PE20SABAYPFVZ282ZY4KJ u7)
(map-set mint-passes 'SP2FSVSGZF6FQY0PG6NH8MGRFV43460GEGHB47CZK u7)
(map-set mint-passes 'SP2ZCER0Z8VVMCDA3817SDFVES833XD9ACYDAFH1T u7)
(map-set mint-passes 'SP20E0RC1NWFVD6A2QC8Z4CTWK7X5FKFCB6M6P6W4 u7)
(map-set mint-passes 'SPPA2C4X2YZ8DNVW241ZZ4FEH12SWE1VTPF8SA8Q u7)
(map-set mint-passes 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B u7)
(map-set mint-passes 'SPJEWNHX09BASH7FCJZPAH226GNFJH6QRRGG79D5 u7)
(map-set mint-passes 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV u7)
(map-set mint-passes 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u7)
(map-set mint-passes 'SP2NVWN1H1PHEP466H9VKDNCS0ZSAV4429YVAZ44D u7)
(map-set mint-passes 'SPVY6KV69F7RBFS540C1JYHT2GXT3ZAZ7GASZYBR u7)
(map-set mint-passes 'SP8WWVPB7ZSRXE2ZBSKPNW8E7X0B7HJP4ZFXRRJH u7)
(map-set mint-passes 'SP451TEGW7ZFKB4W3NFDKD6Q1T3G5GJ2EYCHG80F u7)
(map-set mint-passes 'SP1NGMS9Z48PRXFAG2MKBSP0PWERF07C0KV9SPJ66 u7)
(map-set mint-passes 'SP293M874EPBS7H5EFF1DYAR3P5V1CNKVPK78GXG3 u7)
(map-set mint-passes 'SP12JCJYJJ31C59MV94SNFFM4687H9A04Q3BHTAJM u7)
(map-set mint-passes 'SP2TV9WT5FM6TEDCS5C10X7P7R813MTA3W5GAGJHQ u7)
(map-set mint-passes 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S u7)
(map-set mint-passes 'SP2RWS7D7RW6DDZCTXJC0VTK86CKD0TF445116V8A u7)
(map-set mint-passes 'SP3YPMD71E1Q0WRW0949AT5MQ4M72GMP915CX1XTW u7)
(map-set mint-passes 'SP1GYWMYK320ASBBAERSC40TA3PA99ZHV3GF256T8 u7)
(map-set mint-passes 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM u7)
(map-set mint-passes 'SP11XNN88FNPAHV3067QGBFSZ7VT14BVPVZX89KB u7)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u7)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u7)
(map-set mint-passes 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V u7)
(map-set mint-passes 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH u7)
(map-set mint-passes 'SP26C9TWJYK6DTCD4T6HKBC76DPMK2DXXRNWS3E2D u7)
(map-set mint-passes 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ u7)
(map-set mint-passes 'SP36NC0KX6RZGPQXR73AMW8R0CXXHS06DRM487A5G u7)
(map-set mint-passes 'SPV9HNVRJ6833QJVN3KD9T1FSXRJSN842M9PJ02V u7)
(map-set mint-passes 'SP2ACM4ECBGRAPJH3Q86VAQ4YRBK5G1C7F4VYJ500 u7)
(map-set mint-passes 'SP1PCEAP62X5BZSMH257ZHAPGAPSX3BDT3TDVCN4M u7)
(map-set mint-passes 'SPHWY482ANTWNTW2618HYHQSDY1WCW7P20BW5F7Y u7)
(map-set mint-passes 'SP2ZGVSV6JDJ6SCGJETE3ZT0PNRSB90FM01P830D4 u7)
(map-set mint-passes 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG u7)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u7)
(map-set mint-passes 'SP1YT6QRRHPGJVDKQY89MSGGFHYAETD4FKVTBRH1P u7)
(map-set mint-passes 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 u7)
(map-set mint-passes 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3 u7)

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? blocksurvey (+ last-nft-id u0) 'SP6BDF695ZM0GFF9AFTEHKS1D735QE6Z0AGH4XK1))
      (map-set token-count 'SP6BDF695ZM0GFF9AFTEHKS1D735QE6Z0AGH4XK1 (+ (get-balance 'SP6BDF695ZM0GFF9AFTEHKS1D735QE6Z0AGH4XK1) u1))
      (try! (nft-mint? blocksurvey (+ last-nft-id u1) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? blocksurvey (+ last-nft-id u2) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))

      (var-set last-id (+ last-nft-id u3))
      (var-set airdrop-called true)
      (ok true))))