;; hashiko-sushi
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token hashiko-sushi uint)

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
(define-data-var mint-limit uint u3000)
(define-data-var last-id uint u1)
(define-data-var total-price uint u1000000)
(define-data-var artist-address principal 'SP28NB976TJHHGF4218KT194NPWP9N1X3WY516Z1P)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmPD863zxGwChqrY75HAdKYePGeZjQZYhY4SHFqY1PJtyq/")
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
      (unwrap! (nft-mint? hashiko-sushi next-id tx-sender) next-id)
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
    (nft-burn? hashiko-sushi token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? hashiko-sushi token-id) false)))

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
  (ok (nft-get-owner? hashiko-sushi token-id)))

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

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/3")
(define-data-var license-name (string-ascii 40) "COMMERCIAL-NO-HATE")

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
  (match (nft-transfer? hashiko-sushi id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? hashiko-sushi id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? hashiko-sushi id) (err ERR-NOT-FOUND)))
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
(define-data-var total-price-xbtc uint u4667)

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
(define-data-var total-price-usda uint u3000000)

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
(define-data-var total-price-mega uint u400)

(define-read-only (get-price-mega)
  (ok (var-get total-price-mega)))

(define-public (set-price-mega (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-mega price))))

(define-public (claim-mega)
  (mint-mega (list true)))

(define-public (claim-two-mega) (mint-mega (list true true)))

(define-public (claim-three-mega) (mint-mega (list true true true)))

(define-public (claim-four-mega) (mint-mega (list true true true true)))

(define-public (claim-five-mega) (mint-mega (list true true true true true)))

(define-public (claim-six-mega) (mint-mega (list true true true true true true)))

(define-public (claim-seven-mega) (mint-mega (list true true true true true true true)))

(define-public (claim-eight-mega) (mint-mega (list true true true true true true true true)))

(define-public (claim-nine-mega) (mint-mega (list true true true true true true true true true)))

(define-public (claim-ten-mega) (mint-mega (list true true true true true true true true true true)))

(define-public (claim-fifteen-mega) (mint-mega (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty-mega) (mint-mega (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive-mega) (mint-mega (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


(define-private (mint-mega (orders (list 25 bool)))
  (mint-many-mega orders))

(define-private (mint-many-mega (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-mega) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Alt Minting Default
(define-data-var total-price-alex uint u700000000)

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
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u0) 'SP1TC21ASZ57YQFC9THB85HSMDH6P1BNVPACWATRB))
      (map-set token-count 'SP1TC21ASZ57YQFC9THB85HSMDH6P1BNVPACWATRB (+ (get-balance 'SP1TC21ASZ57YQFC9THB85HSMDH6P1BNVPACWATRB) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u1) 'SPYJF7AM2ZDMMEB01M425SEWH083VGB7Z2MVG1RW))
      (map-set token-count 'SPYJF7AM2ZDMMEB01M425SEWH083VGB7Z2MVG1RW (+ (get-balance 'SPYJF7AM2ZDMMEB01M425SEWH083VGB7Z2MVG1RW) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u2) 'SP3QZ0TFKZCJQNG0VYG2G00EFQ82GMNGW0GFVQ97R))
      (map-set token-count 'SP3QZ0TFKZCJQNG0VYG2G00EFQ82GMNGW0GFVQ97R (+ (get-balance 'SP3QZ0TFKZCJQNG0VYG2G00EFQ82GMNGW0GFVQ97R) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u3) 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K))
      (map-set token-count 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K (+ (get-balance 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u4) 'SP3A0H5WERFZKYSPYJFRJ23RA04SV5PC07E69999W))
      (map-set token-count 'SP3A0H5WERFZKYSPYJFRJ23RA04SV5PC07E69999W (+ (get-balance 'SP3A0H5WERFZKYSPYJFRJ23RA04SV5PC07E69999W) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u5) 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY))
      (map-set token-count 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY (+ (get-balance 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u6) 'SP2GS2DJ9BY6Y9K1B6NTS2751S9BEG8SVC2P1PZDE))
      (map-set token-count 'SP2GS2DJ9BY6Y9K1B6NTS2751S9BEG8SVC2P1PZDE (+ (get-balance 'SP2GS2DJ9BY6Y9K1B6NTS2751S9BEG8SVC2P1PZDE) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u7) 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K))
      (map-set token-count 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K (+ (get-balance 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u8) 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R))
      (map-set token-count 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R (+ (get-balance 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u9) 'SPF0V8KWBS70F0WDKTMY65B3G591NN52PTHHN51D))
      (map-set token-count 'SPF0V8KWBS70F0WDKTMY65B3G591NN52PTHHN51D (+ (get-balance 'SPF0V8KWBS70F0WDKTMY65B3G591NN52PTHHN51D) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u10) 'SP308FR1T8908G7QP5XNXGVTMH32650A9H8GM5V07))
      (map-set token-count 'SP308FR1T8908G7QP5XNXGVTMH32650A9H8GM5V07 (+ (get-balance 'SP308FR1T8908G7QP5XNXGVTMH32650A9H8GM5V07) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u11) 'SP156DD4YJVBF1B8HQY25NEEZM1Q6JK0ZG82AW35P))
      (map-set token-count 'SP156DD4YJVBF1B8HQY25NEEZM1Q6JK0ZG82AW35P (+ (get-balance 'SP156DD4YJVBF1B8HQY25NEEZM1Q6JK0ZG82AW35P) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u12) 'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V))
      (map-set token-count 'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V (+ (get-balance 'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u13) 'SP32QMFREQ1AT633QGP88P1SNHNT6Z4N8THX7QQAE))
      (map-set token-count 'SP32QMFREQ1AT633QGP88P1SNHNT6Z4N8THX7QQAE (+ (get-balance 'SP32QMFREQ1AT633QGP88P1SNHNT6Z4N8THX7QQAE) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u14) 'SP12GKCWQ85MVMS8N4WGXA12S8SYJY5NQ8258PF3B))
      (map-set token-count 'SP12GKCWQ85MVMS8N4WGXA12S8SYJY5NQ8258PF3B (+ (get-balance 'SP12GKCWQ85MVMS8N4WGXA12S8SYJY5NQ8258PF3B) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u15) 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8))
      (map-set token-count 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8 (+ (get-balance 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u16) 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV))
      (map-set token-count 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV (+ (get-balance 'SP12WHJ0PCGE53HNRZNF92PKH4R3C6HWZV4MF2SRV) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u17) 'SP18YW2C7CSK4EC1JEV554RVWWHG6G5T5MFPAKBJ2))
      (map-set token-count 'SP18YW2C7CSK4EC1JEV554RVWWHG6G5T5MFPAKBJ2 (+ (get-balance 'SP18YW2C7CSK4EC1JEV554RVWWHG6G5T5MFPAKBJ2) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u18) 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R))
      (map-set token-count 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R (+ (get-balance 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u19) 'SPR47JA8P9FHJ5A9DC3SSH2MDEHY8N82SHY9GEVY))
      (map-set token-count 'SPR47JA8P9FHJ5A9DC3SSH2MDEHY8N82SHY9GEVY (+ (get-balance 'SPR47JA8P9FHJ5A9DC3SSH2MDEHY8N82SHY9GEVY) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u20) 'SP2VCZJDTT5TJ7A3QPPJPTEF7A9CD8FRG2BEEJF3D))
      (map-set token-count 'SP2VCZJDTT5TJ7A3QPPJPTEF7A9CD8FRG2BEEJF3D (+ (get-balance 'SP2VCZJDTT5TJ7A3QPPJPTEF7A9CD8FRG2BEEJF3D) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u21) 'SP3R1WCPTE2M55PNYD0A29G9Q5BJ2RDTMFGB3RAW2))
      (map-set token-count 'SP3R1WCPTE2M55PNYD0A29G9Q5BJ2RDTMFGB3RAW2 (+ (get-balance 'SP3R1WCPTE2M55PNYD0A29G9Q5BJ2RDTMFGB3RAW2) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u22) 'SPCGCKV5KRD6XV0GETEQAYYY8CTY6YTKC5XBE13A))
      (map-set token-count 'SPCGCKV5KRD6XV0GETEQAYYY8CTY6YTKC5XBE13A (+ (get-balance 'SPCGCKV5KRD6XV0GETEQAYYY8CTY6YTKC5XBE13A) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u23) 'SP37S6ASV5A45JJ9MQWD1GG53W0CYMKXQZ6D9BR2P))
      (map-set token-count 'SP37S6ASV5A45JJ9MQWD1GG53W0CYMKXQZ6D9BR2P (+ (get-balance 'SP37S6ASV5A45JJ9MQWD1GG53W0CYMKXQZ6D9BR2P) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u24) 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0))
      (map-set token-count 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0 (+ (get-balance 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0) u1))
      (try! (nft-mint? hashiko-sushi (+ last-nft-id u25) 'SPMJKNA2XF993TA33K24SK5ENM0WHDMTVY73CH0K))
      (map-set token-count 'SPMJKNA2XF993TA33K24SK5ENM0WHDMTVY73CH0K (+ (get-balance 'SPMJKNA2XF993TA33K24SK5ENM0WHDMTVY73CH0K) u1))

      (var-set last-id (+ last-nft-id u26))
      (var-set airdrop-called true)
      (ok true))))