;; bank-of-welshi
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token bank-of-welshi uint)

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
(define-data-var mint-limit uint u150)
(define-data-var last-id uint u1)
(define-data-var total-price uint u1000000)
(define-data-var artist-address principal 'SP2JXR92K9HH56SW25D7VZXEA4R60PV5QPW1G7RSD)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmYHSXJNb14qdtUMDpPizppwLdndUSY6nswfQDFoRRuGGt/json/")
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

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-twentyfive) (mint (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

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
      (unwrap! (nft-mint? bank-of-welshi next-id tx-sender) next-id)
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
    (nft-burn? bank-of-welshi token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? bank-of-welshi token-id) false)))

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
  (ok (nft-get-owner? bank-of-welshi token-id)))

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
  (match (nft-transfer? bank-of-welshi id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? bank-of-welshi id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? bank-of-welshi id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u0) 'SP3NBQMGEJWF4YYXFM7TTDCTWC3ZQQSVTV29KZYVE))
      (map-set token-count 'SP3NBQMGEJWF4YYXFM7TTDCTWC3ZQQSVTV29KZYVE (+ (get-balance 'SP3NBQMGEJWF4YYXFM7TTDCTWC3ZQQSVTV29KZYVE) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u1) 'SP3S29FMRBDVXGNZDFW0TP21D1ZE34ERZ8KAAQYFN))
      (map-set token-count 'SP3S29FMRBDVXGNZDFW0TP21D1ZE34ERZ8KAAQYFN (+ (get-balance 'SP3S29FMRBDVXGNZDFW0TP21D1ZE34ERZ8KAAQYFN) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u2) 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT))
      (map-set token-count 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT (+ (get-balance 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u3) 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT))
      (map-set token-count 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT (+ (get-balance 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u4) 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT))
      (map-set token-count 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT (+ (get-balance 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u5) 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT))
      (map-set token-count 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT (+ (get-balance 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u6) 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT))
      (map-set token-count 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT (+ (get-balance 'SP3NRG8DMXEPD4TMDX18PZM9PCPEH36QEZ83QDZPT) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u7) 'SP17D2C9PE4WAV8J8GAY1DBWZ9G4KQY68KKMFC9CD))
      (map-set token-count 'SP17D2C9PE4WAV8J8GAY1DBWZ9G4KQY68KKMFC9CD (+ (get-balance 'SP17D2C9PE4WAV8J8GAY1DBWZ9G4KQY68KKMFC9CD) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u8) 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y))
      (map-set token-count 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y (+ (get-balance 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u9) 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y))
      (map-set token-count 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y (+ (get-balance 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u10) 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y))
      (map-set token-count 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y (+ (get-balance 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u11) 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y))
      (map-set token-count 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y (+ (get-balance 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u12) 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y))
      (map-set token-count 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y (+ (get-balance 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u13) 'SPW0CHYR5S4J0DM03ACH2PH9ZHPFJ776Z1EQBPSV))
      (map-set token-count 'SPW0CHYR5S4J0DM03ACH2PH9ZHPFJ776Z1EQBPSV (+ (get-balance 'SPW0CHYR5S4J0DM03ACH2PH9ZHPFJ776Z1EQBPSV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u14) 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV))
      (map-set token-count 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV (+ (get-balance 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u15) 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV))
      (map-set token-count 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV (+ (get-balance 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u16) 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV))
      (map-set token-count 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV (+ (get-balance 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u17) 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV))
      (map-set token-count 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV (+ (get-balance 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u18) 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV))
      (map-set token-count 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV (+ (get-balance 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u19) 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV))
      (map-set token-count 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV (+ (get-balance 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u20) 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3))
      (map-set token-count 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3 (+ (get-balance 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u21) 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3))
      (map-set token-count 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3 (+ (get-balance 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u22) 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3))
      (map-set token-count 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3 (+ (get-balance 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u23) 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3))
      (map-set token-count 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3 (+ (get-balance 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u24) 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3))
      (map-set token-count 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3 (+ (get-balance 'SPRV7ZMM4WMMY1RKMFBB0F4RVCXQHRYMFV2PW6B3) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u25) 'SP18YW2C7CSK4EC1JEV554RVWWHG6G5T5MFPAKBJ2))
      (map-set token-count 'SP18YW2C7CSK4EC1JEV554RVWWHG6G5T5MFPAKBJ2 (+ (get-balance 'SP18YW2C7CSK4EC1JEV554RVWWHG6G5T5MFPAKBJ2) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u26) 'SPR47JA8P9FHJ5A9DC3SSH2MDEHY8N82SHY9GEVY))
      (map-set token-count 'SPR47JA8P9FHJ5A9DC3SSH2MDEHY8N82SHY9GEVY (+ (get-balance 'SPR47JA8P9FHJ5A9DC3SSH2MDEHY8N82SHY9GEVY) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u27) 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX))
      (map-set token-count 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX (+ (get-balance 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u28) 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R))
      (map-set token-count 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R (+ (get-balance 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u29) 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW))
      (map-set token-count 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW (+ (get-balance 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u30) 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW))
      (map-set token-count 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW (+ (get-balance 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u31) 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW))
      (map-set token-count 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW (+ (get-balance 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u32) 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW))
      (map-set token-count 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW (+ (get-balance 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u33) 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW))
      (map-set token-count 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW (+ (get-balance 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u34) 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A))
      (map-set token-count 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A (+ (get-balance 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u35) 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A))
      (map-set token-count 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A (+ (get-balance 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u36) 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A))
      (map-set token-count 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A (+ (get-balance 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u37) 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A))
      (map-set token-count 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A (+ (get-balance 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u38) 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A))
      (map-set token-count 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A (+ (get-balance 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u39) 'SP20BG6DH4NEVAADQX5FMWQMGPYWMVKVAM4VA9P1P))
      (map-set token-count 'SP20BG6DH4NEVAADQX5FMWQMGPYWMVKVAM4VA9P1P (+ (get-balance 'SP20BG6DH4NEVAADQX5FMWQMGPYWMVKVAM4VA9P1P) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u40) 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA))
      (map-set token-count 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA (+ (get-balance 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u41) 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA))
      (map-set token-count 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA (+ (get-balance 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u42) 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA))
      (map-set token-count 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA (+ (get-balance 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u43) 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA))
      (map-set token-count 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA (+ (get-balance 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u44) 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA))
      (map-set token-count 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA (+ (get-balance 'SPGS7N9AV3YZYT9MFWBY12SZGSFDXFMBQYEMRFZA) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u45) 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C))
      (map-set token-count 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C (+ (get-balance 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u46) 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C))
      (map-set token-count 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C (+ (get-balance 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u47) 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C))
      (map-set token-count 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C (+ (get-balance 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u48) 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C))
      (map-set token-count 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C (+ (get-balance 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u49) 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C))
      (map-set token-count 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C (+ (get-balance 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u50) 'SP2KXR9180B10JM3437VD7C48BH03NZF371XR61H2))
      (map-set token-count 'SP2KXR9180B10JM3437VD7C48BH03NZF371XR61H2 (+ (get-balance 'SP2KXR9180B10JM3437VD7C48BH03NZF371XR61H2) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u51) 'SP2KXR9180B10JM3437VD7C48BH03NZF371XR61H2))
      (map-set token-count 'SP2KXR9180B10JM3437VD7C48BH03NZF371XR61H2 (+ (get-balance 'SP2KXR9180B10JM3437VD7C48BH03NZF371XR61H2) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u52) 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV))
      (map-set token-count 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV (+ (get-balance 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u53) 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV))
      (map-set token-count 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV (+ (get-balance 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u54) 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV))
      (map-set token-count 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV (+ (get-balance 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u55) 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV))
      (map-set token-count 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV (+ (get-balance 'SP7XZVVXFFHMMTWZ8WNNKNY0TSHM5FQVJDT707CV) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u56) 'SP1DY3DQMVAA1F8JJAJBKPQ0HKQ1FZG67JG0YD5P3))
      (map-set token-count 'SP1DY3DQMVAA1F8JJAJBKPQ0HKQ1FZG67JG0YD5P3 (+ (get-balance 'SP1DY3DQMVAA1F8JJAJBKPQ0HKQ1FZG67JG0YD5P3) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u57) 'SP1DY3DQMVAA1F8JJAJBKPQ0HKQ1FZG67JG0YD5P3))
      (map-set token-count 'SP1DY3DQMVAA1F8JJAJBKPQ0HKQ1FZG67JG0YD5P3 (+ (get-balance 'SP1DY3DQMVAA1F8JJAJBKPQ0HKQ1FZG67JG0YD5P3) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u58) 'SP3XP79JT5KZ565QXVG5S5BJD7T2C5J6D6MS9SWN7))
      (map-set token-count 'SP3XP79JT5KZ565QXVG5S5BJD7T2C5J6D6MS9SWN7 (+ (get-balance 'SP3XP79JT5KZ565QXVG5S5BJD7T2C5J6D6MS9SWN7) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u59) 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R))
      (map-set token-count 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R (+ (get-balance 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u60) 'SPX9QGZCJFXS28N7GWJDWEBPS1HT3QKXV9Y5WF5Y))
      (map-set token-count 'SPX9QGZCJFXS28N7GWJDWEBPS1HT3QKXV9Y5WF5Y (+ (get-balance 'SPX9QGZCJFXS28N7GWJDWEBPS1HT3QKXV9Y5WF5Y) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u61) 'SPX9QGZCJFXS28N7GWJDWEBPS1HT3QKXV9Y5WF5Y))
      (map-set token-count 'SPX9QGZCJFXS28N7GWJDWEBPS1HT3QKXV9Y5WF5Y (+ (get-balance 'SPX9QGZCJFXS28N7GWJDWEBPS1HT3QKXV9Y5WF5Y) u1))
      (try! (nft-mint? bank-of-welshi (+ last-nft-id u62) 'SPX9QGZCJFXS28N7GWJDWEBPS1HT3QKXV9Y5WF5Y))
      (map-set token-count 'SPX9QGZCJFXS28N7GWJDWEBPS1HT3QKXV9Y5WF5Y (+ (get-balance 'SPX9QGZCJFXS28N7GWJDWEBPS1HT3QKXV9Y5WF5Y) u1))

      (var-set last-id (+ last-nft-id u63))
      (var-set airdrop-called true)
      (ok true))))