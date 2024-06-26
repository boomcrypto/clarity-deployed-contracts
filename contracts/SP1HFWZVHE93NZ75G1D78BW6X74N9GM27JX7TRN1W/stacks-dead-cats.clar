;; stacks-dead-cats
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stacks-dead-cats uint)

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
(define-data-var mint-limit uint u2222)
(define-data-var last-id uint u1)
(define-data-var total-price uint u3000000)
(define-data-var artist-address principal 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qma2hqCWBaD979kRZL8CdTuJXpbsXDicA6bvj2nRtc3uVZ/json/")
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
      (unwrap! (nft-mint? stacks-dead-cats next-id tx-sender) next-id)
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
    (nft-burn? stacks-dead-cats token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stacks-dead-cats token-id) false)))

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
  (ok (nft-get-owner? stacks-dead-cats token-id)))

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

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/0")
(define-data-var license-name (string-ascii 40) "PUBLIC")

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
  (match (nft-transfer? stacks-dead-cats id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? stacks-dead-cats id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? stacks-dead-cats id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u0) 'SP23HDTMC0HTV1R39P71107QA6RW40SBXNRSJZ9G7))
      (map-set token-count 'SP23HDTMC0HTV1R39P71107QA6RW40SBXNRSJZ9G7 (+ (get-balance 'SP23HDTMC0HTV1R39P71107QA6RW40SBXNRSJZ9G7) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u1) 'SP3WE275ASTHP6MSRC2D2HR2GD3TQF4V1J51AKQD7))
      (map-set token-count 'SP3WE275ASTHP6MSRC2D2HR2GD3TQF4V1J51AKQD7 (+ (get-balance 'SP3WE275ASTHP6MSRC2D2HR2GD3TQF4V1J51AKQD7) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u2) 'SP2FDXGTKM9VZTX0EWKKMV65EW7QT1GF79QZMDVJR))
      (map-set token-count 'SP2FDXGTKM9VZTX0EWKKMV65EW7QT1GF79QZMDVJR (+ (get-balance 'SP2FDXGTKM9VZTX0EWKKMV65EW7QT1GF79QZMDVJR) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u3) 'SP2A7PQ42NRJRPH3Y0HHQ20ZVG6KGA1ED0QV03KBW))
      (map-set token-count 'SP2A7PQ42NRJRPH3Y0HHQ20ZVG6KGA1ED0QV03KBW (+ (get-balance 'SP2A7PQ42NRJRPH3Y0HHQ20ZVG6KGA1ED0QV03KBW) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u4) 'SP25JESXTBQBXGHBNAD4599G4WSZ0NJC1NH804AS6))
      (map-set token-count 'SP25JESXTBQBXGHBNAD4599G4WSZ0NJC1NH804AS6 (+ (get-balance 'SP25JESXTBQBXGHBNAD4599G4WSZ0NJC1NH804AS6) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u5) 'SP3JKTHVSH1SESQG2JZ3G4QQRDD8NAQSYSWBB395S))
      (map-set token-count 'SP3JKTHVSH1SESQG2JZ3G4QQRDD8NAQSYSWBB395S (+ (get-balance 'SP3JKTHVSH1SESQG2JZ3G4QQRDD8NAQSYSWBB395S) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u6) 'SP2TCWSB36ES3SHD1WX1QR436J0J9BQN9KY4YCQHE))
      (map-set token-count 'SP2TCWSB36ES3SHD1WX1QR436J0J9BQN9KY4YCQHE (+ (get-balance 'SP2TCWSB36ES3SHD1WX1QR436J0J9BQN9KY4YCQHE) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u7) 'SPSX317MQWBPGD6PR343XEV09Y7X6M6DBPP2S1WK))
      (map-set token-count 'SPSX317MQWBPGD6PR343XEV09Y7X6M6DBPP2S1WK (+ (get-balance 'SPSX317MQWBPGD6PR343XEV09Y7X6M6DBPP2S1WK) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u8) 'SPSX317MQWBPGD6PR343XEV09Y7X6M6DBPP2S1WK))
      (map-set token-count 'SPSX317MQWBPGD6PR343XEV09Y7X6M6DBPP2S1WK (+ (get-balance 'SPSX317MQWBPGD6PR343XEV09Y7X6M6DBPP2S1WK) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u9) 'SP1EDWGJQC5267KKZ3QRAM7GGNNHYZX6V50VMRDK3))
      (map-set token-count 'SP1EDWGJQC5267KKZ3QRAM7GGNNHYZX6V50VMRDK3 (+ (get-balance 'SP1EDWGJQC5267KKZ3QRAM7GGNNHYZX6V50VMRDK3) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u10) 'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V))
      (map-set token-count 'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V (+ (get-balance 'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u11) 'SP26JANC54SG8Q1JKVZK5R89Z35S60J2AF8ZJKGMR))
      (map-set token-count 'SP26JANC54SG8Q1JKVZK5R89Z35S60J2AF8ZJKGMR (+ (get-balance 'SP26JANC54SG8Q1JKVZK5R89Z35S60J2AF8ZJKGMR) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u12) 'SP3N66VSF1HAH9BP36XEAT2JZWZ45TDJXWENGS7Y5))
      (map-set token-count 'SP3N66VSF1HAH9BP36XEAT2JZWZ45TDJXWENGS7Y5 (+ (get-balance 'SP3N66VSF1HAH9BP36XEAT2JZWZ45TDJXWENGS7Y5) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u13) 'SP1N8B98NEXFZKSK1HY9KMVCS5XX2EPTDX6C1DAW0))
      (map-set token-count 'SP1N8B98NEXFZKSK1HY9KMVCS5XX2EPTDX6C1DAW0 (+ (get-balance 'SP1N8B98NEXFZKSK1HY9KMVCS5XX2EPTDX6C1DAW0) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u14) 'SP3N66VSF1HAH9BP36XEAT2JZWZ45TDJXWENGS7Y5))
      (map-set token-count 'SP3N66VSF1HAH9BP36XEAT2JZWZ45TDJXWENGS7Y5 (+ (get-balance 'SP3N66VSF1HAH9BP36XEAT2JZWZ45TDJXWENGS7Y5) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u15) 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR))
      (map-set token-count 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR (+ (get-balance 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u16) 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR))
      (map-set token-count 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR (+ (get-balance 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u17) 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR))
      (map-set token-count 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR (+ (get-balance 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u18) 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR))
      (map-set token-count 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR (+ (get-balance 'SPKH205E1MZMBRSQ07PCZN3A1RJCGSHY5P9CM1DR) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u19) 'SP29DWJYKWQ356T8DRGE7BG7ZMPTC1Y7JY97TEVFM))
      (map-set token-count 'SP29DWJYKWQ356T8DRGE7BG7ZMPTC1Y7JY97TEVFM (+ (get-balance 'SP29DWJYKWQ356T8DRGE7BG7ZMPTC1Y7JY97TEVFM) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u20) 'SP1ZCT38K25QAB3SKFANT6HY2ERF58SPMJQJYZFRV))
      (map-set token-count 'SP1ZCT38K25QAB3SKFANT6HY2ERF58SPMJQJYZFRV (+ (get-balance 'SP1ZCT38K25QAB3SKFANT6HY2ERF58SPMJQJYZFRV) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u21) 'SP21K1RWW54ZTYJB3ANR580NVY787CHTTXF7PDF5K))
      (map-set token-count 'SP21K1RWW54ZTYJB3ANR580NVY787CHTTXF7PDF5K (+ (get-balance 'SP21K1RWW54ZTYJB3ANR580NVY787CHTTXF7PDF5K) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u22) 'SP1NHKT2M72WSBWRQFRS3H2A3W5BGWFZZJEXYWZ6Q))
      (map-set token-count 'SP1NHKT2M72WSBWRQFRS3H2A3W5BGWFZZJEXYWZ6Q (+ (get-balance 'SP1NHKT2M72WSBWRQFRS3H2A3W5BGWFZZJEXYWZ6Q) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u23) 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6))
      (map-set token-count 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 (+ (get-balance 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u24) 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ))
      (map-set token-count 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ (+ (get-balance 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u25) 'SP116PWFHERYGV4NJF2NKDE9DZ2PNRFX41NS2EKN))
      (map-set token-count 'SP116PWFHERYGV4NJF2NKDE9DZ2PNRFX41NS2EKN (+ (get-balance 'SP116PWFHERYGV4NJF2NKDE9DZ2PNRFX41NS2EKN) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u26) 'SPH7P46DMTTFNSHDD33N6G8GFE1MQB2R0QW176B1))
      (map-set token-count 'SPH7P46DMTTFNSHDD33N6G8GFE1MQB2R0QW176B1 (+ (get-balance 'SPH7P46DMTTFNSHDD33N6G8GFE1MQB2R0QW176B1) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u27) 'SPF92JPNKM02DV4QX6YX6AA93884J62QVBYKJSD5))
      (map-set token-count 'SPF92JPNKM02DV4QX6YX6AA93884J62QVBYKJSD5 (+ (get-balance 'SPF92JPNKM02DV4QX6YX6AA93884J62QVBYKJSD5) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u28) 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W))
      (map-set token-count 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W (+ (get-balance 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u29) 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W))
      (map-set token-count 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W (+ (get-balance 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u30) 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W))
      (map-set token-count 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W (+ (get-balance 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u31) 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W))
      (map-set token-count 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W (+ (get-balance 'SP1HFWZVHE93NZ75G1D78BW6X74N9GM27JX7TRN1W) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u32) 'SPA3NWNDYGERC9BNK7BH7QFNTCYMPC8XD2Z1V6TF))
      (map-set token-count 'SPA3NWNDYGERC9BNK7BH7QFNTCYMPC8XD2Z1V6TF (+ (get-balance 'SPA3NWNDYGERC9BNK7BH7QFNTCYMPC8XD2Z1V6TF) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u33) 'SP3C6XCM2RR8Z7WS3DQY72HR5V2E4W8HA8CDM2YYJ))
      (map-set token-count 'SP3C6XCM2RR8Z7WS3DQY72HR5V2E4W8HA8CDM2YYJ (+ (get-balance 'SP3C6XCM2RR8Z7WS3DQY72HR5V2E4W8HA8CDM2YYJ) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u34) 'SP2WGKYE37XEW9R75AR8NA71579GNH5HVFSNTQPVJ))
      (map-set token-count 'SP2WGKYE37XEW9R75AR8NA71579GNH5HVFSNTQPVJ (+ (get-balance 'SP2WGKYE37XEW9R75AR8NA71579GNH5HVFSNTQPVJ) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u35) 'SP1KK5CG4VE8AM7CWQ8AQJMSFTYFKB2S6B2ZQM6KE))
      (map-set token-count 'SP1KK5CG4VE8AM7CWQ8AQJMSFTYFKB2S6B2ZQM6KE (+ (get-balance 'SP1KK5CG4VE8AM7CWQ8AQJMSFTYFKB2S6B2ZQM6KE) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u36) 'SP1KK5CG4VE8AM7CWQ8AQJMSFTYFKB2S6B2ZQM6KE))
      (map-set token-count 'SP1KK5CG4VE8AM7CWQ8AQJMSFTYFKB2S6B2ZQM6KE (+ (get-balance 'SP1KK5CG4VE8AM7CWQ8AQJMSFTYFKB2S6B2ZQM6KE) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u37) 'SP2Y5Y9QJ69679NJ2HPBBVEJKGYZMSX4E46JEQQKE))
      (map-set token-count 'SP2Y5Y9QJ69679NJ2HPBBVEJKGYZMSX4E46JEQQKE (+ (get-balance 'SP2Y5Y9QJ69679NJ2HPBBVEJKGYZMSX4E46JEQQKE) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u38) 'SPWRJ6AQRYR8E68GS8XP3TGM33FBA898E08PM1MD))
      (map-set token-count 'SPWRJ6AQRYR8E68GS8XP3TGM33FBA898E08PM1MD (+ (get-balance 'SPWRJ6AQRYR8E68GS8XP3TGM33FBA898E08PM1MD) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u39) 'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59))
      (map-set token-count 'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59 (+ (get-balance 'SPQ5CEHETP8K4Q2FSNNK9ANMPAVBSA9NN86YSN59) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u40) 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG))
      (map-set token-count 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG (+ (get-balance 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u41) 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335))
      (map-set token-count 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335 (+ (get-balance 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u42) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u43) 'SP127263XG6REJ1H6YSNWCEKM9E6XBZ03F4MYR1S5))
      (map-set token-count 'SP127263XG6REJ1H6YSNWCEKM9E6XBZ03F4MYR1S5 (+ (get-balance 'SP127263XG6REJ1H6YSNWCEKM9E6XBZ03F4MYR1S5) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u44) 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ))
      (map-set token-count 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ (+ (get-balance 'SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u45) 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG))
      (map-set token-count 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG (+ (get-balance 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u46) 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87))
      (map-set token-count 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87 (+ (get-balance 'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u47) 'SP28NB976TJHHGF4218KT194NPWP9N1X3WY516Z1P))
      (map-set token-count 'SP28NB976TJHHGF4218KT194NPWP9N1X3WY516Z1P (+ (get-balance 'SP28NB976TJHHGF4218KT194NPWP9N1X3WY516Z1P) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u48) 'SP1ZR1Q8528Z7DC5BVY8JZNX3CTK7ARTBTQER8VS9))
      (map-set token-count 'SP1ZR1Q8528Z7DC5BVY8JZNX3CTK7ARTBTQER8VS9 (+ (get-balance 'SP1ZR1Q8528Z7DC5BVY8JZNX3CTK7ARTBTQER8VS9) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u49) 'SP1ZFD74YXR85GGFXHVCY26P73D1RQ2ME97PRB44J))
      (map-set token-count 'SP1ZFD74YXR85GGFXHVCY26P73D1RQ2ME97PRB44J (+ (get-balance 'SP1ZFD74YXR85GGFXHVCY26P73D1RQ2ME97PRB44J) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u50) 'SP23HDTMC0HTV1R39P71107QA6RW40SBXNRSJZ9G7))
      (map-set token-count 'SP23HDTMC0HTV1R39P71107QA6RW40SBXNRSJZ9G7 (+ (get-balance 'SP23HDTMC0HTV1R39P71107QA6RW40SBXNRSJZ9G7) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u51) 'SP23HDTMC0HTV1R39P71107QA6RW40SBXNRSJZ9G7))
      (map-set token-count 'SP23HDTMC0HTV1R39P71107QA6RW40SBXNRSJZ9G7 (+ (get-balance 'SP23HDTMC0HTV1R39P71107QA6RW40SBXNRSJZ9G7) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u52) 'SPMNYK9F2RHZJHVX0SW4A5J5A2ZART7B3SHY3895))
      (map-set token-count 'SPMNYK9F2RHZJHVX0SW4A5J5A2ZART7B3SHY3895 (+ (get-balance 'SPMNYK9F2RHZJHVX0SW4A5J5A2ZART7B3SHY3895) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u53) 'SP3BJAJVRB1HMKJ8V7TSA72DTKT7C1J4AK4VYD0GJ))
      (map-set token-count 'SP3BJAJVRB1HMKJ8V7TSA72DTKT7C1J4AK4VYD0GJ (+ (get-balance 'SP3BJAJVRB1HMKJ8V7TSA72DTKT7C1J4AK4VYD0GJ) u1))
      (try! (nft-mint? stacks-dead-cats (+ last-nft-id u54) 'SP21K1RWW54ZTYJB3ANR580NVY787CHTTXF7PDF5K))
      (map-set token-count 'SP21K1RWW54ZTYJB3ANR580NVY787CHTTXF7PDF5K (+ (get-balance 'SP21K1RWW54ZTYJB3ANR580NVY787CHTTXF7PDF5K) u1))

      (var-set last-id (+ last-nft-id u55))
      (var-set airdrop-called true)
      (ok true))))