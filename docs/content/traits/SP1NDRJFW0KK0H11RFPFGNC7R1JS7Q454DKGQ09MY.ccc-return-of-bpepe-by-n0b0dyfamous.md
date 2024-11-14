---
title: "Trait ccc-return-of-bpepe-by-n0b0dyfamous"
draft: true
---
```
;; ccc-return-of-bpepe-by-n0b0dyfamous
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token ccc-return-of-bpepe-by-n0b0dyfamous uint)

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
(define-data-var mint-limit uint u2500)
(define-data-var last-id uint u1)
(define-data-var total-price uint u1000000)
(define-data-var artist-address principal 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmbbYFuVZix9Nhk1e1ysxwPoTPXHNWshYzMHdcpjLgLVPu/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u50)
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
      (unwrap! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous next-id tx-sender) next-id)
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
    (nft-burn? ccc-return-of-bpepe-by-n0b0dyfamous token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? ccc-return-of-bpepe-by-n0b0dyfamous token-id) false)))

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
  (ok (nft-get-owner? ccc-return-of-bpepe-by-n0b0dyfamous token-id)))

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
  (match (nft-transfer? ccc-return-of-bpepe-by-n0b0dyfamous id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? ccc-return-of-bpepe-by-n0b0dyfamous id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? ccc-return-of-bpepe-by-n0b0dyfamous id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u0) 'SP3KMSSAHGD2WY42N1VZ11M6E8XQ42222HQMNTSD3))
      (map-set token-count 'SP3KMSSAHGD2WY42N1VZ11M6E8XQ42222HQMNTSD3 (+ (get-balance 'SP3KMSSAHGD2WY42N1VZ11M6E8XQ42222HQMNTSD3) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u1) 'SP1NP36KD0PWVPZP56XB8ECB6M6ZEF21731SA0SXR))
      (map-set token-count 'SP1NP36KD0PWVPZP56XB8ECB6M6ZEF21731SA0SXR (+ (get-balance 'SP1NP36KD0PWVPZP56XB8ECB6M6ZEF21731SA0SXR) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u2) 'SP1RJC76DDEGTXEA21MNVDAV40Y4HW845C9J46RJS))
      (map-set token-count 'SP1RJC76DDEGTXEA21MNVDAV40Y4HW845C9J46RJS (+ (get-balance 'SP1RJC76DDEGTXEA21MNVDAV40Y4HW845C9J46RJS) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u3) 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9))
      (map-set token-count 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9 (+ (get-balance 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u4) 'SP2TG5BXDQKQS3391WJKK96KW9CBQBDYFSQCAAGE2))
      (map-set token-count 'SP2TG5BXDQKQS3391WJKK96KW9CBQBDYFSQCAAGE2 (+ (get-balance 'SP2TG5BXDQKQS3391WJKK96KW9CBQBDYFSQCAAGE2) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u5) 'SP9JDGSZ2DSYPAXPM74EG6ZBG2FX6WHZGWYQV077))
      (map-set token-count 'SP9JDGSZ2DSYPAXPM74EG6ZBG2FX6WHZGWYQV077 (+ (get-balance 'SP9JDGSZ2DSYPAXPM74EG6ZBG2FX6WHZGWYQV077) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u6) 'SP3YM5YRTKHTWRC82K5DZJBY9XW0K4AX0P9PM5VSH))
      (map-set token-count 'SP3YM5YRTKHTWRC82K5DZJBY9XW0K4AX0P9PM5VSH (+ (get-balance 'SP3YM5YRTKHTWRC82K5DZJBY9XW0K4AX0P9PM5VSH) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u7) 'SP1GZQJR3PDKTHYRJ5KCXYWYTPWXRVHQEED86P2TP))
      (map-set token-count 'SP1GZQJR3PDKTHYRJ5KCXYWYTPWXRVHQEED86P2TP (+ (get-balance 'SP1GZQJR3PDKTHYRJ5KCXYWYTPWXRVHQEED86P2TP) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u8) 'SP1GM28D4X7M6P516BE6QGNVHYDNB4F5SC48VK5BM))
      (map-set token-count 'SP1GM28D4X7M6P516BE6QGNVHYDNB4F5SC48VK5BM (+ (get-balance 'SP1GM28D4X7M6P516BE6QGNVHYDNB4F5SC48VK5BM) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u9) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u10) 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ))
      (map-set token-count 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ (+ (get-balance 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u11) 'SP3GA9N7Q1JZWAT8B0F7N8QXVDPYA6TQ8C1Q05HSW))
      (map-set token-count 'SP3GA9N7Q1JZWAT8B0F7N8QXVDPYA6TQ8C1Q05HSW (+ (get-balance 'SP3GA9N7Q1JZWAT8B0F7N8QXVDPYA6TQ8C1Q05HSW) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u12) 'SP10VZPY1AG63J0F3VD957SF8FNSVWBY3PV2ESVAC))
      (map-set token-count 'SP10VZPY1AG63J0F3VD957SF8FNSVWBY3PV2ESVAC (+ (get-balance 'SP10VZPY1AG63J0F3VD957SF8FNSVWBY3PV2ESVAC) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u13) 'SP24YFCR1H3KC6FD49GBDG0CRDR2WGHG9DB97YDD6))
      (map-set token-count 'SP24YFCR1H3KC6FD49GBDG0CRDR2WGHG9DB97YDD6 (+ (get-balance 'SP24YFCR1H3KC6FD49GBDG0CRDR2WGHG9DB97YDD6) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u14) 'SP3NGPFXYV23XYFEF8BFG0M6X51H967PJCTJ93NEM))
      (map-set token-count 'SP3NGPFXYV23XYFEF8BFG0M6X51H967PJCTJ93NEM (+ (get-balance 'SP3NGPFXYV23XYFEF8BFG0M6X51H967PJCTJ93NEM) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u15) 'SP2C2EGS52E16KA6SJFZGQDD9KZXPVAAS5PXFR39X))
      (map-set token-count 'SP2C2EGS52E16KA6SJFZGQDD9KZXPVAAS5PXFR39X (+ (get-balance 'SP2C2EGS52E16KA6SJFZGQDD9KZXPVAAS5PXFR39X) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u16) 'SP1NPDHF9CQ8B9Q045CCQS1MR9M9SGJ5TT6WFFCD2))
      (map-set token-count 'SP1NPDHF9CQ8B9Q045CCQS1MR9M9SGJ5TT6WFFCD2 (+ (get-balance 'SP1NPDHF9CQ8B9Q045CCQS1MR9M9SGJ5TT6WFFCD2) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u17) 'SP16SRR777TVB1WS5XSS9QT3YEZEC9JQFKYZENRAJ))
      (map-set token-count 'SP16SRR777TVB1WS5XSS9QT3YEZEC9JQFKYZENRAJ (+ (get-balance 'SP16SRR777TVB1WS5XSS9QT3YEZEC9JQFKYZENRAJ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u18) 'SM2J5VCY4DCFX6VZYDANHMXA3VN9DMWYCEK7Y8D93))
      (map-set token-count 'SM2J5VCY4DCFX6VZYDANHMXA3VN9DMWYCEK7Y8D93 (+ (get-balance 'SM2J5VCY4DCFX6VZYDANHMXA3VN9DMWYCEK7Y8D93) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u19) 'SP2J43W4ZJED1HJ117PYEPW0GBK67DR40Z3AXVZA9))
      (map-set token-count 'SP2J43W4ZJED1HJ117PYEPW0GBK67DR40Z3AXVZA9 (+ (get-balance 'SP2J43W4ZJED1HJ117PYEPW0GBK67DR40Z3AXVZA9) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u20) 'SP1731QPHJ6ER0N3PMPH8BB3354PFPK9PNVMXV99P))
      (map-set token-count 'SP1731QPHJ6ER0N3PMPH8BB3354PFPK9PNVMXV99P (+ (get-balance 'SP1731QPHJ6ER0N3PMPH8BB3354PFPK9PNVMXV99P) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u21) 'SP3MYTHK18PMGCDN6EG9Y4XN13FA87NMZRDZST0XN))
      (map-set token-count 'SP3MYTHK18PMGCDN6EG9Y4XN13FA87NMZRDZST0XN (+ (get-balance 'SP3MYTHK18PMGCDN6EG9Y4XN13FA87NMZRDZST0XN) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u22) 'SP3ANWNWTHJAH4E1WNQ9RT7V07ERJN5S4DA7X6XEW))
      (map-set token-count 'SP3ANWNWTHJAH4E1WNQ9RT7V07ERJN5S4DA7X6XEW (+ (get-balance 'SP3ANWNWTHJAH4E1WNQ9RT7V07ERJN5S4DA7X6XEW) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u23) 'SP1NP36KD0PWVPZP56XB8ECB6M6ZEF21731SA0SXR))
      (map-set token-count 'SP1NP36KD0PWVPZP56XB8ECB6M6ZEF21731SA0SXR (+ (get-balance 'SP1NP36KD0PWVPZP56XB8ECB6M6ZEF21731SA0SXR) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u24) 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9))
      (map-set token-count 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9 (+ (get-balance 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u25) 'SP3SWCB67W8ZRS06FZA43JZ5KQZQWMQ7TH2BEGPXZ))
      (map-set token-count 'SP3SWCB67W8ZRS06FZA43JZ5KQZQWMQ7TH2BEGPXZ (+ (get-balance 'SP3SWCB67W8ZRS06FZA43JZ5KQZQWMQ7TH2BEGPXZ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u26) 'SP41EESY6S3Y9XYAVBAE8RGQ3QJPG86PRXBATZAQ))
      (map-set token-count 'SP41EESY6S3Y9XYAVBAE8RGQ3QJPG86PRXBATZAQ (+ (get-balance 'SP41EESY6S3Y9XYAVBAE8RGQ3QJPG86PRXBATZAQ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u27) 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR))
      (map-set token-count 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR (+ (get-balance 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u28) 'SP1MGBEQ6G2QNCMF2AT8534YAB1VNQG93727JEH7T))
      (map-set token-count 'SP1MGBEQ6G2QNCMF2AT8534YAB1VNQG93727JEH7T (+ (get-balance 'SP1MGBEQ6G2QNCMF2AT8534YAB1VNQG93727JEH7T) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u29) 'SP3MN0F6BEVDV734H3ZW2MM0PVZDZWBXBNKEJHJXN))
      (map-set token-count 'SP3MN0F6BEVDV734H3ZW2MM0PVZDZWBXBNKEJHJXN (+ (get-balance 'SP3MN0F6BEVDV734H3ZW2MM0PVZDZWBXBNKEJHJXN) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u30) 'SP1SFDWHQ3TJK5G4QPCPPPJBZ42SK8SX3YE43SJZC))
      (map-set token-count 'SP1SFDWHQ3TJK5G4QPCPPPJBZ42SK8SX3YE43SJZC (+ (get-balance 'SP1SFDWHQ3TJK5G4QPCPPPJBZ42SK8SX3YE43SJZC) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u31) 'SP2ZQ2WDFFAGAS3E0FVXV6NDRZW938PT6ZZQ5PMQK))
      (map-set token-count 'SP2ZQ2WDFFAGAS3E0FVXV6NDRZW938PT6ZZQ5PMQK (+ (get-balance 'SP2ZQ2WDFFAGAS3E0FVXV6NDRZW938PT6ZZQ5PMQK) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u32) 'SP29D6YMDNAKN1P045T6Z817RTE1AC0JAA99WAX2B))
      (map-set token-count 'SP29D6YMDNAKN1P045T6Z817RTE1AC0JAA99WAX2B (+ (get-balance 'SP29D6YMDNAKN1P045T6Z817RTE1AC0JAA99WAX2B) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u33) 'SP33DNHJ2P3XCB5R5JF0TCA6R8ATG7NJCV3D4R5T2))
      (map-set token-count 'SP33DNHJ2P3XCB5R5JF0TCA6R8ATG7NJCV3D4R5T2 (+ (get-balance 'SP33DNHJ2P3XCB5R5JF0TCA6R8ATG7NJCV3D4R5T2) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u34) 'SP16S6ERS7A02GPK9RP6ZXH7E4SWJ4QJYWHC7JB89))
      (map-set token-count 'SP16S6ERS7A02GPK9RP6ZXH7E4SWJ4QJYWHC7JB89 (+ (get-balance 'SP16S6ERS7A02GPK9RP6ZXH7E4SWJ4QJYWHC7JB89) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u35) 'SP1HWC9R4PD6RR2N399FZS79K3GXNAHT8FRN3NA7J))
      (map-set token-count 'SP1HWC9R4PD6RR2N399FZS79K3GXNAHT8FRN3NA7J (+ (get-balance 'SP1HWC9R4PD6RR2N399FZS79K3GXNAHT8FRN3NA7J) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u36) 'SM2J5VCY4DCFX6VZYDANHMXA3VN9DMWYCEK7Y8D93))
      (map-set token-count 'SM2J5VCY4DCFX6VZYDANHMXA3VN9DMWYCEK7Y8D93 (+ (get-balance 'SM2J5VCY4DCFX6VZYDANHMXA3VN9DMWYCEK7Y8D93) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u37) 'SP3KVRE3RDYYSJ3JDGXKA0K15CC4JEA2ZGX4TJ5EC))
      (map-set token-count 'SP3KVRE3RDYYSJ3JDGXKA0K15CC4JEA2ZGX4TJ5EC (+ (get-balance 'SP3KVRE3RDYYSJ3JDGXKA0K15CC4JEA2ZGX4TJ5EC) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u38) 'SP1VYA8Q1XPNH01BEZXYPN2M4S9NVREQAEFGPX446))
      (map-set token-count 'SP1VYA8Q1XPNH01BEZXYPN2M4S9NVREQAEFGPX446 (+ (get-balance 'SP1VYA8Q1XPNH01BEZXYPN2M4S9NVREQAEFGPX446) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u39) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u40) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u41) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u42) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u43) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u44) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u45) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u46) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u47) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u48) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u49) 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY))
      (map-set token-count 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY (+ (get-balance 'SP1NDRJFW0KK0H11RFPFGNC7R1JS7Q454DKGQ09MY) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u50) 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ))
      (map-set token-count 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ (+ (get-balance 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u51) 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ))
      (map-set token-count 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ (+ (get-balance 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u52) 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ))
      (map-set token-count 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ (+ (get-balance 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u53) 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ))
      (map-set token-count 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ (+ (get-balance 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u54) 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ))
      (map-set token-count 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ (+ (get-balance 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u55) 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ))
      (map-set token-count 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ (+ (get-balance 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u56) 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ))
      (map-set token-count 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ (+ (get-balance 'SP3BK84YKXCHSSXV1PGJVEKJMH9XW6JSXF1PKVYRQ) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u57) 'SP3DHAND5K2WR8PEJN5F7P7B8YH3MJ1HQ3FX7M85Z))
      (map-set token-count 'SP3DHAND5K2WR8PEJN5F7P7B8YH3MJ1HQ3FX7M85Z (+ (get-balance 'SP3DHAND5K2WR8PEJN5F7P7B8YH3MJ1HQ3FX7M85Z) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u58) 'SPAHTV25EDZPSFPSH3DGKN0ANRSDMEHYFVA1CS3N))
      (map-set token-count 'SPAHTV25EDZPSFPSH3DGKN0ANRSDMEHYFVA1CS3N (+ (get-balance 'SPAHTV25EDZPSFPSH3DGKN0ANRSDMEHYFVA1CS3N) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u59) 'SP10VZPY1AG63J0F3VD957SF8FNSVWBY3PV2ESVAC))
      (map-set token-count 'SP10VZPY1AG63J0F3VD957SF8FNSVWBY3PV2ESVAC (+ (get-balance 'SP10VZPY1AG63J0F3VD957SF8FNSVWBY3PV2ESVAC) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u60) 'SP3NGPFXYV23XYFEF8BFG0M6X51H967PJCTJ93NEM))
      (map-set token-count 'SP3NGPFXYV23XYFEF8BFG0M6X51H967PJCTJ93NEM (+ (get-balance 'SP3NGPFXYV23XYFEF8BFG0M6X51H967PJCTJ93NEM) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u61) 'SP8KEMJYB3MHFKMYVHSR3634PHQYBKAFG0EXJRFD))
      (map-set token-count 'SP8KEMJYB3MHFKMYVHSR3634PHQYBKAFG0EXJRFD (+ (get-balance 'SP8KEMJYB3MHFKMYVHSR3634PHQYBKAFG0EXJRFD) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u62) 'SP224RAWAT8RR2XKYJQZGK1HGX67XJFECV3C0TFH2))
      (map-set token-count 'SP224RAWAT8RR2XKYJQZGK1HGX67XJFECV3C0TFH2 (+ (get-balance 'SP224RAWAT8RR2XKYJQZGK1HGX67XJFECV3C0TFH2) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u63) 'SP280DM0CJ9YS8RZV7SXN11PHZGQPN0F162T65Z7V))
      (map-set token-count 'SP280DM0CJ9YS8RZV7SXN11PHZGQPN0F162T65Z7V (+ (get-balance 'SP280DM0CJ9YS8RZV7SXN11PHZGQPN0F162T65Z7V) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u64) 'SPKD3K7TSYP7XWTPA0WM7YCBH0614RA276FPA8ZC))
      (map-set token-count 'SPKD3K7TSYP7XWTPA0WM7YCBH0614RA276FPA8ZC (+ (get-balance 'SPKD3K7TSYP7XWTPA0WM7YCBH0614RA276FPA8ZC) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u65) 'SP3658EQDEKG3RYGVE4H1KC3PAS8MRJCXPJN7CYHC))
      (map-set token-count 'SP3658EQDEKG3RYGVE4H1KC3PAS8MRJCXPJN7CYHC (+ (get-balance 'SP3658EQDEKG3RYGVE4H1KC3PAS8MRJCXPJN7CYHC) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u66) 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K))
      (map-set token-count 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K (+ (get-balance 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u67) 'SP365TEC0ZRKT68PAX2SE8FNS8DC6P63BZTG1S7Y8))
      (map-set token-count 'SP365TEC0ZRKT68PAX2SE8FNS8DC6P63BZTG1S7Y8 (+ (get-balance 'SP365TEC0ZRKT68PAX2SE8FNS8DC6P63BZTG1S7Y8) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u68) 'SP2XBRCMNEZKDT5G2CVB8EXE4K9WZGJVB374XHSMX))
      (map-set token-count 'SP2XBRCMNEZKDT5G2CVB8EXE4K9WZGJVB374XHSMX (+ (get-balance 'SP2XBRCMNEZKDT5G2CVB8EXE4K9WZGJVB374XHSMX) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u69) 'SP27YJ4ATAB5WK4SP3ZESV2AXXGSTNJT9HMFEKS0N))
      (map-set token-count 'SP27YJ4ATAB5WK4SP3ZESV2AXXGSTNJT9HMFEKS0N (+ (get-balance 'SP27YJ4ATAB5WK4SP3ZESV2AXXGSTNJT9HMFEKS0N) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u70) 'SP1B91MKXWMBQP50YWCNR08XZKBJJVSJRHB72SBX))
      (map-set token-count 'SP1B91MKXWMBQP50YWCNR08XZKBJJVSJRHB72SBX (+ (get-balance 'SP1B91MKXWMBQP50YWCNR08XZKBJJVSJRHB72SBX) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u71) 'SP2HP9HA7VHW1D1Y0XEG0CJPC3A883R70T6JKK103))
      (map-set token-count 'SP2HP9HA7VHW1D1Y0XEG0CJPC3A883R70T6JKK103 (+ (get-balance 'SP2HP9HA7VHW1D1Y0XEG0CJPC3A883R70T6JKK103) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u72) 'SP1REGTTRBMCV355TCW4C5V2ZC8EVA9YV58P9HY9K))
      (map-set token-count 'SP1REGTTRBMCV355TCW4C5V2ZC8EVA9YV58P9HY9K (+ (get-balance 'SP1REGTTRBMCV355TCW4C5V2ZC8EVA9YV58P9HY9K) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u73) 'SP3YXRZYQZYJ7T8SFJ52YXNSEW7JFSGP6FDMCGCDP))
      (map-set token-count 'SP3YXRZYQZYJ7T8SFJ52YXNSEW7JFSGP6FDMCGCDP (+ (get-balance 'SP3YXRZYQZYJ7T8SFJ52YXNSEW7JFSGP6FDMCGCDP) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u74) 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9))
      (map-set token-count 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9 (+ (get-balance 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u75) 'SP27D7NSM1XHD96K2T2VFF8CER6G029CJB75XC51M))
      (map-set token-count 'SP27D7NSM1XHD96K2T2VFF8CER6G029CJB75XC51M (+ (get-balance 'SP27D7NSM1XHD96K2T2VFF8CER6G029CJB75XC51M) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u76) 'SP1G33VQSPNQAEGY3ZYQMWGT75XMT884640KACR9H))
      (map-set token-count 'SP1G33VQSPNQAEGY3ZYQMWGT75XMT884640KACR9H (+ (get-balance 'SP1G33VQSPNQAEGY3ZYQMWGT75XMT884640KACR9H) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u77) 'SP238D2Z7EJH9XVVX6DQYAS1Q0SP7XZ390RAPHWRM))
      (map-set token-count 'SP238D2Z7EJH9XVVX6DQYAS1Q0SP7XZ390RAPHWRM (+ (get-balance 'SP238D2Z7EJH9XVVX6DQYAS1Q0SP7XZ390RAPHWRM) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u78) 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP))
      (map-set token-count 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP (+ (get-balance 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP) u1))
      (try! (nft-mint? ccc-return-of-bpepe-by-n0b0dyfamous (+ last-nft-id u79) 'SP1XWA2E2XCC4EMNQ44AJT20QK0FA6Y1ANEHW6Q5C))
      (map-set token-count 'SP1XWA2E2XCC4EMNQ44AJT20QK0FA6Y1ANEHW6Q5C (+ (get-balance 'SP1XWA2E2XCC4EMNQ44AJT20QK0FA6Y1ANEHW6Q5C) u1))

      (var-set last-id (+ last-nft-id u80))
      (var-set airdrop-called true)
      (ok true))))
```
