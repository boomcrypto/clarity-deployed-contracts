;; btc-sports-vip-pass
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token btc-sports-vip-pass uint)

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
(define-constant ERR-STAKING-FROZEN u115)
(define-constant ERR-STAKED u116)
(define-constant ERR-ITEM-LISTED u117)

;; Internal variables
(define-data-var mint-limit uint u500)
(define-data-var last-id uint u1)
(define-data-var total-price uint u250000000)
(define-data-var artist-address principal 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmbC5AFjvJtW9LZKmzxKjJP9TZ6ZcCSBvoeP1SMpb8CcZf/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)
(define-data-var approved-staking-contract principal 'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW)
(define-data-var staking-frozen bool false)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)
(define-map transferable uint bool)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-five) (mint (list true true true true true)))

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
      (unwrap! (nft-mint? btc-sports-vip-pass next-id tx-sender) next-id)
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
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? btc-sports-vip-pass token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? btc-sports-vip-pass token-id) false)))

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
    (asserts! (default-to true (map-get? transferable id)) (err ERR-STAKED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? btc-sports-vip-pass token-id)))

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
  (match (nft-transfer? btc-sports-vip-pass id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? btc-sports-vip-pass id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait), royalty: (var-get royalty-percent)}))
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (asserts! (default-to true (map-get? transferable id)) (err ERR-STAKED))
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
  (let ((owner (unwrap! (nft-get-owner? btc-sports-vip-pass id) (err ERR-NOT-FOUND)))
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

;; Alt Minting Mintpass
(define-data-var total-price-banana uint u1300000000)

(define-read-only (get-price-banana)
  (ok (var-get total-price-banana)))

(define-public (set-price-banana (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-banana price))))

(define-public (claim-banana)
  (mint-banana (list true)))

(define-public (claim-two-banana) (mint-banana (list true true)))

(define-public (claim-three-banana) (mint-banana (list true true true)))

(define-public (claim-four-banana) (mint-banana (list true true true true)))

(define-public (claim-five-banana) (mint-banana (list true true true true true)))

(define-private (mint-banana (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-banana orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-banana orders)
      )
    )))

(define-private (mint-many-banana (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-banana) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Alt Minting Mintpass
(define-data-var total-price-slime uint u14000000000)

(define-read-only (get-price-slime)
  (ok (var-get total-price-slime)))

(define-public (set-price-slime (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-slime price))))

(define-public (claim-slime)
  (mint-slime (list true)))

(define-public (claim-two-slime) (mint-slime (list true true)))

(define-public (claim-three-slime) (mint-slime (list true true true)))

(define-public (claim-four-slime) (mint-slime (list true true true true)))

(define-public (claim-five-slime) (mint-slime (list true true true true true)))

(define-private (mint-slime (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-slime orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-slime orders)
      )
    )))

(define-private (mint-many-slime (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-slime) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

(map-set mint-passes 'SP10GJCQ6SX1GN33Y925GE0SQPHQYJAFM7M1CC61P u2)

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u0) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u1) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u2) 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV))
      (map-set token-count 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV (+ (get-balance 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u3) 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV))
      (map-set token-count 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV (+ (get-balance 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u4) 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S))
      (map-set token-count 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S (+ (get-balance 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u5) 'SPEJ2JKG5SVZD793CEWFZQ0VDPEGZ6QVP39QFAHM))
      (map-set token-count 'SPEJ2JKG5SVZD793CEWFZQ0VDPEGZ6QVP39QFAHM (+ (get-balance 'SPEJ2JKG5SVZD793CEWFZQ0VDPEGZ6QVP39QFAHM) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u6) 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA))
      (map-set token-count 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA (+ (get-balance 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u7) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u8) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u9) 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6))
      (map-set token-count 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6 (+ (get-balance 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u10) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u11) 'SP467VFDYHV185JSQ98V9VTA7JS3PFJ3DM8PXD20))
      (map-set token-count 'SP467VFDYHV185JSQ98V9VTA7JS3PFJ3DM8PXD20 (+ (get-balance 'SP467VFDYHV185JSQ98V9VTA7JS3PFJ3DM8PXD20) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u12) 'SP4D5X7MNXVGVC344KPBQ20T1EK5MGHA56TZ7NHT))
      (map-set token-count 'SP4D5X7MNXVGVC344KPBQ20T1EK5MGHA56TZ7NHT (+ (get-balance 'SP4D5X7MNXVGVC344KPBQ20T1EK5MGHA56TZ7NHT) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u13) 'SP4D5X7MNXVGVC344KPBQ20T1EK5MGHA56TZ7NHT))
      (map-set token-count 'SP4D5X7MNXVGVC344KPBQ20T1EK5MGHA56TZ7NHT (+ (get-balance 'SP4D5X7MNXVGVC344KPBQ20T1EK5MGHA56TZ7NHT) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u14) 'SPT1BS3PV5Z16S3V6ZEVWHVQS4RTJXS849R19KVC))
      (map-set token-count 'SPT1BS3PV5Z16S3V6ZEVWHVQS4RTJXS849R19KVC (+ (get-balance 'SPT1BS3PV5Z16S3V6ZEVWHVQS4RTJXS849R19KVC) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u15) 'SPT1BS3PV5Z16S3V6ZEVWHVQS4RTJXS849R19KVC))
      (map-set token-count 'SPT1BS3PV5Z16S3V6ZEVWHVQS4RTJXS849R19KVC (+ (get-balance 'SPT1BS3PV5Z16S3V6ZEVWHVQS4RTJXS849R19KVC) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u16) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u17) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u18) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u19) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u20) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u21) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u22) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u23) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u24) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u25) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u26) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u27) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u28) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u29) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u30) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u31) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u32) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u33) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u34) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u35) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u36) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u37) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u38) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-vip-pass (+ last-nft-id u39) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))

      (var-set last-id (+ last-nft-id u40))
      (var-set airdrop-called true)
      (ok true))))

(define-public (set-mint-passes (addr principal) (passes uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (map-set mint-passes addr passes)
    (ok true)
  )
)

(define-public (add-mint-passes (addr principal) (passes uint))
  (let (
      (existing-passes (get-mints addr))
    )
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (map-set mint-passes addr (+ existing-passes passes))
    (ok true)
  )
)

(define-public (set-transferable (id uint) (switch bool))
  (begin
    (asserts! (is-sender-owner id) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-eq contract-caller (var-get approved-staking-contract)) (err ERR-NOT-AUTHORIZED))
    (if (not switch) (asserts! (is-none (get-listing-in-ustx id)) (err ERR-ITEM-LISTED)) true)
    (map-set transferable id switch)
    (ok true)))

(define-public (change-staking (address principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get staking-frozen)) (err ERR-STAKING-FROZEN))
    (var-set approved-staking-contract address)
    (ok true)))

(define-public (freeze-staking)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (var-set staking-frozen true)
    (ok true)))
