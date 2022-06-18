;; nfts-for-peace

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token nfts-for-peace uint)

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
(define-data-var mint-limit uint u500)
(define-data-var last-id uint u1)
(define-data-var total-price uint u40000000)
(define-data-var artist-address principal 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qmf3g7qXKTMRzScq2dS3aaMhg2etw8ZuJM5StaV3kjVv31/")
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
        (try! (stx-transfer? (/ (* price u1500) u10000) tx-sender (var-get artist-address))) ;; curator
        (try! (stx-transfer? (/ (* price u1500) u10000) tx-sender 'SP3MY40Y01G87Q4W0V76T9JEHQ8PG0ZPFAGBSV4B8)) ;; manuel
        (try! (stx-transfer? (/ (* price u1500) u10000) tx-sender 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y)) ;; sean
        (try! (stx-transfer? (/ (* price u1500) u10000) tx-sender 'SP57BAPA05DVWVSFJ9N7NCJ2PM0NZHKGHB6B8Y6S)) ;; adrian
        (try! (stx-transfer? (/ (* price u300) u10000) tx-sender 'SP2H703XWJD575CCW81C0C4B2JPJVES97E3KA3M01)) ;; borges
        (try! (stx-transfer? (/ (* price u700) u10000) tx-sender 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7)) ;; drawing
        (try! (stx-transfer? (/ (* price u2000) u10000) tx-sender 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7.NFTs-for-Peace)) ;; multisig-refugee
        (try! (stx-transfer? total-commission tx-sender COMM-ADDR))
      )    
    )
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? nfts-for-peace next-id tx-sender) next-id)
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
    (nft-burn? nfts-for-peace token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? nfts-for-peace token-id) false)))

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
  (ok (nft-get-owner? nfts-for-peace token-id)))

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
  (match (nft-transfer? nfts-for-peace id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? nfts-for-peace id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? nfts-for-peace id) (err ERR-NOT-FOUND)))
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

;; Alt Minting Mintpass
(define-data-var total-price-mia uint u0)

(define-read-only (get-price-mia)
  (ok (var-get total-price-mia)))

(define-public (claim-mia)
  (mint-mia (list true)))

(define-private (mint-mia (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-mia orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-mia orders)
      )
    )))

(define-private (mint-many-mia (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-mia) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Alt Minting Mintpass
(define-data-var total-price-nyc uint u0)

(define-read-only (get-price-nyc)
  (ok (var-get total-price-nyc)))

(define-public (claim-nyc)
  (mint-nyc (list true)))

(define-private (mint-nyc (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-nyc orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-nyc orders)
      )
    )))

(define-private (mint-many-nyc (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-nyc) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

(map-set mint-passes 'SP3MY40Y01G87Q4W0V76T9JEHQ8PG0ZPFAGBSV4B8 u6)
(map-set mint-passes 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y u5)
(map-set mint-passes 'SP57BAPA05DVWVSFJ9N7NCJ2PM0NZHKGHB6B8Y6S u5)
(map-set mint-passes 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7 u5)
(map-set mint-passes 'SP2AYJHP9H3JM3T26ZBW0SKBCXJ9S4JW03VQBP7K1 u3)
(map-set mint-passes 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN u6)
(map-set mint-passes 'SP2AA923Y7YMT32AWD92GN9GD4Y91AGSNNXMW2VGW u3)
(map-set mint-passes 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X u3)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u1)
(map-set mint-passes 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX u2)
(map-set mint-passes 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG u2)
(map-set mint-passes 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 u5)
(map-set mint-passes 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX u1)
(map-set mint-passes 'SP13NK68ADVWYDZM2GZCNF0ZCFMCYAYGCTK22YE6T u1)
(map-set mint-passes 'SP2ACM4ECBGRAPJH3Q86VAQ4YRBK5G1C7F4VYJ500 u1)
(map-set mint-passes 'SPEXAF3YRNCR01Z4DFZ567Z0FB4RKPHM88DMKJSQ u3)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u11)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u1)
(map-set mint-passes 'SP1X5NZTWNA7DH2QBZ71BY7P3XS2HBY0AAJ42XEK6 u5)
(map-set mint-passes 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH u2)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u3)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u1)
(map-set mint-passes 'SP2JZEYYZX4DGWKTF21JZK637694R3VGBR0XWFZPR u1)
(map-set mint-passes 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V u2)
(map-set mint-passes 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294 u1)
(map-set mint-passes 'SP643H4YMDRDNAE89EHY4B65S9K047XWX3QNW3W9 u2)
(map-set mint-passes 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y u1)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u2)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u1)
(map-set mint-passes 'SP2DW9RTN82J2MR2FHQXY5EE0Y616JJ076RYG8PTY u1)
(map-set mint-passes 'SP1TCA7QER9J9NKCKBB78K48TADDFC2GXYM3QQV3X u3)
(map-set mint-passes 'SP2EF3C3YBK9HCTBQTQG1883V2TSZQ3T2M13FDXR8 u3)
(map-set mint-passes 'SP3SYJYKKCV8M7W3ZF4VGRRE9GC7XTPE8MFX1TBS7 u2)
(map-set mint-passes 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4 u5)
(map-set mint-passes 'SPV5GYRXDQRYQKZW7FFAZDNRRNVFS41P3YZWXFGD u2)
(map-set mint-passes 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG u3)
(map-set mint-passes 'SP1K8RG4PV202FHT8J9023G1WJRPFTSZXN9TPNEJX u2)
(map-set mint-passes 'SPTE2M6TA977BZK6G6N8V1XB196YD18VETDR67EE u1)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u1)
(map-set mint-passes 'SPJFF8H2TRX7Z6FJCXYZSD2A403J45T0HP95K8QF u2)
(map-set mint-passes 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0 u3)
(map-set mint-passes 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D u4)
(map-set mint-passes 'SPCJ0JZVB02YYVSR5XVS1JJ17G4ZP1KFGD15B049 u1)
(map-set mint-passes 'SP1RDVQHYK1DGF3WR2BM83BCCKPWDS2M8FX11WDWP u1)
(map-set mint-passes 'SP5CQR0EPFKM8WET982GNG3GJF59K7CBFBF4S71G u1)
(map-set mint-passes 'SP1SBTRXDJP4N825PY69B1MKTQ4MSPB0DW9JCQHKE u1)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u1)
(map-set mint-passes 'SP1XBS03PFDTV1HSD7BY02V6VG16VTNRDP9N1QZAV u1)
(map-set mint-passes 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ u1)
(map-set mint-passes 'SP2JCF3ME5QC779DQ2X1CM9S62VNJF44GC23MKQXK u3)
(map-set mint-passes 'SP2NBCT6WVMD8PX46VTNRT4ENTQBZZ8ZYYYZY65RB u1)
(map-set mint-passes 'SP1QSA6J2HC2TV5NV0Q7X1H6ZBV6SDTDKC4GXBJPY u1)
(map-set mint-passes 'SP3PNS0DPE0NSVNGKQD1J9KYCMY2X5Y98PVM8MEQA u1)
(map-set mint-passes 'SP30R5X0EC0TTW2YE3HWW5NZ8NSWBD0QFHMQTDE1B u1)
(map-set mint-passes 'SP3VRDX2C875CWXSZXC1C7B5EKQSZH2975DHSA8FN u1)
(map-set mint-passes 'SP3WDK7DSVQ7ZN1WV8XWXTCHTDY99W0Z4YBVCK94K u1)
(map-set mint-passes 'SP31F1SERK1KNDJ1GNHS7ZKTM18V6NW0DTGYTQJG2 u2)
(map-set mint-passes 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8 u1)
(map-set mint-passes 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G u1)
(map-set mint-passes 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK u3)
(map-set mint-passes 'SP3F50PNGA4PY5PVB590SKY4WE8NHZEYQKRDBSJX8 u1)
(map-set mint-passes 'SPTETNN57BDV0X796ZVW41B5VVN99JQRDH68Z5W6 u1)
(map-set mint-passes 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV u1)
(map-set mint-passes 'SPQVG91FWDN2KZ6V8DTSKYCXC5FEZFDZSQC8ZNM1 u3)
(map-set mint-passes 'SP36BHKET7TJKBH4Q7G2EY1SMA390Q52VJTEF181K u3)
(map-set mint-passes 'SP16H5R1ZDFJQ7FE3ZYZKGFD8QTGPAGVEYWQXJMS5 u1)
(map-set mint-passes 'SP2ZCER0Z8VVMCDA3817SDFVES833XD9ACYDAFH1T u1)
(map-set mint-passes 'SP3A3KBET6JXHCHGQSE8ZMTXE4ZNJ4QF5TQWHWYSE u2)
(map-set mint-passes 'SP9QXM38XZX8744Z9DFWX1EG92ENF0NKPNMF24TH u3)
(map-set mint-passes 'SP2JHNX03F22FJ9A8SZ00MRTPEWZQDRAFRY61P2W5 u2)
(map-set mint-passes 'SP1MS7KGA5WESV319PV9GVKW2FFJJ1YNT9ETC6FQC u1)
(map-set mint-passes 'SP4CFPJA53W1VHVZ6WJ00G1M4CAX904PZ8EAAY03 u1)
(map-set mint-passes 'SPKSG77V3EGXED5RJ4H7P6G2H24TAWFJFR083A9B u1)
(map-set mint-passes 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 u5)
(map-set mint-passes 'SP1HJZKZ4GBJS8PFEQD969QPNS2W1GMJ9PAGA4P2D u5)
(map-set mint-passes 'SP21M4GV6XA7MKK9Q06GPN6TWVMR27C604AB81FFE u3)
(map-set mint-passes 'SP1G9PZMQSFRQ7Q98XP7JMNE2C22RXK1W61RXTNKP u3)
(map-set mint-passes 'SP1H19NX0KNQFF25MA3Q2S1WPEHN99CVS7TFZAPZ7 u2)
(map-set mint-passes 'SP3CK642B6119EVC6CT550PW5EZZ1AJW661ZMQTYD u2)
(map-set mint-passes 'SPX5F21SSNTWTM55F24TM03S095QYQM7JARDA1F u5)
(map-set mint-passes 'SPKFSJ4T8T39ZJN455QBY7TJX4DYF47J7344HNNF u3)
(map-set mint-passes 'SPMNM4PET76RKHYGHKZGJ8MRZ0NAXXZKY5AH2RE4 u3)
(map-set mint-passes 'SPCP6QYQG399SWCF2TVAFHVHN302TB3ABRTWHPEH u2)
(map-set mint-passes 'SP14E544B2FY8BSKTV5V7W8NCRYX2B7NXRQ7B7NJ9 u1)
(map-set mint-passes 'SP2DG03SMAV8Q8JTDHF9F32Y7B3523ZJYM0Q3MK3Y u1)
(map-set mint-passes 'SP3G2203JNVE8BQ10YJ352RBPMNWN023PJ1R7AP8S u1)
(map-set mint-passes 'SP3VP4DWQ177CH3TF63HA25DNW300Z555AHWAKAJ3 u1)
(map-set mint-passes 'SP2GSEVPVKX2PX027NMCQK74XH5Z4FK3M7K62SVCE u1)
(map-set mint-passes 'SPVY7SXW4WWJ8DV2664DNS3SW8CZCCD3HSMCZ05M u1)
(map-set mint-passes 'SP2WDPBYR0JTYRKF750PMSBREHHJKX5JJ80N21S7E u1)
(map-set mint-passes 'SPCWYAMVCTXXAR0HKD0R5G7EP5XRNKPSB370V9GC u1)
(map-set mint-passes 'SP2JAN0ZZ16BJTEBFN8TPHDJABGB8X4SE88JVKT5V u1)
(map-set mint-passes 'SP2YJGGD8YZ5F0XZAXERZ0DDNYSGG7SJHTGG9MWV8 u1)
(map-set mint-passes 'SP3MB74HT9SDNGENKFDA3AKZEXEMBZWB1FTFSHWBJ u1)
(map-set mint-passes 'SPQQWXPWRKPM404YT4H80V94168TWRNE6GBSD1S7 u1)
(map-set mint-passes 'SPEY81VZ4688E4D0P0NRVAD0GA9F30GWV9HJ5M0E u1)
(map-set mint-passes 'SP2NHMWWJZTEDBNXNZ4A89FF6R2980YD9GWF7R1Q2 u1)
(map-set mint-passes 'SP1B7FFVFHHBCB466DVJR02BQ7PS9TNW02YA29DR3 u1)
(map-set mint-passes 'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B u1)
(map-set mint-passes 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D u1)
(map-set mint-passes 'SP2BZQ48MADDN62X044NNJCNXF5BA33C3BFQ3TZJW u1)
(map-set mint-passes 'SP3EYT7KF5ERWQFTWW3SWHS8QRYBNSMRZ7JW73YXR u1)
(map-set mint-passes 'SP37MA19SG0HH69SK56P0VA14Z1NW3Y7RYDG6SE7K u1)
(map-set mint-passes 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 u1)
(map-set mint-passes 'SP2T04RQY3SP5V24233ABVX9G5CV14NMSB1ZF83NQ u1)
(map-set mint-passes 'SP1P94TYSJZ25849PHEBR5Y4J9BCW8MJMZCE0TD4K u1)
(map-set mint-passes 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W u1)
(map-set mint-passes 'SP176VFN4EB07HBDS4KPEQGFWP9MQKX7FJ4H40673 u1)
(map-set mint-passes 'SPF4FR0X9Q4PAF6KENDD3NVAGQTM8A830A4F96YG u1)
(map-set mint-passes 'SP2FYQ7FP7PF8JBN84J58194CZ24K05ZY6E4JPC6W u1)
(map-set mint-passes 'SPZ3AFWCMJX73GQ4FN691W25QG3E8QSP8P5KJR5N u1)
(map-set mint-passes 'SPN9JGFGXFJZD7AM5VF2S7BRATNCQYVHVWG3087B u1)
(map-set mint-passes 'SP3Y9SWNSPDX6K6TFCFWTX3B3V4K3GB7KXB669GT4 u1)
(map-set mint-passes 'SP3TYAQVV9378DDA1HF118CH6521NRCY7YBCWAX6G u1)
(map-set mint-passes 'SPBAEPGDF9T0KGY5GY8P92XPM2RA1VVAAG43BJY7 u1)
(map-set mint-passes 'SP6Y9FQ6HE0HZ4G5XVT9PG0XZJJM2WWN0SXCY8YV u1)
(map-set mint-passes 'SP3GK0DJYBGTAFXV6B92YQ96FV8GT5AT5RWBBE3XY u1)
(map-set mint-passes 'SP2VJG4K68TCF1FQ67N1CE9MFJMJ008VKG5HY9S80 u1)
(map-set mint-passes 'SP34ZEET21QZMHC7HEKSCEP3B0S53S1GDGZT12M3A u1)
(map-set mint-passes 'SP2MDEE7BMXWTNST6PKE8MGP2EWD6412ZNPTYMQ5S u1)
(map-set mint-passes 'SP2F5G73XGYNKNV1FKBMY19SWZR3EYZCST8XKVE9C u1)
(map-set mint-passes 'SP3HY8Z7BBPVJH7PKP3VBCEA9DE8XATR9ENR39QB3 u1)
(map-set mint-passes 'SP2527G0DP3P0SJAJ2Z4DT6VSFQMD70TSB0XV7HP u2)
(map-set mint-passes 'SP9MZHJH0FQB746YZ7D22ZBHJFQVBYN8M8FQ4PCX u1)
(map-set mint-passes 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E u1)
(map-set mint-passes 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191 u1)
(map-set mint-passes 'SP1QCMFS4X8RM65FQP02M7WGDHBZR5BXN8NJ741ME u1)
(map-set mint-passes 'SPHSJ8X8NM1B59FRR9H643J93TC8G75F3TGWNRJ1 u1)
(map-set mint-passes 'SP1PRJKBT43P9G31R8FVNMCTTY1E3520YG8ZWD9BR u1)
(map-set mint-passes 'SP1Q1T7QNQ4K5FVVSBZ6AF06YB2SZ9NKFKMXGK41Q u1)
(map-set mint-passes 'SP218F71JZ4R2ERQDKEBGA1FKVAQNZBM3HK7W8EA7 u1)
(map-set mint-passes 'SP1PGB1T5KRNWZGDS1JEV7775HJMYBSEM2Z333Y8Y u1)
(map-set mint-passes 'SPW5TXSS62ASTVDC9QAE7YADFAWD1EBKVPW8GS6P u1)
(map-set mint-passes 'SP1S0VW3TF5Y5EFRJ090TV6SCQ4A2WSWS4RTR67CD u1)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA u1)
(map-set mint-passes 'SPJ52DQFJVJACKHY0QX5DRE559MBCXWTSGNBN76V u1)
(map-set mint-passes 'SP60NM5KTMV734EZZWRCHA0403Z4JWEDJ1JJSKPS u1)
(map-set mint-passes 'SP2DMHTS1V4J34R6XZ7Q8J4MXEX8Q0JAJ9N2KTNT4 u1)
(map-set mint-passes 'SP3NH76GQ6M070SEMXE1PHM1GW9A5GKTJME2S8Y4H u1)
(map-set mint-passes 'SP79JMAGQVWMVWRXG2AE5GF8Z27VF1W4KZ3J03WG u1)
(map-set mint-passes 'SPJCSG2ZJD95JR4QG9Z0EP786WN7T3CAF7GKBD01 u1)
(map-set mint-passes 'SP3XB3VKJ8SFX6RV2N42VW9NSY7PGC96HH8TE69R0 u1)
(map-set mint-passes 'SP3EPS563XJNK170J902C78ZPDPNXVZFWWCN7DGWH u1)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u2)
(map-set mint-passes 'SPH7P46DMTTFNSHDD33N6G8GFE1MQB2R0QW176B1 u2)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP1XGVC95Z0HPG50YPEV5XZB5YA08DC29B0XZWBWN u1)
(map-set mint-passes 'SP2A4R43TCNHZ19AKK44WEBP4R16X7DV4093GQ0X4 u1)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? nfts-for-peace (+ last-nft-id u0) 'SP3MY40Y01G87Q4W0V76T9JEHQ8PG0ZPFAGBSV4B8))
      (map-set token-count 'SP3MY40Y01G87Q4W0V76T9JEHQ8PG0ZPFAGBSV4B8 (+ (get-balance 'SP3MY40Y01G87Q4W0V76T9JEHQ8PG0ZPFAGBSV4B8) u1))
      (try! (nft-mint? nfts-for-peace (+ last-nft-id u1) 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y))
      (map-set token-count 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y (+ (get-balance 'SP27PMQWPBDV1XK9HK259XZNHW8B6XZJJXMNQCV6Y) u1))
      (try! (nft-mint? nfts-for-peace (+ last-nft-id u2) 'SP57BAPA05DVWVSFJ9N7NCJ2PM0NZHKGHB6B8Y6S))
      (map-set token-count 'SP57BAPA05DVWVSFJ9N7NCJ2PM0NZHKGHB6B8Y6S (+ (get-balance 'SP57BAPA05DVWVSFJ9N7NCJ2PM0NZHKGHB6B8Y6S) u1))
      (try! (nft-mint? nfts-for-peace (+ last-nft-id u3) 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7))
      (map-set token-count 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7 (+ (get-balance 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7) u1))
      (try! (nft-mint? nfts-for-peace (+ last-nft-id u4) 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D))
      (map-set token-count 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D (+ (get-balance 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D) u1))
      (try! (nft-mint? nfts-for-peace (+ last-nft-id u5) 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK))
      (map-set token-count 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK (+ (get-balance 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK) u1))
      (try! (nft-mint? nfts-for-peace (+ last-nft-id u6) 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0))
      (map-set token-count 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0 (+ (get-balance 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0) u1))
      (try! (nft-mint? nfts-for-peace (+ last-nft-id u7) 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20))
      (map-set token-count 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 (+ (get-balance 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20) u1))
      (try! (nft-mint? nfts-for-peace (+ last-nft-id u8) 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW))
      (map-set token-count 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW (+ (get-balance 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW) u1))
      (try! (nft-mint? nfts-for-peace (+ last-nft-id u9) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))

      (var-set last-id (+ last-nft-id u10))
      (var-set airdrop-called true)
      (ok true))))
