;; corrupt-glitch
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token corrupt-glitch uint)

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
(define-data-var mint-limit uint u65)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP28V7K7AJX74RD3RAKFMJ1TGFFKXHMJA51RC3RNN)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qman3gJ4ih5dTgkHqPe9JeLengHFtSRVB2aknBrcPyyVgp/")
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

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-public (mint-for-many (recipients (list 25 principal)))
  (let
    (
      (next-id (var-get last-id))
      (id-reached (fold mint-for-many-iter recipients next-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (var-set last-id id-reached)
      (ok id-reached))))

(define-private (mint-for-many-iter (recipient principal) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? corrupt-glitch next-id tx-sender) next-id)
      (unwrap! (nft-transfer? corrupt-glitch next-id tx-sender recipient) next-id)
      (map-set token-count recipient (+ (get-balance recipient) u1))      
      (+ next-id u1)
    )
    next-id))

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
      (unwrap! (nft-mint? corrupt-glitch next-id tx-sender) next-id)
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
    (nft-burn? corrupt-glitch token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? corrupt-glitch token-id) false)))

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
  (ok (nft-get-owner? corrupt-glitch token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get ipfs-root))))

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
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? corrupt-glitch id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? corrupt-glitch id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? corrupt-glitch id) (err ERR-NOT-FOUND)))
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
  (if (> royalty-amount u0)
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
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u0) 'SP1QPTCQZ5YA89JCBPW6T0JR03RK7GVMKSKRJ87R))
      (map-set token-count 'SP1QPTCQZ5YA89JCBPW6T0JR03RK7GVMKSKRJ87R (+ (get-balance 'SP1QPTCQZ5YA89JCBPW6T0JR03RK7GVMKSKRJ87R) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u1) 'SP3QFHMSGAW6CB7VDX289EW454Y60R3GF0WASMKVE))
      (map-set token-count 'SP3QFHMSGAW6CB7VDX289EW454Y60R3GF0WASMKVE (+ (get-balance 'SP3QFHMSGAW6CB7VDX289EW454Y60R3GF0WASMKVE) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u2) 'SP3QFHMSGAW6CB7VDX289EW454Y60R3GF0WASMKVE))
      (map-set token-count 'SP3QFHMSGAW6CB7VDX289EW454Y60R3GF0WASMKVE (+ (get-balance 'SP3QFHMSGAW6CB7VDX289EW454Y60R3GF0WASMKVE) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u3) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u4) 'SP1P4JM3KYHYPV7G8VYT2QDPXW2X8FHRAY62CP0SE))
      (map-set token-count 'SP1P4JM3KYHYPV7G8VYT2QDPXW2X8FHRAY62CP0SE (+ (get-balance 'SP1P4JM3KYHYPV7G8VYT2QDPXW2X8FHRAY62CP0SE) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u5) 'SP2FKKNNMJH1J50VN6ZRSWRES8EKXCDA9JXQKV35P))
      (map-set token-count 'SP2FKKNNMJH1J50VN6ZRSWRES8EKXCDA9JXQKV35P (+ (get-balance 'SP2FKKNNMJH1J50VN6ZRSWRES8EKXCDA9JXQKV35P) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u6) 'SPC22ADNQZ0DMVBFDSDJS3KK1QK72JYQPCNWPY9S))
      (map-set token-count 'SPC22ADNQZ0DMVBFDSDJS3KK1QK72JYQPCNWPY9S (+ (get-balance 'SPC22ADNQZ0DMVBFDSDJS3KK1QK72JYQPCNWPY9S) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u7) 'SP398XVFFDW7ZVM078EKSCYZHD84AFMHG59MZ8GPA))
      (map-set token-count 'SP398XVFFDW7ZVM078EKSCYZHD84AFMHG59MZ8GPA (+ (get-balance 'SP398XVFFDW7ZVM078EKSCYZHD84AFMHG59MZ8GPA) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u8) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u9) 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K))
      (map-set token-count 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K (+ (get-balance 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u10) 'SP35X0JGSJ6A0E7SXX51Z8MQ6NZ13DXYH6V8TNAPM))
      (map-set token-count 'SP35X0JGSJ6A0E7SXX51Z8MQ6NZ13DXYH6V8TNAPM (+ (get-balance 'SP35X0JGSJ6A0E7SXX51Z8MQ6NZ13DXYH6V8TNAPM) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u11) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u12) 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1))
      (map-set token-count 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 (+ (get-balance 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u13) 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1))
      (map-set token-count 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 (+ (get-balance 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u14) 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X))
      (map-set token-count 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X (+ (get-balance 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u15) 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W))
      (map-set token-count 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W (+ (get-balance 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u16) 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR))
      (map-set token-count 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR (+ (get-balance 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u17) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u18) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u19) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u20) 'SP132JME06AN53AJSPVK5NHBN9TJAEC0W2RGDE21F))
      (map-set token-count 'SP132JME06AN53AJSPVK5NHBN9TJAEC0W2RGDE21F (+ (get-balance 'SP132JME06AN53AJSPVK5NHBN9TJAEC0W2RGDE21F) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u21) 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27))
      (map-set token-count 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27 (+ (get-balance 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u22) 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27))
      (map-set token-count 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27 (+ (get-balance 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u23) 'SP2TZE09GHARKG0B8NTT9X77QXBTQPQ2J1579T0D8))
      (map-set token-count 'SP2TZE09GHARKG0B8NTT9X77QXBTQPQ2J1579T0D8 (+ (get-balance 'SP2TZE09GHARKG0B8NTT9X77QXBTQPQ2J1579T0D8) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u24) 'SPFK6E20DN1PFBY02956QN23TCWSPHMY76KYWGEZ))
      (map-set token-count 'SPFK6E20DN1PFBY02956QN23TCWSPHMY76KYWGEZ (+ (get-balance 'SPFK6E20DN1PFBY02956QN23TCWSPHMY76KYWGEZ) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u25) 'SP3R566RQQ8J023DBZ1AZQYJG1MZZRQ8P3ZKVZ3V1))
      (map-set token-count 'SP3R566RQQ8J023DBZ1AZQYJG1MZZRQ8P3ZKVZ3V1 (+ (get-balance 'SP3R566RQQ8J023DBZ1AZQYJG1MZZRQ8P3ZKVZ3V1) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u26) 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V))
      (map-set token-count 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V (+ (get-balance 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u27) 'SP36TDQZTXVFGP3H1PQX7VJCSRQW6F9QDM5APHMQC))
      (map-set token-count 'SP36TDQZTXVFGP3H1PQX7VJCSRQW6F9QDM5APHMQC (+ (get-balance 'SP36TDQZTXVFGP3H1PQX7VJCSRQW6F9QDM5APHMQC) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u28) 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR))
      (map-set token-count 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR (+ (get-balance 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u29) 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1))
      (map-set token-count 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 (+ (get-balance 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u30) 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6))
      (map-set token-count 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 (+ (get-balance 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u31) 'SP3JJC9CVH2251JC0B4QTPS661H6JNTA2P9E6HA6N))
      (map-set token-count 'SP3JJC9CVH2251JC0B4QTPS661H6JNTA2P9E6HA6N (+ (get-balance 'SP3JJC9CVH2251JC0B4QTPS661H6JNTA2P9E6HA6N) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u32) 'SP1NW8Q0CTAP9BDCBB0KWC1K5Q0W4JDDS674RGRCR))
      (map-set token-count 'SP1NW8Q0CTAP9BDCBB0KWC1K5Q0W4JDDS674RGRCR (+ (get-balance 'SP1NW8Q0CTAP9BDCBB0KWC1K5Q0W4JDDS674RGRCR) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u33) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u34) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u35) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u36) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u37) 'SPHWY482ANTWNTW2618HYHQSDY1WCW7P20BW5F7Y))
      (map-set token-count 'SPHWY482ANTWNTW2618HYHQSDY1WCW7P20BW5F7Y (+ (get-balance 'SPHWY482ANTWNTW2618HYHQSDY1WCW7P20BW5F7Y) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u38) 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ))
      (map-set token-count 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ (+ (get-balance 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u39) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u40) 'SP216YJTD76S81ZXKVHEBTJT77PSVR33AZ57548V3))
      (map-set token-count 'SP216YJTD76S81ZXKVHEBTJT77PSVR33AZ57548V3 (+ (get-balance 'SP216YJTD76S81ZXKVHEBTJT77PSVR33AZ57548V3) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u41) 'SP216YJTD76S81ZXKVHEBTJT77PSVR33AZ57548V3))
      (map-set token-count 'SP216YJTD76S81ZXKVHEBTJT77PSVR33AZ57548V3 (+ (get-balance 'SP216YJTD76S81ZXKVHEBTJT77PSVR33AZ57548V3) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u42) 'SP3C27ZAE4K2RE9M5WNRTN7W2626H4CZDGE2TPDWF))
      (map-set token-count 'SP3C27ZAE4K2RE9M5WNRTN7W2626H4CZDGE2TPDWF (+ (get-balance 'SP3C27ZAE4K2RE9M5WNRTN7W2626H4CZDGE2TPDWF) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u43) 'SP3C27ZAE4K2RE9M5WNRTN7W2626H4CZDGE2TPDWF))
      (map-set token-count 'SP3C27ZAE4K2RE9M5WNRTN7W2626H4CZDGE2TPDWF (+ (get-balance 'SP3C27ZAE4K2RE9M5WNRTN7W2626H4CZDGE2TPDWF) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u44) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u45) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u46) 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX))
      (map-set token-count 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX (+ (get-balance 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u47) 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH))
      (map-set token-count 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH (+ (get-balance 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u48) 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ))
      (map-set token-count 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ (+ (get-balance 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u49) 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191))
      (map-set token-count 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191 (+ (get-balance 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u50) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u51) 'SP0NRH95EFRV9BH75JW1K5E3DGWYZYPRVF0AXBC))
      (map-set token-count 'SP0NRH95EFRV9BH75JW1K5E3DGWYZYPRVF0AXBC (+ (get-balance 'SP0NRH95EFRV9BH75JW1K5E3DGWYZYPRVF0AXBC) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u52) 'SPFK6E20DN1PFBY02956QN23TCWSPHMY76KYWGEZ))
      (map-set token-count 'SPFK6E20DN1PFBY02956QN23TCWSPHMY76KYWGEZ (+ (get-balance 'SPFK6E20DN1PFBY02956QN23TCWSPHMY76KYWGEZ) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u53) 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB))
      (map-set token-count 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB (+ (get-balance 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u54) 'SP2YG90T7GPVJDGXQAJ40Y08NB5ZBV4KVASSAQNE8))
      (map-set token-count 'SP2YG90T7GPVJDGXQAJ40Y08NB5ZBV4KVASSAQNE8 (+ (get-balance 'SP2YG90T7GPVJDGXQAJ40Y08NB5ZBV4KVASSAQNE8) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u55) 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5))
      (map-set token-count 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 (+ (get-balance 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u56) 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191))
      (map-set token-count 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191 (+ (get-balance 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u57) 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV))
      (map-set token-count 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV (+ (get-balance 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u58) 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE))
      (map-set token-count 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE (+ (get-balance 'SPN3Y24JD5B17DN9Y8AEQGQV4VVWA644ACXBE3XE) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u59) 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y))
      (map-set token-count 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y (+ (get-balance 'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u60) 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY))
      (map-set token-count 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY (+ (get-balance 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u61) 'SP2A0NZDC68W5CWFQBT180JZPP93759W7H9CG3KRW))
      (map-set token-count 'SP2A0NZDC68W5CWFQBT180JZPP93759W7H9CG3KRW (+ (get-balance 'SP2A0NZDC68W5CWFQBT180JZPP93759W7H9CG3KRW) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u62) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u63) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? corrupt-glitch (+ last-nft-id u64) 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W))
      (map-set token-count 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W (+ (get-balance 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W) u1))

      (var-set last-id (+ last-nft-id u65))
      (var-set airdrop-called true)
      (ok true))))