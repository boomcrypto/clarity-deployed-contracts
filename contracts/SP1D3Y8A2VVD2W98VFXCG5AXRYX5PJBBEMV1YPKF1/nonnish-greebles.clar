;; nonnish-greebles
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token nonnish-greebles uint)

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
(define-data-var mint-limit uint u1000)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qme9CJE36oWcm4qGgde1WDF9nbqwS2bkjcdDVL55BzV7Fj/json/")
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
      (unwrap! (nft-mint? nonnish-greebles next-id tx-sender) next-id)
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
    (nft-burn? nonnish-greebles token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? nonnish-greebles token-id) false)))

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
  (ok (nft-get-owner? nonnish-greebles token-id)))

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
  (match (nft-transfer? nonnish-greebles id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? nonnish-greebles id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? nonnish-greebles id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SPVCMKZTGYMKYJEHFN4FABNFBBYMM02HNF66A6N6 u105)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u62)
(map-set mint-passes 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE u51)
(map-set mint-passes 'SP12391ZGS5YJXHXVJPQ0DVTB3M8AQNAQGYEH72ZR u50)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u49)
(map-set mint-passes 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 u30)
(map-set mint-passes 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2 u29)
(map-set mint-passes 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH u25)
(map-set mint-passes 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u23)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u22)
(map-set mint-passes 'SP1TQZS5G1Y47KXWQE8WG2Q606664A7MFMPVCKHRZ u21)
(map-set mint-passes 'SP1XGVC95Z0HPG50YPEV5XZB5YA08DC29B0XZWBWN u20)
(map-set mint-passes 'SP1F9156MENFJTEWE6WJPMVWFAHNGKGC7YJX6HK72 u19)
(map-set mint-passes 'SPS2FZ3K6N2CZPBM4BSQCEQV23V2334E7MJ4CHZT u19)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u19)
(map-set mint-passes 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168 u18)
(map-set mint-passes 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3 u17)
(map-set mint-passes 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 u16)
(map-set mint-passes 'SP3EPS563XJNK170J902C78ZPDPNXVZFWWCN7DGWH u15)
(map-set mint-passes 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV u15)
(map-set mint-passes 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY u14)
(map-set mint-passes 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR u14)
(map-set mint-passes 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8 u13)
(map-set mint-passes 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE u12)
(map-set mint-passes 'SP2KSK3WJ1TJWMBWWEAA5043ARA21ZNFCARTHT8EZ u12)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u12)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u11)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u10)
(map-set mint-passes 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6 u10)
(map-set mint-passes 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG u9)
(map-set mint-passes 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ u9)
(map-set mint-passes 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 u8)
(map-set mint-passes 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q u8)
(map-set mint-passes 'SP342MMZRDFSC556F193N76D87SCTYX7SSHD8H3XD u8)
(map-set mint-passes 'SP3GG2XRSX2APJ1JFWV2A3KFEJPAJ5X8JGDXTSF1N u6)
(map-set mint-passes 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG u6)
(map-set mint-passes 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294 u6)
(map-set mint-passes 'SP1XZ7KEMJT5V8ATRYZB0XWJ20KMGM37JXJZG9D6S u6)
(map-set mint-passes 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10 u5)
(map-set mint-passes 'SP16PPSNDG265N42ZG7GPDADAAAMQCDY9MT6TN4XY u5)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u5)
(map-set mint-passes 'SP1A9NAK7RCXN0E47D95X5E0VY0HPAAA0VVC2M322 u5)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u5)
(map-set mint-passes 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 u4)
(map-set mint-passes 'SP1XAR0A0J2AFWXQXCJ07SPV3TSZV2BCQQAQ6H5B5 u4)
(map-set mint-passes 'SP3ST6K5W36V2MTSNYYXE56SCXR7DGTW9N4NMZHYV u4)
(map-set mint-passes 'SP32QTYYGG6SWTP198FST4SPM85J0A3JPNB9S2BEA u4)
(map-set mint-passes 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9 u4)
(map-set mint-passes 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY u4)
(map-set mint-passes 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X u4)
(map-set mint-passes 'SP33N5R751MG99QAM4CN6HQ3MDTYBR71SB4NXVGT1 u4)
(map-set mint-passes 'SP3Q1VW36FD1HF4J0EFRF2E486QGYNYJASB9PKDKF u3)
(map-set mint-passes 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 u3)
(map-set mint-passes 'SPN9JGFGXFJZD7AM5VF2S7BRATNCQYVHVWG3087B u3)
(map-set mint-passes 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1 u3)
(map-set mint-passes 'SPXZ0GWQTMGQ860MGG86PNMFJNHJ2NWJSWJWGM0K u3)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u3)
(map-set mint-passes 'SP2W0KJMJB2601KK53Y7F8W9FV5YJ1QVCT0GBJHTA u3)
(map-set mint-passes 'SP2HK9TYP0662DZMM6FSC2T18BG18YXE0N037JT08 u3)
(map-set mint-passes 'SP1MHYF45ZRE9QCG4SRHB72W65K89Q48FSQR4PDNK u3)
(map-set mint-passes 'SP1HHSDYJ0SGAM6K2W01ZF5K7AJFKWMJNH365ZWS9 u3)
(map-set mint-passes 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV u3)
(map-set mint-passes 'SPFK6E20DN1PFBY02956QN23TCWSPHMY76KYWGEZ u3)
(map-set mint-passes 'SP2MMK0WPM6Y5VMKZ87RBSDC0J66FTTYM7GVWCN0Z u3)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u3)
(map-set mint-passes 'SP3WXWMD8NC947EASJCMCVT11YDDMBHPXT8WE9WMF u3)
(map-set mint-passes 'SP265DNHNK1NHX7FE9MZKCCA4G1VS7TT3BMES5TR u3)
(map-set mint-passes 'SP3BRAY8T6S1K7WDCPM9CEEA00XMZD33PE9V4JT8C u3)
(map-set mint-passes 'SP26SB34D9THJ8BMSPT6EJHW9JDGBHWMX74PVDFEN u3)
(map-set mint-passes 'SP1JCPNPAMAQJ364AFHPTW3HY7X0HYZ3TJ0ZDGWZH u3)
(map-set mint-passes 'SP3JJC9CVH2251JC0B4QTPS661H6JNTA2P9E6HA6N u3)
(map-set mint-passes 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG u3)
(map-set mint-passes 'SP3BWAHYMTHQZHSB8N49AXQNTYWBACQBAN8Z4QFRD u2)
(map-set mint-passes 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN u2)
(map-set mint-passes 'SP1GNB1KSWAB2SK9GWZ9A1R8HSYKWKBBQ40QP240F u2)
(map-set mint-passes 'SP2RQXNR5Z9W4TW0TH9Y0FJEY19F61G1SD726AV9H u2)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u2)
(map-set mint-passes 'SPE6KAAKXSC0QSGG17SWYPX5R2KP3Q56V9KD88TP u2)
(map-set mint-passes 'SPJCSG2ZJD95JR4QG9Z0EP786WN7T3CAF7GKBD01 u2)
(map-set mint-passes 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 u2)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u2)
(map-set mint-passes 'SPV5GYRXDQRYQKZW7FFAZDNRRNVFS41P3YZWXFGD u2)
(map-set mint-passes 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ u2)
(map-set mint-passes 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ u2)
(map-set mint-passes 'SPTETNN57BDV0X796ZVW41B5VVN99JQRDH68Z5W6 u2)
(map-set mint-passes 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G u2)
(map-set mint-passes 'SPRXRB7J5SF0N0XQJF1FK332H5VZ67ZA5Y9Q036S u2)
(map-set mint-passes 'SP2MC6PBPNPSEHA6G87DDMN6WX3HGMTANXZBYKCNF u2)
(map-set mint-passes 'SP2NBCT6WVMD8PX46VTNRT4ENTQBZZ8ZYYYZY65RB u2)
(map-set mint-passes 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW u2)
(map-set mint-passes 'SP2C8P3MM137K1A48D1SRENG67KHEVPZV4K36G3JY u2)
(map-set mint-passes 'SP3PZGB6ZXH1G9K158H56A6TF26X7K1GGMAGMW0M3 u2)
(map-set mint-passes 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68 u2)
(map-set mint-passes 'SP3CXP82SP2M920C5XX42RMAJ3Y6FS0KS5ZK1N1BC u2)
(map-set mint-passes 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY u2)
(map-set mint-passes 'SP1PCEAP62X5BZSMH257ZHAPGAPSX3BDT3TDVCN4M u2)
(map-set mint-passes 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4 u2)
(map-set mint-passes 'SP2KD44XNHAXEPY4WXDQDCM596DNM68N29EGWJJ52 u2)
(map-set mint-passes 'SP216YJTD76S81ZXKVHEBTJT77PSVR33AZ57548V3 u2)
(map-set mint-passes 'SP2RN25RGDZPZQAHGFRPQ31P6QAW82H9H9HVCKDGR u2)
(map-set mint-passes 'SP3GKD03CY339NVCVG0PKKRRC4CAGCECYXNXGQ69 u2)
(map-set mint-passes 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533 u2)
(map-set mint-passes 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X u2)
(map-set mint-passes 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 u2)
(map-set mint-passes 'SP23FMJXH1MBKW7H4GTZZTPWHZR21NZACYQE5DEN1 u2)
(map-set mint-passes 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191 u2)
(map-set mint-passes 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ u2)
(map-set mint-passes 'SP1FXY0FASRSJ00BC71YS569RG9JFFG0J51EW42GD u1)
(map-set mint-passes 'SP21M4GV6XA7MKK9Q06GPN6TWVMR27C604AB81FFE u1)
(map-set mint-passes 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8 u1)
(map-set mint-passes 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA u1)
(map-set mint-passes 'SP249AVXAABB31ZKDEDSF4S22DD6X2208PXYC6GPP u1)
(map-set mint-passes 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX u1)
(map-set mint-passes 'SP2BEFSB43KR4M6C9117SA2A6T4SA6H0X1XDZF716 u1)
(map-set mint-passes 'SP32V5EAKRWZ66VVA67XGDK18VYMZM5NT7NP98M9 u1)
(map-set mint-passes 'SP3VCX5NFQ8VCHFS9M6N40ZJNVTRT4HZ62WFH5C4Q u1)
(map-set mint-passes 'SP1QJDCZ0J9NRPPPZ9186GGBFQZEZM86VKCE19D4T u1)
(map-set mint-passes 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB u1)
(map-set mint-passes 'SP3JP1QHR31X0HRX1VM0SEMRAMCEAHC5BR626QX16 u1)
(map-set mint-passes 'SP3TTE9TNNDK1DFP2CHGSQ21P3TQVQNCVWEMSWN21 u1)
(map-set mint-passes 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN u1)
(map-set mint-passes 'SP1FZKAJ5V0QSV19RB5T2DG1PJQ6R6MKSB5ZJF5A5 u1)
(map-set mint-passes 'SP17XZQC08H8ASTGNYJ651YGCM5497G9TX8V061SX u1)
(map-set mint-passes 'SP12YGGACNA4R43DB1HAQ3AE03PKPJGXZ1BX96CYB u1)
(map-set mint-passes 'SP4TH5RH19FSBNC54JA8S1V5N9G1GRNPCX39HK5P u1)
(map-set mint-passes 'SP18V7NZHXPQKRNBYAF5WGBV79PDY6XMDNHMZSW4R u1)
(map-set mint-passes 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH u1)
(map-set mint-passes 'SP2H94BXVGSH92VD407JX18VZ7S2ZFW2CFT5TJKKZ u1)
(map-set mint-passes 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX u1)
(map-set mint-passes 'SP3F2QCGP5QZFM19VWXNA1T32T9XCGCMXMMSMT5VH u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0 u1)
(map-set mint-passes 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A u1)
(map-set mint-passes 'SP1NFRJJFQAA5AB4R8RDA3F0WEBZHK0HQSKW1PPNY u1)
(map-set mint-passes 'SP3WSEATAT4VFFR6KAGX0QXS13E491TV64ZD1E4YY u1)
(map-set mint-passes 'SPJFHQVQNGRWNX90FA49QQ5RGPR31YVVFB3EJ71D u1)
(map-set mint-passes 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V u1)
(map-set mint-passes 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7 u1)
(map-set mint-passes 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79 u1)
(map-set mint-passes 'SP268V0BZFF2B4VNRGVFM934QR9TKT76M6G6FCKJ u1)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u1)
(map-set mint-passes 'SP33SCE1F3J9N6D4ZFY9AA3GR05GS3112GS1VZDFC u1)
(map-set mint-passes 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 u1)
(map-set mint-passes 'SPK70AN512VN2VRD52D0928MA05JVJ7DY2H5F3CF u1)
(map-set mint-passes 'SPAX2SZCDFTVV76SR4JY4RYEPC5PBH2QAHEJXHTF u1)
(map-set mint-passes 'SP7PSDAPGQ2A36G1EPX363AZFWS017Q6FXFFF2BX u1)
(map-set mint-passes 'SP3M16X85R7ED2RR70ANNB3X0HXPHGSAXBEGGZKK0 u1)
(map-set mint-passes 'SP3JCJYVVZVY7Y64JYJ57JFS6FM7ASHX6QDTKFXGY u1)
(map-set mint-passes 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 u1)
(map-set mint-passes 'SP349J1ZTEE71M1J5D4YS0BPQCCFJ3YSNM1P8BJY4 u1)
(map-set mint-passes 'SP7MAP8XJCMRZ9901ETFA3EKVVPJ4X51AWQ2VG4F u1)
(map-set mint-passes 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB u1)
(map-set mint-passes 'SP3R7Q3QMTYC4QR0RFDR9HZBWNBNBNDA7S549CR6Y u1)
(map-set mint-passes 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR u1)
(map-set mint-passes 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y u1)
(map-set mint-passes 'SPMDGP7AP5JQTDYY83V0Q7JD3CM7YQRXQYWW3E54 u1)
(map-set mint-passes 'SP1ATHZCMZA4CDJY3ZVNFRFNZZ4R2VEJ0PHYYX3YF u1)
(map-set mint-passes 'SP2TZE09GHARKG0B8NTT9X77QXBTQPQ2J1579T0D8 u1)
(map-set mint-passes 'SP23X8JVMHN2A9N1PWSGNW83Q0VV5T7NF2N6PJW9J u1)
(map-set mint-passes 'SPN0DSRZGFNGE6D59S4ZRF8GP604NDTSQ9RRS2BM u1)
(map-set mint-passes 'SP2SH0QW45QY23H6G9YVDJMRXT55SX67CXAAM61NT u1)
(map-set mint-passes 'SP1CMFJW9J8WN7R2XJ26AC90AARGW68R1CWNYDANC u1)
(map-set mint-passes 'SP39VDGM02VMDTAAXC0DC1HB7GX1QQJBEGMMMZA8Z u1)
(map-set mint-passes 'SP9J6BTSPCXGQ5HC066NRYQPK43S48V7K299PTQX u1)
(map-set mint-passes 'SP136AXDAQ41R31GJWJX8KX14E2T4K8PA08NCE6Q5 u1)
(map-set mint-passes 'SP2ZY7ETKYAN1M7R4HWQ77Q4CVDVH8PVQ41XS0N0S u1)
(map-set mint-passes 'SP3BJ4GDXYMBRS42NJNVE271YPAPYTF28T9722GHJ u1)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u1)
