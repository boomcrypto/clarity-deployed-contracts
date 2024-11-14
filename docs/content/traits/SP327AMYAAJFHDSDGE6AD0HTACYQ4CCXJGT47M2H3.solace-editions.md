---
title: "Trait solace-editions"
draft: true
---
```
;; solace-editions
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token solace-editions uint)

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
(define-constant ERR-CONTRACT-LOCKED u115)

;; Internal variables
(define-data-var mint-limit uint u15)
(define-data-var last-id uint u1)
(define-data-var total-price uint u1000000000)
(define-data-var artist-address principal 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmRivHzgS6kvBamzqjWoZfWnZnsWuEq63y2gnmwoFuVsBo/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)
(define-data-var locked bool false)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-public (claim) 
  (mint (list true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (or (is-eq (var-get mint-limit) u0) (<= last-nft-id (var-get mint-limit))) (err ERR-NO-MORE-NFTS)))
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
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
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
  (if (or (is-eq (var-get mint-limit) u0) (<= next-id (var-get mint-limit)))
    (begin
      (unwrap! (nft-mint? solace-editions next-id tx-sender) next-id)
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
    (nft-burn? solace-editions token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? solace-editions token-id) false)))

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
  (ok (nft-get-owner? solace-editions token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get ipfs-root))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-locked)
  (ok (var-get locked)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/5")
(define-data-var license-name (string-ascii 40) "PERSONAL-NO-HATE")

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
  (match (nft-transfer? solace-editions id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? solace-editions id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? solace-editions id) (err ERR-NOT-FOUND)))
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
  

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? solace-editions (+ last-nft-id u0) 'SP15ZW2BT5E4BSM8SBJJ2P95NAAPRNT3YZ23KMY56))
      (map-set token-count 'SP15ZW2BT5E4BSM8SBJJ2P95NAAPRNT3YZ23KMY56 (+ (get-balance 'SP15ZW2BT5E4BSM8SBJJ2P95NAAPRNT3YZ23KMY56) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u1) 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3))
      (map-set token-count 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3 (+ (get-balance 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u2) 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3))
      (map-set token-count 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3 (+ (get-balance 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u3) 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3))
      (map-set token-count 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3 (+ (get-balance 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u4) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u5) 'SPB16ZJVEEMXH4C1DT4HSW2GAKC7G6Q7E5AHGXPP))
      (map-set token-count 'SPB16ZJVEEMXH4C1DT4HSW2GAKC7G6Q7E5AHGXPP (+ (get-balance 'SPB16ZJVEEMXH4C1DT4HSW2GAKC7G6Q7E5AHGXPP) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u6) 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9))
      (map-set token-count 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9 (+ (get-balance 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u7) 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV))
      (map-set token-count 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV (+ (get-balance 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u8) 'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV))
      (map-set token-count 'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV (+ (get-balance 'SPBNZD0NMBJVRYJZ3SJ4MTRSZ3FEMGGTV2YM5MFV) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u9) 'SP3GEB8844GGSG23312PXQCE6W879YKK1A6CW33JN))
      (map-set token-count 'SP3GEB8844GGSG23312PXQCE6W879YKK1A6CW33JN (+ (get-balance 'SP3GEB8844GGSG23312PXQCE6W879YKK1A6CW33JN) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u10) 'SP11AH2N2ZNQ3GZNQ65PER3ME9J336875X6YF03MG))
      (map-set token-count 'SP11AH2N2ZNQ3GZNQ65PER3ME9J336875X6YF03MG (+ (get-balance 'SP11AH2N2ZNQ3GZNQ65PER3ME9J336875X6YF03MG) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u11) 'SP1VSV3ZA8BHT7DN3RS3REQRRCS33V92KRQ994QT7))
      (map-set token-count 'SP1VSV3ZA8BHT7DN3RS3REQRRCS33V92KRQ994QT7 (+ (get-balance 'SP1VSV3ZA8BHT7DN3RS3REQRRCS33V92KRQ994QT7) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u12) 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3))
      (map-set token-count 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3 (+ (get-balance 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u13) 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3))
      (map-set token-count 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3 (+ (get-balance 'SP327AMYAAJFHDSDGE6AD0HTACYQ4CCXJGT47M2H3) u1))
      (try! (nft-mint? solace-editions (+ last-nft-id u14) 'SPP74WS833MY99FXA1H2QC64RFMVCNZ37765FM3R))
      (map-set token-count 'SPP74WS833MY99FXA1H2QC64RFMVCNZ37765FM3R (+ (get-balance 'SPP74WS833MY99FXA1H2QC64RFMVCNZ37765FM3R) u1))

      (var-set last-id (+ last-nft-id u15))
      (var-set airdrop-called true)
      (ok true))))
```
