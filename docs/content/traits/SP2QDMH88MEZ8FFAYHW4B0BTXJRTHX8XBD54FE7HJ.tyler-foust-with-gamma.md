---
title: "Trait tyler-foust-with-gamma"
draft: true
---
```
;; tyler-foust-with-gamma

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token tyler-foust-with-gamma uint)

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
(define-data-var mint-limit uint u90)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmWqffxcAhrjxJjBDNQQiXL7ivP79F6Kjwat4LvimNVU9B/json/")
(define-data-var mint-paused bool true)
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
      (unwrap! (nft-mint? tyler-foust-with-gamma next-id tx-sender) next-id)
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
    (nft-burn? tyler-foust-with-gamma token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? tyler-foust-with-gamma token-id) false)))

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
  (ok (nft-get-owner? tyler-foust-with-gamma token-id)))

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
  (match (nft-transfer? tyler-foust-with-gamma id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? tyler-foust-with-gamma id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? tyler-foust-with-gamma id) (err ERR-NOT-FOUND)))
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
  

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u0) 'SP397HG9F74EN8HCES5G72832RNPYTHFYFPYZQQQZ))
      (map-set token-count 'SP397HG9F74EN8HCES5G72832RNPYTHFYFPYZQQQZ (+ (get-balance 'SP397HG9F74EN8HCES5G72832RNPYTHFYFPYZQQQZ) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u1) 'SP1ZBJGKDPTH9KBJ60Y2PD2MEE38JN9Z6D51RZ3NA))
      (map-set token-count 'SP1ZBJGKDPTH9KBJ60Y2PD2MEE38JN9Z6D51RZ3NA (+ (get-balance 'SP1ZBJGKDPTH9KBJ60Y2PD2MEE38JN9Z6D51RZ3NA) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u2) 'SP2N65XG5NHHZQB50X119YMZ018AP0FCSXDJPNE05))
      (map-set token-count 'SP2N65XG5NHHZQB50X119YMZ018AP0FCSXDJPNE05 (+ (get-balance 'SP2N65XG5NHHZQB50X119YMZ018AP0FCSXDJPNE05) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u3) 'SPQS1J3X9FJ6N4E9K2MW81W5DNBSCC8ZPHR6K2YA))
      (map-set token-count 'SPQS1J3X9FJ6N4E9K2MW81W5DNBSCC8ZPHR6K2YA (+ (get-balance 'SPQS1J3X9FJ6N4E9K2MW81W5DNBSCC8ZPHR6K2YA) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u4) 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W))
      (map-set token-count 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W (+ (get-balance 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u5) 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ))
      (map-set token-count 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ (+ (get-balance 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u6) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u7) 'SP1ZTC41HNC5PS8A7K444GBHN4104JXJ5EWRHTDM8))
      (map-set token-count 'SP1ZTC41HNC5PS8A7K444GBHN4104JXJ5EWRHTDM8 (+ (get-balance 'SP1ZTC41HNC5PS8A7K444GBHN4104JXJ5EWRHTDM8) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u8) 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9))
      (map-set token-count 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9 (+ (get-balance 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u9) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u10) 'SPWRCVSTCCKBMP67NS8BXK8QTF1CD1KP5RF4T053))
      (map-set token-count 'SPWRCVSTCCKBMP67NS8BXK8QTF1CD1KP5RF4T053 (+ (get-balance 'SPWRCVSTCCKBMP67NS8BXK8QTF1CD1KP5RF4T053) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u11) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u12) 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227))
      (map-set token-count 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227 (+ (get-balance 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u13) 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA))
      (map-set token-count 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA (+ (get-balance 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u14) 'SP2KB6KMN1M3YH4V8C0GKR89K0VD05QGR871CPP5Q))
      (map-set token-count 'SP2KB6KMN1M3YH4V8C0GKR89K0VD05QGR871CPP5Q (+ (get-balance 'SP2KB6KMN1M3YH4V8C0GKR89K0VD05QGR871CPP5Q) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u15) 'SP2HY55JTX8P6EXY9JSRKK407MQKZ9MB9VF9X5W6R))
      (map-set token-count 'SP2HY55JTX8P6EXY9JSRKK407MQKZ9MB9VF9X5W6R (+ (get-balance 'SP2HY55JTX8P6EXY9JSRKK407MQKZ9MB9VF9X5W6R) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u16) 'SP1B0RHX29DPRTDYNTF2RG4MH32ARMD6T9V3QC03K))
      (map-set token-count 'SP1B0RHX29DPRTDYNTF2RG4MH32ARMD6T9V3QC03K (+ (get-balance 'SP1B0RHX29DPRTDYNTF2RG4MH32ARMD6T9V3QC03K) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u17) 'SP3FKXR1RQS94A6M81VR4B09Z65S5D7AWKNX8VYEM))
      (map-set token-count 'SP3FKXR1RQS94A6M81VR4B09Z65S5D7AWKNX8VYEM (+ (get-balance 'SP3FKXR1RQS94A6M81VR4B09Z65S5D7AWKNX8VYEM) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u18) 'SP2V3SR6C0T0BWK379H6A12Z53A14CCFSSNKR2V6A))
      (map-set token-count 'SP2V3SR6C0T0BWK379H6A12Z53A14CCFSSNKR2V6A (+ (get-balance 'SP2V3SR6C0T0BWK379H6A12Z53A14CCFSSNKR2V6A) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u19) 'SP1QFB0WFWT7S63RQ8C34GCC1TTTWG2JV6NAFS6MT))
      (map-set token-count 'SP1QFB0WFWT7S63RQ8C34GCC1TTTWG2JV6NAFS6MT (+ (get-balance 'SP1QFB0WFWT7S63RQ8C34GCC1TTTWG2JV6NAFS6MT) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u20) 'SP3KR9Q9DQ7P4467FC6XC38S0EQSW06Q1DCVVM8KZ))
      (map-set token-count 'SP3KR9Q9DQ7P4467FC6XC38S0EQSW06Q1DCVVM8KZ (+ (get-balance 'SP3KR9Q9DQ7P4467FC6XC38S0EQSW06Q1DCVVM8KZ) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u21) 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW))
      (map-set token-count 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW (+ (get-balance 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u22) 'SP17Y608F82R6HAJ581MM88E4G1SYRQDNXW7F5A7Q))
      (map-set token-count 'SP17Y608F82R6HAJ581MM88E4G1SYRQDNXW7F5A7Q (+ (get-balance 'SP17Y608F82R6HAJ581MM88E4G1SYRQDNXW7F5A7Q) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u23) 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A))
      (map-set token-count 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A (+ (get-balance 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u24) 'SP1W4WC3DGZ2YYKNAZNJ80F621R11FAPZGGA4Y2QH))
      (map-set token-count 'SP1W4WC3DGZ2YYKNAZNJ80F621R11FAPZGGA4Y2QH (+ (get-balance 'SP1W4WC3DGZ2YYKNAZNJ80F621R11FAPZGGA4Y2QH) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u25) 'SP3SWCB67W8ZRS06FZA43JZ5KQZQWMQ7TH2BEGPXZ))
      (map-set token-count 'SP3SWCB67W8ZRS06FZA43JZ5KQZQWMQ7TH2BEGPXZ (+ (get-balance 'SP3SWCB67W8ZRS06FZA43JZ5KQZQWMQ7TH2BEGPXZ) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u26) 'SP350GRJNB4NFXM1F091KX834K1MY93FC9M8R2539))
      (map-set token-count 'SP350GRJNB4NFXM1F091KX834K1MY93FC9M8R2539 (+ (get-balance 'SP350GRJNB4NFXM1F091KX834K1MY93FC9M8R2539) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u27) 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH))
      (map-set token-count 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH (+ (get-balance 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u28) 'SP1XFBMC876H0V7W5J8EX3PE7ETV2FQT25VK547GV))
      (map-set token-count 'SP1XFBMC876H0V7W5J8EX3PE7ETV2FQT25VK547GV (+ (get-balance 'SP1XFBMC876H0V7W5J8EX3PE7ETV2FQT25VK547GV) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u29) 'SP7A8C66VJMTHZE0PZXF7MYQR4RD0R1QW9QYRC8H))
      (map-set token-count 'SP7A8C66VJMTHZE0PZXF7MYQR4RD0R1QW9QYRC8H (+ (get-balance 'SP7A8C66VJMTHZE0PZXF7MYQR4RD0R1QW9QYRC8H) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u30) 'SP267W1MFXGV8HJQ0ZAA1E8J6DSJYR6EBXQSK3187))
      (map-set token-count 'SP267W1MFXGV8HJQ0ZAA1E8J6DSJYR6EBXQSK3187 (+ (get-balance 'SP267W1MFXGV8HJQ0ZAA1E8J6DSJYR6EBXQSK3187) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u31) 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ))
      (map-set token-count 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ (+ (get-balance 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u32) 'SP23Z3QX3CPAF7ARD2N1YP4BR5ATZW9X2Z6J0740J))
      (map-set token-count 'SP23Z3QX3CPAF7ARD2N1YP4BR5ATZW9X2Z6J0740J (+ (get-balance 'SP23Z3QX3CPAF7ARD2N1YP4BR5ATZW9X2Z6J0740J) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u33) 'SPMEQ7E77HBSWJSXRRF4TR428JKY7D7YEPA6XPSD))
      (map-set token-count 'SPMEQ7E77HBSWJSXRRF4TR428JKY7D7YEPA6XPSD (+ (get-balance 'SPMEQ7E77HBSWJSXRRF4TR428JKY7D7YEPA6XPSD) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u34) 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR))
      (map-set token-count 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR (+ (get-balance 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u35) 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC))
      (map-set token-count 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC (+ (get-balance 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u36) 'SP2AYZAQ8K0SM2JYGM2H74YB7B52GSRQJWS3R96R6))
      (map-set token-count 'SP2AYZAQ8K0SM2JYGM2H74YB7B52GSRQJWS3R96R6 (+ (get-balance 'SP2AYZAQ8K0SM2JYGM2H74YB7B52GSRQJWS3R96R6) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u37) 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K))
      (map-set token-count 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K (+ (get-balance 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u38) 'SP35Q9M893AEGZWBRWWBNXWWH7RTPC6WKD6XP5HAJ))
      (map-set token-count 'SP35Q9M893AEGZWBRWWBNXWWH7RTPC6WKD6XP5HAJ (+ (get-balance 'SP35Q9M893AEGZWBRWWBNXWWH7RTPC6WKD6XP5HAJ) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u39) 'SP2ZZW2C44B6GB8B6Y3RVQ5KNXSGEX1JA5S1J0G12))
      (map-set token-count 'SP2ZZW2C44B6GB8B6Y3RVQ5KNXSGEX1JA5S1J0G12 (+ (get-balance 'SP2ZZW2C44B6GB8B6Y3RVQ5KNXSGEX1JA5S1J0G12) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u40) 'SP2J857CFCZ6694H7GHRG5K68DEYX2GR51C33VZGR))
      (map-set token-count 'SP2J857CFCZ6694H7GHRG5K68DEYX2GR51C33VZGR (+ (get-balance 'SP2J857CFCZ6694H7GHRG5K68DEYX2GR51C33VZGR) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u41) 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY))
      (map-set token-count 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY (+ (get-balance 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u42) 'SP2MZAMWH8QKHS35PH5F78HC96E38K108EMN8VEQ7))
      (map-set token-count 'SP2MZAMWH8QKHS35PH5F78HC96E38K108EMN8VEQ7 (+ (get-balance 'SP2MZAMWH8QKHS35PH5F78HC96E38K108EMN8VEQ7) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u43) 'SP3E5D8XFKB6TXZVDK8R5ZK3WR57FJAVYBG7FKSGN))
      (map-set token-count 'SP3E5D8XFKB6TXZVDK8R5ZK3WR57FJAVYBG7FKSGN (+ (get-balance 'SP3E5D8XFKB6TXZVDK8R5ZK3WR57FJAVYBG7FKSGN) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u44) 'SP162CVWN4SY3DQ9HNQY4XVVVJQ99AVGSR5YMWB3S))
      (map-set token-count 'SP162CVWN4SY3DQ9HNQY4XVVVJQ99AVGSR5YMWB3S (+ (get-balance 'SP162CVWN4SY3DQ9HNQY4XVVVJQ99AVGSR5YMWB3S) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u45) 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG))
      (map-set token-count 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG (+ (get-balance 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u46) 'SP12M0KHK5AG3RJVVYHQYJJKQTYEAK8ZC258KMQAM))
      (map-set token-count 'SP12M0KHK5AG3RJVVYHQYJJKQTYEAK8ZC258KMQAM (+ (get-balance 'SP12M0KHK5AG3RJVVYHQYJJKQTYEAK8ZC258KMQAM) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u47) 'SP186R5011HEKS83VH10Y6ZBTZHN5GZ6G46T20AYN))
      (map-set token-count 'SP186R5011HEKS83VH10Y6ZBTZHN5GZ6G46T20AYN (+ (get-balance 'SP186R5011HEKS83VH10Y6ZBTZHN5GZ6G46T20AYN) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u48) 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR))
      (map-set token-count 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR (+ (get-balance 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u49) 'SP2EJMPGZKE983KP58VRZZVTYV6Q99HHZ0WYEKGZR))
      (map-set token-count 'SP2EJMPGZKE983KP58VRZZVTYV6Q99HHZ0WYEKGZR (+ (get-balance 'SP2EJMPGZKE983KP58VRZZVTYV6Q99HHZ0WYEKGZR) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u50) 'SP37CB46940Y9JXPYGGK7A87PYCPZ08HT46S3BR9T))
      (map-set token-count 'SP37CB46940Y9JXPYGGK7A87PYCPZ08HT46S3BR9T (+ (get-balance 'SP37CB46940Y9JXPYGGK7A87PYCPZ08HT46S3BR9T) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u51) 'SP1ZJQRJ7TT1HA636DQRJ7PMGTP5GN89CS7FQSKKP))
      (map-set token-count 'SP1ZJQRJ7TT1HA636DQRJ7PMGTP5GN89CS7FQSKKP (+ (get-balance 'SP1ZJQRJ7TT1HA636DQRJ7PMGTP5GN89CS7FQSKKP) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u52) 'SP32QTYYGG6SWTP198FST4SPM85J0A3JPNB9S2BEA))
      (map-set token-count 'SP32QTYYGG6SWTP198FST4SPM85J0A3JPNB9S2BEA (+ (get-balance 'SP32QTYYGG6SWTP198FST4SPM85J0A3JPNB9S2BEA) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u53) 'SPGRQERDKBT29K5PYNBGF7QY2N68S1GVAC1ERWQW))
      (map-set token-count 'SPGRQERDKBT29K5PYNBGF7QY2N68S1GVAC1ERWQW (+ (get-balance 'SPGRQERDKBT29K5PYNBGF7QY2N68S1GVAC1ERWQW) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u54) 'SP3XZWPSPTY0X58GTG3HQR97R4CCG47N429PX73MT))
      (map-set token-count 'SP3XZWPSPTY0X58GTG3HQR97R4CCG47N429PX73MT (+ (get-balance 'SP3XZWPSPTY0X58GTG3HQR97R4CCG47N429PX73MT) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u55) 'SP2CEKCMQJ8FSEZT7V754WFWJQP0R4VPNX9Z7J270))
      (map-set token-count 'SP2CEKCMQJ8FSEZT7V754WFWJQP0R4VPNX9Z7J270 (+ (get-balance 'SP2CEKCMQJ8FSEZT7V754WFWJQP0R4VPNX9Z7J270) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u56) 'SPQ705N2SDZVW21FFXRWT5AH4HB53S4KHT9RER4W))
      (map-set token-count 'SPQ705N2SDZVW21FFXRWT5AH4HB53S4KHT9RER4W (+ (get-balance 'SPQ705N2SDZVW21FFXRWT5AH4HB53S4KHT9RER4W) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u57) 'SPVXSAFD0PQ1VSWN5A4MGG862JZ7QG8J69Q38N2Z))
      (map-set token-count 'SPVXSAFD0PQ1VSWN5A4MGG862JZ7QG8J69Q38N2Z (+ (get-balance 'SPVXSAFD0PQ1VSWN5A4MGG862JZ7QG8J69Q38N2Z) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u58) 'SP1EJRY4QWAHPQZW8JMGCTC8MX6Q7JPV5FR6ABZZT))
      (map-set token-count 'SP1EJRY4QWAHPQZW8JMGCTC8MX6Q7JPV5FR6ABZZT (+ (get-balance 'SP1EJRY4QWAHPQZW8JMGCTC8MX6Q7JPV5FR6ABZZT) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u59) 'SP1S8PQJ7XV0H87EJK329Y0YE41Y4STK19AMAV7ZB))
      (map-set token-count 'SP1S8PQJ7XV0H87EJK329Y0YE41Y4STK19AMAV7ZB (+ (get-balance 'SP1S8PQJ7XV0H87EJK329Y0YE41Y4STK19AMAV7ZB) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u60) 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27))
      (map-set token-count 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27 (+ (get-balance 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u61) 'SP2BZQ48MADDN62X044NNJCNXF5BA33C3BFQ3TZJW))
      (map-set token-count 'SP2BZQ48MADDN62X044NNJCNXF5BA33C3BFQ3TZJW (+ (get-balance 'SP2BZQ48MADDN62X044NNJCNXF5BA33C3BFQ3TZJW) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u62) 'SP3EWX7MNQM8K4K575PA93K276KCK0SVHSJD2DVMZ))
      (map-set token-count 'SP3EWX7MNQM8K4K575PA93K276KCK0SVHSJD2DVMZ (+ (get-balance 'SP3EWX7MNQM8K4K575PA93K276KCK0SVHSJD2DVMZ) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u63) 'SP1RXWPQQZKZ4MS6XESX34X4JDXNJ5YQ181AFNK7A))
      (map-set token-count 'SP1RXWPQQZKZ4MS6XESX34X4JDXNJ5YQ181AFNK7A (+ (get-balance 'SP1RXWPQQZKZ4MS6XESX34X4JDXNJ5YQ181AFNK7A) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u64) 'SPKFSJ4T8T39ZJN455QBY7TJX4DYF47J7344HNNF))
      (map-set token-count 'SPKFSJ4T8T39ZJN455QBY7TJX4DYF47J7344HNNF (+ (get-balance 'SPKFSJ4T8T39ZJN455QBY7TJX4DYF47J7344HNNF) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u65) 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X))
      (map-set token-count 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X (+ (get-balance 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u66) 'SP2S1QHN8ES928Z9NH21APKXN20YE91STTP5D7HZH))
      (map-set token-count 'SP2S1QHN8ES928Z9NH21APKXN20YE91STTP5D7HZH (+ (get-balance 'SP2S1QHN8ES928Z9NH21APKXN20YE91STTP5D7HZH) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u67) 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20))
      (map-set token-count 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 (+ (get-balance 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u68) 'SP16PPSNDG265N42ZG7GPDADAAAMQCDY9MT6TN4XY))
      (map-set token-count 'SP16PPSNDG265N42ZG7GPDADAAAMQCDY9MT6TN4XY (+ (get-balance 'SP16PPSNDG265N42ZG7GPDADAAAMQCDY9MT6TN4XY) u1))
      (try! (nft-mint? tyler-foust-with-gamma (+ last-nft-id u69) 'SP3Z0AA5KMEFM4E6K0MCTVG9CNV0VPYHHQYGSWSMB))
      (map-set token-count 'SP3Z0AA5KMEFM4E6K0MCTVG9CNV0VPYHHQYGSWSMB (+ (get-balance 'SP3Z0AA5KMEFM4E6K0MCTVG9CNV0VPYHHQYGSWSMB) u1))

      (var-set last-id (+ last-nft-id u70))
      (var-set airdrop-called true)
      (ok true))))
```