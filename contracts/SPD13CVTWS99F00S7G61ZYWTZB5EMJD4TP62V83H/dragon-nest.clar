;; dragon-nest
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token dragon-nest uint)

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
(define-data-var mint-limit uint u320)
(define-data-var last-id uint u1)
(define-data-var total-price uint u2000000)
(define-data-var artist-address principal 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmR8mVgMsABUCyntLZC8GWw5Y75wVZzfB2YmyH9cngevgM/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u100)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-six) (mint (list true true true true true true)))

(define-public (claim-seven) (mint (list true true true true true true true)))

(define-public (claim-eight) (mint (list true true true true true true true true)))

(define-public (claim-nine) (mint (list true true true true true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-fifteen) (mint (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty) (mint (list true true true true true true true true true true true true true true true true true true true true)))

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
      (unwrap! (nft-mint? dragon-nest next-id tx-sender) next-id)
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
    (nft-burn? dragon-nest token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? dragon-nest token-id) false)))

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
  (ok (nft-get-owner? dragon-nest token-id)))

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
  (match (nft-transfer? dragon-nest id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? dragon-nest id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? dragon-nest id) (err ERR-NOT-FOUND)))
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
(define-data-var total-price-xbtc uint u9622)

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

(define-public (claim-four-xbtc) (mint-xbtc (list true true true true)))

(define-public (claim-five-xbtc) (mint-xbtc (list true true true true true)))

(define-public (claim-six-xbtc) (mint-xbtc (list true true true true true true)))

(define-public (claim-seven-xbtc) (mint-xbtc (list true true true true true true true)))

(define-public (claim-eight-xbtc) (mint-xbtc (list true true true true true true true true)))

(define-public (claim-nine-xbtc) (mint-xbtc (list true true true true true true true true true)))

(define-public (claim-ten-xbtc) (mint-xbtc (list true true true true true true true true true true)))

(define-public (claim-fifteen-xbtc) (mint-xbtc (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty-xbtc) (mint-xbtc (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive-xbtc) (mint-xbtc (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


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
(define-data-var total-price-usda uint u7000000)

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

(define-public (claim-four-usda) (mint-usda (list true true true true)))

(define-public (claim-five-usda) (mint-usda (list true true true true true)))

(define-public (claim-six-usda) (mint-usda (list true true true true true true)))

(define-public (claim-seven-usda) (mint-usda (list true true true true true true true)))

(define-public (claim-eight-usda) (mint-usda (list true true true true true true true true)))

(define-public (claim-nine-usda) (mint-usda (list true true true true true true true true true)))

(define-public (claim-ten-usda) (mint-usda (list true true true true true true true true true true)))

(define-public (claim-fifteen-usda) (mint-usda (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty-usda) (mint-usda (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive-usda) (mint-usda (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


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
(define-data-var total-price-mia2 uint u2448000000)

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

(define-public (claim-four-mia2) (mint-mia2 (list true true true true)))

(define-public (claim-five-mia2) (mint-mia2 (list true true true true true)))

(define-public (claim-six-mia2) (mint-mia2 (list true true true true true true)))

(define-public (claim-seven-mia2) (mint-mia2 (list true true true true true true true)))

(define-public (claim-eight-mia2) (mint-mia2 (list true true true true true true true true)))

(define-public (claim-nine-mia2) (mint-mia2 (list true true true true true true true true true)))

(define-public (claim-ten-mia2) (mint-mia2 (list true true true true true true true true true true)))

(define-public (claim-fifteen-mia2) (mint-mia2 (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty-mia2) (mint-mia2 (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive-mia2) (mint-mia2 (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


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
(define-data-var total-price-nyc2 uint u1126000000)

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

(define-public (claim-four-nyc2) (mint-nyc2 (list true true true true)))

(define-public (claim-five-nyc2) (mint-nyc2 (list true true true true true)))

(define-public (claim-six-nyc2) (mint-nyc2 (list true true true true true true)))

(define-public (claim-seven-nyc2) (mint-nyc2 (list true true true true true true true)))

(define-public (claim-eight-nyc2) (mint-nyc2 (list true true true true true true true true)))

(define-public (claim-nine-nyc2) (mint-nyc2 (list true true true true true true true true true)))

(define-public (claim-ten-nyc2) (mint-nyc2 (list true true true true true true true true true true)))

(define-public (claim-fifteen-nyc2) (mint-nyc2 (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty-nyc2) (mint-nyc2 (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive-nyc2) (mint-nyc2 (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


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
(define-data-var total-price-banana uint u25000000)

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

(define-public (claim-six-banana) (mint-banana (list true true true true true true)))

(define-public (claim-seven-banana) (mint-banana (list true true true true true true true)))

(define-public (claim-eight-banana) (mint-banana (list true true true true true true true true)))

(define-public (claim-nine-banana) (mint-banana (list true true true true true true true true true)))

(define-public (claim-ten-banana) (mint-banana (list true true true true true true true true true true)))

(define-public (claim-fifteen-banana) (mint-banana (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty-banana) (mint-banana (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive-banana) (mint-banana (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


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
(define-data-var total-price-slime uint u226000000)

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

(define-public (claim-six-slime) (mint-slime (list true true true true true true)))

(define-public (claim-seven-slime) (mint-slime (list true true true true true true true)))

(define-public (claim-eight-slime) (mint-slime (list true true true true true true true true)))

(define-public (claim-nine-slime) (mint-slime (list true true true true true true true true true)))

(define-public (claim-ten-slime) (mint-slime (list true true true true true true true true true true)))

(define-public (claim-fifteen-slime) (mint-slime (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty-slime) (mint-slime (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive-slime) (mint-slime (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


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
(define-data-var total-price-alex uint u1400000000)

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

(define-public (claim-four-alex) (mint-alex (list true true true true)))

(define-public (claim-five-alex) (mint-alex (list true true true true true)))

(define-public (claim-six-alex) (mint-alex (list true true true true true true)))

(define-public (claim-seven-alex) (mint-alex (list true true true true true true true)))

(define-public (claim-eight-alex) (mint-alex (list true true true true true true true true)))

(define-public (claim-nine-alex) (mint-alex (list true true true true true true true true true)))

(define-public (claim-ten-alex) (mint-alex (list true true true true true true true true true true)))

(define-public (claim-fifteen-alex) (mint-alex (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty-alex) (mint-alex (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive-alex) (mint-alex (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


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
      (try! (nft-mint? dragon-nest (+ last-nft-id u0) 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN))
      (map-set token-count 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN (+ (get-balance 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN) u1))
      (try! (nft-mint? dragon-nest (+ last-nft-id u1) 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN))
      (map-set token-count 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN (+ (get-balance 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN) u1))
      (try! (nft-mint? dragon-nest (+ last-nft-id u2) 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN))
      (map-set token-count 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN (+ (get-balance 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN) u1))

      (var-set last-id (+ last-nft-id u3))
      (var-set airdrop-called true)
      (ok true))))