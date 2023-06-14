;; spaghettipunk-club
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token spaghettipunk-club uint)

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
(define-data-var mint-limit uint u5000)
(define-data-var last-id uint u1)
(define-data-var total-price uint u20000000)
(define-data-var artist-address principal 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmSFmPopzJwVuXfzLNqSnwjoKM5o8WgYtzyHpk7ocR6gon/json/")
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
      (unwrap! (nft-mint? spaghettipunk-club next-id tx-sender) next-id)
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
    (nft-burn? spaghettipunk-club token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? spaghettipunk-club token-id) false)))

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

(define-public (reveal-artwork (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))
;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? spaghettipunk-club token-id)))

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
  (match (nft-transfer? spaghettipunk-club id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? spaghettipunk-club id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? spaghettipunk-club id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV u2)
(map-set mint-passes 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 u2)
(map-set mint-passes 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2 u1)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u5)
(map-set mint-passes 'SP5GX6PQVGYQKBFA3E9EWWVPM65SN5Z0XDDX3YW7 u1)
(map-set mint-passes 'SP35T3VRATM64YWPVVTJJ494FY184MY7XBDRT668 u7)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u1)
(map-set mint-passes 'SP1R803WWC3G0HDEKTMBRRZ3PGNAGJCDCC2VHGBZ6 u2)
(map-set mint-passes 'SP3ST7HR5E29EGH299RYHEW85QMSH2PC3WTR5DJCG u3)
(map-set mint-passes 'SPXE4CC9QNP0VVVMWHQDAQ3DZ8WCFTV5J2RZWRM0 u5)
(map-set mint-passes 'SP3ZQ3PRK7K9YG2E1AA2F4KAV6TZ876XDEQQBBGDB u37)
(map-set mint-passes 'SP3ANMVKK0P1YT48CMYEBWRFKSEM1N212TB2A1P78 u44)
(map-set mint-passes 'SP14TMQH37FXX0XG577R6D3426SPX1QT0KMEG0ZXJ u50)
(map-set mint-passes 'SPM4JKECG23CJGXC93BDXX7579WVH5NR7E2XVC5H u4)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u59)
(map-set mint-passes 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH u30)
(map-set mint-passes 'SP23X8JVMHN2A9N1PWSGNW83Q0VV5T7NF2N6PJW9J u6)
(map-set mint-passes 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK u3)
(map-set mint-passes 'SP2KSNCT9MF74MFCXKDNDCAJ0B0CZ2JZQ20QBCX45 u3)
(map-set mint-passes 'SP1SPQDHQE82A51THD6944SPA9NNYBC92RTA6HXPN u2)
(map-set mint-passes 'SPRN8QHNVERT98BEJA3HF7BEXS081TTKV9D10EK0 u2)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u2)
(map-set mint-passes 'SP2QFXPC7ESM7NVPSP7M7M711VEJFE7GBASSJMRTP u2)
(map-set mint-passes 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE u12)
(map-set mint-passes 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY u10)
(map-set mint-passes 'SP9S3VNXYY7VSQPDJM5HD4GM1W0673Q76JB1CRCH u1)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u9)
(map-set mint-passes 'SP1YDPFN0ZXK9ZNVEC9YCG0MGY348HZWQK3EPNAMJ u4)
(map-set mint-passes 'SP138TF1WBX358512CJMG798SPS66JWSTVPF28V91 u34)
(map-set mint-passes 'SP10P039ZPEJ23HDX6TSZVZGY2Z0GDM4S8MGAV2R u28)
(map-set mint-passes 'SP3RK1EPV102CBAX8HFSER8ATH348HBCT04DCNSYR u19)
(map-set mint-passes 'SP1CQXBYR1FE2Z7CEVP23Z39WQ48KNAS2CV03GF3V u4)
(map-set mint-passes 'SP1Y6WNAE8YAYBH8T6NSR0THD9RKTJE07PWZCKP5J u3)
(map-set mint-passes 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99 u4)
(map-set mint-passes 'SP2XJCFE0MZB33AAP91ZY8TXJ03HMXCJPJD71AJCM u2)
(map-set mint-passes 'SP3BCKC9STZKCVBJRB3EFK86JEWVEJWYH7JRXG9Q u7)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u2)
(map-set mint-passes 'SPE9CQ6VBE2DER8MG4DJVZ9123CZM0QSVGWXSKWD u1)
(map-set mint-passes 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG u2)
(map-set mint-passes 'SP12YGGACNA4R43DB1HAQ3AE03PKPJGXZ1BX96CYB u37)
(map-set mint-passes 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR u2)
(map-set mint-passes 'SP2K5Q1QR0KARHB3749EFPNGGH0BC26A6M3X5851D u4)
(map-set mint-passes 'SP2CTPAPT2PHJ3ARMF5T2CZ7390HC0HAA77XSV09Z u5)
(map-set mint-passes 'SPAWG6BF0Q82RXB93XEZXG9N9K8M0VMWQW64XBDJ u6)
(map-set mint-passes 'SP1DQ7ES2N969X065V487N182Y2Y2XMSEPGV98CMT u5)
(map-set mint-passes 'SP6N3AKTPSW2EASH3H06ZJVH5376ASQHE5QS4V7A u3)
(map-set mint-passes 'SP2QEW9J463X22JFA3928HWAZC612GM571XPZWY2K u6)
(map-set mint-passes 'SP3Y6KWHW3JNZ41T5S4X5TWQEVZBEKS53019T5VSV u2)
(map-set mint-passes 'SP2HAX866JDGG352DGF3K83DW0X5M8D2F8P9MM3V8 u2)
(map-set mint-passes 'SP31ZMV9C7EB503DRPQD6AKGDRH2G5967F2PRPX5K u2)
(map-set mint-passes 'SP39Y32VB4JJ95D4NPBPWFBFQ50YTH5CQ7PE0HVKP u1)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u0) 'SP132QXWFJ11WWXPW4JBTM9FP6XE8MZWB8AF206FX))
      (map-set token-count 'SP132QXWFJ11WWXPW4JBTM9FP6XE8MZWB8AF206FX (+ (get-balance 'SP132QXWFJ11WWXPW4JBTM9FP6XE8MZWB8AF206FX) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u1) 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK))
      (map-set token-count 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK (+ (get-balance 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u2) 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99))
      (map-set token-count 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99 (+ (get-balance 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u3) 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV))
      (map-set token-count 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV (+ (get-balance 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u4) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u5) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u6) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u7) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u8) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u9) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u10) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u11) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u12) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u13) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u14) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u15) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u16) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u17) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u18) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u19) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u20) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u21) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u22) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u23) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u24) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u25) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u26) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u27) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u28) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? spaghettipunk-club (+ last-nft-id u29) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))

      (var-set last-id (+ last-nft-id u30))
      (var-set airdrop-called true)
      (ok true))))