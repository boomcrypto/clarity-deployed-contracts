;; the-hereafter
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token the-hereafter uint)

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
(define-data-var mint-limit uint u33)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmPgxDF86sweJDxrqsAZjcTnJUwHRyZgN65hqQoF6ohTah/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u1)

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
      (unwrap! (nft-mint? the-hereafter next-id tx-sender) next-id)
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
    (nft-burn? the-hereafter token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? the-hereafter token-id) false)))

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
  (ok (nft-get-owner? the-hereafter token-id)))

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
  (match (nft-transfer? the-hereafter id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? the-hereafter id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? the-hereafter id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? the-hereafter (+ last-nft-id u0) 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC))
      (map-set token-count 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC (+ (get-balance 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u1) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u2) 'SP3P08QBCVS8K93MDV8YVZ9H3009AC5B8TA67WG0N))
      (map-set token-count 'SP3P08QBCVS8K93MDV8YVZ9H3009AC5B8TA67WG0N (+ (get-balance 'SP3P08QBCVS8K93MDV8YVZ9H3009AC5B8TA67WG0N) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u3) 'SP1KJFMMT64ANCYR637SCZS6X5JGMX6M31X7NY8RW))
      (map-set token-count 'SP1KJFMMT64ANCYR637SCZS6X5JGMX6M31X7NY8RW (+ (get-balance 'SP1KJFMMT64ANCYR637SCZS6X5JGMX6M31X7NY8RW) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u4) 'SP1A7SMJX338P2RBNMEDEERDWPHZ8PJQ70J92YGHP))
      (map-set token-count 'SP1A7SMJX338P2RBNMEDEERDWPHZ8PJQ70J92YGHP (+ (get-balance 'SP1A7SMJX338P2RBNMEDEERDWPHZ8PJQ70J92YGHP) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u5) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u6) 'SPPAX6EMKH35PT8PR5RKA7DFWMXGAWA171TNFQF3))
      (map-set token-count 'SPPAX6EMKH35PT8PR5RKA7DFWMXGAWA171TNFQF3 (+ (get-balance 'SPPAX6EMKH35PT8PR5RKA7DFWMXGAWA171TNFQF3) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u7) 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P))
      (map-set token-count 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P (+ (get-balance 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u8) 'SP3XFSS6D2FPECBVVT9Z0VD2ZNBB2MV9FR8JCD7EN))
      (map-set token-count 'SP3XFSS6D2FPECBVVT9Z0VD2ZNBB2MV9FR8JCD7EN (+ (get-balance 'SP3XFSS6D2FPECBVVT9Z0VD2ZNBB2MV9FR8JCD7EN) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u9) 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP))
      (map-set token-count 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP (+ (get-balance 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u10) 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558))
      (map-set token-count 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558 (+ (get-balance 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u11) 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR))
      (map-set token-count 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR (+ (get-balance 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u12) 'SP377R6M98T0AC4MJZZFQ80DQX6AB1RFAY1WQK2D6))
      (map-set token-count 'SP377R6M98T0AC4MJZZFQ80DQX6AB1RFAY1WQK2D6 (+ (get-balance 'SP377R6M98T0AC4MJZZFQ80DQX6AB1RFAY1WQK2D6) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u13) 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC))
      (map-set token-count 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC (+ (get-balance 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u14) 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP))
      (map-set token-count 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP (+ (get-balance 'SPYD2E5MYVXE5V84BX8V202E5DD4R3D2X0V6D4XP) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u15) 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG))
      (map-set token-count 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG (+ (get-balance 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u16) 'SP1S2R6361HAWES48BG8F3QX1SEDS20BJREQDEGKX))
      (map-set token-count 'SP1S2R6361HAWES48BG8F3QX1SEDS20BJREQDEGKX (+ (get-balance 'SP1S2R6361HAWES48BG8F3QX1SEDS20BJREQDEGKX) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u17) 'SP2YJGGD8YZ5F0XZAXERZ0DDNYSGG7SJHTGG9MWV8))
      (map-set token-count 'SP2YJGGD8YZ5F0XZAXERZ0DDNYSGG7SJHTGG9MWV8 (+ (get-balance 'SP2YJGGD8YZ5F0XZAXERZ0DDNYSGG7SJHTGG9MWV8) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u18) 'SP1A7SMJX338P2RBNMEDEERDWPHZ8PJQ70J92YGHP))
      (map-set token-count 'SP1A7SMJX338P2RBNMEDEERDWPHZ8PJQ70J92YGHP (+ (get-balance 'SP1A7SMJX338P2RBNMEDEERDWPHZ8PJQ70J92YGHP) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u19) 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S))
      (map-set token-count 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S (+ (get-balance 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u20) 'SP1Q7ZQCCYNDVMP4ZS60KWQV24TZ3RNBER720FFZ3))
      (map-set token-count 'SP1Q7ZQCCYNDVMP4ZS60KWQV24TZ3RNBER720FFZ3 (+ (get-balance 'SP1Q7ZQCCYNDVMP4ZS60KWQV24TZ3RNBER720FFZ3) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u21) 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7))
      (map-set token-count 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 (+ (get-balance 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u22) 'SP293M874EPBS7H5EFF1DYAR3P5V1CNKVPK78GXG3))
      (map-set token-count 'SP293M874EPBS7H5EFF1DYAR3P5V1CNKVPK78GXG3 (+ (get-balance 'SP293M874EPBS7H5EFF1DYAR3P5V1CNKVPK78GXG3) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u23) 'SP1WWPJK6VVW4KW2XSTMQF17WXN8T5V81BSVSBXFB))
      (map-set token-count 'SP1WWPJK6VVW4KW2XSTMQF17WXN8T5V81BSVSBXFB (+ (get-balance 'SP1WWPJK6VVW4KW2XSTMQF17WXN8T5V81BSVSBXFB) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u24) 'SP1T78J8434G726CJ8CRZN2SMPCVV63MW1RZ118Z7))
      (map-set token-count 'SP1T78J8434G726CJ8CRZN2SMPCVV63MW1RZ118Z7 (+ (get-balance 'SP1T78J8434G726CJ8CRZN2SMPCVV63MW1RZ118Z7) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u25) 'SP3MPF5ZBRRJM7VP49DJGSDX8T0THCKGRQDJ2DDYR))
      (map-set token-count 'SP3MPF5ZBRRJM7VP49DJGSDX8T0THCKGRQDJ2DDYR (+ (get-balance 'SP3MPF5ZBRRJM7VP49DJGSDX8T0THCKGRQDJ2DDYR) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u26) 'SP1TRJR66FTZZGJWDG3ZK6VCS4SNQ10CHWTTMHMHZ))
      (map-set token-count 'SP1TRJR66FTZZGJWDG3ZK6VCS4SNQ10CHWTTMHMHZ (+ (get-balance 'SP1TRJR66FTZZGJWDG3ZK6VCS4SNQ10CHWTTMHMHZ) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u27) 'SP5DZEC4897YG12ZSYETN84AWX5TEANJHYZV15DJ))
      (map-set token-count 'SP5DZEC4897YG12ZSYETN84AWX5TEANJHYZV15DJ (+ (get-balance 'SP5DZEC4897YG12ZSYETN84AWX5TEANJHYZV15DJ) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u28) 'SP2QPKZPPEBZ7ZB7E558TTW15X75S9VDHC09M9SJF))
      (map-set token-count 'SP2QPKZPPEBZ7ZB7E558TTW15X75S9VDHC09M9SJF (+ (get-balance 'SP2QPKZPPEBZ7ZB7E558TTW15X75S9VDHC09M9SJF) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u29) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u30) 'SP23MDNANPJDANJ5ZBN8YJW9V6DRCGSENM9NHKDQK))
      (map-set token-count 'SP23MDNANPJDANJ5ZBN8YJW9V6DRCGSENM9NHKDQK (+ (get-balance 'SP23MDNANPJDANJ5ZBN8YJW9V6DRCGSENM9NHKDQK) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u31) 'SPRQC28KFS4QGSE5FCWF0Y6QFEANCGNXHX9YV341))
      (map-set token-count 'SPRQC28KFS4QGSE5FCWF0Y6QFEANCGNXHX9YV341 (+ (get-balance 'SPRQC28KFS4QGSE5FCWF0Y6QFEANCGNXHX9YV341) u1))
      (try! (nft-mint? the-hereafter (+ last-nft-id u32) 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S))
      (map-set token-count 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S (+ (get-balance 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S) u1))

      (var-set last-id (+ last-nft-id u33))
      (var-set airdrop-called true)
      (ok true))))