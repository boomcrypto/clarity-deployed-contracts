;; game-on
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token game-on uint)

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
(define-data-var mint-limit uint u400)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP289VXX3BR141M6PFM7C6BE4Z7C4JHFJZ5F17JSZ)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmcVPmoRGGSTGMVJjC71Hvi4XBC3kgHPCgwoBeHrYsPGX4/json/")
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

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

;; Mintpass Minting
(define-private (mint (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many orders)
      )
    )))

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
      (unwrap! (nft-mint? game-on next-id tx-sender) next-id)
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
    (nft-burn? game-on token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? game-on token-id) false)))

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
  (ok (nft-get-owner? game-on token-id)))

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
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? game-on id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? game-on id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? game-on id) (err ERR-NOT-FOUND)))
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

;; Extra functionality required for mintpass
(define-public (toggle-sale-state)
  (let 
    (
      ;; (premint (not (var-get premint-enabled)))
      (sale (not (var-get sale-enabled)))
    )
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set premint-enabled false)
    (var-set sale-enabled sale)
    (print { sale: sale })
    (ok true)))

(define-public (enable-premint)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled true))))

(define-public (disable-premint)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled false))))

(define-read-only (get-passes (caller principal))
  (default-to u0 (map-get? mint-passes caller)))

(define-read-only (get-premint-enabled)
  (ok (var-get premint-enabled)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))  

(map-set mint-passes 'SPE9CQ6VBE2DER8MG4DJVZ9123CZM0QSVGWXSKWD u1)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u1)
(map-set mint-passes 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV u1)
(map-set mint-passes 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D u1)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u1)
(map-set mint-passes 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV u1)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u1)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u1)
(map-set mint-passes 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q u2)
(map-set mint-passes 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV u1)
(map-set mint-passes 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V u1)
(map-set mint-passes 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR u1)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u3)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? game-on (+ last-nft-id u0) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u1) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u2) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u3) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u4) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u5) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u6) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u7) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u8) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u9) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u10) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u11) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u12) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u13) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u14) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u15) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u16) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u17) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u18) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u19) 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3))
      (map-set token-count 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3 (+ (get-balance 'SP8HMQP4Q63V3E6SXXPXZ4WJXA263HBD95QY2AM3) u1))
      (try! (nft-mint? game-on (+ last-nft-id u20) 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF))
      (map-set token-count 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF (+ (get-balance 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF) u1))
      (try! (nft-mint? game-on (+ last-nft-id u21) 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF))
      (map-set token-count 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF (+ (get-balance 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF) u1))
      (try! (nft-mint? game-on (+ last-nft-id u22) 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF))
      (map-set token-count 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF (+ (get-balance 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF) u1))
      (try! (nft-mint? game-on (+ last-nft-id u23) 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF))
      (map-set token-count 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF (+ (get-balance 'SP2CSGM4TXAVPQTDH4H89JHKYZCZF0B5GQ4W0SFPF) u1))

      (var-set last-id (+ last-nft-id u24))
      (var-set airdrop-called true)
      (ok true))))