;; hallways
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token hallways uint)

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
(define-data-var mint-limit uint u500)
(define-data-var last-id uint u1)
(define-data-var total-price uint u3000000)
(define-data-var artist-address principal 'SP1T78J8434G726CJ8CRZN2SMPCVV63MW1RZ118Z7)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmZa51EyKfGAeehg2gNpcLWg7UUSfjWBKx1z6SnLQT9hai/")
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

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-five) (mint (list true true true true true)))

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
      (unwrap! (nft-mint? hallways next-id tx-sender) next-id)
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
    (nft-burn? hallways token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? hallways token-id) false)))

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
  (ok (nft-get-owner? hallways token-id)))

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
  (match (nft-transfer? hallways id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? hallways id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? hallways id) (err ERR-NOT-FOUND)))
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

(define-public (pay (id uint) (price uint)) 
    (begin 
        ;; First Artist (34%)
        (try! (stx-transfer? (/ (* price u3400) u10000) tx-sender 'SP1T78J8434G726CJ8CRZN2SMPCVV63MW1RZ118Z7))

        ;; Second Artist (32%)
        (try! (stx-transfer? (/ (* price u3200) u10000) tx-sender 'SP21PHVD191WXY02NT1XZS4T25N1Q9X9KAB8BWS6Y))

        ;; Third Artist (32%)
        (try! (stx-transfer? (/ (* price u3200) u10000) tx-sender 'SP2W0F9A86JPJ2TY34317QDG96SSX6ZDDK75XX4VX))

        ;; Developer (2%)
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP1F3YK0PG6F1P9WM9CB0HM39PE6H0CM8DWY02NXY))

        (ok true)
    )
)
    
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
      (try! (nft-mint? hallways (+ last-nft-id u0) 'SP2C20XGZBAYFZ1NYNHT1J6MGMM0EW9X7PFBWK7QG))
      (map-set token-count 'SP2C20XGZBAYFZ1NYNHT1J6MGMM0EW9X7PFBWK7QG (+ (get-balance 'SP2C20XGZBAYFZ1NYNHT1J6MGMM0EW9X7PFBWK7QG) u1))
      (try! (nft-mint? hallways (+ last-nft-id u1) 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN))
      (map-set token-count 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN (+ (get-balance 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN) u1))
      (try! (nft-mint? hallways (+ last-nft-id u2) 'SP1T78J8434G726CJ8CRZN2SMPCVV63MW1RZ118Z7))
      (map-set token-count 'SP1T78J8434G726CJ8CRZN2SMPCVV63MW1RZ118Z7 (+ (get-balance 'SP1T78J8434G726CJ8CRZN2SMPCVV63MW1RZ118Z7) u1))
      (try! (nft-mint? hallways (+ last-nft-id u3) 'SP2DCFHTZSY5YKSRHC7YRD1AD6HRA9CBZENCM4NGV))
      (map-set token-count 'SP2DCFHTZSY5YKSRHC7YRD1AD6HRA9CBZENCM4NGV (+ (get-balance 'SP2DCFHTZSY5YKSRHC7YRD1AD6HRA9CBZENCM4NGV) u1))
      (try! (nft-mint? hallways (+ last-nft-id u4) 'SPYZ9RXB9PQRRK30FS587NV973JH60RGFR5SNPGK))
      (map-set token-count 'SPYZ9RXB9PQRRK30FS587NV973JH60RGFR5SNPGK (+ (get-balance 'SPYZ9RXB9PQRRK30FS587NV973JH60RGFR5SNPGK) u1))
      (try! (nft-mint? hallways (+ last-nft-id u5) 'SP2RFGZ9WWXV3CZAR9QR94FHJ1WVZ59SF8J6QEA0C))
      (map-set token-count 'SP2RFGZ9WWXV3CZAR9QR94FHJ1WVZ59SF8J6QEA0C (+ (get-balance 'SP2RFGZ9WWXV3CZAR9QR94FHJ1WVZ59SF8J6QEA0C) u1))
      (try! (nft-mint? hallways (+ last-nft-id u6) 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8))
      (map-set token-count 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8 (+ (get-balance 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8) u1))
      (try! (nft-mint? hallways (+ last-nft-id u7) 'SP2BJ0RE1JX3X7158KSY6VR4DVD364AS5X6V5E8SH))
      (map-set token-count 'SP2BJ0RE1JX3X7158KSY6VR4DVD364AS5X6V5E8SH (+ (get-balance 'SP2BJ0RE1JX3X7158KSY6VR4DVD364AS5X6V5E8SH) u1))
      (try! (nft-mint? hallways (+ last-nft-id u8) 'SP285FVD7DDYBFHVM25HEQVR6XRM9GBP9SHK5RBYP))
      (map-set token-count 'SP285FVD7DDYBFHVM25HEQVR6XRM9GBP9SHK5RBYP (+ (get-balance 'SP285FVD7DDYBFHVM25HEQVR6XRM9GBP9SHK5RBYP) u1))
      (try! (nft-mint? hallways (+ last-nft-id u9) 'SP30Y7Z13N2H2RW0NAQNVZT6261QA6JJ7KR9578BE))
      (map-set token-count 'SP30Y7Z13N2H2RW0NAQNVZT6261QA6JJ7KR9578BE (+ (get-balance 'SP30Y7Z13N2H2RW0NAQNVZT6261QA6JJ7KR9578BE) u1))
      (try! (nft-mint? hallways (+ last-nft-id u10) 'SP3A8AVK2R7KKQ5E8Q1REHNS7WSNPZR3PGVVREAQS))
      (map-set token-count 'SP3A8AVK2R7KKQ5E8Q1REHNS7WSNPZR3PGVVREAQS (+ (get-balance 'SP3A8AVK2R7KKQ5E8Q1REHNS7WSNPZR3PGVVREAQS) u1))
      (try! (nft-mint? hallways (+ last-nft-id u11) 'SPBQ3VHZAXDP7BFH2C5DSNN7XZFP3E5GDEF5JYPJ))
      (map-set token-count 'SPBQ3VHZAXDP7BFH2C5DSNN7XZFP3E5GDEF5JYPJ (+ (get-balance 'SPBQ3VHZAXDP7BFH2C5DSNN7XZFP3E5GDEF5JYPJ) u1))
      (try! (nft-mint? hallways (+ last-nft-id u12) 'SP3C21854QXS876FKET64QWAK46DFA0FGG49RC984))
      (map-set token-count 'SP3C21854QXS876FKET64QWAK46DFA0FGG49RC984 (+ (get-balance 'SP3C21854QXS876FKET64QWAK46DFA0FGG49RC984) u1))
      (try! (nft-mint? hallways (+ last-nft-id u13) 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR))
      (map-set token-count 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR (+ (get-balance 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR) u1))
      (try! (nft-mint? hallways (+ last-nft-id u14) 'SP3MJ27QVV5ZZ9YWZFF2TW27FC2KVNNFKK6TCSWAA))
      (map-set token-count 'SP3MJ27QVV5ZZ9YWZFF2TW27FC2KVNNFKK6TCSWAA (+ (get-balance 'SP3MJ27QVV5ZZ9YWZFF2TW27FC2KVNNFKK6TCSWAA) u1))
      (try! (nft-mint? hallways (+ last-nft-id u15) 'SP20945N5G0F0V9AZCAHEC1GS3C1S2RWT325H9N0K))
      (map-set token-count 'SP20945N5G0F0V9AZCAHEC1GS3C1S2RWT325H9N0K (+ (get-balance 'SP20945N5G0F0V9AZCAHEC1GS3C1S2RWT325H9N0K) u1))
      (try! (nft-mint? hallways (+ last-nft-id u16) 'SPP90JN2DSY4PHMKG613G3163A5VEQSN2KB2FAHP))
      (map-set token-count 'SPP90JN2DSY4PHMKG613G3163A5VEQSN2KB2FAHP (+ (get-balance 'SPP90JN2DSY4PHMKG613G3163A5VEQSN2KB2FAHP) u1))
      (try! (nft-mint? hallways (+ last-nft-id u17) 'SP1X9WS1VTYBV9MR0YR0X8934C9575K1X3Q6YSTH9))
      (map-set token-count 'SP1X9WS1VTYBV9MR0YR0X8934C9575K1X3Q6YSTH9 (+ (get-balance 'SP1X9WS1VTYBV9MR0YR0X8934C9575K1X3Q6YSTH9) u1))
      (try! (nft-mint? hallways (+ last-nft-id u18) 'SP1G587Z50B7SXCWHDA5WPKYV9RDFDV93TQ2VH58Z))
      (map-set token-count 'SP1G587Z50B7SXCWHDA5WPKYV9RDFDV93TQ2VH58Z (+ (get-balance 'SP1G587Z50B7SXCWHDA5WPKYV9RDFDV93TQ2VH58Z) u1))
      (try! (nft-mint? hallways (+ last-nft-id u19) 'SPSGP0XHF7VFJQ5193N2SV9MY87EWGVJXAZK35K2))
      (map-set token-count 'SPSGP0XHF7VFJQ5193N2SV9MY87EWGVJXAZK35K2 (+ (get-balance 'SPSGP0XHF7VFJQ5193N2SV9MY87EWGVJXAZK35K2) u1))
      (try! (nft-mint? hallways (+ last-nft-id u20) 'SP228WEAEMYX21RW0TT5T38THPNDYPPGGVW2RP570))
      (map-set token-count 'SP228WEAEMYX21RW0TT5T38THPNDYPPGGVW2RP570 (+ (get-balance 'SP228WEAEMYX21RW0TT5T38THPNDYPPGGVW2RP570) u1))
      (try! (nft-mint? hallways (+ last-nft-id u21) 'SP2JZRS8TF894NNJFVAAD06ZDC5XG0R5N33HSH4QM))
      (map-set token-count 'SP2JZRS8TF894NNJFVAAD06ZDC5XG0R5N33HSH4QM (+ (get-balance 'SP2JZRS8TF894NNJFVAAD06ZDC5XG0R5N33HSH4QM) u1))
      (try! (nft-mint? hallways (+ last-nft-id u22) 'SPRN60C5X6J4HBQPSHAD76JTDMACGE6NJ8T4WDS1))
      (map-set token-count 'SPRN60C5X6J4HBQPSHAD76JTDMACGE6NJ8T4WDS1 (+ (get-balance 'SPRN60C5X6J4HBQPSHAD76JTDMACGE6NJ8T4WDS1) u1))
      (try! (nft-mint? hallways (+ last-nft-id u23) 'SP2XNHZTGFWJ73W2NW6PJ2MJ53WY7X5Y7QE9PB4Z))
      (map-set token-count 'SP2XNHZTGFWJ73W2NW6PJ2MJ53WY7X5Y7QE9PB4Z (+ (get-balance 'SP2XNHZTGFWJ73W2NW6PJ2MJ53WY7X5Y7QE9PB4Z) u1))
      (try! (nft-mint? hallways (+ last-nft-id u24) 'SP7QQ9DV0DMV7YW4HR713MKBWADVA0BFC2J65PJT))
      (map-set token-count 'SP7QQ9DV0DMV7YW4HR713MKBWADVA0BFC2J65PJT (+ (get-balance 'SP7QQ9DV0DMV7YW4HR713MKBWADVA0BFC2J65PJT) u1))
      (try! (nft-mint? hallways (+ last-nft-id u25) 'SP284D73FSY8R7KPBFQ8QCY9TPN7BRE1ZGZ5MDX9T))
      (map-set token-count 'SP284D73FSY8R7KPBFQ8QCY9TPN7BRE1ZGZ5MDX9T (+ (get-balance 'SP284D73FSY8R7KPBFQ8QCY9TPN7BRE1ZGZ5MDX9T) u1))

      (var-set last-id (+ last-nft-id u26))
      (var-set airdrop-called true)
      (ok true))))