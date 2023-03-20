;; radboy-first-feat
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token radboy-first-feat uint)

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
(define-data-var mint-limit uint u555)
(define-data-var last-id uint u1)
(define-data-var total-price uint u11050000)
(define-data-var artist-address principal 'SP1E1RNN4JZ7T6Y0JVCSY2TH4918Z590P8JAB9HZM)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmP8JuscoaqRAVcVWfgPeRLesRhQjq3NEVezpU7JvH9e7w/json/")
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
      (unwrap! (nft-mint? radboy-first-feat next-id tx-sender) next-id)
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
    (nft-burn? radboy-first-feat token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? radboy-first-feat token-id) false)))

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
  (ok (nft-get-owner? radboy-first-feat token-id)))

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
  (match (nft-transfer? radboy-first-feat id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? radboy-first-feat id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? radboy-first-feat id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u0) 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB))
      (map-set token-count 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB (+ (get-balance 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u1) 'SP206Y5HNJ0XSXQCDCYEY6M3E46BE9A3NHJJ71BXX))
      (map-set token-count 'SP206Y5HNJ0XSXQCDCYEY6M3E46BE9A3NHJJ71BXX (+ (get-balance 'SP206Y5HNJ0XSXQCDCYEY6M3E46BE9A3NHJJ71BXX) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u2) 'SP1QTSBFXZYJXK7CQ3E0DAFV8PYSK6N1ZK4PH1KMD))
      (map-set token-count 'SP1QTSBFXZYJXK7CQ3E0DAFV8PYSK6N1ZK4PH1KMD (+ (get-balance 'SP1QTSBFXZYJXK7CQ3E0DAFV8PYSK6N1ZK4PH1KMD) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u3) 'SPEV4KC4TQGHXP0T91FDJCAMTQ5EP92CZER59NS4))
      (map-set token-count 'SPEV4KC4TQGHXP0T91FDJCAMTQ5EP92CZER59NS4 (+ (get-balance 'SPEV4KC4TQGHXP0T91FDJCAMTQ5EP92CZER59NS4) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u4) 'SPQXKSXJSGYNG97NZA1SNNM2RCTARC1ZSZ5V4BMB))
      (map-set token-count 'SPQXKSXJSGYNG97NZA1SNNM2RCTARC1ZSZ5V4BMB (+ (get-balance 'SPQXKSXJSGYNG97NZA1SNNM2RCTARC1ZSZ5V4BMB) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u5) 'SP3SGW7WSYXPQ1DR8V0MTB9J1XC6GB0XEHRQE23V5))
      (map-set token-count 'SP3SGW7WSYXPQ1DR8V0MTB9J1XC6GB0XEHRQE23V5 (+ (get-balance 'SP3SGW7WSYXPQ1DR8V0MTB9J1XC6GB0XEHRQE23V5) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u6) 'SP201N7VWH0BB702P9PBDZB9QGGWNH3YB8PPB1K9))
      (map-set token-count 'SP201N7VWH0BB702P9PBDZB9QGGWNH3YB8PPB1K9 (+ (get-balance 'SP201N7VWH0BB702P9PBDZB9QGGWNH3YB8PPB1K9) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u7) 'SP1S0EHDMWHX51W3TCPRY6K3RV452QVGW9R23P10K))
      (map-set token-count 'SP1S0EHDMWHX51W3TCPRY6K3RV452QVGW9R23P10K (+ (get-balance 'SP1S0EHDMWHX51W3TCPRY6K3RV452QVGW9R23P10K) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u8) 'SP1YV11RPW6RMTCQEPXZHEDC1FG2MNN3VNA350YAS))
      (map-set token-count 'SP1YV11RPW6RMTCQEPXZHEDC1FG2MNN3VNA350YAS (+ (get-balance 'SP1YV11RPW6RMTCQEPXZHEDC1FG2MNN3VNA350YAS) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u9) 'SP2M1XW6T6F9JS575BS6QQMV87D2AEPPG6EZ6CH0Q))
      (map-set token-count 'SP2M1XW6T6F9JS575BS6QQMV87D2AEPPG6EZ6CH0Q (+ (get-balance 'SP2M1XW6T6F9JS575BS6QQMV87D2AEPPG6EZ6CH0Q) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u10) 'SPSSCWS0A9TESQA16Z3KMD0TWX1Z5W776W7600AS))
      (map-set token-count 'SPSSCWS0A9TESQA16Z3KMD0TWX1Z5W776W7600AS (+ (get-balance 'SPSSCWS0A9TESQA16Z3KMD0TWX1Z5W776W7600AS) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u11) 'SP3NPM3QEHZS2XWRA88M2HQV8NPFA8RWGF5P40FPX))
      (map-set token-count 'SP3NPM3QEHZS2XWRA88M2HQV8NPFA8RWGF5P40FPX (+ (get-balance 'SP3NPM3QEHZS2XWRA88M2HQV8NPFA8RWGF5P40FPX) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u12) 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN))
      (map-set token-count 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN (+ (get-balance 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u13) 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN))
      (map-set token-count 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN (+ (get-balance 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u14) 'SP2DRA4MF5T96G0ARBCW97TV1H83AV3P7H04NAPGF))
      (map-set token-count 'SP2DRA4MF5T96G0ARBCW97TV1H83AV3P7H04NAPGF (+ (get-balance 'SP2DRA4MF5T96G0ARBCW97TV1H83AV3P7H04NAPGF) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u15) 'SP141ZVAWA6TC8GMB82APSD16J26KK0SXJXD5SWEV))
      (map-set token-count 'SP141ZVAWA6TC8GMB82APSD16J26KK0SXJXD5SWEV (+ (get-balance 'SP141ZVAWA6TC8GMB82APSD16J26KK0SXJXD5SWEV) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u16) 'SPAX2SZCDFTVV76SR4JY4RYEPC5PBH2QAHEJXHTF))
      (map-set token-count 'SPAX2SZCDFTVV76SR4JY4RYEPC5PBH2QAHEJXHTF (+ (get-balance 'SPAX2SZCDFTVV76SR4JY4RYEPC5PBH2QAHEJXHTF) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u17) 'SPBQNXCXEFFQDDQSXD0RD93AHSVCQ76QJ3QFRFZ7))
      (map-set token-count 'SPBQNXCXEFFQDDQSXD0RD93AHSVCQ76QJ3QFRFZ7 (+ (get-balance 'SPBQNXCXEFFQDDQSXD0RD93AHSVCQ76QJ3QFRFZ7) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u18) 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E))
      (map-set token-count 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E (+ (get-balance 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u19) 'SP1GH7Q7R73X27TQGV27MVKDHR4YF83HZAMJ9K5YH))
      (map-set token-count 'SP1GH7Q7R73X27TQGV27MVKDHR4YF83HZAMJ9K5YH (+ (get-balance 'SP1GH7Q7R73X27TQGV27MVKDHR4YF83HZAMJ9K5YH) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u20) 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH))
      (map-set token-count 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH (+ (get-balance 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u21) 'SP1KQ1NNKJB7N65T10VN1410SM88NF8CBSDA1NPNT))
      (map-set token-count 'SP1KQ1NNKJB7N65T10VN1410SM88NF8CBSDA1NPNT (+ (get-balance 'SP1KQ1NNKJB7N65T10VN1410SM88NF8CBSDA1NPNT) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u22) 'SP2QMRMRT8NFEY6HEW0CE4DXJ7GFF8YV2TQ701P0K))
      (map-set token-count 'SP2QMRMRT8NFEY6HEW0CE4DXJ7GFF8YV2TQ701P0K (+ (get-balance 'SP2QMRMRT8NFEY6HEW0CE4DXJ7GFF8YV2TQ701P0K) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u23) 'SPBTHBWMJ95JM8PF0Q8EP4BH0YAAKTJ29MXWA71F))
      (map-set token-count 'SPBTHBWMJ95JM8PF0Q8EP4BH0YAAKTJ29MXWA71F (+ (get-balance 'SPBTHBWMJ95JM8PF0Q8EP4BH0YAAKTJ29MXWA71F) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u24) 'SP3G5DYXFNSNW7Y2A7EHR6H1RH8QZ9PGWF9CC0T7S))
      (map-set token-count 'SP3G5DYXFNSNW7Y2A7EHR6H1RH8QZ9PGWF9CC0T7S (+ (get-balance 'SP3G5DYXFNSNW7Y2A7EHR6H1RH8QZ9PGWF9CC0T7S) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u25) 'SP3GCSJH3J5TVJEJD1FVXK44GFXR8633AJJ5E5BEY))
      (map-set token-count 'SP3GCSJH3J5TVJEJD1FVXK44GFXR8633AJJ5E5BEY (+ (get-balance 'SP3GCSJH3J5TVJEJD1FVXK44GFXR8633AJJ5E5BEY) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u26) 'SP2BYA6C1H31EW8W9ZYMRGQE9RBH929F852HED193))
      (map-set token-count 'SP2BYA6C1H31EW8W9ZYMRGQE9RBH929F852HED193 (+ (get-balance 'SP2BYA6C1H31EW8W9ZYMRGQE9RBH929F852HED193) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u27) 'SP1G18KGVMP2RF5S2387DBC4VRZGK2T9ETMMVT7BB))
      (map-set token-count 'SP1G18KGVMP2RF5S2387DBC4VRZGK2T9ETMMVT7BB (+ (get-balance 'SP1G18KGVMP2RF5S2387DBC4VRZGK2T9ETMMVT7BB) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u28) 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN))
      (map-set token-count 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN (+ (get-balance 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u29) 'SPYJF7AM2ZDMMEB01M425SEWH083VGB7Z2MVG1RW))
      (map-set token-count 'SPYJF7AM2ZDMMEB01M425SEWH083VGB7Z2MVG1RW (+ (get-balance 'SPYJF7AM2ZDMMEB01M425SEWH083VGB7Z2MVG1RW) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u30) 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E))
      (map-set token-count 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E (+ (get-balance 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u31) 'SPF4FR0X9Q4PAF6KENDD3NVAGQTM8A830A4F96YG))
      (map-set token-count 'SPF4FR0X9Q4PAF6KENDD3NVAGQTM8A830A4F96YG (+ (get-balance 'SPF4FR0X9Q4PAF6KENDD3NVAGQTM8A830A4F96YG) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u32) 'SP2MMF30WNFRQRB3H6PKZR07BA5W4YQ6XY2JF8X5R))
      (map-set token-count 'SP2MMF30WNFRQRB3H6PKZR07BA5W4YQ6XY2JF8X5R (+ (get-balance 'SP2MMF30WNFRQRB3H6PKZR07BA5W4YQ6XY2JF8X5R) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u33) 'SPQ2EJYG80JYYZQB40E5J30AMATCY1A72R1XC65Z))
      (map-set token-count 'SPQ2EJYG80JYYZQB40E5J30AMATCY1A72R1XC65Z (+ (get-balance 'SPQ2EJYG80JYYZQB40E5J30AMATCY1A72R1XC65Z) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u34) 'SP1W205AJ74K0TP5CKPFY2ZWNM7PYHJW24WH16VQ6))
      (map-set token-count 'SP1W205AJ74K0TP5CKPFY2ZWNM7PYHJW24WH16VQ6 (+ (get-balance 'SP1W205AJ74K0TP5CKPFY2ZWNM7PYHJW24WH16VQ6) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u35) 'SP2XXNBX3A811NZ7H2489P57DEJJG5RVKQJ1MNFCT))
      (map-set token-count 'SP2XXNBX3A811NZ7H2489P57DEJJG5RVKQJ1MNFCT (+ (get-balance 'SP2XXNBX3A811NZ7H2489P57DEJJG5RVKQJ1MNFCT) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u36) 'SPXKPY2NMKPQW7W5PCNKD1YG67GVBJKATQKNA1ZH))
      (map-set token-count 'SPXKPY2NMKPQW7W5PCNKD1YG67GVBJKATQKNA1ZH (+ (get-balance 'SPXKPY2NMKPQW7W5PCNKD1YG67GVBJKATQKNA1ZH) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u37) 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0))
      (map-set token-count 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0 (+ (get-balance 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u38) 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G))
      (map-set token-count 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G (+ (get-balance 'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u39) 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79))
      (map-set token-count 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79 (+ (get-balance 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u40) 'SP1KNDWRCN5DTDDZW1029E9AQDT6ZJQ2NWWQBFVEP))
      (map-set token-count 'SP1KNDWRCN5DTDDZW1029E9AQDT6ZJQ2NWWQBFVEP (+ (get-balance 'SP1KNDWRCN5DTDDZW1029E9AQDT6ZJQ2NWWQBFVEP) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u41) 'SP2W529KV1ZW0MRESDC5ESZHNSQE9CHVH4GJ3ZG1Y))
      (map-set token-count 'SP2W529KV1ZW0MRESDC5ESZHNSQE9CHVH4GJ3ZG1Y (+ (get-balance 'SP2W529KV1ZW0MRESDC5ESZHNSQE9CHVH4GJ3ZG1Y) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u42) 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV))
      (map-set token-count 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV (+ (get-balance 'SP31WG1RDCABM0AESH0B29F6NSSM6860FMDMJN3RV) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u43) 'SP3K80TDYVVNKC1SBVSSG0KMSP9MS2B13ZDWD2MHC))
      (map-set token-count 'SP3K80TDYVVNKC1SBVSSG0KMSP9MS2B13ZDWD2MHC (+ (get-balance 'SP3K80TDYVVNKC1SBVSSG0KMSP9MS2B13ZDWD2MHC) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u44) 'SPQ60DRKYNQKDDEH85547FXJ8C4Q1JC0EXNA53PE))
      (map-set token-count 'SPQ60DRKYNQKDDEH85547FXJ8C4Q1JC0EXNA53PE (+ (get-balance 'SPQ60DRKYNQKDDEH85547FXJ8C4Q1JC0EXNA53PE) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u45) 'SP104YJ508E2380VPABG4DHAHE00DN0MM7S0W5F1F))
      (map-set token-count 'SP104YJ508E2380VPABG4DHAHE00DN0MM7S0W5F1F (+ (get-balance 'SP104YJ508E2380VPABG4DHAHE00DN0MM7S0W5F1F) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u46) 'SPHDN375JDERBEBKSZ61D4J677FQNQ6VSAER51H6))
      (map-set token-count 'SPHDN375JDERBEBKSZ61D4J677FQNQ6VSAER51H6 (+ (get-balance 'SPHDN375JDERBEBKSZ61D4J677FQNQ6VSAER51H6) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u47) 'SP11DXBHH1R1FTTNH0NJGM7QD2BD9BX1D74DKQ2GR))
      (map-set token-count 'SP11DXBHH1R1FTTNH0NJGM7QD2BD9BX1D74DKQ2GR (+ (get-balance 'SP11DXBHH1R1FTTNH0NJGM7QD2BD9BX1D74DKQ2GR) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u48) 'SP3WWZT5N7DVHQV71EADFFM9TQCSA6MZJDB9H3M0T))
      (map-set token-count 'SP3WWZT5N7DVHQV71EADFFM9TQCSA6MZJDB9H3M0T (+ (get-balance 'SP3WWZT5N7DVHQV71EADFFM9TQCSA6MZJDB9H3M0T) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u49) 'SP16KM2MMCPAKQWA5CX9YH6QBS30W37RWFXWVGJA6))
      (map-set token-count 'SP16KM2MMCPAKQWA5CX9YH6QBS30W37RWFXWVGJA6 (+ (get-balance 'SP16KM2MMCPAKQWA5CX9YH6QBS30W37RWFXWVGJA6) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u50) 'SP3JD4KSXYDSQQS9T43JSGAWTFKE7QH7CA2CEDWP))
      (map-set token-count 'SP3JD4KSXYDSQQS9T43JSGAWTFKE7QH7CA2CEDWP (+ (get-balance 'SP3JD4KSXYDSQQS9T43JSGAWTFKE7QH7CA2CEDWP) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u51) 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH))
      (map-set token-count 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH (+ (get-balance 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u52) 'SP3W23AJE2FEJN3R9ZPCS1QZEGRZQ86A4810H9HSQ))
      (map-set token-count 'SP3W23AJE2FEJN3R9ZPCS1QZEGRZQ86A4810H9HSQ (+ (get-balance 'SP3W23AJE2FEJN3R9ZPCS1QZEGRZQ86A4810H9HSQ) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u53) 'SP2TZE09GHARKG0B8NTT9X77QXBTQPQ2J1579T0D8))
      (map-set token-count 'SP2TZE09GHARKG0B8NTT9X77QXBTQPQ2J1579T0D8 (+ (get-balance 'SP2TZE09GHARKG0B8NTT9X77QXBTQPQ2J1579T0D8) u1))
      (try! (nft-mint? radboy-first-feat (+ last-nft-id u54) 'SPGM4RBXP6GM6M2FDCPVZYCKPK1FXYH1767XR7FC))
      (map-set token-count 'SPGM4RBXP6GM6M2FDCPVZYCKPK1FXYH1767XR7FC (+ (get-balance 'SPGM4RBXP6GM6M2FDCPVZYCKPK1FXYH1767XR7FC) u1))

      (var-set last-id (+ last-nft-id u55))
      (var-set airdrop-called true)
      (ok true))))