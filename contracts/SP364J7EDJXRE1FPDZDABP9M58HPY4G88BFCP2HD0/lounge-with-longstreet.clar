;; lounge-with-longstreet
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token lounge-with-longstreet uint)

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
(define-data-var mint-limit uint u420)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmPRGDyDm4yMhTwC6pArhuijW1sMDg5Acy3sJ9S1CD9XhT/")
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
      (unwrap! (nft-mint? lounge-with-longstreet next-id tx-sender) next-id)
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
    (nft-burn? lounge-with-longstreet token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? lounge-with-longstreet token-id) false)))

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
  (ok (nft-get-owner? lounge-with-longstreet token-id)))

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
  (match (nft-transfer? lounge-with-longstreet id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? lounge-with-longstreet id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? lounge-with-longstreet id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u0) 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J))
      (map-set token-count 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J (+ (get-balance 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u1) 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7))
      (map-set token-count 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 (+ (get-balance 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u2) 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH))
      (map-set token-count 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH (+ (get-balance 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u3) 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX))
      (map-set token-count 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX (+ (get-balance 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u4) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u5) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u6) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u7) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u8) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u9) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u10) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u11) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u12) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u13) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u14) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u15) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u16) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (map-set token-count 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 (+ (get-balance 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u17) 'SP1RW8644DAFE03DTPS4MMJ83TCVBCBEMVAQG62T6))
      (map-set token-count 'SP1RW8644DAFE03DTPS4MMJ83TCVBCBEMVAQG62T6 (+ (get-balance 'SP1RW8644DAFE03DTPS4MMJ83TCVBCBEMVAQG62T6) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u18) 'SP1V19KW8DVQ5D8YPBVHBF9NZXWMC0Q4FGG7S9NRY))
      (map-set token-count 'SP1V19KW8DVQ5D8YPBVHBF9NZXWMC0Q4FGG7S9NRY (+ (get-balance 'SP1V19KW8DVQ5D8YPBVHBF9NZXWMC0Q4FGG7S9NRY) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u19) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u20) 'SP1YVF9EWSK6HM0JZR4B3KCM7V3NKVE18VVNFSQV5))
      (map-set token-count 'SP1YVF9EWSK6HM0JZR4B3KCM7V3NKVE18VVNFSQV5 (+ (get-balance 'SP1YVF9EWSK6HM0JZR4B3KCM7V3NKVE18VVNFSQV5) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u21) 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8))
      (map-set token-count 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8 (+ (get-balance 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u22) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u23) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u24) 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N))
      (map-set token-count 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N (+ (get-balance 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u25) 'SP28JM4X6GWB3X9KFF01TE8FFND2V9GFRBS1PJGZN))
      (map-set token-count 'SP28JM4X6GWB3X9KFF01TE8FFND2V9GFRBS1PJGZN (+ (get-balance 'SP28JM4X6GWB3X9KFF01TE8FFND2V9GFRBS1PJGZN) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u26) 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC))
      (map-set token-count 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC (+ (get-balance 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u27) 'SP295QANJTGHJJ9TSHJ4WH28Z52VDKWDW68VT8KAH))
      (map-set token-count 'SP295QANJTGHJJ9TSHJ4WH28Z52VDKWDW68VT8KAH (+ (get-balance 'SP295QANJTGHJJ9TSHJ4WH28Z52VDKWDW68VT8KAH) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u28) 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80))
      (map-set token-count 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80 (+ (get-balance 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u29) 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ))
      (map-set token-count 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ (+ (get-balance 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u30) 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D))
      (map-set token-count 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D (+ (get-balance 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u31) 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D))
      (map-set token-count 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D (+ (get-balance 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u32) 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6))
      (map-set token-count 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 (+ (get-balance 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u33) 'SP2PWAZ7FFGGEFA53MG4M8HG3KNAH3Q5TMMG66GJA))
      (map-set token-count 'SP2PWAZ7FFGGEFA53MG4M8HG3KNAH3Q5TMMG66GJA (+ (get-balance 'SP2PWAZ7FFGGEFA53MG4M8HG3KNAH3Q5TMMG66GJA) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u34) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u35) 'SP2RQ9MEEQA2E3DZ7DQY24D3F1XESVR4721PZZ63Q))
      (map-set token-count 'SP2RQ9MEEQA2E3DZ7DQY24D3F1XESVR4721PZZ63Q (+ (get-balance 'SP2RQ9MEEQA2E3DZ7DQY24D3F1XESVR4721PZZ63Q) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u36) 'SP2X5KYYXWFCCH30FHQSAP1XVVAVXFT8P8FS44VRY))
      (map-set token-count 'SP2X5KYYXWFCCH30FHQSAP1XVVAVXFT8P8FS44VRY (+ (get-balance 'SP2X5KYYXWFCCH30FHQSAP1XVVAVXFT8P8FS44VRY) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u37) 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX))
      (map-set token-count 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX (+ (get-balance 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u38) 'SP31SJ2X5683KDX8P58HWRA2DXY3ED4WZ6Z3DM0A9))
      (map-set token-count 'SP31SJ2X5683KDX8P58HWRA2DXY3ED4WZ6Z3DM0A9 (+ (get-balance 'SP31SJ2X5683KDX8P58HWRA2DXY3ED4WZ6Z3DM0A9) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u39) 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20))
      (map-set token-count 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 (+ (get-balance 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u40) 'SPVMTRNCE4MF2C28Q6MQ6HC6ARY1YP54WPZPTXE2))
      (map-set token-count 'SPVMTRNCE4MF2C28Q6MQ6HC6ARY1YP54WPZPTXE2 (+ (get-balance 'SPVMTRNCE4MF2C28Q6MQ6HC6ARY1YP54WPZPTXE2) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u41) 'SP3866CAJYT8HXF36JT0B24DD6WPFSSEWA9CSA1W9))
      (map-set token-count 'SP3866CAJYT8HXF36JT0B24DD6WPFSSEWA9CSA1W9 (+ (get-balance 'SP3866CAJYT8HXF36JT0B24DD6WPFSSEWA9CSA1W9) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u42) 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0))
      (map-set token-count 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0 (+ (get-balance 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u43) 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6))
      (map-set token-count 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 (+ (get-balance 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u44) 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES))
      (map-set token-count 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES (+ (get-balance 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u45) 'SP3DXVC12KG5PV0545PJF15VQVN6CZ641QH82GYYQ))
      (map-set token-count 'SP3DXVC12KG5PV0545PJF15VQVN6CZ641QH82GYYQ (+ (get-balance 'SP3DXVC12KG5PV0545PJF15VQVN6CZ641QH82GYYQ) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u46) 'SP3FHNTPZ8HYZNFER6EWJ7DZ6Q3WNPVKFWJST7GYR))
      (map-set token-count 'SP3FHNTPZ8HYZNFER6EWJ7DZ6Q3WNPVKFWJST7GYR (+ (get-balance 'SP3FHNTPZ8HYZNFER6EWJ7DZ6Q3WNPVKFWJST7GYR) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u47) 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10))
      (map-set token-count 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10 (+ (get-balance 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u48) 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10))
      (map-set token-count 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10 (+ (get-balance 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u49) 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10))
      (map-set token-count 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10 (+ (get-balance 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u50) 'SP3JK6D2D6MC8PWVCZ0Q9N1786E5PMY744XS1CVGN))
      (map-set token-count 'SP3JK6D2D6MC8PWVCZ0Q9N1786E5PMY744XS1CVGN (+ (get-balance 'SP3JK6D2D6MC8PWVCZ0Q9N1786E5PMY744XS1CVGN) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u51) 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY))
      (map-set token-count 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY (+ (get-balance 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u52) 'SP3JYDFHTNVTDWFDMNG6A3RPCAAJ5NT17EMGP8AQD))
      (map-set token-count 'SP3JYDFHTNVTDWFDMNG6A3RPCAAJ5NT17EMGP8AQD (+ (get-balance 'SP3JYDFHTNVTDWFDMNG6A3RPCAAJ5NT17EMGP8AQD) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u53) 'SP3JYDFHTNVTDWFDMNG6A3RPCAAJ5NT17EMGP8AQD))
      (map-set token-count 'SP3JYDFHTNVTDWFDMNG6A3RPCAAJ5NT17EMGP8AQD (+ (get-balance 'SP3JYDFHTNVTDWFDMNG6A3RPCAAJ5NT17EMGP8AQD) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u54) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u55) 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF))
      (map-set token-count 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF (+ (get-balance 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u56) 'SP3ST6K5W36V2MTSNYYXE56SCXR7DGTW9N4NMZHYV))
      (map-set token-count 'SP3ST6K5W36V2MTSNYYXE56SCXR7DGTW9N4NMZHYV (+ (get-balance 'SP3ST6K5W36V2MTSNYYXE56SCXR7DGTW9N4NMZHYV) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u57) 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW))
      (map-set token-count 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW (+ (get-balance 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u58) 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK))
      (map-set token-count 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK (+ (get-balance 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u59) 'SP3Z2QT1HN3CQE03XY2CRRC0TFM8QYSKKV0ETB96N))
      (map-set token-count 'SP3Z2QT1HN3CQE03XY2CRRC0TFM8QYSKKV0ETB96N (+ (get-balance 'SP3Z2QT1HN3CQE03XY2CRRC0TFM8QYSKKV0ETB96N) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u60) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u61) 'SP3ZCZ0CDR5EH8XYYXQ9H6P5G43N6YYCYYYX0BTMJ))
      (map-set token-count 'SP3ZCZ0CDR5EH8XYYXQ9H6P5G43N6YYCYYYX0BTMJ (+ (get-balance 'SP3ZCZ0CDR5EH8XYYXQ9H6P5G43N6YYCYYYX0BTMJ) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u62) 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD))
      (map-set token-count 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD (+ (get-balance 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u63) 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG))
      (map-set token-count 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG (+ (get-balance 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u64) 'SP6VV2AFXM7ZMT5V3ZAE8M6JXK9EA5N1GPFHJC4M))
      (map-set token-count 'SP6VV2AFXM7ZMT5V3ZAE8M6JXK9EA5N1GPFHJC4M (+ (get-balance 'SP6VV2AFXM7ZMT5V3ZAE8M6JXK9EA5N1GPFHJC4M) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u65) 'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V))
      (map-set token-count 'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V (+ (get-balance 'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u66) 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7))
      (map-set token-count 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7 (+ (get-balance 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u67) 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558))
      (map-set token-count 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558 (+ (get-balance 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u68) 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB))
      (map-set token-count 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB (+ (get-balance 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u69) 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB))
      (map-set token-count 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB (+ (get-balance 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u70) 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ))
      (map-set token-count 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ (+ (get-balance 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u71) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u72) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))
      (try! (nft-mint? lounge-with-longstreet (+ last-nft-id u73) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))

      (var-set last-id (+ last-nft-id u74))
      (var-set airdrop-called true)
      (ok true))))