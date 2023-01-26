;; boombox-50-extra
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token boombox-50-extra uint)

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
(define-data-var mint-limit uint u1)
(define-data-var last-id uint u1)
(define-data-var total-price uint u25000000)
(define-data-var artist-address principal 'SP21CYC2GKWTVK3FHFF4VVJNKVNQDMRY5GQS27XQB)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmcZ5Y1JBJW5kbosNUmXno4Ya9BEXr6fYEWEt2Zz7uQrZU/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u3)

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
      (unwrap! (nft-mint? boombox-50-extra next-id tx-sender) next-id)
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
    (nft-burn? boombox-50-extra token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? boombox-50-extra token-id) false)))

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
  (ok (nft-get-owner? boombox-50-extra token-id)))

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
  (match (nft-transfer? boombox-50-extra id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? boombox-50-extra id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? boombox-50-extra id) (err ERR-NOT-FOUND)))
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
(define-data-var total-price-mia2 uint u16501000000)

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
(define-data-var total-price-nyc2 uint u24548000000)

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
(define-data-var total-price-banana uint u210000000)

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
(define-data-var total-price-slime uint u2889000000)

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
(define-data-var total-price-alex uint u55400000000)

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
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u0) 'SP1JY766Q0PM5R5MC3J603NTK27SW7Y7GKXM2T946))
      (map-set token-count 'SP1JY766Q0PM5R5MC3J603NTK27SW7Y7GKXM2T946 (+ (get-balance 'SP1JY766Q0PM5R5MC3J603NTK27SW7Y7GKXM2T946) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u1) 'SP25QZMBZ43ZWMCW9FB102XT4EFD602KZ6V0TBY7W))
      (map-set token-count 'SP25QZMBZ43ZWMCW9FB102XT4EFD602KZ6V0TBY7W (+ (get-balance 'SP25QZMBZ43ZWMCW9FB102XT4EFD602KZ6V0TBY7W) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u2) 'SP123TY61PFFAEZBX3PNH7KG3663B3GBW440NMYX0))
      (map-set token-count 'SP123TY61PFFAEZBX3PNH7KG3663B3GBW440NMYX0 (+ (get-balance 'SP123TY61PFFAEZBX3PNH7KG3663B3GBW440NMYX0) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u3) 'SP2009N95GZJWQ7W6QFN4CXKVVCM3HKCY050ZM97Y))
      (map-set token-count 'SP2009N95GZJWQ7W6QFN4CXKVVCM3HKCY050ZM97Y (+ (get-balance 'SP2009N95GZJWQ7W6QFN4CXKVVCM3HKCY050ZM97Y) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u4) 'SP18EDVDZRXYWG6Z0CB4J3Q7R37164ACY6TBSVB9K))
      (map-set token-count 'SP18EDVDZRXYWG6Z0CB4J3Q7R37164ACY6TBSVB9K (+ (get-balance 'SP18EDVDZRXYWG6Z0CB4J3Q7R37164ACY6TBSVB9K) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u5) 'SPKFNC4GMXFXM1X4WH82MSEFSZC09MQ673R9CXCD))
      (map-set token-count 'SPKFNC4GMXFXM1X4WH82MSEFSZC09MQ673R9CXCD (+ (get-balance 'SPKFNC4GMXFXM1X4WH82MSEFSZC09MQ673R9CXCD) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u6) 'SPWG2646NEV92ZXH2D261WFKRHC25ZGMXA0KHVQA))
      (map-set token-count 'SPWG2646NEV92ZXH2D261WFKRHC25ZGMXA0KHVQA (+ (get-balance 'SPWG2646NEV92ZXH2D261WFKRHC25ZGMXA0KHVQA) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u7) 'SP3YF5XZN4CNKRANEHVFWS18DAG5M2CHQTSBZQX35))
      (map-set token-count 'SP3YF5XZN4CNKRANEHVFWS18DAG5M2CHQTSBZQX35 (+ (get-balance 'SP3YF5XZN4CNKRANEHVFWS18DAG5M2CHQTSBZQX35) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u8) 'SP3ZAZ6K5X8QHTKYN22E3EFEBMNT7FTS42681WMZ4))
      (map-set token-count 'SP3ZAZ6K5X8QHTKYN22E3EFEBMNT7FTS42681WMZ4 (+ (get-balance 'SP3ZAZ6K5X8QHTKYN22E3EFEBMNT7FTS42681WMZ4) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u9) 'SP3FD0JFJ56AYTGA88W2HEKFNWKHMXS4VEA627KXV))
      (map-set token-count 'SP3FD0JFJ56AYTGA88W2HEKFNWKHMXS4VEA627KXV (+ (get-balance 'SP3FD0JFJ56AYTGA88W2HEKFNWKHMXS4VEA627KXV) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u10) 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG))
      (map-set token-count 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG (+ (get-balance 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u11) 'SP3JJ3SH2841FYVN6AR7EGP5KZBAN5Z3ZX52KT1XF))
      (map-set token-count 'SP3JJ3SH2841FYVN6AR7EGP5KZBAN5Z3ZX52KT1XF (+ (get-balance 'SP3JJ3SH2841FYVN6AR7EGP5KZBAN5Z3ZX52KT1XF) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u12) 'SP1GV16H3B3JA72X496VEPX5FFHD0F97RMX8DCX2J))
      (map-set token-count 'SP1GV16H3B3JA72X496VEPX5FFHD0F97RMX8DCX2J (+ (get-balance 'SP1GV16H3B3JA72X496VEPX5FFHD0F97RMX8DCX2J) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u13) 'SP1ZNSXW7FTVC96DJB9J6QF14ZY7B582XDR46VG5M))
      (map-set token-count 'SP1ZNSXW7FTVC96DJB9J6QF14ZY7B582XDR46VG5M (+ (get-balance 'SP1ZNSXW7FTVC96DJB9J6QF14ZY7B582XDR46VG5M) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u14) 'SP1386044X5N01AJAGN50NGKE87K4Q72P7DHVXF3F))
      (map-set token-count 'SP1386044X5N01AJAGN50NGKE87K4Q72P7DHVXF3F (+ (get-balance 'SP1386044X5N01AJAGN50NGKE87K4Q72P7DHVXF3F) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u15) 'SPNDM273MY6ZNGGN1DH4JA0F03BPVGX8T7M80FK6))
      (map-set token-count 'SPNDM273MY6ZNGGN1DH4JA0F03BPVGX8T7M80FK6 (+ (get-balance 'SPNDM273MY6ZNGGN1DH4JA0F03BPVGX8T7M80FK6) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u16) 'SP2XFT963GCVW6FKYSTW4B0EFSNZ2GV2Y5MTZEPCP))
      (map-set token-count 'SP2XFT963GCVW6FKYSTW4B0EFSNZ2GV2Y5MTZEPCP (+ (get-balance 'SP2XFT963GCVW6FKYSTW4B0EFSNZ2GV2Y5MTZEPCP) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u17) 'SPHZYWBWK910G2B1V1N23WVG8VN0JRWDNG0SZGC4))
      (map-set token-count 'SPHZYWBWK910G2B1V1N23WVG8VN0JRWDNG0SZGC4 (+ (get-balance 'SPHZYWBWK910G2B1V1N23WVG8VN0JRWDNG0SZGC4) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u18) 'SP26QBNK5GQT6XKK9VHXGERE8MX7880QHHTA5F26R))
      (map-set token-count 'SP26QBNK5GQT6XKK9VHXGERE8MX7880QHHTA5F26R (+ (get-balance 'SP26QBNK5GQT6XKK9VHXGERE8MX7880QHHTA5F26R) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u19) 'SP1DNQQGEBADXNMFKFTVHJBER4XZNH9XJ3DF7KE6X))
      (map-set token-count 'SP1DNQQGEBADXNMFKFTVHJBER4XZNH9XJ3DF7KE6X (+ (get-balance 'SP1DNQQGEBADXNMFKFTVHJBER4XZNH9XJ3DF7KE6X) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u20) 'SP5SSDMPF51Q2B9VS4F8HH52249AKAEDDBWYZ678))
      (map-set token-count 'SP5SSDMPF51Q2B9VS4F8HH52249AKAEDDBWYZ678 (+ (get-balance 'SP5SSDMPF51Q2B9VS4F8HH52249AKAEDDBWYZ678) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u21) 'SP18XHCP5ZKE1ZXABA3NPJAT4BRBBXRK5F9F75DD3))
      (map-set token-count 'SP18XHCP5ZKE1ZXABA3NPJAT4BRBBXRK5F9F75DD3 (+ (get-balance 'SP18XHCP5ZKE1ZXABA3NPJAT4BRBBXRK5F9F75DD3) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u22) 'SP3FQWCHEE92TCD1AVJEHP4W9KEW7QCFMT89YYWJP))
      (map-set token-count 'SP3FQWCHEE92TCD1AVJEHP4W9KEW7QCFMT89YYWJP (+ (get-balance 'SP3FQWCHEE92TCD1AVJEHP4W9KEW7QCFMT89YYWJP) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u23) 'SP3S25JE324ZY8G3JS7T983V0KQV14RBRZZNEGPPR))
      (map-set token-count 'SP3S25JE324ZY8G3JS7T983V0KQV14RBRZZNEGPPR (+ (get-balance 'SP3S25JE324ZY8G3JS7T983V0KQV14RBRZZNEGPPR) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u24) 'SP66GN64A2BKD4Y1TJBJ21SJP90WE21ZRGZH4ZR6))
      (map-set token-count 'SP66GN64A2BKD4Y1TJBJ21SJP90WE21ZRGZH4ZR6 (+ (get-balance 'SP66GN64A2BKD4Y1TJBJ21SJP90WE21ZRGZH4ZR6) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u25) 'SP24SEFZTNWQBC205YC1W44RW03W0SRN418NZ80CF))
      (map-set token-count 'SP24SEFZTNWQBC205YC1W44RW03W0SRN418NZ80CF (+ (get-balance 'SP24SEFZTNWQBC205YC1W44RW03W0SRN418NZ80CF) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u26) 'SP25EV6W08DK6TGMC7ENRYWQC2DP61XV6BBMVA02E))
      (map-set token-count 'SP25EV6W08DK6TGMC7ENRYWQC2DP61XV6BBMVA02E (+ (get-balance 'SP25EV6W08DK6TGMC7ENRYWQC2DP61XV6BBMVA02E) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u27) 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9))
      (map-set token-count 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9 (+ (get-balance 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u28) 'SP3JXAXGZA5JJJ4YHTEW6Q46PKX3VMT0Q0F7JDYF7))
      (map-set token-count 'SP3JXAXGZA5JJJ4YHTEW6Q46PKX3VMT0Q0F7JDYF7 (+ (get-balance 'SP3JXAXGZA5JJJ4YHTEW6Q46PKX3VMT0Q0F7JDYF7) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u29) 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F))
      (map-set token-count 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F (+ (get-balance 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u30) 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X))
      (map-set token-count 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X (+ (get-balance 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u31) 'SP2J56JG0SMAVW0DXXJ7W18W2CQHD1FE83FZCFV26))
      (map-set token-count 'SP2J56JG0SMAVW0DXXJ7W18W2CQHD1FE83FZCFV26 (+ (get-balance 'SP2J56JG0SMAVW0DXXJ7W18W2CQHD1FE83FZCFV26) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u32) 'SP13J4QQAWZCB64ZFQH8Y1BY9VD49VEJ30TJMRK1D))
      (map-set token-count 'SP13J4QQAWZCB64ZFQH8Y1BY9VD49VEJ30TJMRK1D (+ (get-balance 'SP13J4QQAWZCB64ZFQH8Y1BY9VD49VEJ30TJMRK1D) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u33) 'SPA6DVSF7S0DEXE4NWG6JQBX3BEA5AS5PEE2NQXP))
      (map-set token-count 'SPA6DVSF7S0DEXE4NWG6JQBX3BEA5AS5PEE2NQXP (+ (get-balance 'SPA6DVSF7S0DEXE4NWG6JQBX3BEA5AS5PEE2NQXP) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u34) 'SP3AY50XK1ACGTWR3W4N64SAEFHBRR7WZC38Z8AX3))
      (map-set token-count 'SP3AY50XK1ACGTWR3W4N64SAEFHBRR7WZC38Z8AX3 (+ (get-balance 'SP3AY50XK1ACGTWR3W4N64SAEFHBRR7WZC38Z8AX3) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u35) 'SP3Y1R9KPDB0SQK8T1BXP9FAMAYV4FR7WTYX42GQZ))
      (map-set token-count 'SP3Y1R9KPDB0SQK8T1BXP9FAMAYV4FR7WTYX42GQZ (+ (get-balance 'SP3Y1R9KPDB0SQK8T1BXP9FAMAYV4FR7WTYX42GQZ) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u36) 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9))
      (map-set token-count 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9 (+ (get-balance 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u37) 'SP3EB2J4GYMGM9W2JP337XCZ8H945D9T11BM8AQR))
      (map-set token-count 'SP3EB2J4GYMGM9W2JP337XCZ8H945D9T11BM8AQR (+ (get-balance 'SP3EB2J4GYMGM9W2JP337XCZ8H945D9T11BM8AQR) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u38) 'SPYQ829C0KWNEVETW09C93CCBHV3AGM60AKS66AJ))
      (map-set token-count 'SPYQ829C0KWNEVETW09C93CCBHV3AGM60AKS66AJ (+ (get-balance 'SPYQ829C0KWNEVETW09C93CCBHV3AGM60AKS66AJ) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u39) 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16))
      (map-set token-count 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 (+ (get-balance 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u40) 'SP16661ZGFH2Y9NGSQXTBH6TYTJ9YZV3B2TARW92J))
      (map-set token-count 'SP16661ZGFH2Y9NGSQXTBH6TYTJ9YZV3B2TARW92J (+ (get-balance 'SP16661ZGFH2Y9NGSQXTBH6TYTJ9YZV3B2TARW92J) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u41) 'SP3ZX7K64FF6NDEFY0TFGPFCKNDTY8EVFD860PXXS))
      (map-set token-count 'SP3ZX7K64FF6NDEFY0TFGPFCKNDTY8EVFD860PXXS (+ (get-balance 'SP3ZX7K64FF6NDEFY0TFGPFCKNDTY8EVFD860PXXS) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u42) 'SP35TP5W1CMNJA97HSH85VG669NSD9XJFXRES0VQH))
      (map-set token-count 'SP35TP5W1CMNJA97HSH85VG669NSD9XJFXRES0VQH (+ (get-balance 'SP35TP5W1CMNJA97HSH85VG669NSD9XJFXRES0VQH) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u43) 'SP27H8AQR7KGNXDEQYV1N7P90PFJAPHE431G23DV7))
      (map-set token-count 'SP27H8AQR7KGNXDEQYV1N7P90PFJAPHE431G23DV7 (+ (get-balance 'SP27H8AQR7KGNXDEQYV1N7P90PFJAPHE431G23DV7) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u44) 'SP1MVN4WTAEA9AMNJT7QCAFXMQ1A9EBN58Y5FE2NE))
      (map-set token-count 'SP1MVN4WTAEA9AMNJT7QCAFXMQ1A9EBN58Y5FE2NE (+ (get-balance 'SP1MVN4WTAEA9AMNJT7QCAFXMQ1A9EBN58Y5FE2NE) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u45) 'SP192QE0B7TQB9H0F7PMHP6M8NJ7HNS0H3GXZTQ8P))
      (map-set token-count 'SP192QE0B7TQB9H0F7PMHP6M8NJ7HNS0H3GXZTQ8P (+ (get-balance 'SP192QE0B7TQB9H0F7PMHP6M8NJ7HNS0H3GXZTQ8P) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u46) 'SP2S5WG0T4H2B4QX4X03HQZ0JP5JB19A3XX9Z3PD0))
      (map-set token-count 'SP2S5WG0T4H2B4QX4X03HQZ0JP5JB19A3XX9Z3PD0 (+ (get-balance 'SP2S5WG0T4H2B4QX4X03HQZ0JP5JB19A3XX9Z3PD0) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u47) 'SPQ3STDA3G4Q6QD716425BE7A2G378QFQ10RJK3V))
      (map-set token-count 'SPQ3STDA3G4Q6QD716425BE7A2G378QFQ10RJK3V (+ (get-balance 'SPQ3STDA3G4Q6QD716425BE7A2G378QFQ10RJK3V) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u48) 'SP3ET3TVWN5K9MH6CSAP3JK1B3BYS9GB16KKWSAMJ))
      (map-set token-count 'SP3ET3TVWN5K9MH6CSAP3JK1B3BYS9GB16KKWSAMJ (+ (get-balance 'SP3ET3TVWN5K9MH6CSAP3JK1B3BYS9GB16KKWSAMJ) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u49) 'SP3KKBF6BSVPJ8KH55W5R3RWZ6HA7FC5BVV8205A5))
      (map-set token-count 'SP3KKBF6BSVPJ8KH55W5R3RWZ6HA7FC5BVV8205A5 (+ (get-balance 'SP3KKBF6BSVPJ8KH55W5R3RWZ6HA7FC5BVV8205A5) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u50) 'SP2B4SYS3A7Z2ZZ2EP4RH9M477A59V6DFT4WG2KEM))
      (map-set token-count 'SP2B4SYS3A7Z2ZZ2EP4RH9M477A59V6DFT4WG2KEM (+ (get-balance 'SP2B4SYS3A7Z2ZZ2EP4RH9M477A59V6DFT4WG2KEM) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u51) 'SP3N0TH3N7BDG4WBSYV6FE2ASSAPEGWK47EEWD9TV))
      (map-set token-count 'SP3N0TH3N7BDG4WBSYV6FE2ASSAPEGWK47EEWD9TV (+ (get-balance 'SP3N0TH3N7BDG4WBSYV6FE2ASSAPEGWK47EEWD9TV) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u52) 'SP379GBZ6DS4XJVEJY4R8FDGT1DK2BREHSBTFM7BP))
      (map-set token-count 'SP379GBZ6DS4XJVEJY4R8FDGT1DK2BREHSBTFM7BP (+ (get-balance 'SP379GBZ6DS4XJVEJY4R8FDGT1DK2BREHSBTFM7BP) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u53) 'SP1S73MMPD15AAW6QCD5VVZ34JM56ZWHGYCCMBBCD))
      (map-set token-count 'SP1S73MMPD15AAW6QCD5VVZ34JM56ZWHGYCCMBBCD (+ (get-balance 'SP1S73MMPD15AAW6QCD5VVZ34JM56ZWHGYCCMBBCD) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u54) 'SPD75C55PRTMSV60GMMDZEEBPZS37ZD01Q7VYD0Z))
      (map-set token-count 'SPD75C55PRTMSV60GMMDZEEBPZS37ZD01Q7VYD0Z (+ (get-balance 'SPD75C55PRTMSV60GMMDZEEBPZS37ZD01Q7VYD0Z) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u55) 'SP0ANQ6E06A81T0WKT0G4NRN04XNBR7PM25F4Y01))
      (map-set token-count 'SP0ANQ6E06A81T0WKT0G4NRN04XNBR7PM25F4Y01 (+ (get-balance 'SP0ANQ6E06A81T0WKT0G4NRN04XNBR7PM25F4Y01) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u56) 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE))
      (map-set token-count 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE (+ (get-balance 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u57) 'SP3CNS7ZAEFRXGGD3TGVB1GW6GQDGTH0TPSB2XN48))
      (map-set token-count 'SP3CNS7ZAEFRXGGD3TGVB1GW6GQDGTH0TPSB2XN48 (+ (get-balance 'SP3CNS7ZAEFRXGGD3TGVB1GW6GQDGTH0TPSB2XN48) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u58) 'SP1WP4F6ZP8QYP61MBXBSNWPT3901BS2CC246XFTX))
      (map-set token-count 'SP1WP4F6ZP8QYP61MBXBSNWPT3901BS2CC246XFTX (+ (get-balance 'SP1WP4F6ZP8QYP61MBXBSNWPT3901BS2CC246XFTX) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u59) 'SP39RBC1PYD2FAGSP589F7ZZSYBWVSWZQTNCH3FM1))
      (map-set token-count 'SP39RBC1PYD2FAGSP589F7ZZSYBWVSWZQTNCH3FM1 (+ (get-balance 'SP39RBC1PYD2FAGSP589F7ZZSYBWVSWZQTNCH3FM1) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u60) 'SPZCFP3486BF968TPQ3H6DBRK70YKKSAW3FBD2E0))
      (map-set token-count 'SPZCFP3486BF968TPQ3H6DBRK70YKKSAW3FBD2E0 (+ (get-balance 'SPZCFP3486BF968TPQ3H6DBRK70YKKSAW3FBD2E0) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u61) 'SP2VA1Y2XQZYCBV3FB3MCSY2B7VVWGVFVXYVFRGS5))
      (map-set token-count 'SP2VA1Y2XQZYCBV3FB3MCSY2B7VVWGVFVXYVFRGS5 (+ (get-balance 'SP2VA1Y2XQZYCBV3FB3MCSY2B7VVWGVFVXYVFRGS5) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u62) 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV))
      (map-set token-count 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV (+ (get-balance 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u63) 'SP3RRA0RQDNGRQYM0K64EVX8E0MBH0DEPPPN4KQG8))
      (map-set token-count 'SP3RRA0RQDNGRQYM0K64EVX8E0MBH0DEPPPN4KQG8 (+ (get-balance 'SP3RRA0RQDNGRQYM0K64EVX8E0MBH0DEPPPN4KQG8) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u64) 'SP39WR7DRCPK9AHRFC0YF96S43QMZ0S8XWQKTJP0X))
      (map-set token-count 'SP39WR7DRCPK9AHRFC0YF96S43QMZ0S8XWQKTJP0X (+ (get-balance 'SP39WR7DRCPK9AHRFC0YF96S43QMZ0S8XWQKTJP0X) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u65) 'SP24WGQVM1PTWJKP1W5CQ7H8CXHXTXV3NQ12QSQQD))
      (map-set token-count 'SP24WGQVM1PTWJKP1W5CQ7H8CXHXTXV3NQ12QSQQD (+ (get-balance 'SP24WGQVM1PTWJKP1W5CQ7H8CXHXTXV3NQ12QSQQD) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u66) 'SP1XCTGM847WJQSVPBDM8SD6H7XHFV7E3809ND3NY))
      (map-set token-count 'SP1XCTGM847WJQSVPBDM8SD6H7XHFV7E3809ND3NY (+ (get-balance 'SP1XCTGM847WJQSVPBDM8SD6H7XHFV7E3809ND3NY) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u67) 'SPM06DTBFP2E6056NGR0Q3TEE5SW9ZYRA98XZ23S))
      (map-set token-count 'SPM06DTBFP2E6056NGR0Q3TEE5SW9ZYRA98XZ23S (+ (get-balance 'SPM06DTBFP2E6056NGR0Q3TEE5SW9ZYRA98XZ23S) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u68) 'SP1PW84909K241NK7F7Y85KW63H3VMRKMTEKS72DJ))
      (map-set token-count 'SP1PW84909K241NK7F7Y85KW63H3VMRKMTEKS72DJ (+ (get-balance 'SP1PW84909K241NK7F7Y85KW63H3VMRKMTEKS72DJ) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u69) 'SP8X90BJRDS47FMER8MJ78SG0ZSYBPXFQWG1H0PS))
      (map-set token-count 'SP8X90BJRDS47FMER8MJ78SG0ZSYBPXFQWG1H0PS (+ (get-balance 'SP8X90BJRDS47FMER8MJ78SG0ZSYBPXFQWG1H0PS) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u70) 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH))
      (map-set token-count 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH (+ (get-balance 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u71) 'SP1Q21V7Q88J0463T9EA1ZH3DJ6XYPFQZ4B62Y9GF))
      (map-set token-count 'SP1Q21V7Q88J0463T9EA1ZH3DJ6XYPFQZ4B62Y9GF (+ (get-balance 'SP1Q21V7Q88J0463T9EA1ZH3DJ6XYPFQZ4B62Y9GF) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u72) 'SP3E9J3D6YJYX5H3XHR00TXG1MD3D42XP4194XNNZ))
      (map-set token-count 'SP3E9J3D6YJYX5H3XHR00TXG1MD3D42XP4194XNNZ (+ (get-balance 'SP3E9J3D6YJYX5H3XHR00TXG1MD3D42XP4194XNNZ) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u73) 'SP3C4YYS3N3NFQQVM04J4FFED70SYSXKK7CYA5WNT))
      (map-set token-count 'SP3C4YYS3N3NFQQVM04J4FFED70SYSXKK7CYA5WNT (+ (get-balance 'SP3C4YYS3N3NFQQVM04J4FFED70SYSXKK7CYA5WNT) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u74) 'SP2XFZR7CTWPM686ZFPBHR5YJ927A5R82EZNRT5V0))
      (map-set token-count 'SP2XFZR7CTWPM686ZFPBHR5YJ927A5R82EZNRT5V0 (+ (get-balance 'SP2XFZR7CTWPM686ZFPBHR5YJ927A5R82EZNRT5V0) u1))
      (try! (nft-mint? boombox-50-extra (+ last-nft-id u75) 'SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE))
      (map-set token-count 'SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE (+ (get-balance 'SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE) u1))

      (var-set last-id (+ last-nft-id u76))
      (var-set airdrop-called true)
      (ok true))))