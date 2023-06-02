;; arbiter-of-souls
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token arbiter-of-souls uint)

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
(define-data-var mint-limit uint u1500)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP2WGQXYAT57PQ8XME1S02E947T4WP9CXKWQSHDB4)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmQU9T8hH9RNYcNzPNwFbB8PAVB2HFrhnFmBUTcrWeeyVg/json/")
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

(define-public (claim-six) (mint (list true true true true true true)))

(define-public (claim-seven) (mint (list true true true true true true true)))

(define-public (claim-eight) (mint (list true true true true true true true true)))

(define-public (claim-nine) (mint (list true true true true true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-fifteen) (mint (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty) (mint (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive) (mint (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

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
      (unwrap! (nft-mint? arbiter-of-souls next-id tx-sender) next-id)
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
    (nft-burn? arbiter-of-souls token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? arbiter-of-souls token-id) false)))

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
  (ok (nft-get-owner? arbiter-of-souls token-id)))

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
  (match (nft-transfer? arbiter-of-souls id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? arbiter-of-souls id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? arbiter-of-souls id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP12391ZGS5YJXHXVJPQ0DVTB3M8AQNAQGYEH72ZR u500)
(map-set mint-passes 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6 u500)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u91)
(map-set mint-passes 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF u71)
(map-set mint-passes 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE u69)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u63)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u55)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u55)
(map-set mint-passes 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9 u50)
(map-set mint-passes 'SPVCMKZTGYMKYJEHFN4FABNFBBYMM02HNF66A6N6 u50)
(map-set mint-passes 'SP1F9156MENFJTEWE6WJPMVWFAHNGKGC7YJX6HK72 u30)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u29)
(map-set mint-passes 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3 u27)
(map-set mint-passes 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0 u24)
(map-set mint-passes 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV u23)
(map-set mint-passes 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH u22)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u20)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u20)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u20)
(map-set mint-passes 'SP28AE5NFQKQWN3YKP6SX5TSK2QZGZ6586EJGFBYV u19)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u16)
(map-set mint-passes 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH u16)
(map-set mint-passes 'SP1XGVC95Z0HPG50YPEV5XZB5YA08DC29B0XZWBWN u15)
(map-set mint-passes 'SP38VV4YM3MEDRCDF77HANWTGVJ5G4MNEDTF951QS u15)
(map-set mint-passes 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u15)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u13)
(map-set mint-passes 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0 u13)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u12)
(map-set mint-passes 'SP1TQZS5G1Y47KXWQE8WG2Q606664A7MFMPVCKHRZ u12)
(map-set mint-passes 'SP3WXWMD8NC947EASJCMCVT11YDDMBHPXT8WE9WMF u11)
(map-set mint-passes 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV u10)
(map-set mint-passes 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168 u10)
(map-set mint-passes 'SP18V7NZHXPQKRNBYAF5WGBV79PDY6XMDNHMZSW4R u10)
(map-set mint-passes 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 u10)
(map-set mint-passes 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY u10)
(map-set mint-passes 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR u9)
(map-set mint-passes 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294 u8)
(map-set mint-passes 'SP33N5R751MG99QAM4CN6HQ3MDTYBR71SB4NXVGT1 u7)
(map-set mint-passes 'SP6DAZJ3X7NCZC0B1JZ7W37PMWHPREVCSMQH995Y u6)
(map-set mint-passes 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q u6)
(map-set mint-passes 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 u6)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u5)
(map-set mint-passes 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106 u5)
(map-set mint-passes 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE u5)
(map-set mint-passes 'SP342MMZRDFSC556F193N76D87SCTYX7SSHD8H3XD u5)
(map-set mint-passes 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV u5)
(map-set mint-passes 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 u5)
(map-set mint-passes 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ u5)
(map-set mint-passes 'SP1XAR0A0J2AFWXQXCJ07SPV3TSZV2BCQQAQ6H5B5 u4)
(map-set mint-passes 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 u4)
(map-set mint-passes 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ u4)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u3)
(map-set mint-passes 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 u3)
(map-set mint-passes 'SPXZ0GWQTMGQ860MGG86PNMFJNHJ2NWJSWJWGM0K u3)
(map-set mint-passes 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K u3)
(map-set mint-passes 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2 u3)
(map-set mint-passes 'SP3GG2XRSX2APJ1JFWV2A3KFEJPAJ5X8JGDXTSF1N u3)
(map-set mint-passes 'SP6VV2AFXM7ZMT5V3ZAE8M6JXK9EA5N1GPFHJC4M u3)
(map-set mint-passes 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 u2)
(map-set mint-passes 'SPBB2EX5DA1NYAP4M2A2XS2BAQ5Y4VCZ89XDCPY7 u2)
(map-set mint-passes 'SP3JJC9CVH2251JC0B4QTPS661H6JNTA2P9E6HA6N u2)
(map-set mint-passes 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG u2)
(map-set mint-passes 'SP1P94TYSJZ25849PHEBR5Y4J9BCW8MJMZCE0TD4K u2)
(map-set mint-passes 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 u2)
(map-set mint-passes 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0 u2)
(map-set mint-passes 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27 u2)
(map-set mint-passes 'SP12ZTNXCQY2Q09JQP6991SDHK6P0J6AG8QDCBMJ0 u2)
(map-set mint-passes 'SP3GCSJH3J5TVJEJD1FVXK44GFXR8633AJJ5E5BEY u2)
(map-set mint-passes 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191 u1)
(map-set mint-passes 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S u1)
(map-set mint-passes 'SP1W7F05KJZEY3WQ4ECHVGWKQR6G6YHZYEE6NXH24 u1)
(map-set mint-passes 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533 u1)
(map-set mint-passes 'SP24F3T8VFGKGR6MQ5R0K65GZJ9NFY41XM97KH1E4 u1)
(map-set mint-passes 'SPJCSG2ZJD95JR4QG9Z0EP786WN7T3CAF7GKBD01 u1)
(map-set mint-passes 'SP25RD2QZD9SZESKKYHRBREDHKGTYETD8BH3DT901 u1)
(map-set mint-passes 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV u1)
(map-set mint-passes 'SP3Z5H5KFMGBTYB37DYTGEA14VZG8AT32EPDEAKQH u1)
(map-set mint-passes 'SP34TK7YSEVPT0K1KH0GSG7EGVHQ70KT5V1EW7TQR u1)
