;; stackers-city

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stackers-city uint)

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
(define-data-var mint-limit uint u3000)
(define-data-var last-id uint u1)
(define-data-var total-price uint u45000000)
(define-data-var artist-address principal 'SP4293RHR2BW6WA4Z6W2QQX6SPXCZVS2X33C9P18)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmWsdApAxNyhuMdF7eTNKwZAh5YQLdjHRzQvqABu8EAZcG/")
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

(define-public (claim-two) 
  (mint (list true true)))

(define-public (claim-five) 
  (mint (list true true true true true)))

(define-public (claim-ten) 
  (mint (list true true true true true true true true true true)))

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
      (unwrap! (nft-mint? stackers-city next-id tx-sender) next-id)
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
    (nft-burn? stackers-city token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stackers-city token-id) false)))

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
  (ok (nft-get-owner? stackers-city token-id)))

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
  (match (nft-transfer? stackers-city id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? stackers-city id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? stackers-city id) (err ERR-NOT-FOUND)))
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
(define-data-var total-price-mia uint u3200000000000)

(define-read-only (get-price-mia)
  (ok (var-get total-price-mia)))

(define-public (set-price-mia (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-mia price))))

(define-public (claim-mia)
  (mint-mia (list true)))

(define-public (claim-mia-two) 
  (mint-mia (list true true)))

(define-public (claim-mia-five) 
  (mint-mia (list true true true true true)))

(define-public (claim-mia-ten) 
  (mint-mia (list true true true true true true true true true true)))

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
(define-data-var total-price-banana uint u74000000)

(define-read-only (get-price-banana)
  (ok (var-get total-price-banana)))

(define-public (set-price-banana (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-banana price))))

(define-public (claim-banana)
  (mint-banana (list true)))

(define-public (claim-banana-two) 
  (mint-banana (list true true)))

(define-public (claim-banana-five) 
  (mint-banana (list true true true true true)))

(define-public (claim-banana-ten) 
  (mint-banana (list true true true true true true true true true true)))

(define-private (mint-banana (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-banana orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-banana orders)
      )
    )))

(define-private (mint-many-banana (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-banana) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

(map-set mint-passes 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE u10)
(map-set mint-passes 'SP1J4SFHSMMT5Z0PG3WDD1TNGZVCWMB5QBYHNFECG u10)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u10)
(map-set mint-passes 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 u10)
(map-set mint-passes 'SP3766HJFN7ZRB6708Y2EZ367H4M3PWBJTNVCYV6G u10)
(map-set mint-passes 'SP2WM2CT5HGE9B791XQVH4FD5MWC65XKG4YFFH1WC u10)
(map-set mint-passes 'SPSG97KXE3GHAAK2TMFC9VKE9KB0JBM47YY84Y8C u10)
(map-set mint-passes 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294 u10)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u10)
(map-set mint-passes 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y u10)
(map-set mint-passes 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM u10)
(map-set mint-passes 'SPQ1P0VQSZGANEA240J64CVP1ZPFF9HH5Z0NCBB u10)
(map-set mint-passes 'SP36NC0KX6RZGPQXR73AMW8R0CXXHS06DRM487A5G u10)
(map-set mint-passes 'SPD06GYCB9CEQT1JEKNC074P4RDXPD64763XAJAW u10)
(map-set mint-passes 'SPAFE45HMP1RY5Y1A3ZJ4WZNWASGFQE070S6NSV9 u10)
(map-set mint-passes 'SP2W84N9SSBX6GXCR846PVE37V32G1D5CGRZM9Y49 u10)
(map-set mint-passes 'SP66SC73VZXDGA3FP8AN2D4HNAEF81823CK4BEAA u10)
(map-set mint-passes 'SP20GTX3TEWK02QDMGCXJYP1HTWAZDVSM1SAHZZBV u10)
(map-set mint-passes 'SP3W6T3EYVW3DXDXN4PCYEWXX51GDTBS0T96DYQR7 u10)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u10)
(map-set mint-passes 'SPTETNN57BDV0X796ZVW41B5VVN99JQRDH68Z5W6 u10)
(map-set mint-passes 'SP2YG90T7GPVJDGXQAJ40Y08NB5ZBV4KVASSAQNE8 u10)
(map-set mint-passes 'SP3R566RQQ8J023DBZ1AZQYJG1MZZRQ8P3ZKVZ3V1 u10)
(map-set mint-passes 'SPFK6E20DN1PFBY02956QN23TCWSPHMY76KYWGEZ u10)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u10)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u10)
(map-set mint-passes 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u10)
(map-set mint-passes 'SPH7P46DMTTFNSHDD33N6G8GFE1MQB2R0QW176B1 u10)
(map-set mint-passes 'SPWYR5GD2GRBZWSZ1YTSN8EE98Q9C2JFA9HTPXWM u10)
(map-set mint-passes 'SPA9NVRN0AX8DT84T3WXPBJ6AYX1YPYZQWPPZDBW u10)
(map-set mint-passes 'SP1QVY5ZFXHK66K5YJG166X9VV7W6DDWVC7V2NWD1 u10)
(map-set mint-passes 'SP35MEYYBHSFCFXY296YGP7NAT6Y4XBJW2VETR8AV u10)
(map-set mint-passes 'SP2BZQ48MADDN62X044NNJCNXF5BA33C3BFQ3TZJW u10)
(map-set mint-passes 'SP293M874EPBS7H5EFF1DYAR3P5V1CNKVPK78GXG3 u10)
(map-set mint-passes 'SPA9NVRN0AX8DT84T3WXPBJ6AYX1YPYZQWPPZDBW u10)
(map-set mint-passes 'SPQ07EP6QK61JDHJQ0YDJJBHX5JZ8TWG5FNS8904 u10)
(map-set mint-passes 'SP2S31PFC49T1J7JWVRJ6TWEW2G1PW4Q603D0CBFC u10)
(map-set mint-passes 'SP1WM9B3RKTNRSWHXAQ9SQ5PKYW91VRRX59SJF10 u10)
(map-set mint-passes 'SP1FWAF97ZST58D7Q9WFQR3SJV3XW9SD8E3G0VTH3 u10)
(map-set mint-passes 'SPVKECY6JDNM1RG88KDJT48GJJKPSEMA9HDKA1T0 u10)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u10)
(map-set mint-passes 'SP3ZEG0WKYKEBF73EYVGBWQE4SZASF7X0WZTBCFJB u10)
(map-set mint-passes 'SP1CHG262X3TQEQPSRPRSTEMN7YEMXPJJM1M403Z9 u10)
(map-set mint-passes 'SP3RY71RCQX2J3BTDAEHTMSDWTXAC70R9W5XY0X05 u10)
(map-set mint-passes 'SP1AC2ZSA6KGGNWE4Y4E5EVR17RN2KT9SBM3BF2QS u10)
(map-set mint-passes 'SP19PYWHN176GDH7RPFWS7Z0S509X55G80DB1CHC9 u10)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u10)
(map-set mint-passes 'SP1QSN2SZKA2ZVE0024WSV5SZP3ZDM645SKHFTV94 u10)
(map-set mint-passes 'SP3YMM3JXFEP4JSPTF8DKD2HSPEBJV2C6GEQDXC06 u10)
(map-set mint-passes 'SP1XZW2BJJRT9T5XD7QRMJXHVPPMZJAJPFQB9B7MN u10)
(map-set mint-passes 'SP218YVRAFYY2Y736VY6869X1QXCHD5TP0S2DVVXD u10)
(map-set mint-passes 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP u10)
(map-set mint-passes 'SP2EJMPGZKE983KP58VRZZVTYV6Q99HHZ0WYEKGZR u10)
(map-set mint-passes 'SP690PDD045XTP8Y10MQZJT3S5W9DPGWQJ4P3X4P u10)
(map-set mint-passes 'SP3MQAQ3ZSF1GM1ZSPGTP6H3W5BDNHNWK4W18M625 u10)
(map-set mint-passes 'SP29YTRCR3N5BJPTWBFYTMZMTM4D0G2FTNCAN8BQE u10)
(map-set mint-passes 'SP27P6TYH0V76AVH02MR7ZR3SV31V0KWZA708J6GE u10)
(map-set mint-passes 'SP2Y9H8TQ4AR1Z2QKBHT1TG7Y9193VX6TTXEMMAD9 u10)
(map-set mint-passes 'SP9KPR5JBMVCBGNA2J68XNMT4QAYC0BW4MRPGSZG u10)
(map-set mint-passes 'SP27QPP024VGM2XQR0CPW8J7MEWZYZE3F54X5NJC u10)
(map-set mint-passes 'SP19KPWZDPBD13N07C7Q1BENQMEPRTNA6J6ACBJB3 u10)
(map-set mint-passes 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP u10)
(map-set mint-passes 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294 u10)
(map-set mint-passes 'SPTETNN57BDV0X796ZVW41B5VVN99JQRDH68Z5W6 u10)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u10)
(map-set mint-passes 'SP1K8ZADQJ7GPXBND02S2V3ZCAC8W1YMGVR7DP99P u10)
(map-set mint-passes 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G u10)
(map-set mint-passes 'SP1K8RG4PV202FHT8J9023G1WJRPFTSZXN9TPNEJX u10)
(map-set mint-passes 'SP3EYT7KF5ERWQFTWW3SWHS8QRYBNSMRZ7JW73YXR u10)
(map-set mint-passes 'SP25HZXKHGGZ2ASKXPF7R7QMG3QPYMQ6ZTGBSCVPS u10)
(map-set mint-passes 'SP3WVWGYZ9NPFJ44Q0D1MNQ3P1XCQAQ0A1KEFKSQD u10)
(map-set mint-passes 'SP262CK3VPG6PDF4S96TTXFBVV9Y9Z75F51A6G83N u10)
(map-set mint-passes 'SP176VFN4EB07HBDS4KPEQGFWP9MQKX7FJ4H40673 u10)
(map-set mint-passes 'SP1B7FFVFHHBCB466DVJR02BQ7PS9TNW02YA29DR3 u10)
(map-set mint-passes 'SPF4FR0X9Q4PAF6KENDD3NVAGQTM8A830A4F96YG u10)
(map-set mint-passes 'SP23RS2V3BAWHNQ3RHVZHK10F51RA99C1FHQKY9QH u10)
(map-set mint-passes 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4 u10)
(map-set mint-passes 'SP2KWZJ80QFPHD6KGBJF33SWAPN7AZDSANWXPWYMM u10)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u10)
(map-set mint-passes 'SP1GSQYR6ADFC2GWVZHGSGB5871NY9AJQ8B5QKCWP u10)
(map-set mint-passes 'SP3YC6DBFEEKRX790Y1SF7GQVE778C2HSJSS8KQAH u10)
(map-set mint-passes 'SP2E62ZJM727VRPNWKGM58HWE0BK7JWPQCC57T16Q u10)
(map-set mint-passes 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV u10)
(map-set mint-passes 'SP1XZW2BJJRT9T5XD7QRMJXHVPPMZJAJPFQB9B7MN u10)
(map-set mint-passes 'SP218YVRAFYY2Y736VY6869X1QXCHD5TP0S2DVVXD u10)
(map-set mint-passes 'SP1CKA3MMJABFQ3ATVC5J6Q24R8QZSHYQ19VB3CQE u10)
(map-set mint-passes 'SP2F9WV0YF46ZJ12545K6125YDKBSGFJ2WF2FMFFM u10)
(map-set mint-passes 'SP2RT3CD78EMEHETDCK7HHHAE7SXZJ6N5CVYCF19R u10)
(map-set mint-passes 'SP3W6T3EYVW3DXDXN4PCYEWXX51GDTBS0T96DYQR7 u10)
(map-set mint-passes 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 u10)
(map-set mint-passes 'SP2DZW1E6R5NEYXRHXW1RS1M4Y55Y4M52T9633M45 u10)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u10)
(map-set mint-passes 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87 u10)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u10)
(map-set mint-passes 'SPPTDXB8FRF3HS4GWMS7D74C9XHJ6K8ACHH0364A u10)
(map-set mint-passes 'SP3JER1QHHQMDMJYG3640MSFZHAS6JQH3C86TNW65 u10)
(map-set mint-passes 'SP25HZXKHGGZ2ASKXPF7R7QMG3QPYMQ6ZTGBSCVPS u10)
(map-set mint-passes 'SPS6543QSVCWM0B1CQYD67RV4QP3MGFPJEHG4FHS u10)
(map-set mint-passes 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294 u10)
(map-set mint-passes 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4 u10)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? stackers-city (+ last-nft-id u0) 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV))
      (map-set token-count 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV (+ (get-balance 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u1) 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV))
      (map-set token-count 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV (+ (get-balance 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u2) 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV))
      (map-set token-count 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV (+ (get-balance 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u3) 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV))
      (map-set token-count 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV (+ (get-balance 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u4) 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV))
      (map-set token-count 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV (+ (get-balance 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u5) 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT))
      (map-set token-count 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT (+ (get-balance 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u6) 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT))
      (map-set token-count 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT (+ (get-balance 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u7) 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT))
      (map-set token-count 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT (+ (get-balance 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u8) 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT))
      (map-set token-count 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT (+ (get-balance 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u9) 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT))
      (map-set token-count 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT (+ (get-balance 'SPSB2CE99GGSYQXM7VQ7C06Q0K8C83RWN0NJG2NT) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u10) 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25))
      (map-set token-count 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25 (+ (get-balance 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u11) 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25))
      (map-set token-count 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25 (+ (get-balance 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u12) 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25))
      (map-set token-count 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25 (+ (get-balance 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u13) 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25))
      (map-set token-count 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25 (+ (get-balance 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u14) 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25))
      (map-set token-count 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25 (+ (get-balance 'SPG34S51QV6YTZQGVRPZY9323MY4BTCFAFP1HR25) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u15) 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4))
      (map-set token-count 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4 (+ (get-balance 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u16) 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4))
      (map-set token-count 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4 (+ (get-balance 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u17) 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4))
      (map-set token-count 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4 (+ (get-balance 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u18) 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4))
      (map-set token-count 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4 (+ (get-balance 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u19) 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4))
      (map-set token-count 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4 (+ (get-balance 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u20) 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51))
      (map-set token-count 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51 (+ (get-balance 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u21) 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51))
      (map-set token-count 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51 (+ (get-balance 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u22) 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51))
      (map-set token-count 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51 (+ (get-balance 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u23) 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51))
      (map-set token-count 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51 (+ (get-balance 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u24) 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51))
      (map-set token-count 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51 (+ (get-balance 'SP225F26PGZ86QX8GN11Z5S8YS6A6V66EY0W64V51) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u25) 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN))
      (map-set token-count 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN (+ (get-balance 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u26) 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN))
      (map-set token-count 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN (+ (get-balance 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN) u1))
      (try! (nft-mint? stackers-city (+ last-nft-id u27) 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN))
      (map-set token-count 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN (+ (get-balance 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN) u1))

      (var-set last-id (+ last-nft-id u28))
      (var-set airdrop-called true)
      (ok true))))
