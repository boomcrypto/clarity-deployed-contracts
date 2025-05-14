---
title: "Trait granite-sbtc-pioneer"
draft: true
---
```
;; granite-sbtc-pioneer
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token granite-sbtc-pioneer uint)

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
(define-data-var mint-limit uint u61)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP2BD0MQ2CJGDBXCME9HEG2N1VN82F9301XAD3EHZ)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qmf214HKSobVhwhokB8GDN1Fmy6eN9hAJ6P4cgqqhQQRZG/")
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
      (unwrap! (nft-mint? granite-sbtc-pioneer next-id tx-sender) next-id)
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
    (nft-burn? granite-sbtc-pioneer token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? granite-sbtc-pioneer token-id) false)))

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
  (ok true))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? granite-sbtc-pioneer token-id)))

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

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u0) 'SP3GPV7YEVS2VNFYYXEJA4HWXA0HFX4SMFK9F12P7))
      (map-set token-count 'SP3GPV7YEVS2VNFYYXEJA4HWXA0HFX4SMFK9F12P7 (+ (get-balance 'SP3GPV7YEVS2VNFYYXEJA4HWXA0HFX4SMFK9F12P7) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u1) 'SP2Q0YNXDTVEEBFSYE2KKPXM0GAYJE9SJQA50YPTX))
      (map-set token-count 'SP2Q0YNXDTVEEBFSYE2KKPXM0GAYJE9SJQA50YPTX (+ (get-balance 'SP2Q0YNXDTVEEBFSYE2KKPXM0GAYJE9SJQA50YPTX) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u2) 'SP329M6CS0S3738Z0T268FXQXBSX0ZD1FZVBZS037))
      (map-set token-count 'SP329M6CS0S3738Z0T268FXQXBSX0ZD1FZVBZS037 (+ (get-balance 'SP329M6CS0S3738Z0T268FXQXBSX0ZD1FZVBZS037) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u3) 'SP3F2W2J9QPZPV3EWWEA09KWK61V6PTD006B911MG))
      (map-set token-count 'SP3F2W2J9QPZPV3EWWEA09KWK61V6PTD006B911MG (+ (get-balance 'SP3F2W2J9QPZPV3EWWEA09KWK61V6PTD006B911MG) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u4) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u5) 'SP3666C2NYH5HVDZ8X323EQ327D6WNCZEVX4G3QCZ))
      (map-set token-count 'SP3666C2NYH5HVDZ8X323EQ327D6WNCZEVX4G3QCZ (+ (get-balance 'SP3666C2NYH5HVDZ8X323EQ327D6WNCZEVX4G3QCZ) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u6) 'SP33HRNWBTQK9GEPQN7G4SD9D7RCNGAQZDM53EHX4))
      (map-set token-count 'SP33HRNWBTQK9GEPQN7G4SD9D7RCNGAQZDM53EHX4 (+ (get-balance 'SP33HRNWBTQK9GEPQN7G4SD9D7RCNGAQZDM53EHX4) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u7) 'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B))
      (map-set token-count 'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B (+ (get-balance 'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u8) 'SP3WT9PV5E28VBHAN7KV2BTHCA93SC9R7B64MB043))
      (map-set token-count 'SP3WT9PV5E28VBHAN7KV2BTHCA93SC9R7B64MB043 (+ (get-balance 'SP3WT9PV5E28VBHAN7KV2BTHCA93SC9R7B64MB043) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u9) 'SP30TN9ZWDW49BSDEQM3SCXSGGF309V61ERZ764J0))
      (map-set token-count 'SP30TN9ZWDW49BSDEQM3SCXSGGF309V61ERZ764J0 (+ (get-balance 'SP30TN9ZWDW49BSDEQM3SCXSGGF309V61ERZ764J0) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u10) 'SP2NSXJKKJBG0T5WX7RTCQ9SA6DAGZZB17BY4C6RM))
      (map-set token-count 'SP2NSXJKKJBG0T5WX7RTCQ9SA6DAGZZB17BY4C6RM (+ (get-balance 'SP2NSXJKKJBG0T5WX7RTCQ9SA6DAGZZB17BY4C6RM) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u11) 'SPVY7SXW4WWJ8DV2664DNS3SW8CZCCD3HSMCZ05M))
      (map-set token-count 'SPVY7SXW4WWJ8DV2664DNS3SW8CZCCD3HSMCZ05M (+ (get-balance 'SPVY7SXW4WWJ8DV2664DNS3SW8CZCCD3HSMCZ05M) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u12) 'SPJVTFT8X5AZCYRGE5AEZAAWXYY4RDYFRGXFA777))
      (map-set token-count 'SPJVTFT8X5AZCYRGE5AEZAAWXYY4RDYFRGXFA777 (+ (get-balance 'SPJVTFT8X5AZCYRGE5AEZAAWXYY4RDYFRGXFA777) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u13) 'SP1P8SSM0TJDXH4JB9YC5CWMFR530QRWECZ598R3T))
      (map-set token-count 'SP1P8SSM0TJDXH4JB9YC5CWMFR530QRWECZ598R3T (+ (get-balance 'SP1P8SSM0TJDXH4JB9YC5CWMFR530QRWECZ598R3T) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u14) 'SP2QTT9D8717TQPHW59YTEVNV07T8BEM6PKYMRVVP))
      (map-set token-count 'SP2QTT9D8717TQPHW59YTEVNV07T8BEM6PKYMRVVP (+ (get-balance 'SP2QTT9D8717TQPHW59YTEVNV07T8BEM6PKYMRVVP) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u15) 'SP60EC74B4J7E894CXCSCRHXX0EKSX6P0BSWN1R7))
      (map-set token-count 'SP60EC74B4J7E894CXCSCRHXX0EKSX6P0BSWN1R7 (+ (get-balance 'SP60EC74B4J7E894CXCSCRHXX0EKSX6P0BSWN1R7) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u16) 'SP3YJHE2FZ5PZDMAWZFN4EGSCT7WB3E90V2PHPG1R))
      (map-set token-count 'SP3YJHE2FZ5PZDMAWZFN4EGSCT7WB3E90V2PHPG1R (+ (get-balance 'SP3YJHE2FZ5PZDMAWZFN4EGSCT7WB3E90V2PHPG1R) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u17) 'SP3XEQCM24QVE2RN99RXKE83TAN1Q35YCXWF3WJW9))
      (map-set token-count 'SP3XEQCM24QVE2RN99RXKE83TAN1Q35YCXWF3WJW9 (+ (get-balance 'SP3XEQCM24QVE2RN99RXKE83TAN1Q35YCXWF3WJW9) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u18) 'SP1V1BS06A7PGHTRHMW9ZZMYVRAJGKNE7F215YVER))
      (map-set token-count 'SP1V1BS06A7PGHTRHMW9ZZMYVRAJGKNE7F215YVER (+ (get-balance 'SP1V1BS06A7PGHTRHMW9ZZMYVRAJGKNE7F215YVER) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u19) 'SP2H9S76Q2QRNCGVS1VXG0DJ310WXR2ZYMQX2TZBH))
      (map-set token-count 'SP2H9S76Q2QRNCGVS1VXG0DJ310WXR2ZYMQX2TZBH (+ (get-balance 'SP2H9S76Q2QRNCGVS1VXG0DJ310WXR2ZYMQX2TZBH) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u20) 'SP3M6D6M2BS7FNEFV111ZF6WQYATNJZ89Q7MXSPAE))
      (map-set token-count 'SP3M6D6M2BS7FNEFV111ZF6WQYATNJZ89Q7MXSPAE (+ (get-balance 'SP3M6D6M2BS7FNEFV111ZF6WQYATNJZ89Q7MXSPAE) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u21) 'SP1108AFB9HK3RPBBW3JJ1WRJN504S09GN53NZ10Y))
      (map-set token-count 'SP1108AFB9HK3RPBBW3JJ1WRJN504S09GN53NZ10Y (+ (get-balance 'SP1108AFB9HK3RPBBW3JJ1WRJN504S09GN53NZ10Y) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u22) 'SP235T4QMFY3SEFMEMFTXF36G840QFBVTJJYJZYEF))
      (map-set token-count 'SP235T4QMFY3SEFMEMFTXF36G840QFBVTJJYJZYEF (+ (get-balance 'SP235T4QMFY3SEFMEMFTXF36G840QFBVTJJYJZYEF) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u23) 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS))
      (map-set token-count 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS (+ (get-balance 'SP1KMAA7TPZ5AZZ4W67X74MJNFKMN576604CWNBQS) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u24) 'SP1RNRWWNY052GAT7B3E8S3TWM7D7MRP6HPEDF215))
      (map-set token-count 'SP1RNRWWNY052GAT7B3E8S3TWM7D7MRP6HPEDF215 (+ (get-balance 'SP1RNRWWNY052GAT7B3E8S3TWM7D7MRP6HPEDF215) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u25) 'SP3P6JN3G14EJCEAVDC56B2J6JE2NNZMT2Y2GDMF8))
      (map-set token-count 'SP3P6JN3G14EJCEAVDC56B2J6JE2NNZMT2Y2GDMF8 (+ (get-balance 'SP3P6JN3G14EJCEAVDC56B2J6JE2NNZMT2Y2GDMF8) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u26) 'SP3X1PPX49N1MHFSHQJASZHNS4K6MDA4MKTGMJ08V))
      (map-set token-count 'SP3X1PPX49N1MHFSHQJASZHNS4K6MDA4MKTGMJ08V (+ (get-balance 'SP3X1PPX49N1MHFSHQJASZHNS4K6MDA4MKTGMJ08V) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u27) 'SP2D21TSA9RB2TXT67E2A0K76JVG1NBEWC93FZE8Q))
      (map-set token-count 'SP2D21TSA9RB2TXT67E2A0K76JVG1NBEWC93FZE8Q (+ (get-balance 'SP2D21TSA9RB2TXT67E2A0K76JVG1NBEWC93FZE8Q) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u28) 'SP3V4WE14W7A9Q7ZEHGX8T7T17765XE8PRDQNADNP))
      (map-set token-count 'SP3V4WE14W7A9Q7ZEHGX8T7T17765XE8PRDQNADNP (+ (get-balance 'SP3V4WE14W7A9Q7ZEHGX8T7T17765XE8PRDQNADNP) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u29) 'SPE5HDPQGE360QSRTA7TQAVVX3DTV44530J1WH1X))
      (map-set token-count 'SPE5HDPQGE360QSRTA7TQAVVX3DTV44530J1WH1X (+ (get-balance 'SPE5HDPQGE360QSRTA7TQAVVX3DTV44530J1WH1X) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u30) 'SP1NP8CYY1XE9ZB132WFY33HS0EA692Y0V2XBNWPF))
      (map-set token-count 'SP1NP8CYY1XE9ZB132WFY33HS0EA692Y0V2XBNWPF (+ (get-balance 'SP1NP8CYY1XE9ZB132WFY33HS0EA692Y0V2XBNWPF) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u31) 'SP326H2T31PKEBR5VDPDG0FCHCGCBKFCN61Y5V8Z0))
      (map-set token-count 'SP326H2T31PKEBR5VDPDG0FCHCGCBKFCN61Y5V8Z0 (+ (get-balance 'SP326H2T31PKEBR5VDPDG0FCHCGCBKFCN61Y5V8Z0) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u32) 'SP1TCA7QER9J9NKCKBB78K48TADDFC2GXYM3QQV3X))
      (map-set token-count 'SP1TCA7QER9J9NKCKBB78K48TADDFC2GXYM3QQV3X (+ (get-balance 'SP1TCA7QER9J9NKCKBB78K48TADDFC2GXYM3QQV3X) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u33) 'SP9XKFETDDVXCACG4501SDWGV3R8AEDRMKZNHP4Y))
      (map-set token-count 'SP9XKFETDDVXCACG4501SDWGV3R8AEDRMKZNHP4Y (+ (get-balance 'SP9XKFETDDVXCACG4501SDWGV3R8AEDRMKZNHP4Y) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u34) 'SP3H8CQHXHY05EXPPR1AP5141A1QTVY2TSK5NCC2K))
      (map-set token-count 'SP3H8CQHXHY05EXPPR1AP5141A1QTVY2TSK5NCC2K (+ (get-balance 'SP3H8CQHXHY05EXPPR1AP5141A1QTVY2TSK5NCC2K) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u35) 'SPKRKWT9EDVC1ZQKWYPF7HSSJM9FS4PNYAF2N8F2))
      (map-set token-count 'SPKRKWT9EDVC1ZQKWYPF7HSSJM9FS4PNYAF2N8F2 (+ (get-balance 'SPKRKWT9EDVC1ZQKWYPF7HSSJM9FS4PNYAF2N8F2) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u36) 'SP28ZTJS8Q58ERK8MDNFGQA85CHQRP4SYH85B95SG))
      (map-set token-count 'SP28ZTJS8Q58ERK8MDNFGQA85CHQRP4SYH85B95SG (+ (get-balance 'SP28ZTJS8Q58ERK8MDNFGQA85CHQRP4SYH85B95SG) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u37) 'SP3FBTQ1NKJSB37ZTQVVGS9GZKCJAGRFYWSM41Q7))
      (map-set token-count 'SP3FBTQ1NKJSB37ZTQVVGS9GZKCJAGRFYWSM41Q7 (+ (get-balance 'SP3FBTQ1NKJSB37ZTQVVGS9GZKCJAGRFYWSM41Q7) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u38) 'SP1ZJHN74VH26SPHHJB4YP6NSEYVKFZD1W0ZK5K9H))
      (map-set token-count 'SP1ZJHN74VH26SPHHJB4YP6NSEYVKFZD1W0ZK5K9H (+ (get-balance 'SP1ZJHN74VH26SPHHJB4YP6NSEYVKFZD1W0ZK5K9H) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u39) 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B))
      (map-set token-count 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B (+ (get-balance 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u40) 'SP1Q0EYK475850ZGER56N1VM710CM3HNGNNBDW6Y2))
      (map-set token-count 'SP1Q0EYK475850ZGER56N1VM710CM3HNGNNBDW6Y2 (+ (get-balance 'SP1Q0EYK475850ZGER56N1VM710CM3HNGNNBDW6Y2) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u41) 'SPQZB84K0ZW6BNAVWETXHY6THQT1RYEMF930QZS2))
      (map-set token-count 'SPQZB84K0ZW6BNAVWETXHY6THQT1RYEMF930QZS2 (+ (get-balance 'SPQZB84K0ZW6BNAVWETXHY6THQT1RYEMF930QZS2) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u42) 'SP22DGADCDARESGJ1A9TJ1B8VMRW5BBSNGTW6P95N))
      (map-set token-count 'SP22DGADCDARESGJ1A9TJ1B8VMRW5BBSNGTW6P95N (+ (get-balance 'SP22DGADCDARESGJ1A9TJ1B8VMRW5BBSNGTW6P95N) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u43) 'SP11EBWRDRHWHWBM8XMNTD45VM5Z41XM29TBV7ECD))
      (map-set token-count 'SP11EBWRDRHWHWBM8XMNTD45VM5Z41XM29TBV7ECD (+ (get-balance 'SP11EBWRDRHWHWBM8XMNTD45VM5Z41XM29TBV7ECD) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u44) 'SP2MYQF316JWNY0M6MBGRFPZS17GJKRA26ZPB35HM))
      (map-set token-count 'SP2MYQF316JWNY0M6MBGRFPZS17GJKRA26ZPB35HM (+ (get-balance 'SP2MYQF316JWNY0M6MBGRFPZS17GJKRA26ZPB35HM) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u45) 'SP2K87H96EBFF6Y16Z9GQHW8JP50G7R0B0FMFZRXC))
      (map-set token-count 'SP2K87H96EBFF6Y16Z9GQHW8JP50G7R0B0FMFZRXC (+ (get-balance 'SP2K87H96EBFF6Y16Z9GQHW8JP50G7R0B0FMFZRXC) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u46) 'SP17D2C9PE4WAV8J8GAY1DBWZ9G4KQY68KKMFC9CD))
      (map-set token-count 'SP17D2C9PE4WAV8J8GAY1DBWZ9G4KQY68KKMFC9CD (+ (get-balance 'SP17D2C9PE4WAV8J8GAY1DBWZ9G4KQY68KKMFC9CD) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u47) 'SP1N6QYMS4771B58J5WDQMX917F2ZQJVD48RJH047))
      (map-set token-count 'SP1N6QYMS4771B58J5WDQMX917F2ZQJVD48RJH047 (+ (get-balance 'SP1N6QYMS4771B58J5WDQMX917F2ZQJVD48RJH047) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u48) 'SP14EBQ926P4APDDMT6VP1F0X867F7Z2TDW5CV69A))
      (map-set token-count 'SP14EBQ926P4APDDMT6VP1F0X867F7Z2TDW5CV69A (+ (get-balance 'SP14EBQ926P4APDDMT6VP1F0X867F7Z2TDW5CV69A) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u49) 'SP3ND3H6QF7RW2H3TM4MA316Y1J158SFWS6YDD83Z))
      (map-set token-count 'SP3ND3H6QF7RW2H3TM4MA316Y1J158SFWS6YDD83Z (+ (get-balance 'SP3ND3H6QF7RW2H3TM4MA316Y1J158SFWS6YDD83Z) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u50) 'SP2YWMJCGXXGZ4R5AKBK61V3CBRKMQ25HRB5K594J))
      (map-set token-count 'SP2YWMJCGXXGZ4R5AKBK61V3CBRKMQ25HRB5K594J (+ (get-balance 'SP2YWMJCGXXGZ4R5AKBK61V3CBRKMQ25HRB5K594J) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u51) 'SP1NQVDT5Q4TEVJB8BYM6HDBF2CVVP4XZ1YX0FG9C))
      (map-set token-count 'SP1NQVDT5Q4TEVJB8BYM6HDBF2CVVP4XZ1YX0FG9C (+ (get-balance 'SP1NQVDT5Q4TEVJB8BYM6HDBF2CVVP4XZ1YX0FG9C) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u52) 'SPN3AV2KQ8HYFHGKC34SGVSS9TNMJXG56GXRSR70))
      (map-set token-count 'SPN3AV2KQ8HYFHGKC34SGVSS9TNMJXG56GXRSR70 (+ (get-balance 'SPN3AV2KQ8HYFHGKC34SGVSS9TNMJXG56GXRSR70) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u53) 'SP1ZCA2YV8TGX1NCJ8K04P5WJSGJVM1XD44APZD9Q))
      (map-set token-count 'SP1ZCA2YV8TGX1NCJ8K04P5WJSGJVM1XD44APZD9Q (+ (get-balance 'SP1ZCA2YV8TGX1NCJ8K04P5WJSGJVM1XD44APZD9Q) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u54) 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864))
      (map-set token-count 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864 (+ (get-balance 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u55) 'SP70S68PQ3FZ5N8ERJVXQQXWBWNTSCMFZWWFZXNR))
      (map-set token-count 'SP70S68PQ3FZ5N8ERJVXQQXWBWNTSCMFZWWFZXNR (+ (get-balance 'SP70S68PQ3FZ5N8ERJVXQQXWBWNTSCMFZWWFZXNR) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u56) 'SP3V8RSTAG4AVNX913MVZG97GS1B3849W4H2G5A0D))
      (map-set token-count 'SP3V8RSTAG4AVNX913MVZG97GS1B3849W4H2G5A0D (+ (get-balance 'SP3V8RSTAG4AVNX913MVZG97GS1B3849W4H2G5A0D) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u57) 'SP2Z7EPPAQGCVSTSKG13DT6YRN8X21HVD83Y5YH1N))
      (map-set token-count 'SP2Z7EPPAQGCVSTSKG13DT6YRN8X21HVD83Y5YH1N (+ (get-balance 'SP2Z7EPPAQGCVSTSKG13DT6YRN8X21HVD83Y5YH1N) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u58) 'SP1RGW2YQ6W5J8KCTY0MC30AHVX1XE7GS9A6YM73))
      (map-set token-count 'SP1RGW2YQ6W5J8KCTY0MC30AHVX1XE7GS9A6YM73 (+ (get-balance 'SP1RGW2YQ6W5J8KCTY0MC30AHVX1XE7GS9A6YM73) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u59) 'SP2G0870GAGSXJJKZ0KQZETY0WN9H85C4YEYCFJ26))
      (map-set token-count 'SP2G0870GAGSXJJKZ0KQZETY0WN9H85C4YEYCFJ26 (+ (get-balance 'SP2G0870GAGSXJJKZ0KQZETY0WN9H85C4YEYCFJ26) u1))
      (try! (nft-mint? granite-sbtc-pioneer (+ last-nft-id u60) 'SP105GNSZG9S5M6G89K6ZR257C9A1YZF0VY8CVVGZ))
      (map-set token-count 'SP105GNSZG9S5M6G89K6ZR257C9A1YZF0VY8CVVGZ (+ (get-balance 'SP105GNSZG9S5M6G89K6ZR257C9A1YZF0VY8CVVGZ) u1))

      (var-set last-id (+ last-nft-id u61))
      (var-set airdrop-called true)
      (ok true))))
```
