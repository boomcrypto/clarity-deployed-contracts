;; goodbye-eth
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token goodbye-eth uint)

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
(define-data-var mint-limit uint u111)
(define-data-var last-id uint u1)
(define-data-var total-price uint u111000000)
(define-data-var artist-address principal 'SPNBGQ5GBVX08HA1P09JNZCZP1FMJ2ZPJR57KHEV)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qmc3bL17jYFqjke3wKfGADMEoC6NaPv32HhN6BA7AcAqv2/json/")
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
      (unwrap! (nft-mint? goodbye-eth next-id tx-sender) next-id)
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
    (nft-burn? goodbye-eth token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? goodbye-eth token-id) false)))

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
  (ok (nft-get-owner? goodbye-eth token-id)))

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
  (match (nft-transfer? goodbye-eth id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? goodbye-eth id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? goodbye-eth id) (err ERR-NOT-FOUND)))
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
  

;; Alt Minting Default
(define-data-var total-price-xbtc uint u343800)

(define-read-only (get-price-xbtc)
  (ok (var-get total-price-xbtc)))

(define-public (set-price-xbtc (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-xbtc price))))

(define-public (claim-xbtc)
  (mint-xbtc (list true)))

(define-public (claim-two-xbtc) (mint-xbtc (list true true)))

(define-public (claim-three-xbtc) (mint-xbtc (list true true true)))


(define-private (mint-xbtc (orders (list 25 bool)))
  (mint-many-xbtc orders))

(define-private (mint-many-xbtc (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-xbtc) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Alt Minting Default
(define-data-var total-price-usda uint u83000000)

(define-read-only (get-price-usda)
  (ok (var-get total-price-usda)))

(define-public (set-price-usda (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-usda price))))

(define-public (claim-usda)
  (mint-usda (list true)))

(define-public (claim-two-usda) (mint-usda (list true true)))

(define-public (claim-three-usda) (mint-usda (list true true true)))


(define-private (mint-usda (orders (list 25 bool)))
  (mint-many-usda orders))

(define-private (mint-many-usda (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-usda) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Alt Minting Default
(define-data-var total-price-mia2 uint u141771000000)

(define-read-only (get-price-mia2)
  (ok (var-get total-price-mia2)))

(define-public (set-price-mia2 (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-mia2 price))))

(define-public (claim-mia2)
  (mint-mia2 (list true)))

(define-public (claim-two-mia2) (mint-mia2 (list true true)))

(define-public (claim-three-mia2) (mint-mia2 (list true true true)))


(define-private (mint-mia2 (orders (list 25 bool)))
  (mint-many-mia2 orders))

(define-private (mint-many-mia2 (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-mia2) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Alt Minting Default
(define-data-var total-price-nyc2 uint u110298000000)

(define-read-only (get-price-nyc2)
  (ok (var-get total-price-nyc2)))

(define-public (set-price-nyc2 (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-nyc2 price))))

(define-public (claim-nyc2)
  (mint-nyc2 (list true)))

(define-public (claim-two-nyc2) (mint-nyc2 (list true true)))

(define-public (claim-three-nyc2) (mint-nyc2 (list true true true)))


(define-private (mint-nyc2 (orders (list 25 bool)))
  (mint-many-nyc2 orders))

(define-private (mint-many-nyc2 (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-nyc2) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Alt Minting Default
(define-data-var total-price-banana uint u569000000)

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


(define-private (mint-banana (orders (list 25 bool)))
  (mint-many-banana orders))

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

;; Alt Minting Default
(define-data-var total-price-slime uint u9472000000)

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


(define-private (mint-slime (orders (list 25 bool)))
  (mint-many-slime orders))

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

;; Alt Minting Default
(define-data-var total-price-alex uint u147600000000)

(define-read-only (get-price-alex)
  (ok (var-get total-price-alex)))

(define-public (set-price-alex (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-alex price))))

(define-public (claim-alex)
  (mint-alex (list true)))

(define-public (claim-two-alex) (mint-alex (list true true)))

(define-public (claim-three-alex) (mint-alex (list true true true)))


(define-private (mint-alex (orders (list 25 bool)))
  (mint-many-alex orders))

(define-private (mint-many-alex (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-alex) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u0) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u1) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u2) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u3) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u4) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u5) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u6) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u7) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u8) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u9) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u10) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u11) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u12) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u13) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u14) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u15) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u16) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u17) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u18) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u19) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u20) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u21) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u22) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u23) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u24) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u25) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u26) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u27) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u28) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u29) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u30) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u31) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u32) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u33) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u34) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u35) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u36) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u37) 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z))
      (map-set token-count 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z (+ (get-balance 'SP35E5TRPMRPYMDZ88TJ5678AYW9RGFCNM2D3228Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u38) 'SPZEW7PN7KF2N5V74B4JV9KG59TN2NY229FGDRXS))
      (map-set token-count 'SPZEW7PN7KF2N5V74B4JV9KG59TN2NY229FGDRXS (+ (get-balance 'SPZEW7PN7KF2N5V74B4JV9KG59TN2NY229FGDRXS) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u39) 'SPZEW7PN7KF2N5V74B4JV9KG59TN2NY229FGDRXS))
      (map-set token-count 'SPZEW7PN7KF2N5V74B4JV9KG59TN2NY229FGDRXS (+ (get-balance 'SPZEW7PN7KF2N5V74B4JV9KG59TN2NY229FGDRXS) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u40) 'SPK24KWEZ64RRQMB2GFAH87XX196WG7ZM4MN2NRP))
      (map-set token-count 'SPK24KWEZ64RRQMB2GFAH87XX196WG7ZM4MN2NRP (+ (get-balance 'SPK24KWEZ64RRQMB2GFAH87XX196WG7ZM4MN2NRP) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u41) 'SP1TQHWAVYHTDJFV7CENFJQA3C0S9XB94TD66SRCT))
      (map-set token-count 'SP1TQHWAVYHTDJFV7CENFJQA3C0S9XB94TD66SRCT (+ (get-balance 'SP1TQHWAVYHTDJFV7CENFJQA3C0S9XB94TD66SRCT) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u42) 'SPTVQVKNZ2N2W8QYR34V6KT7QPCMS3N4ARCPHAD7))
      (map-set token-count 'SPTVQVKNZ2N2W8QYR34V6KT7QPCMS3N4ARCPHAD7 (+ (get-balance 'SPTVQVKNZ2N2W8QYR34V6KT7QPCMS3N4ARCPHAD7) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u43) 'SPTVQVKNZ2N2W8QYR34V6KT7QPCMS3N4ARCPHAD7))
      (map-set token-count 'SPTVQVKNZ2N2W8QYR34V6KT7QPCMS3N4ARCPHAD7 (+ (get-balance 'SPTVQVKNZ2N2W8QYR34V6KT7QPCMS3N4ARCPHAD7) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u44) 'SP2J3QZ32TYX44K5M748MMHEXVKN0QAJ32ZTV8E1C))
      (map-set token-count 'SP2J3QZ32TYX44K5M748MMHEXVKN0QAJ32ZTV8E1C (+ (get-balance 'SP2J3QZ32TYX44K5M748MMHEXVKN0QAJ32ZTV8E1C) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u45) 'SP2J3QZ32TYX44K5M748MMHEXVKN0QAJ32ZTV8E1C))
      (map-set token-count 'SP2J3QZ32TYX44K5M748MMHEXVKN0QAJ32ZTV8E1C (+ (get-balance 'SP2J3QZ32TYX44K5M748MMHEXVKN0QAJ32ZTV8E1C) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u46) 'SP2J3QZ32TYX44K5M748MMHEXVKN0QAJ32ZTV8E1C))
      (map-set token-count 'SP2J3QZ32TYX44K5M748MMHEXVKN0QAJ32ZTV8E1C (+ (get-balance 'SP2J3QZ32TYX44K5M748MMHEXVKN0QAJ32ZTV8E1C) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u47) 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP))
      (map-set token-count 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP (+ (get-balance 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u48) 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP))
      (map-set token-count 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP (+ (get-balance 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u49) 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP))
      (map-set token-count 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP (+ (get-balance 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u50) 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP))
      (map-set token-count 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP (+ (get-balance 'SP1R7KA5DXEN5SBFFTE91ZEADNCWAAFB9VDZXVHGP) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u51) 'SPGWNJJJ1QGSV2Q2VCX4J17S7FA9VC56RXGAQ3VK))
      (map-set token-count 'SPGWNJJJ1QGSV2Q2VCX4J17S7FA9VC56RXGAQ3VK (+ (get-balance 'SPGWNJJJ1QGSV2Q2VCX4J17S7FA9VC56RXGAQ3VK) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u52) 'SP1ECSCC7CQ172ARRYTNZ6A8ZCMPBHBYAGWSYZZP6))
      (map-set token-count 'SP1ECSCC7CQ172ARRYTNZ6A8ZCMPBHBYAGWSYZZP6 (+ (get-balance 'SP1ECSCC7CQ172ARRYTNZ6A8ZCMPBHBYAGWSYZZP6) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u53) 'SP2SY4BKPKSQZNSRRMWM80W06N3KHA9606SJAESDQ))
      (map-set token-count 'SP2SY4BKPKSQZNSRRMWM80W06N3KHA9606SJAESDQ (+ (get-balance 'SP2SY4BKPKSQZNSRRMWM80W06N3KHA9606SJAESDQ) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u54) 'SPHYNMYYW3C8DZYH2CAGV40YYBAT58NP3T7MHY4V))
      (map-set token-count 'SPHYNMYYW3C8DZYH2CAGV40YYBAT58NP3T7MHY4V (+ (get-balance 'SPHYNMYYW3C8DZYH2CAGV40YYBAT58NP3T7MHY4V) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u55) 'SP2X7NAHWSMBYFKVFPQHA3HGHX34AQZJPZGAPJ14D))
      (map-set token-count 'SP2X7NAHWSMBYFKVFPQHA3HGHX34AQZJPZGAPJ14D (+ (get-balance 'SP2X7NAHWSMBYFKVFPQHA3HGHX34AQZJPZGAPJ14D) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u56) 'SP2X7NAHWSMBYFKVFPQHA3HGHX34AQZJPZGAPJ14D))
      (map-set token-count 'SP2X7NAHWSMBYFKVFPQHA3HGHX34AQZJPZGAPJ14D (+ (get-balance 'SP2X7NAHWSMBYFKVFPQHA3HGHX34AQZJPZGAPJ14D) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u57) 'SP2BSPJDZHF4MY0E73VRHF99QYGPVNN6ANNSZKZ70))
      (map-set token-count 'SP2BSPJDZHF4MY0E73VRHF99QYGPVNN6ANNSZKZ70 (+ (get-balance 'SP2BSPJDZHF4MY0E73VRHF99QYGPVNN6ANNSZKZ70) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u58) 'SP3JG4NW331T2V8MZ1KAETT2KNM06W0SD7F2BZJG5))
      (map-set token-count 'SP3JG4NW331T2V8MZ1KAETT2KNM06W0SD7F2BZJG5 (+ (get-balance 'SP3JG4NW331T2V8MZ1KAETT2KNM06W0SD7F2BZJG5) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u59) 'SP3JG4NW331T2V8MZ1KAETT2KNM06W0SD7F2BZJG5))
      (map-set token-count 'SP3JG4NW331T2V8MZ1KAETT2KNM06W0SD7F2BZJG5 (+ (get-balance 'SP3JG4NW331T2V8MZ1KAETT2KNM06W0SD7F2BZJG5) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u60) 'SP3JG4NW331T2V8MZ1KAETT2KNM06W0SD7F2BZJG5))
      (map-set token-count 'SP3JG4NW331T2V8MZ1KAETT2KNM06W0SD7F2BZJG5 (+ (get-balance 'SP3JG4NW331T2V8MZ1KAETT2KNM06W0SD7F2BZJG5) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u61) 'SP3YT9M5QAQ4Q9320BT6E13A95A9TNXM3NHKSTYJH))
      (map-set token-count 'SP3YT9M5QAQ4Q9320BT6E13A95A9TNXM3NHKSTYJH (+ (get-balance 'SP3YT9M5QAQ4Q9320BT6E13A95A9TNXM3NHKSTYJH) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u62) 'SP2MV6HXP5N1DCH0SRTA1V1V5CPNR2HTXK1B190Q8))
      (map-set token-count 'SP2MV6HXP5N1DCH0SRTA1V1V5CPNR2HTXK1B190Q8 (+ (get-balance 'SP2MV6HXP5N1DCH0SRTA1V1V5CPNR2HTXK1B190Q8) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u63) 'SP1MDYRHBG5DXKB6J4QFJG2PM3QS3S8XX0DJ2V87R))
      (map-set token-count 'SP1MDYRHBG5DXKB6J4QFJG2PM3QS3S8XX0DJ2V87R (+ (get-balance 'SP1MDYRHBG5DXKB6J4QFJG2PM3QS3S8XX0DJ2V87R) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u64) 'SP33Y6ECDXKNH869DTAD8Q12VSJ46XDJNYZGZ7RRY))
      (map-set token-count 'SP33Y6ECDXKNH869DTAD8Q12VSJ46XDJNYZGZ7RRY (+ (get-balance 'SP33Y6ECDXKNH869DTAD8Q12VSJ46XDJNYZGZ7RRY) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u65) 'SP2HARF82Z6ZS9W89C5CFDT9TJ5ZFP0K56TR812F2))
      (map-set token-count 'SP2HARF82Z6ZS9W89C5CFDT9TJ5ZFP0K56TR812F2 (+ (get-balance 'SP2HARF82Z6ZS9W89C5CFDT9TJ5ZFP0K56TR812F2) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u66) 'SP2HSTDE5SMMVAC3QP8KXTM37BBJTTGWJ0KSRH4P1))
      (map-set token-count 'SP2HSTDE5SMMVAC3QP8KXTM37BBJTTGWJ0KSRH4P1 (+ (get-balance 'SP2HSTDE5SMMVAC3QP8KXTM37BBJTTGWJ0KSRH4P1) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u67) 'SP3WKVYSYCH166NNXMDVH7Q1BTMH6VR4TZRG3F66H))
      (map-set token-count 'SP3WKVYSYCH166NNXMDVH7Q1BTMH6VR4TZRG3F66H (+ (get-balance 'SP3WKVYSYCH166NNXMDVH7Q1BTMH6VR4TZRG3F66H) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u68) 'SP297P5RNZ6FB9EWRE3MZM8BTEHYJE76Q7EHM0X5Y))
      (map-set token-count 'SP297P5RNZ6FB9EWRE3MZM8BTEHYJE76Q7EHM0X5Y (+ (get-balance 'SP297P5RNZ6FB9EWRE3MZM8BTEHYJE76Q7EHM0X5Y) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u69) 'SP2S1W0ZAQSVEJ89KAJEG2DV57THMR87CV40GA4WB))
      (map-set token-count 'SP2S1W0ZAQSVEJ89KAJEG2DV57THMR87CV40GA4WB (+ (get-balance 'SP2S1W0ZAQSVEJ89KAJEG2DV57THMR87CV40GA4WB) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u70) 'SP9DE8JYNCTAE47F5FSSDHYQ7NMQHMYEVR43R2JP))
      (map-set token-count 'SP9DE8JYNCTAE47F5FSSDHYQ7NMQHMYEVR43R2JP (+ (get-balance 'SP9DE8JYNCTAE47F5FSSDHYQ7NMQHMYEVR43R2JP) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u71) 'SP2ZTAB20X1THDE5MBEDTZD1ZMVYWC1E1WBTJGFBT))
      (map-set token-count 'SP2ZTAB20X1THDE5MBEDTZD1ZMVYWC1E1WBTJGFBT (+ (get-balance 'SP2ZTAB20X1THDE5MBEDTZD1ZMVYWC1E1WBTJGFBT) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u72) 'SP39RY5QPS2VZGSNRK0H6VCZNBP5684R1MK0EAKEC))
      (map-set token-count 'SP39RY5QPS2VZGSNRK0H6VCZNBP5684R1MK0EAKEC (+ (get-balance 'SP39RY5QPS2VZGSNRK0H6VCZNBP5684R1MK0EAKEC) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u73) 'SP3HJ9CJES6835149T2F8WF33PTSVEJDAMQ9M0F3N))
      (map-set token-count 'SP3HJ9CJES6835149T2F8WF33PTSVEJDAMQ9M0F3N (+ (get-balance 'SP3HJ9CJES6835149T2F8WF33PTSVEJDAMQ9M0F3N) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u74) 'SP20D3V7CTVP2J23P3WE0KYZR7MA67SK2A84CSSE8))
      (map-set token-count 'SP20D3V7CTVP2J23P3WE0KYZR7MA67SK2A84CSSE8 (+ (get-balance 'SP20D3V7CTVP2J23P3WE0KYZR7MA67SK2A84CSSE8) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u75) 'SP20D3V7CTVP2J23P3WE0KYZR7MA67SK2A84CSSE8))
      (map-set token-count 'SP20D3V7CTVP2J23P3WE0KYZR7MA67SK2A84CSSE8 (+ (get-balance 'SP20D3V7CTVP2J23P3WE0KYZR7MA67SK2A84CSSE8) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u76) 'SPVAE0JCD6C3H0WN9K43HCMEW3Z8S8S3Q9J9V45M))
      (map-set token-count 'SPVAE0JCD6C3H0WN9K43HCMEW3Z8S8S3Q9J9V45M (+ (get-balance 'SPVAE0JCD6C3H0WN9K43HCMEW3Z8S8S3Q9J9V45M) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u77) 'SP3M2A8M5XQHD6Z0RTEH7F7CQR791D2HHFFYN9H85))
      (map-set token-count 'SP3M2A8M5XQHD6Z0RTEH7F7CQR791D2HHFFYN9H85 (+ (get-balance 'SP3M2A8M5XQHD6Z0RTEH7F7CQR791D2HHFFYN9H85) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u78) 'SP2WCBT9W1RCR3J6PE2XP1AK24N2S9TNVXYYX4KK3))
      (map-set token-count 'SP2WCBT9W1RCR3J6PE2XP1AK24N2S9TNVXYYX4KK3 (+ (get-balance 'SP2WCBT9W1RCR3J6PE2XP1AK24N2S9TNVXYYX4KK3) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u79) 'SP1BGBE41EDN2E65YJC70ACS9D34ESVVBQW7BZ6T9))
      (map-set token-count 'SP1BGBE41EDN2E65YJC70ACS9D34ESVVBQW7BZ6T9 (+ (get-balance 'SP1BGBE41EDN2E65YJC70ACS9D34ESVVBQW7BZ6T9) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u80) 'SPXYR5Y6M67HYT09TPXPA6Q6CFYPFSYF2BR38Z3F))
      (map-set token-count 'SPXYR5Y6M67HYT09TPXPA6Q6CFYPFSYF2BR38Z3F (+ (get-balance 'SPXYR5Y6M67HYT09TPXPA6Q6CFYPFSYF2BR38Z3F) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u81) 'SP39RFBN925PH1JP3VWWXZNRNBQ18BXD73BRQGW3H))
      (map-set token-count 'SP39RFBN925PH1JP3VWWXZNRNBQ18BXD73BRQGW3H (+ (get-balance 'SP39RFBN925PH1JP3VWWXZNRNBQ18BXD73BRQGW3H) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u82) 'SP2CRCVC6M38MPSQD8NA08Y265K1TD35JNSYY3HQM))
      (map-set token-count 'SP2CRCVC6M38MPSQD8NA08Y265K1TD35JNSYY3HQM (+ (get-balance 'SP2CRCVC6M38MPSQD8NA08Y265K1TD35JNSYY3HQM) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u83) 'SPHE0J7HDNN5J6QTEJNCFRCDSNPYNKSYBGZZFMHP))
      (map-set token-count 'SPHE0J7HDNN5J6QTEJNCFRCDSNPYNKSYBGZZFMHP (+ (get-balance 'SPHE0J7HDNN5J6QTEJNCFRCDSNPYNKSYBGZZFMHP) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u84) 'SP28CB27E62AZAQMS47MPRVT5J4PFJZVZNV97GYX4))
      (map-set token-count 'SP28CB27E62AZAQMS47MPRVT5J4PFJZVZNV97GYX4 (+ (get-balance 'SP28CB27E62AZAQMS47MPRVT5J4PFJZVZNV97GYX4) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u85) 'SP3WMB9TF21WQ71J89333FASCGV1D5Q48D59K9MNW))
      (map-set token-count 'SP3WMB9TF21WQ71J89333FASCGV1D5Q48D59K9MNW (+ (get-balance 'SP3WMB9TF21WQ71J89333FASCGV1D5Q48D59K9MNW) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u86) 'SP1AQ4W3E7ATNA66FDW08YPNE7EE8J5XYYNXC90TG))
      (map-set token-count 'SP1AQ4W3E7ATNA66FDW08YPNE7EE8J5XYYNXC90TG (+ (get-balance 'SP1AQ4W3E7ATNA66FDW08YPNE7EE8J5XYYNXC90TG) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u87) 'SP1EEGVYDK2WB6QW2MQF16R345VJHYYG7HMK7X9N3))
      (map-set token-count 'SP1EEGVYDK2WB6QW2MQF16R345VJHYYG7HMK7X9N3 (+ (get-balance 'SP1EEGVYDK2WB6QW2MQF16R345VJHYYG7HMK7X9N3) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u88) 'SP29TEPA0SY0VPWRY0YF1702AN3HYWYC8YJ4BVTMK))
      (map-set token-count 'SP29TEPA0SY0VPWRY0YF1702AN3HYWYC8YJ4BVTMK (+ (get-balance 'SP29TEPA0SY0VPWRY0YF1702AN3HYWYC8YJ4BVTMK) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u89) 'SP1T36HRNZBCK6VF3ESYCYY7K73PMYYXV4R3NH5CZ))
      (map-set token-count 'SP1T36HRNZBCK6VF3ESYCYY7K73PMYYXV4R3NH5CZ (+ (get-balance 'SP1T36HRNZBCK6VF3ESYCYY7K73PMYYXV4R3NH5CZ) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u90) 'SP3Z4TC5D1D60VZTKRXMSYP8SWXJZ8WM33G9QVKFW))
      (map-set token-count 'SP3Z4TC5D1D60VZTKRXMSYP8SWXJZ8WM33G9QVKFW (+ (get-balance 'SP3Z4TC5D1D60VZTKRXMSYP8SWXJZ8WM33G9QVKFW) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u91) 'SP3RXE1XATCSPEFZ6ZPR3JXA53TMSEZX7Y7BK3ADN))
      (map-set token-count 'SP3RXE1XATCSPEFZ6ZPR3JXA53TMSEZX7Y7BK3ADN (+ (get-balance 'SP3RXE1XATCSPEFZ6ZPR3JXA53TMSEZX7Y7BK3ADN) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u92) 'SP1WNNXZV8SBG8WNMAJP2SGMYKEKZMNM591J5E6MP))
      (map-set token-count 'SP1WNNXZV8SBG8WNMAJP2SGMYKEKZMNM591J5E6MP (+ (get-balance 'SP1WNNXZV8SBG8WNMAJP2SGMYKEKZMNM591J5E6MP) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u93) 'SP2KASY6S0721P36DM3E68YK62K4SPXN0S5AT2RRH))
      (map-set token-count 'SP2KASY6S0721P36DM3E68YK62K4SPXN0S5AT2RRH (+ (get-balance 'SP2KASY6S0721P36DM3E68YK62K4SPXN0S5AT2RRH) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u94) 'SP2KASY6S0721P36DM3E68YK62K4SPXN0S5AT2RRH))
      (map-set token-count 'SP2KASY6S0721P36DM3E68YK62K4SPXN0S5AT2RRH (+ (get-balance 'SP2KASY6S0721P36DM3E68YK62K4SPXN0S5AT2RRH) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u95) 'SP2KASY6S0721P36DM3E68YK62K4SPXN0S5AT2RRH))
      (map-set token-count 'SP2KASY6S0721P36DM3E68YK62K4SPXN0S5AT2RRH (+ (get-balance 'SP2KASY6S0721P36DM3E68YK62K4SPXN0S5AT2RRH) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u96) 'SP187T43WBESYWP8KF3NMZ3GAP1GV0CPBRAQVKKV8))
      (map-set token-count 'SP187T43WBESYWP8KF3NMZ3GAP1GV0CPBRAQVKKV8 (+ (get-balance 'SP187T43WBESYWP8KF3NMZ3GAP1GV0CPBRAQVKKV8) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u97) 'SP3TT879PFN0AF9CF498QE45Y0HS54ZBAQYQZ8ZFA))
      (map-set token-count 'SP3TT879PFN0AF9CF498QE45Y0HS54ZBAQYQZ8ZFA (+ (get-balance 'SP3TT879PFN0AF9CF498QE45Y0HS54ZBAQYQZ8ZFA) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u98) 'SP1TB63VCCRJCNC660XN3R9A76GS14500JDGZFV71))
      (map-set token-count 'SP1TB63VCCRJCNC660XN3R9A76GS14500JDGZFV71 (+ (get-balance 'SP1TB63VCCRJCNC660XN3R9A76GS14500JDGZFV71) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u99) 'SP1TW7YE1AVX2S4E3YSPRKDY951YSTAHGMYKWEV4N))
      (map-set token-count 'SP1TW7YE1AVX2S4E3YSPRKDY951YSTAHGMYKWEV4N (+ (get-balance 'SP1TW7YE1AVX2S4E3YSPRKDY951YSTAHGMYKWEV4N) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u100) 'SP294GRGKT0XM3ZRET74263R26SE891W25F2N3FTA))
      (map-set token-count 'SP294GRGKT0XM3ZRET74263R26SE891W25F2N3FTA (+ (get-balance 'SP294GRGKT0XM3ZRET74263R26SE891W25F2N3FTA) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u101) 'SP3W3PYRZ78H2HP9P9M4PTBH8PCGA478HPK5YPAG))
      (map-set token-count 'SP3W3PYRZ78H2HP9P9M4PTBH8PCGA478HPK5YPAG (+ (get-balance 'SP3W3PYRZ78H2HP9P9M4PTBH8PCGA478HPK5YPAG) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u102) 'SP4816Z5M35KDAA97ADMMDCG4QHX2YN0T0DNA6ZG))
      (map-set token-count 'SP4816Z5M35KDAA97ADMMDCG4QHX2YN0T0DNA6ZG (+ (get-balance 'SP4816Z5M35KDAA97ADMMDCG4QHX2YN0T0DNA6ZG) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u103) 'SP35CTY5CMTXNJ5KXHPY1RB9M1Y6X6053S0D21Z46))
      (map-set token-count 'SP35CTY5CMTXNJ5KXHPY1RB9M1Y6X6053S0D21Z46 (+ (get-balance 'SP35CTY5CMTXNJ5KXHPY1RB9M1Y6X6053S0D21Z46) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u104) 'SP35CTY5CMTXNJ5KXHPY1RB9M1Y6X6053S0D21Z46))
      (map-set token-count 'SP35CTY5CMTXNJ5KXHPY1RB9M1Y6X6053S0D21Z46 (+ (get-balance 'SP35CTY5CMTXNJ5KXHPY1RB9M1Y6X6053S0D21Z46) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u105) 'SP50KJSSP211Q74EY98WK0H50JC910QYS813FH52))
      (map-set token-count 'SP50KJSSP211Q74EY98WK0H50JC910QYS813FH52 (+ (get-balance 'SP50KJSSP211Q74EY98WK0H50JC910QYS813FH52) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u106) 'SP50KJSSP211Q74EY98WK0H50JC910QYS813FH52))
      (map-set token-count 'SP50KJSSP211Q74EY98WK0H50JC910QYS813FH52 (+ (get-balance 'SP50KJSSP211Q74EY98WK0H50JC910QYS813FH52) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u107) 'SP2KSHW0NN5587CRE89RBNAEYVVJTQ08C79D37976))
      (map-set token-count 'SP2KSHW0NN5587CRE89RBNAEYVVJTQ08C79D37976 (+ (get-balance 'SP2KSHW0NN5587CRE89RBNAEYVVJTQ08C79D37976) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u108) 'SP3TSASFAKYZDHVTP98V7KQZPTHM33S3GVDYSC01Z))
      (map-set token-count 'SP3TSASFAKYZDHVTP98V7KQZPTHM33S3GVDYSC01Z (+ (get-balance 'SP3TSASFAKYZDHVTP98V7KQZPTHM33S3GVDYSC01Z) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u109) 'SP1Q47W9SC5XM0RK11DA9JGX4R3V796BNGR0QT5FC))
      (map-set token-count 'SP1Q47W9SC5XM0RK11DA9JGX4R3V796BNGR0QT5FC (+ (get-balance 'SP1Q47W9SC5XM0RK11DA9JGX4R3V796BNGR0QT5FC) u1))
      (try! (nft-mint? goodbye-eth (+ last-nft-id u110) 'SP1Q47W9SC5XM0RK11DA9JGX4R3V796BNGR0QT5FC))
      (map-set token-count 'SP1Q47W9SC5XM0RK11DA9JGX4R3V796BNGR0QT5FC (+ (get-balance 'SP1Q47W9SC5XM0RK11DA9JGX4R3V796BNGR0QT5FC) u1))

      (var-set last-id (+ last-nft-id u111))
      (var-set airdrop-called true)
      (ok true))))