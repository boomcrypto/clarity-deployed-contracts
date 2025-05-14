---
title: "Trait demon-doggoz"
draft: true
---
```
;; demon-doggoz
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token demon-doggoz uint)

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
(define-data-var mint-limit uint u69)
(define-data-var last-id uint u1)
(define-data-var total-price uint u1100000)
(define-data-var artist-address principal 'SPKW6PSNQQ5Y8RQ17BWB0X162XW696NQX1868DNJ)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmPGx8GAUGDMzz2TnfLsYn1XQm74jBdkwwLAHgry3PsSCn/json/")
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
      (unwrap! (nft-mint? demon-doggoz next-id tx-sender) next-id)
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
    (nft-burn? demon-doggoz token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? demon-doggoz token-id) false)))

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
  (ok (nft-get-owner? demon-doggoz token-id)))

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
  (match (nft-transfer? demon-doggoz id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? demon-doggoz id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? demon-doggoz id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? demon-doggoz (+ last-nft-id u0) 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE))
      (map-set token-count 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE (+ (get-balance 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u1) 'SP3KVRE3RDYYSJ3JDGXKA0K15CC4JEA2ZGX4TJ5EC))
      (map-set token-count 'SP3KVRE3RDYYSJ3JDGXKA0K15CC4JEA2ZGX4TJ5EC (+ (get-balance 'SP3KVRE3RDYYSJ3JDGXKA0K15CC4JEA2ZGX4TJ5EC) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u2) 'SP1NPDHF9CQ8B9Q045CCQS1MR9M9SGJ5TT6WFFCD2))
      (map-set token-count 'SP1NPDHF9CQ8B9Q045CCQS1MR9M9SGJ5TT6WFFCD2 (+ (get-balance 'SP1NPDHF9CQ8B9Q045CCQS1MR9M9SGJ5TT6WFFCD2) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u3) 'SP1BM118CZRA5DG9T4B2F8K466PXQZGHF7ZZKW5RM))
      (map-set token-count 'SP1BM118CZRA5DG9T4B2F8K466PXQZGHF7ZZKW5RM (+ (get-balance 'SP1BM118CZRA5DG9T4B2F8K466PXQZGHF7ZZKW5RM) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u4) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u5) 'SP1GN9H48K7813BQDMQGRW1YREV9R2Z8307QKXDKV))
      (map-set token-count 'SP1GN9H48K7813BQDMQGRW1YREV9R2Z8307QKXDKV (+ (get-balance 'SP1GN9H48K7813BQDMQGRW1YREV9R2Z8307QKXDKV) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u6) 'SP10ECZKBTMVGV9Z41A9QQP80TQFZK2QRSV5BWNMX))
      (map-set token-count 'SP10ECZKBTMVGV9Z41A9QQP80TQFZK2QRSV5BWNMX (+ (get-balance 'SP10ECZKBTMVGV9Z41A9QQP80TQFZK2QRSV5BWNMX) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u7) 'SP1FHC2XXJW3CQFNFZX60633E5WPWST4DBW8JFP66))
      (map-set token-count 'SP1FHC2XXJW3CQFNFZX60633E5WPWST4DBW8JFP66 (+ (get-balance 'SP1FHC2XXJW3CQFNFZX60633E5WPWST4DBW8JFP66) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u8) 'SP26PZG61DH667XCX51TZNBHXM4HG4M6B2HWVM47V))
      (map-set token-count 'SP26PZG61DH667XCX51TZNBHXM4HG4M6B2HWVM47V (+ (get-balance 'SP26PZG61DH667XCX51TZNBHXM4HG4M6B2HWVM47V) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u9) 'SP1454QJJZC5E7Q5D25R32Q1WYCGAN2MZHC1W349D))
      (map-set token-count 'SP1454QJJZC5E7Q5D25R32Q1WYCGAN2MZHC1W349D (+ (get-balance 'SP1454QJJZC5E7Q5D25R32Q1WYCGAN2MZHC1W349D) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u10) 'SP2Z7EPPAQGCVSTSKG13DT6YRN8X21HVD83Y5YH1N))
      (map-set token-count 'SP2Z7EPPAQGCVSTSKG13DT6YRN8X21HVD83Y5YH1N (+ (get-balance 'SP2Z7EPPAQGCVSTSKG13DT6YRN8X21HVD83Y5YH1N) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u11) 'SP3T1M18J3VX038KSYPP5G450WVWWG9F9G6GAZA4Q))
      (map-set token-count 'SP3T1M18J3VX038KSYPP5G450WVWWG9F9G6GAZA4Q (+ (get-balance 'SP3T1M18J3VX038KSYPP5G450WVWWG9F9G6GAZA4Q) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u12) 'SP20FG5HZH3PZJRVCG6SQA2ZP3SV6WEXCVAGCKX1D))
      (map-set token-count 'SP20FG5HZH3PZJRVCG6SQA2ZP3SV6WEXCVAGCKX1D (+ (get-balance 'SP20FG5HZH3PZJRVCG6SQA2ZP3SV6WEXCVAGCKX1D) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u13) 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH))
      (map-set token-count 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH (+ (get-balance 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u14) 'SP2P4XX8HRA792EQ5DZN0R6PK906F0AETQ18B1XDD))
      (map-set token-count 'SP2P4XX8HRA792EQ5DZN0R6PK906F0AETQ18B1XDD (+ (get-balance 'SP2P4XX8HRA792EQ5DZN0R6PK906F0AETQ18B1XDD) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u15) 'SP15ZW2BT5E4BSM8SBJJ2P95NAAPRNT3YZ23KMY56))
      (map-set token-count 'SP15ZW2BT5E4BSM8SBJJ2P95NAAPRNT3YZ23KMY56 (+ (get-balance 'SP15ZW2BT5E4BSM8SBJJ2P95NAAPRNT3YZ23KMY56) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u16) 'SPSHPX1ETZ8TVD6HN6JK3MMTVREYM8QNRC49Z617))
      (map-set token-count 'SPSHPX1ETZ8TVD6HN6JK3MMTVREYM8QNRC49Z617 (+ (get-balance 'SPSHPX1ETZ8TVD6HN6JK3MMTVREYM8QNRC49Z617) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u17) 'SP1RDVQHYK1DGF3WR2BM83BCCKPWDS2M8FX11WDWP))
      (map-set token-count 'SP1RDVQHYK1DGF3WR2BM83BCCKPWDS2M8FX11WDWP (+ (get-balance 'SP1RDVQHYK1DGF3WR2BM83BCCKPWDS2M8FX11WDWP) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u18) 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS))
      (map-set token-count 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS (+ (get-balance 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u19) 'SP145Z1WBN4CEDF39KCYF9QCYQD27AW0AH5KH58H))
      (map-set token-count 'SP145Z1WBN4CEDF39KCYF9QCYQD27AW0AH5KH58H (+ (get-balance 'SP145Z1WBN4CEDF39KCYF9QCYQD27AW0AH5KH58H) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u20) 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75))
      (map-set token-count 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75 (+ (get-balance 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u21) 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0))
      (map-set token-count 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0 (+ (get-balance 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u22) 'SPAFPBD7M89973WDEN68FKYW761RQVYNHSEFQZB9))
      (map-set token-count 'SPAFPBD7M89973WDEN68FKYW761RQVYNHSEFQZB9 (+ (get-balance 'SPAFPBD7M89973WDEN68FKYW761RQVYNHSEFQZB9) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u23) 'SP2FPTH274BXVB1E2HNXBAMGABV5TCSZTFNC16FR3))
      (map-set token-count 'SP2FPTH274BXVB1E2HNXBAMGABV5TCSZTFNC16FR3 (+ (get-balance 'SP2FPTH274BXVB1E2HNXBAMGABV5TCSZTFNC16FR3) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u24) 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C))
      (map-set token-count 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C (+ (get-balance 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u25) 'SP1RB1V65A1PAAXYT8PVFFFC6T1FN9E8RQX7HMDKC))
      (map-set token-count 'SP1RB1V65A1PAAXYT8PVFFFC6T1FN9E8RQX7HMDKC (+ (get-balance 'SP1RB1V65A1PAAXYT8PVFFFC6T1FN9E8RQX7HMDKC) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u26) 'SP345FTTDC4VT580K18ER0MP5PR1ZRP5C3Q0KYA1P))
      (map-set token-count 'SP345FTTDC4VT580K18ER0MP5PR1ZRP5C3Q0KYA1P (+ (get-balance 'SP345FTTDC4VT580K18ER0MP5PR1ZRP5C3Q0KYA1P) u1))
      (try! (nft-mint? demon-doggoz (+ last-nft-id u27) 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY))
      (map-set token-count 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY (+ (get-balance 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY) u1))

      (var-set last-id (+ last-nft-id u28))
      (var-set airdrop-called true)
      (ok true))))
```
