;; b-my-valentine
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token b-my-valentine uint)

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
(define-data-var mint-limit uint u100)
(define-data-var last-id uint u1)
(define-data-var total-price uint u6900000)
(define-data-var artist-address principal 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmdHVzzsTHhHGE4DAp97dB3mazqx1CztqTed4vu4QR68tn/")
(define-data-var mint-paused bool false)
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
      (unwrap! (nft-mint? b-my-valentine next-id tx-sender) next-id)
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
    (nft-burn? b-my-valentine token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? b-my-valentine token-id) false)))

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
  (ok (nft-get-owner? b-my-valentine token-id)))

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

;; Non-custodial marketplace extras
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? b-my-valentine id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? b-my-valentine id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? b-my-valentine id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? b-my-valentine (+ last-nft-id u0) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u1) 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX))
      (map-set token-count 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX (+ (get-balance 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u2) 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH))
      (map-set token-count 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH (+ (get-balance 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u3) 'SP3J4WEWR42Q5919MR8CBV4X4ZC19SSA0Q7PKHZVG))
      (map-set token-count 'SP3J4WEWR42Q5919MR8CBV4X4ZC19SSA0Q7PKHZVG (+ (get-balance 'SP3J4WEWR42Q5919MR8CBV4X4ZC19SSA0Q7PKHZVG) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u4) 'SP1XGVC95Z0HPG50YPEV5XZB5YA08DC29B0XZWBWN))
      (map-set token-count 'SP1XGVC95Z0HPG50YPEV5XZB5YA08DC29B0XZWBWN (+ (get-balance 'SP1XGVC95Z0HPG50YPEV5XZB5YA08DC29B0XZWBWN) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u5) 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44))
      (map-set token-count 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44 (+ (get-balance 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u6) 'SP1QGQM4HC236ZQK68QT5K9CFJFJK90ZA2ZXBADR9))
      (map-set token-count 'SP1QGQM4HC236ZQK68QT5K9CFJFJK90ZA2ZXBADR9 (+ (get-balance 'SP1QGQM4HC236ZQK68QT5K9CFJFJK90ZA2ZXBADR9) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u7) 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G))
      (map-set token-count 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G (+ (get-balance 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u8) 'SPHDN375JDERBEBKSZ61D4J677FQNQ6VSAER51H6))
      (map-set token-count 'SPHDN375JDERBEBKSZ61D4J677FQNQ6VSAER51H6 (+ (get-balance 'SPHDN375JDERBEBKSZ61D4J677FQNQ6VSAER51H6) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u9) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u10) 'SP3HTFPB135F5ZSAYYXR8JWNZKAE8X195KD1FAVYG))
      (map-set token-count 'SP3HTFPB135F5ZSAYYXR8JWNZKAE8X195KD1FAVYG (+ (get-balance 'SP3HTFPB135F5ZSAYYXR8JWNZKAE8X195KD1FAVYG) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u11) 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG))
      (map-set token-count 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG (+ (get-balance 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u12) 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5))
      (map-set token-count 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 (+ (get-balance 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u13) 'SP31EEHQHNCGNEQ24RK06S3J2VNR6SBXET4AESXAM))
      (map-set token-count 'SP31EEHQHNCGNEQ24RK06S3J2VNR6SBXET4AESXAM (+ (get-balance 'SP31EEHQHNCGNEQ24RK06S3J2VNR6SBXET4AESXAM) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u14) 'SP1ZJHN74VH26SPHHJB4YP6NSEYVKFZD1W0ZK5K9H))
      (map-set token-count 'SP1ZJHN74VH26SPHHJB4YP6NSEYVKFZD1W0ZK5K9H (+ (get-balance 'SP1ZJHN74VH26SPHHJB4YP6NSEYVKFZD1W0ZK5K9H) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u15) 'SP1RE17THZVB6ZS261EZX3BVW6J5GFXH67Z9DECJY))
      (map-set token-count 'SP1RE17THZVB6ZS261EZX3BVW6J5GFXH67Z9DECJY (+ (get-balance 'SP1RE17THZVB6ZS261EZX3BVW6J5GFXH67Z9DECJY) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u16) 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0))
      (map-set token-count 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 (+ (get-balance 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u17) 'SP3ESBKP1EDKAA0083DA2MAM1TYPF93MFME2MRE2B))
      (map-set token-count 'SP3ESBKP1EDKAA0083DA2MAM1TYPF93MFME2MRE2B (+ (get-balance 'SP3ESBKP1EDKAA0083DA2MAM1TYPF93MFME2MRE2B) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u18) 'SP1CMFJW9J8WN7R2XJ26AC90AARGW68R1CWNYDANC))
      (map-set token-count 'SP1CMFJW9J8WN7R2XJ26AC90AARGW68R1CWNYDANC (+ (get-balance 'SP1CMFJW9J8WN7R2XJ26AC90AARGW68R1CWNYDANC) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u19) 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7))
      (map-set token-count 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7 (+ (get-balance 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u20) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u21) 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D))
      (map-set token-count 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D (+ (get-balance 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u22) 'SP3JRHW6MESKE576TAF36DM3TXG6D9S6GZXHB37V1))
      (map-set token-count 'SP3JRHW6MESKE576TAF36DM3TXG6D9S6GZXHB37V1 (+ (get-balance 'SP3JRHW6MESKE576TAF36DM3TXG6D9S6GZXHB37V1) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u23) 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV))
      (map-set token-count 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV (+ (get-balance 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u24) 'SP2QJZYMR66J4YRNWSXJBP3X8EVQ9X2VG8S3M24ES))
      (map-set token-count 'SP2QJZYMR66J4YRNWSXJBP3X8EVQ9X2VG8S3M24ES (+ (get-balance 'SP2QJZYMR66J4YRNWSXJBP3X8EVQ9X2VG8S3M24ES) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u25) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u26) 'SP5GX6PQVGYQKBFA3E9EWWVPM65SN5Z0XDDX3YW7))
      (map-set token-count 'SP5GX6PQVGYQKBFA3E9EWWVPM65SN5Z0XDDX3YW7 (+ (get-balance 'SP5GX6PQVGYQKBFA3E9EWWVPM65SN5Z0XDDX3YW7) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u27) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u28) 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ))
      (map-set token-count 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ (+ (get-balance 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u29) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u30) 'SP5DDDWRV2QV17GDM1SBMCZNX4E9WQB7DSYYK4T2))
      (map-set token-count 'SP5DDDWRV2QV17GDM1SBMCZNX4E9WQB7DSYYK4T2 (+ (get-balance 'SP5DDDWRV2QV17GDM1SBMCZNX4E9WQB7DSYYK4T2) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u31) 'SP1YNXNHFA35XKSMAPR5ZDA82MRPZ07GVTK4GNK7W))
      (map-set token-count 'SP1YNXNHFA35XKSMAPR5ZDA82MRPZ07GVTK4GNK7W (+ (get-balance 'SP1YNXNHFA35XKSMAPR5ZDA82MRPZ07GVTK4GNK7W) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u32) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u33) 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN))
      (map-set token-count 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN (+ (get-balance 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u34) 'SP3H0DJMGJFXJ6HP30B74YGK19ADYMD9H13ECSPZJ))
      (map-set token-count 'SP3H0DJMGJFXJ6HP30B74YGK19ADYMD9H13ECSPZJ (+ (get-balance 'SP3H0DJMGJFXJ6HP30B74YGK19ADYMD9H13ECSPZJ) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u35) 'SP3SC6NKMHPW5CB0A9TQFJSSRK7WKSCQENM2NREG7))
      (map-set token-count 'SP3SC6NKMHPW5CB0A9TQFJSSRK7WKSCQENM2NREG7 (+ (get-balance 'SP3SC6NKMHPW5CB0A9TQFJSSRK7WKSCQENM2NREG7) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u36) 'SP33M5BGDQD9WVV0MPDT8WCSM03J0WX3ABK5DEXZA))
      (map-set token-count 'SP33M5BGDQD9WVV0MPDT8WCSM03J0WX3ABK5DEXZA (+ (get-balance 'SP33M5BGDQD9WVV0MPDT8WCSM03J0WX3ABK5DEXZA) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u37) 'SP1C5N37KPVY75A42VKVFD10V8N04TA0YFNEGQET1))
      (map-set token-count 'SP1C5N37KPVY75A42VKVFD10V8N04TA0YFNEGQET1 (+ (get-balance 'SP1C5N37KPVY75A42VKVFD10V8N04TA0YFNEGQET1) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u38) 'SP1PHAGEQ5RWM8G84DFGMRPENKQGFC4QJ9YWXAYKF))
      (map-set token-count 'SP1PHAGEQ5RWM8G84DFGMRPENKQGFC4QJ9YWXAYKF (+ (get-balance 'SP1PHAGEQ5RWM8G84DFGMRPENKQGFC4QJ9YWXAYKF) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u39) 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ))
      (map-set token-count 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ (+ (get-balance 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u40) 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168))
      (map-set token-count 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168 (+ (get-balance 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u41) 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27))
      (map-set token-count 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27 (+ (get-balance 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u42) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u43) 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1))
      (map-set token-count 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1 (+ (get-balance 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u44) 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA))
      (map-set token-count 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA (+ (get-balance 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u45) 'SP38RZYZWJ8CPVNFHGGD6MT8JBTS28Q3EMQZ9XKA))
      (map-set token-count 'SP38RZYZWJ8CPVNFHGGD6MT8JBTS28Q3EMQZ9XKA (+ (get-balance 'SP38RZYZWJ8CPVNFHGGD6MT8JBTS28Q3EMQZ9XKA) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u46) 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9))
      (map-set token-count 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9 (+ (get-balance 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u47) 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB))
      (map-set token-count 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB (+ (get-balance 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u48) 'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B))
      (map-set token-count 'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B (+ (get-balance 'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u49) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u50) 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB))
      (map-set token-count 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB (+ (get-balance 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u51) 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6))
      (map-set token-count 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 (+ (get-balance 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u52) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u53) 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10))
      (map-set token-count 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10 (+ (get-balance 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u54) 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D))
      (map-set token-count 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D (+ (get-balance 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u55) 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8))
      (map-set token-count 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8 (+ (get-balance 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u56) 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH))
      (map-set token-count 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH (+ (get-balance 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u57) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? b-my-valentine (+ last-nft-id u58) 'SPBBHW86SPQNVRBFMQ6VP0FEKA25599B3CSD047X))
      (map-set token-count 'SPBBHW86SPQNVRBFMQ6VP0FEKA25599B3CSD047X (+ (get-balance 'SPBBHW86SPQNVRBFMQ6VP0FEKA25599B3CSD047X) u1))

      (var-set last-id (+ last-nft-id u59))
      (var-set airdrop-called true)
      (ok true))))