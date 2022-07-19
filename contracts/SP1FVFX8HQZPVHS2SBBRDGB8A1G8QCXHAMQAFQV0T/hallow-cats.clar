;; hallow-cats

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token hallow-cats uint)

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
(define-data-var mint-limit uint u133)
(define-data-var last-id uint u1)
(define-data-var total-price uint u6000000)
(define-data-var artist-address principal 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmdQJQy81my2NctJcpGVjGDjqmEMEx5BYwBcfD9W9nQ9wv/json/")
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
      (unwrap! (nft-mint? hallow-cats next-id tx-sender) next-id)
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
    (nft-burn? hallow-cats token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? hallow-cats token-id) false)))

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
  (ok (nft-get-owner? hallow-cats token-id)))

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
  (match (nft-transfer? hallow-cats id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? hallow-cats id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? hallow-cats id) (err ERR-NOT-FOUND)))
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

(define-public (set-royalty-percent (royalty uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (asserts! (and (>= royalty u0) (<= royalty u1000)) (err ERR-INVALID-PERCENTAGE))
    (ok (var-set royalty-percent royalty))))

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
      (try! (nft-mint? hallow-cats (+ last-nft-id u0) 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T))
      (map-set token-count 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T (+ (get-balance 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u1) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u2) 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA))
      (map-set token-count 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA (+ (get-balance 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u3) 'SP23FMJXH1MBKW7H4GTZZTPWHZR21NZACYQE5DEN1))
      (map-set token-count 'SP23FMJXH1MBKW7H4GTZZTPWHZR21NZACYQE5DEN1 (+ (get-balance 'SP23FMJXH1MBKW7H4GTZZTPWHZR21NZACYQE5DEN1) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u4) 'SP1F0014GTXSKD6GFJ5370BB1XX5GTH9R6RP4Q9RV))
      (map-set token-count 'SP1F0014GTXSKD6GFJ5370BB1XX5GTH9R6RP4Q9RV (+ (get-balance 'SP1F0014GTXSKD6GFJ5370BB1XX5GTH9R6RP4Q9RV) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u5) 'SP25HZXKHGGZ2ASKXPF7R7QMG3QPYMQ6ZTGBSCVPS))
      (map-set token-count 'SP25HZXKHGGZ2ASKXPF7R7QMG3QPYMQ6ZTGBSCVPS (+ (get-balance 'SP25HZXKHGGZ2ASKXPF7R7QMG3QPYMQ6ZTGBSCVPS) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u6) 'SP1K8RG4PV202FHT8J9023G1WJRPFTSZXN9TPNEJX))
      (map-set token-count 'SP1K8RG4PV202FHT8J9023G1WJRPFTSZXN9TPNEJX (+ (get-balance 'SP1K8RG4PV202FHT8J9023G1WJRPFTSZXN9TPNEJX) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u7) 'SPRN8QHNVERT98BEJA3HF7BEXS081TTKV9D10EK0))
      (map-set token-count 'SPRN8QHNVERT98BEJA3HF7BEXS081TTKV9D10EK0 (+ (get-balance 'SPRN8QHNVERT98BEJA3HF7BEXS081TTKV9D10EK0) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u8) 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN))
      (map-set token-count 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN (+ (get-balance 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u9) 'SP3BFEKZK4ZT6YTRWJMQ3YFP7EV2YTDN5EQ1KFQ8J))
      (map-set token-count 'SP3BFEKZK4ZT6YTRWJMQ3YFP7EV2YTDN5EQ1KFQ8J (+ (get-balance 'SP3BFEKZK4ZT6YTRWJMQ3YFP7EV2YTDN5EQ1KFQ8J) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u10) 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN))
      (map-set token-count 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN (+ (get-balance 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u11) 'SP3WSEATAT4VFFR6KAGX0QXS13E491TV64ZD1E4YY))
      (map-set token-count 'SP3WSEATAT4VFFR6KAGX0QXS13E491TV64ZD1E4YY (+ (get-balance 'SP3WSEATAT4VFFR6KAGX0QXS13E491TV64ZD1E4YY) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u12) 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0))
      (map-set token-count 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0 (+ (get-balance 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u13) 'SPPWN1N1CQAK8DFC1W9BR5RTY9K77JTBD0P4K88G))
      (map-set token-count 'SPPWN1N1CQAK8DFC1W9BR5RTY9K77JTBD0P4K88G (+ (get-balance 'SPPWN1N1CQAK8DFC1W9BR5RTY9K77JTBD0P4K88G) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u14) 'SP363ECSA62Y3HTHD6NB70RY5WTVA113WJPGN7G6N))
      (map-set token-count 'SP363ECSA62Y3HTHD6NB70RY5WTVA113WJPGN7G6N (+ (get-balance 'SP363ECSA62Y3HTHD6NB70RY5WTVA113WJPGN7G6N) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u15) 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8))
      (map-set token-count 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8 (+ (get-balance 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u16) 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5))
      (map-set token-count 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 (+ (get-balance 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u17) 'SP1YT6QRRHPGJVDKQY89MSGGFHYAETD4FKVTBRH1P))
      (map-set token-count 'SP1YT6QRRHPGJVDKQY89MSGGFHYAETD4FKVTBRH1P (+ (get-balance 'SP1YT6QRRHPGJVDKQY89MSGGFHYAETD4FKVTBRH1P) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u18) 'SP2ACM4ECBGRAPJH3Q86VAQ4YRBK5G1C7F4VYJ500))
      (map-set token-count 'SP2ACM4ECBGRAPJH3Q86VAQ4YRBK5G1C7F4VYJ500 (+ (get-balance 'SP2ACM4ECBGRAPJH3Q86VAQ4YRBK5G1C7F4VYJ500) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u19) 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR))
      (map-set token-count 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR (+ (get-balance 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u20) 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W))
      (map-set token-count 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W (+ (get-balance 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u21) 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB))
      (map-set token-count 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB (+ (get-balance 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u22) 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6))
      (map-set token-count 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 (+ (get-balance 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u23) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u24) 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T))
      (map-set token-count 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T (+ (get-balance 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u25) 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T))
      (map-set token-count 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T (+ (get-balance 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u26) 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T))
      (map-set token-count 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T (+ (get-balance 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u27) 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T))
      (map-set token-count 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T (+ (get-balance 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u28) 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T))
      (map-set token-count 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T (+ (get-balance 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T) u1))
      (try! (nft-mint? hallow-cats (+ last-nft-id u29) 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T))
      (map-set token-count 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T (+ (get-balance 'SP1FVFX8HQZPVHS2SBBRDGB8A1G8QCXHAMQAFQV0T) u1))

      (var-set last-id (+ last-nft-id u30))
      (var-set airdrop-called true)
      (ok true))))