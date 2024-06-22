---
title: "Trait vintage-ventures-legacy"
draft: true
---
```
;; vintage-ventures-legacy
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token vintage-ventures-legacy uint)

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
(define-data-var mint-limit uint u444)
(define-data-var last-id uint u1)
(define-data-var total-price uint u3000000)
(define-data-var artist-address principal 'SP1KPPYB2R9ZVK0YZDSMYX6E0G9GZFJEARZQS1C1Y)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmZwjrTcFvXzG1nn6bfKgJ9RFMzRqmJdHZcvbrT4JKMiZz/json/")
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

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-eight) (mint (list true true true true true true true true)))

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
      (unwrap! (nft-mint? vintage-ventures-legacy next-id tx-sender) next-id)
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
    (nft-burn? vintage-ventures-legacy token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? vintage-ventures-legacy token-id) false)))

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
  (ok (nft-get-owner? vintage-ventures-legacy token-id)))

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
  (match (nft-transfer? vintage-ventures-legacy id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? vintage-ventures-legacy id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? vintage-ventures-legacy id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u0) 'SPGG4ETPWVF72DMJB35TTTVPNNABHJY11CPR6E0Q))
      (map-set token-count 'SPGG4ETPWVF72DMJB35TTTVPNNABHJY11CPR6E0Q (+ (get-balance 'SPGG4ETPWVF72DMJB35TTTVPNNABHJY11CPR6E0Q) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u1) 'SP38142W7333X0Y8CQ3WN6R91S7F63SVRDN5QB0SS))
      (map-set token-count 'SP38142W7333X0Y8CQ3WN6R91S7F63SVRDN5QB0SS (+ (get-balance 'SP38142W7333X0Y8CQ3WN6R91S7F63SVRDN5QB0SS) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u2) 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R))
      (map-set token-count 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R (+ (get-balance 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u3) 'SP6R1EKY8QYG4MPWXT6NZHXCDZDF1RVMJMKMYN7R))
      (map-set token-count 'SP6R1EKY8QYG4MPWXT6NZHXCDZDF1RVMJMKMYN7R (+ (get-balance 'SP6R1EKY8QYG4MPWXT6NZHXCDZDF1RVMJMKMYN7R) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u4) 'SP2H4DZR0C5Y2X0HTC3PW79PEHNRQHPP7GGHX35P6))
      (map-set token-count 'SP2H4DZR0C5Y2X0HTC3PW79PEHNRQHPP7GGHX35P6 (+ (get-balance 'SP2H4DZR0C5Y2X0HTC3PW79PEHNRQHPP7GGHX35P6) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u5) 'SPKYK8BWJTT8D38SJFAQ0KHFPT88QVMZ3VMSNDKW))
      (map-set token-count 'SPKYK8BWJTT8D38SJFAQ0KHFPT88QVMZ3VMSNDKW (+ (get-balance 'SPKYK8BWJTT8D38SJFAQ0KHFPT88QVMZ3VMSNDKW) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u6) 'SP17D2C9PE4WAV8J8GAY1DBWZ9G4KQY68KKMFC9CD))
      (map-set token-count 'SP17D2C9PE4WAV8J8GAY1DBWZ9G4KQY68KKMFC9CD (+ (get-balance 'SP17D2C9PE4WAV8J8GAY1DBWZ9G4KQY68KKMFC9CD) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u7) 'SP3J6Q1KGB2CCMD0EN5K29E95DYWAHYCDA0KJK09G))
      (map-set token-count 'SP3J6Q1KGB2CCMD0EN5K29E95DYWAHYCDA0KJK09G (+ (get-balance 'SP3J6Q1KGB2CCMD0EN5K29E95DYWAHYCDA0KJK09G) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u8) 'SP2CFXP1F7CAWQQ7TNHGE16ZZMZMN3A6WYTKPQ3WT))
      (map-set token-count 'SP2CFXP1F7CAWQQ7TNHGE16ZZMZMN3A6WYTKPQ3WT (+ (get-balance 'SP2CFXP1F7CAWQQ7TNHGE16ZZMZMN3A6WYTKPQ3WT) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u9) 'SP27KBRZ7GRQ6BHHX4973SPNB6M07HK3DGFD9J4CN))
      (map-set token-count 'SP27KBRZ7GRQ6BHHX4973SPNB6M07HK3DGFD9J4CN (+ (get-balance 'SP27KBRZ7GRQ6BHHX4973SPNB6M07HK3DGFD9J4CN) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u10) 'SP3BSNDWN9SC195GP7XQWE9M35JX609ARKNT12RAX))
      (map-set token-count 'SP3BSNDWN9SC195GP7XQWE9M35JX609ARKNT12RAX (+ (get-balance 'SP3BSNDWN9SC195GP7XQWE9M35JX609ARKNT12RAX) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u11) 'SP25WCP3QWQR6EGASRKW0KVSQ460PNHFBQ79VAZDR))
      (map-set token-count 'SP25WCP3QWQR6EGASRKW0KVSQ460PNHFBQ79VAZDR (+ (get-balance 'SP25WCP3QWQR6EGASRKW0KVSQ460PNHFBQ79VAZDR) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u12) 'SP2CEBH7PWF2SJ1CBH94TMT0D08P462HRGBKHFM6D))
      (map-set token-count 'SP2CEBH7PWF2SJ1CBH94TMT0D08P462HRGBKHFM6D (+ (get-balance 'SP2CEBH7PWF2SJ1CBH94TMT0D08P462HRGBKHFM6D) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u13) 'SP37E46M4GR5X7A1KGE3B3V7TCVWBJCZCGQH0PS40))
      (map-set token-count 'SP37E46M4GR5X7A1KGE3B3V7TCVWBJCZCGQH0PS40 (+ (get-balance 'SP37E46M4GR5X7A1KGE3B3V7TCVWBJCZCGQH0PS40) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u14) 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX))
      (map-set token-count 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX (+ (get-balance 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u15) 'SP150GJWQXH1M8DHWM38T0AHFVAFN4SC2NJHDR1HH))
      (map-set token-count 'SP150GJWQXH1M8DHWM38T0AHFVAFN4SC2NJHDR1HH (+ (get-balance 'SP150GJWQXH1M8DHWM38T0AHFVAFN4SC2NJHDR1HH) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u16) 'SP2QWQXA0RH5ZXKEAPR1QD26WFKG7PW4D4SEH7W4))
      (map-set token-count 'SP2QWQXA0RH5ZXKEAPR1QD26WFKG7PW4D4SEH7W4 (+ (get-balance 'SP2QWQXA0RH5ZXKEAPR1QD26WFKG7PW4D4SEH7W4) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u17) 'SPBNJ6AE40H35XR2FWBRCMYMAB2FCXQX56W8M7QP))
      (map-set token-count 'SPBNJ6AE40H35XR2FWBRCMYMAB2FCXQX56W8M7QP (+ (get-balance 'SPBNJ6AE40H35XR2FWBRCMYMAB2FCXQX56W8M7QP) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u18) 'SP2G37HWR5QFPA73B3MX471CPKG7R8EFAP907CYTS))
      (map-set token-count 'SP2G37HWR5QFPA73B3MX471CPKG7R8EFAP907CYTS (+ (get-balance 'SP2G37HWR5QFPA73B3MX471CPKG7R8EFAP907CYTS) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u19) 'SP3ERV4C3HE8K9SDEA82QXP1Z1J2218C3673CVHAK))
      (map-set token-count 'SP3ERV4C3HE8K9SDEA82QXP1Z1J2218C3673CVHAK (+ (get-balance 'SP3ERV4C3HE8K9SDEA82QXP1Z1J2218C3673CVHAK) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u20) 'SP28JP1FEVX7G3YFDJ59GKKQTZEVQQ49YDM0FDFK4))
      (map-set token-count 'SP28JP1FEVX7G3YFDJ59GKKQTZEVQQ49YDM0FDFK4 (+ (get-balance 'SP28JP1FEVX7G3YFDJ59GKKQTZEVQQ49YDM0FDFK4) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u21) 'SP24478XYAB7DZF7850JWVYQRGGRKDWXF7WKKRY30))
      (map-set token-count 'SP24478XYAB7DZF7850JWVYQRGGRKDWXF7WKKRY30 (+ (get-balance 'SP24478XYAB7DZF7850JWVYQRGGRKDWXF7WKKRY30) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u22) 'SPHFNT5EKP2E29NVBC6YFMQ9GPSC2BDBBQMG4CCK))
      (map-set token-count 'SPHFNT5EKP2E29NVBC6YFMQ9GPSC2BDBBQMG4CCK (+ (get-balance 'SPHFNT5EKP2E29NVBC6YFMQ9GPSC2BDBBQMG4CCK) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u23) 'SPGGZDAHMY21WV30MJHPY9KR6B1EEYW6RBRB3Y1Z))
      (map-set token-count 'SPGGZDAHMY21WV30MJHPY9KR6B1EEYW6RBRB3Y1Z (+ (get-balance 'SPGGZDAHMY21WV30MJHPY9KR6B1EEYW6RBRB3Y1Z) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u24) 'SPVN6PSK8PNH2QZ9M06W2A1KQQQA6J1FF267VCWC))
      (map-set token-count 'SPVN6PSK8PNH2QZ9M06W2A1KQQQA6J1FF267VCWC (+ (get-balance 'SPVN6PSK8PNH2QZ9M06W2A1KQQQA6J1FF267VCWC) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u25) 'SP282MPCBMDEMB6ZJ2GRV1FE5HC1PZN96GHD8A99K))
      (map-set token-count 'SP282MPCBMDEMB6ZJ2GRV1FE5HC1PZN96GHD8A99K (+ (get-balance 'SP282MPCBMDEMB6ZJ2GRV1FE5HC1PZN96GHD8A99K) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u26) 'SP388WVM5SA4B6MJ6J2TB04F7JY1P8H417A8GWTE0))
      (map-set token-count 'SP388WVM5SA4B6MJ6J2TB04F7JY1P8H417A8GWTE0 (+ (get-balance 'SP388WVM5SA4B6MJ6J2TB04F7JY1P8H417A8GWTE0) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u27) 'SP3DNVSQBYVJDSZXMCFTWZP3DHAC01PGG8RWNRQ3E))
      (map-set token-count 'SP3DNVSQBYVJDSZXMCFTWZP3DHAC01PGG8RWNRQ3E (+ (get-balance 'SP3DNVSQBYVJDSZXMCFTWZP3DHAC01PGG8RWNRQ3E) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u28) 'SP1RQK9GGDJ840JVF4B5TCWBGP8FNEQK21EB43B36))
      (map-set token-count 'SP1RQK9GGDJ840JVF4B5TCWBGP8FNEQK21EB43B36 (+ (get-balance 'SP1RQK9GGDJ840JVF4B5TCWBGP8FNEQK21EB43B36) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u29) 'SP103BZSXCX2YF8HXMN8DDP5Z46DN4A0HPRDYJXDD))
      (map-set token-count 'SP103BZSXCX2YF8HXMN8DDP5Z46DN4A0HPRDYJXDD (+ (get-balance 'SP103BZSXCX2YF8HXMN8DDP5Z46DN4A0HPRDYJXDD) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u30) 'SP2HQ4FM4Y4AS7NTKGQ89X0DYDVHD7PM5DQ1XER7C))
      (map-set token-count 'SP2HQ4FM4Y4AS7NTKGQ89X0DYDVHD7PM5DQ1XER7C (+ (get-balance 'SP2HQ4FM4Y4AS7NTKGQ89X0DYDVHD7PM5DQ1XER7C) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u31) 'SP37X7A32WWTGNNKGZRSR4D4SANDQSSCWN4674WWA))
      (map-set token-count 'SP37X7A32WWTGNNKGZRSR4D4SANDQSSCWN4674WWA (+ (get-balance 'SP37X7A32WWTGNNKGZRSR4D4SANDQSSCWN4674WWA) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u32) 'SP9PSSZ62G16EQBDASC1G18H7SW2AEP9QYSXJNTP))
      (map-set token-count 'SP9PSSZ62G16EQBDASC1G18H7SW2AEP9QYSXJNTP (+ (get-balance 'SP9PSSZ62G16EQBDASC1G18H7SW2AEP9QYSXJNTP) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u33) 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R))
      (map-set token-count 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R (+ (get-balance 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u34) 'SP2WS28J7A725HPCGPFBG9F0973JQTQ8Z0FX3GDJP))
      (map-set token-count 'SP2WS28J7A725HPCGPFBG9F0973JQTQ8Z0FX3GDJP (+ (get-balance 'SP2WS28J7A725HPCGPFBG9F0973JQTQ8Z0FX3GDJP) u1))
      (try! (nft-mint? vintage-ventures-legacy (+ last-nft-id u35) 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8))
      (map-set token-count 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8 (+ (get-balance 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8) u1))

      (var-set last-id (+ last-nft-id u36))
      (var-set airdrop-called true)
      (ok true))))
```
