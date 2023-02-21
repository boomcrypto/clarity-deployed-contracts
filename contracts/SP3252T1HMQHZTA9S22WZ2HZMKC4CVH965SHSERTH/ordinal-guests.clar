;; ordinal-guests
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token ordinal-guests uint)

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
(define-data-var mint-limit uint u100)
(define-data-var last-id uint u1)
(define-data-var total-price uint u333000000)
(define-data-var artist-address principal 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmQ7xUTixcwHTLf2Nnghn66S77sJZtaR8pXK72j8wKgCqm/json/")
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

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-five) (mint (list true true true true true)))

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
      (unwrap! (nft-mint? ordinal-guests next-id tx-sender) next-id)
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
    (asserts! (is-none (map-get? market token-id)) (err ERR-LISTING))
    (nft-burn? ordinal-guests token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? ordinal-guests token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (print { notification: "token-metadata-update", payload: { token-class: "nft", contract-id: (as-contract tx-sender) }})
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
  (ok (nft-get-owner? ordinal-guests token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-data-var license-uri (string-ascii 80) "")
(define-data-var license-name (string-ascii 40) "")

(define-read-only (get-license-uri)
  (ok (var-get license-uri)))
  
(define-read-only (get-license-name)
  (ok (var-get license-name)))
  
(define-public (set-license-uri (uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-uri uri))))
    
(define-public (set-license-name (name (string-ascii 40)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set license-name name))))

;; Non-custodial marketplace extras
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? ordinal-guests id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? ordinal-guests id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? ordinal-guests id) (err ERR-NOT-FOUND)))
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
  (if (and (> royalty-amount u0) (not (is-eq tx-sender (var-get artist-address))))
    (try! (stx-transfer? royalty-amount tx-sender (var-get artist-address)))
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

(map-set mint-passes 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG u5)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u5)
(map-set mint-passes 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q u5)
(map-set mint-passes 'SP6VV2AFXM7ZMT5V3ZAE8M6JXK9EA5N1GPFHJC4M u5)
(map-set mint-passes 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH u5)
(map-set mint-passes 'SP38VV4YM3MEDRCDF77HANWTGVJ5G4MNEDTF951QS u5)
(map-set mint-passes 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ u5)
(map-set mint-passes 'SP28AE5NFQKQWN3YKP6SX5TSK2QZGZ6586EJGFBYV u5)
(map-set mint-passes 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 u5)
(map-set mint-passes 'SP1W7F05KJZEY3WQ4ECHVGWKQR6G6YHZYEE6NXH24 u5)
(map-set mint-passes 'SP12ZTNXCQY2Q09JQP6991SDHK6P0J6AG8QDCBMJ0 u5)
(map-set mint-passes 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D u5)
(map-set mint-passes 'SP31SJ2X5683KDX8P58HWRA2DXY3ED4WZ6Z3DM0A9 u5)
(map-set mint-passes 'SP82S7H3DPXG6NN2YGW413DSK5Q83BT59E92G1H1 u5)
(map-set mint-passes 'SP26SB34D9THJ8BMSPT6EJHW9JDGBHWMX74PVDFEN u5)
(map-set mint-passes 'SP1P94TYSJZ25849PHEBR5Y4J9BCW8MJMZCE0TD4K u5)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u5)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u5)
(map-set mint-passes 'SPV5GYRXDQRYQKZW7FFAZDNRRNVFS41P3YZWXFGD u5)
(map-set mint-passes 'SP2P207ZB8A0AW7WRJB4J6X2F0D3KZGRJBWJVKV8F u5)
(map-set mint-passes 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u5)
(map-set mint-passes 'SP3WXWMD8NC947EASJCMCVT11YDDMBHPXT8WE9WMF u5)
(map-set mint-passes 'SP6Y9FQ6HE0HZ4G5XVT9PG0XZJJM2WWN0SXCY8YV u5)
(map-set mint-passes 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX u5)
(map-set mint-passes 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY u5)
(map-set mint-passes 'SP4BK08PVYFGEBX3H1CFWTCRGWTRNMQ9FBQZNH0M u5)
(map-set mint-passes 'SP23W0SXEGJFSNBN38WK4G8VD0XVXFZAX7WHM880G u5)
(map-set mint-passes 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG u5)
(map-set mint-passes 'SP3CK642B6119EVC6CT550PW5EZZ1AJW661ZMQTYD u5)
(map-set mint-passes 'SP19N6NE3EYCM96N0Y173Z2B61MCPNDT8PQEQY166 u5)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u5)
(map-set mint-passes 'SP3D5EHK8SMJ3MMJWYCAKWJ2H4F1JQX85E33ZJDB9 u5)
(map-set mint-passes 'SP36NC0KX6RZGPQXR73AMW8R0CXXHS06DRM487A5G u5)
(map-set mint-passes 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106 u5)
(map-set mint-passes 'SP2ZD78CEHCFPJ71SB8R0EK0ZMVAGB3NTHK947F06 u5)
(map-set mint-passes 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV u5)
(map-set mint-passes 'SP2AZZWG7H99G9JW0PJAAC1JDANZ02GZ9CWGEJQC4 u5)
(map-set mint-passes 'SP1ZTC41HNC5PS8A7K444GBHN4104JXJ5EWRHTDM8 u5)
(map-set mint-passes 'SP3JJC9CVH2251JC0B4QTPS661H6JNTA2P9E6HA6N u5)
(map-set mint-passes 'SP18V7NZHXPQKRNBYAF5WGBV79PDY6XMDNHMZSW4R u5)
(map-set mint-passes 'SPQ0X8F9MG5042E2QE0WT2K88TJWAYBZADGAF6E7 u5)
(map-set mint-passes 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2 u5)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u5)
(map-set mint-passes 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN u5)
(map-set mint-passes 'SP99GMESHFA1WBXXNY7R1V2SD9TV9VWGM62GRT7S u5)
(map-set mint-passes 'SP1P637C9NB6GSK9TY8AT8SN3QKH1WSV5ZVCZZSKS u5)
(map-set mint-passes 'SP342MMZRDFSC556F193N76D87SCTYX7SSHD8H3XD u5)
(map-set mint-passes 'SP216YJTD76S81ZXKVHEBTJT77PSVR33AZ57548V3 u5)
(map-set mint-passes 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0 u5)
(map-set mint-passes 'SP3057NPXRGQ4X5MSA2YM90BA6DYAKJTC3E021WV7 u5)
(map-set mint-passes 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1 u5)
(map-set mint-passes 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW u5)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u5)
(map-set mint-passes 'SP2W7RC4ERS8XKN83MR2KJPJ97DWN68K4064Q7C2W u5)
(map-set mint-passes 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0 u5)
(map-set mint-passes 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE u5)
(map-set mint-passes 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF u5)
(map-set mint-passes 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY u5)
(map-set mint-passes 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV u5)
(map-set mint-passes 'SP1VPAJY32NR1VVX8TK0F9QH803VREQGT22RPMJ8S u5)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u5)
(map-set mint-passes 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9 u5)
(map-set mint-passes 'SP2JCF3ME5QC779DQ2X1CM9S62VNJF44GC23MKQXK u5)
(map-set mint-passes 'SPDYN7ZFZA28PVXAD688T50J1P3QJT2HYEC0BZJM u5)
(map-set mint-passes 'SP6K8CTMC52XBCNG9TRCF3JBE76S2BFYS985DANQ u5)
(map-set mint-passes 'SP25RD2QZD9SZESKKYHRBREDHKGTYETD8BH3DT901 u5)
(map-set mint-passes 'SP218P6TAB7GXHV6G43GZM42NSXFHR6YB9VKC43XV u5)
(map-set mint-passes 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 u5)
(map-set mint-passes 'SPS2FZ3K6N2CZPBM4BSQCEQV23V2334E7MJ4CHZT u5)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u5)
(map-set mint-passes 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 u5)
(map-set mint-passes 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X u5)
(map-set mint-passes 'SP1SX5YDFDYWW16SMD1PQ5KS1QV3XK5S27PJPJMTG u5)
(map-set mint-passes 'SP156PKFGDHNQ5322FWE631WR391K7NMZ091G3J6A u5)
(map-set mint-passes 'SP12YGGACNA4R43DB1HAQ3AE03PKPJGXZ1BX96CYB u5)
(map-set mint-passes 'SP8R5PHHMTNRQ7WY56KMVQGVDG8859P35278XSGR u5)
(map-set mint-passes 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27 u5)
(map-set mint-passes 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S u5)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u5)
(map-set mint-passes 'SP2GXKMEZE9WPX2YG5XDF9CBP642AMTMF5TBYJJ9 u5)
(map-set mint-passes 'SP32V5EAKRWZ66VVA67XGDK18VYMZM5NT7NP98M9 u5)
(map-set mint-passes 'SPXKPY2NMKPQW7W5PCNKD1YG67GVBJKATQKNA1ZH u5)
(map-set mint-passes 'SPR35JC5BGKTN20GJAKRZJDM1P8J81NZSHZ40AV7 u5)
(map-set mint-passes 'SP17XZQC08H8ASTGNYJ651YGCM5497G9TX8V061SX u5)
(map-set mint-passes 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8 u5)
(map-set mint-passes 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3 u5)
(map-set mint-passes 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V u5)
(map-set mint-passes 'SP18KN2HDVMD2J7VDYPGGPFDWJFRKPQ7N1CN6VXXC u5)
(map-set mint-passes 'SP2QR6NNM61XJM3MJCRFKQDMT558M2735CKP56CBD u5)
(map-set mint-passes 'SP1EF64D5ZWF4HEBHSPJPX68M9DA5XYH6V97RBXCH u5)
(map-set mint-passes 'SP1VRHC4B8M5QSEA005GBQ3MXRP68RNG097SKEXHS u5)
(map-set mint-passes 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27 u5)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u5)
(map-set mint-passes 'SP3Z5H5KFMGBTYB37DYTGEA14VZG8AT32EPDEAKQH u5)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u5)
(map-set mint-passes 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 u5)
(map-set mint-passes 'SP24F3T8VFGKGR6MQ5R0K65GZJ9NFY41XM97KH1E4 u5)
(map-set mint-passes 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 u5)
(map-set mint-passes 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79 u5)
(map-set mint-passes 'SPS6543QSVCWM0B1CQYD67RV4QP3MGFPJEHG4FHS u5)
(map-set mint-passes 'SP1XAR0A0J2AFWXQXCJ07SPV3TSZV2BCQQAQ6H5B5 u5)
(map-set mint-passes 'SP1P72Z3704VMT3DMHPP2CB8TGQWGDBHD3RPR9GZS u5)
(map-set mint-passes 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 u5)
(map-set mint-passes 'SP35MEYYBHSFCFXY296YGP7NAT6Y4XBJW2VETR8AV u5)
(map-set mint-passes 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G u5)
(map-set mint-passes 'SP22VM38JNZ8GGKXBZ9VP4A9JA0W800N6G9ZVG9XR u5)
(map-set mint-passes 'SP2RTE7F21N6GQ6BBZR7JGGRWAT0T5Q3Z9ZHB9KRS u5)
(map-set mint-passes 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR u5)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u5)
(map-set mint-passes 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9 u5)
(map-set mint-passes 'SPK8785ECMV8E8Q94KQF94JVZ50TH8FTS5TMQV7Y u5)
(map-set mint-passes 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV u5)
(map-set mint-passes 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0 u5)
(map-set mint-passes 'SP2MS5KKM4CFTC6C6H2QAB7BKYBSNXWZKVCCXBMQG u5)
(map-set mint-passes 'SP5RSRY9K5PYQ6NJS2F9Y2JMQH2NB62RBZNRV2KF u5)
(map-set mint-passes 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168 u5)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u5)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u5)
(map-set mint-passes 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH u5)
(map-set mint-passes 'SP1HNS1QE5Y2S9E09MV9WZSKYWAXE5FGMM6RDYB4E u5)
(map-set mint-passes 'SP0DKPNHR7FW183BQQHABN5CEJHPG93FR0Z41FH2 u5)
(map-set mint-passes 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ u5)
(map-set mint-passes 'SPDAAZZ75RKKXKS67HVHYXMKMJNR72V5AGWMA7D6 u5)
(map-set mint-passes 'SP2DW9RTN82J2MR2FHQXY5EE0Y616JJ076RYG8PTY u5)
(map-set mint-passes 'SP1TRJR66FTZZGJWDG3ZK6VCS4SNQ10CHWTTMHMHZ u5)
(map-set mint-passes 'SP262CK3VPG6PDF4S96TTXFBVV9Y9Z75F51A6G83N u5)
(map-set mint-passes 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294 u5)
(map-set mint-passes 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ u5)
(map-set mint-passes 'SP3GKWW70RNNXHCYHF8S93NSSV9GPR6N6XEX0CRV u5)
(map-set mint-passes 'SP134377BE00PYV1N2D5VSKTZ7P8PS2932KK5PGRQ u5)
(map-set mint-passes 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K u5)
(map-set mint-passes 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV u5)
(map-set mint-passes 'SP3H0DJMGJFXJ6HP30B74YGK19ADYMD9H13ECSPZJ u5)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u5)
(map-set mint-passes 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN u5)
(map-set mint-passes 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF u5)
(map-set mint-passes 'SP3GG2XRSX2APJ1JFWV2A3KFEJPAJ5X8JGDXTSF1N u5)
(map-set mint-passes 'SP3GARS14D25RNGWRS85V5VZWJ6TKNFY8Y2TPZV3K u5)
(map-set mint-passes 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR u5)
(map-set mint-passes 'SP2MC6PBPNPSEHA6G87DDMN6WX3HGMTANXZBYKCNF u5)
(map-set mint-passes 'SP1VEQYSMWF1J3XV35XVCFXY8YW2E92QMPG2VT5WR u5)
(map-set mint-passes 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 u5)
(map-set mint-passes 'SP1EPBKHN6PTKE53R1RSDJ8FH531CTNZYRQC33X1E u5)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? ordinal-guests (+ last-nft-id u0) 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB))
      (map-set token-count 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB (+ (get-balance 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB) u1))
      (try! (nft-mint? ordinal-guests (+ last-nft-id u1) 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB))
      (map-set token-count 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB (+ (get-balance 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB) u1))
      (try! (nft-mint? ordinal-guests (+ last-nft-id u2) 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9))
      (map-set token-count 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9 (+ (get-balance 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9) u1))
      (try! (nft-mint? ordinal-guests (+ last-nft-id u3) 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF))
      (map-set token-count 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF (+ (get-balance 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF) u1))
      (try! (nft-mint? ordinal-guests (+ last-nft-id u4) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))

      (var-set last-id (+ last-nft-id u5))
      (var-set airdrop-called true)
      (ok true))))