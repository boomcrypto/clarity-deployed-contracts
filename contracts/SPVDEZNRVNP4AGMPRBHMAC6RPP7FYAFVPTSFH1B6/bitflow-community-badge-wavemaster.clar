;; bitflow-community-badge-wavemaster
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token bitflow-community-badge-wavemaster uint)

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
(define-data-var mint-limit uint u30)
(define-data-var last-id uint u1)
(define-data-var total-price uint u21000000000000)
(define-data-var artist-address principal 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmVU89JXCF9DHHooRQStEfc9qfp2BCASmdR4bqDMdoDVjD/")
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
      (unwrap! (nft-mint? bitflow-community-badge-wavemaster next-id tx-sender) next-id)
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
    (nft-burn? bitflow-community-badge-wavemaster token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? bitflow-community-badge-wavemaster token-id) false)))

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
  (ok (nft-get-owner? bitflow-community-badge-wavemaster token-id)))

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
  (match (nft-transfer? bitflow-community-badge-wavemaster id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? bitflow-community-badge-wavemaster id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? bitflow-community-badge-wavemaster id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u0) 'SP2QKGSF0ZD334MEKYRJZS5RBRPZB6QSJWETAXP75))
      (map-set token-count 'SP2QKGSF0ZD334MEKYRJZS5RBRPZB6QSJWETAXP75 (+ (get-balance 'SP2QKGSF0ZD334MEKYRJZS5RBRPZB6QSJWETAXP75) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u1) 'SP20P9R0ACZWJ6F2SG9QEKXF5F1QATGY003ZTN7Z4))
      (map-set token-count 'SP20P9R0ACZWJ6F2SG9QEKXF5F1QATGY003ZTN7Z4 (+ (get-balance 'SP20P9R0ACZWJ6F2SG9QEKXF5F1QATGY003ZTN7Z4) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u2) 'SP3FC6SB8Y4XWGKN6RWWNYB37QSP2046P47MDDP0X))
      (map-set token-count 'SP3FC6SB8Y4XWGKN6RWWNYB37QSP2046P47MDDP0X (+ (get-balance 'SP3FC6SB8Y4XWGKN6RWWNYB37QSP2046P47MDDP0X) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u3) 'SP28Q4T5Z1FZAR6ZYZASQB04YSYP456QXJ09W6H1N))
      (map-set token-count 'SP28Q4T5Z1FZAR6ZYZASQB04YSYP456QXJ09W6H1N (+ (get-balance 'SP28Q4T5Z1FZAR6ZYZASQB04YSYP456QXJ09W6H1N) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u4) 'ST29NYBF43398HTC1GS57N2XVTH2X6PW29VAFP8JP))
      (map-set token-count 'ST29NYBF43398HTC1GS57N2XVTH2X6PW29VAFP8JP (+ (get-balance 'ST29NYBF43398HTC1GS57N2XVTH2X6PW29VAFP8JP) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u5) 'SP2DB1N7B0F08EP6K0SKHNGWK4F0E4S43CW23711S))
      (map-set token-count 'SP2DB1N7B0F08EP6K0SKHNGWK4F0E4S43CW23711S (+ (get-balance 'SP2DB1N7B0F08EP6K0SKHNGWK4F0E4S43CW23711S) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u6) 'STD7C0DVXEF7Z2D6QJHVEWJMVQS866K6XQW9FY5F))
      (map-set token-count 'STD7C0DVXEF7Z2D6QJHVEWJMVQS866K6XQW9FY5F (+ (get-balance 'STD7C0DVXEF7Z2D6QJHVEWJMVQS866K6XQW9FY5F) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u7) 'ST3SRTYNG8ZBKNZ1N32VZXG12RBRHVD6KKGH0CY1))
      (map-set token-count 'ST3SRTYNG8ZBKNZ1N32VZXG12RBRHVD6KKGH0CY1 (+ (get-balance 'ST3SRTYNG8ZBKNZ1N32VZXG12RBRHVD6KKGH0CY1) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u8) 'SPMN4QFY3QVD6JFC7YKX0C1KBKAKYQQKYG68F1KF))
      (map-set token-count 'SPMN4QFY3QVD6JFC7YKX0C1KBKAKYQQKYG68F1KF (+ (get-balance 'SPMN4QFY3QVD6JFC7YKX0C1KBKAKYQQKYG68F1KF) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u9) 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV))
      (map-set token-count 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV (+ (get-balance 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u10) 'SP14SVKN6YBXME46X29QJRFTP93PT531SFR2DZ4ZC))
      (map-set token-count 'SP14SVKN6YBXME46X29QJRFTP93PT531SFR2DZ4ZC (+ (get-balance 'SP14SVKN6YBXME46X29QJRFTP93PT531SFR2DZ4ZC) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u11) 'SP8W4Z1JDSY7V7RGX0K390W67XCF4RMSYM4741ER))
      (map-set token-count 'SP8W4Z1JDSY7V7RGX0K390W67XCF4RMSYM4741ER (+ (get-balance 'SP8W4Z1JDSY7V7RGX0K390W67XCF4RMSYM4741ER) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u12) 'SP1PZDF5ZV48AK0YSJ18VV9C0W9J1NWE5H2K1DR4B))
      (map-set token-count 'SP1PZDF5ZV48AK0YSJ18VV9C0W9J1NWE5H2K1DR4B (+ (get-balance 'SP1PZDF5ZV48AK0YSJ18VV9C0W9J1NWE5H2K1DR4B) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u13) 'SP2PB9G60BXVT0JD5JP6CWSMK24F75YTSAM7Q3CHF))
      (map-set token-count 'SP2PB9G60BXVT0JD5JP6CWSMK24F75YTSAM7Q3CHF (+ (get-balance 'SP2PB9G60BXVT0JD5JP6CWSMK24F75YTSAM7Q3CHF) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u14) 'SP12ASG6PJT5VMQVEMXNMEM6D58B2SYRQR2RZAXK))
      (map-set token-count 'SP12ASG6PJT5VMQVEMXNMEM6D58B2SYRQR2RZAXK (+ (get-balance 'SP12ASG6PJT5VMQVEMXNMEM6D58B2SYRQR2RZAXK) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u15) 'SPWH3TWXJEE9FYFW03RR5DW66BTQC6VHQRF261YB))
      (map-set token-count 'SPWH3TWXJEE9FYFW03RR5DW66BTQC6VHQRF261YB (+ (get-balance 'SPWH3TWXJEE9FYFW03RR5DW66BTQC6VHQRF261YB) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u16) 'SP32232RQ30MR1VFHHA9TM48BDM9E38DZZS54G87M))
      (map-set token-count 'SP32232RQ30MR1VFHHA9TM48BDM9E38DZZS54G87M (+ (get-balance 'SP32232RQ30MR1VFHHA9TM48BDM9E38DZZS54G87M) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u17) 'SPJ391F327B3MPA0KX29X2B16F6DQB8766BMMSH1))
      (map-set token-count 'SPJ391F327B3MPA0KX29X2B16F6DQB8766BMMSH1 (+ (get-balance 'SPJ391F327B3MPA0KX29X2B16F6DQB8766BMMSH1) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u18) 'SP1NJ1ARMDTYAFHP0EA5HNHM365XD0ZKCERSDKKXY))
      (map-set token-count 'SP1NJ1ARMDTYAFHP0EA5HNHM365XD0ZKCERSDKKXY (+ (get-balance 'SP1NJ1ARMDTYAFHP0EA5HNHM365XD0ZKCERSDKKXY) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u19) 'SP3S1GB9KPRMBEQEFY85A8C9AED6WFR24FV8FTM2Y))
      (map-set token-count 'SP3S1GB9KPRMBEQEFY85A8C9AED6WFR24FV8FTM2Y (+ (get-balance 'SP3S1GB9KPRMBEQEFY85A8C9AED6WFR24FV8FTM2Y) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u20) 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6))
      (map-set token-count 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6 (+ (get-balance 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u21) 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6))
      (map-set token-count 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6 (+ (get-balance 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u22) 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6))
      (map-set token-count 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6 (+ (get-balance 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u23) 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6))
      (map-set token-count 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6 (+ (get-balance 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u24) 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6))
      (map-set token-count 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6 (+ (get-balance 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u25) 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6))
      (map-set token-count 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6 (+ (get-balance 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u26) 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6))
      (map-set token-count 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6 (+ (get-balance 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u27) 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6))
      (map-set token-count 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6 (+ (get-balance 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u28) 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6))
      (map-set token-count 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6 (+ (get-balance 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6) u1))
      (try! (nft-mint? bitflow-community-badge-wavemaster (+ last-nft-id u29) 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6))
      (map-set token-count 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6 (+ (get-balance 'SPVDEZNRVNP4AGMPRBHMAC6RPP7FYAFVPTSFH1B6) u1))

      (var-set last-id (+ last-nft-id u30))
      (var-set airdrop-called true)
      (ok true))))