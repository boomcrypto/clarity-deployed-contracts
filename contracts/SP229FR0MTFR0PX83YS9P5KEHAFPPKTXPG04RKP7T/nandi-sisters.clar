;; nandi-sisters

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token nandi-sisters uint)

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

;; Internal variables
(define-data-var mint-limit uint u500)
(define-data-var last-id uint u1)
(define-data-var total-price uint u10000000)
(define-data-var artist-address principal 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmdVqqwVDHcmJmm7egC8W5ci4u2Lk3yjFF4SfNeofPxgbL/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u2)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-twentyfive) (mint (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

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
      (unwrap! (nft-mint? nandi-sisters next-id tx-sender) next-id)
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
    (nft-burn? nandi-sisters token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? nandi-sisters token-id) false)))

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
  (ok (nft-get-owner? nandi-sisters token-id)))

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
(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? nandi-sisters id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? nandi-sisters id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
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
  (let ((owner (unwrap! (nft-get-owner? nandi-sisters id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
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
(define-data-var total-price-mia uint u8000)

(define-read-only (get-price-mia)
  (ok (var-get total-price-mia)))

(define-public (claim-mia)
  (mint-mia (list true)))

(define-public (claim-three-mia) (mint-mia (list true true true)))

(define-public (claim-twentyfive-mia) (mint-mia (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-ten-mia) (mint-mia (list true true true true true true true true true true)))

(define-private (mint-mia (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-mia orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-mia orders)
      )
    )))

(define-private (mint-many-mia (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-mia) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Alt Minting Mintpass
(define-data-var total-price-nyc uint u8000)

(define-read-only (get-price-nyc)
  (ok (var-get total-price-nyc)))

(define-public (claim-nyc)
  (mint-nyc (list true)))

(define-public (claim-three-nyc) (mint-nyc (list true true true)))

(define-public (claim-twentyfive-nyc) (mint-nyc (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-ten-nyc) (mint-nyc (list true true true true true true true true true true)))

(define-private (mint-nyc (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-nyc orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-nyc orders)
      )
    )))

(define-private (mint-many-nyc (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-nyc) (- id-reached last-nft-id)))
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
        (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Alt Minting Mintpass
(define-data-var total-price-xbtc uint u27000)

(define-read-only (get-price-xbtc)
  (ok (var-get total-price-xbtc)))

(define-public (claim-xbtc)
  (mint-xbtc (list true)))

(define-public (claim-three-xbtc) (mint-xbtc (list true true true)))

(define-public (claim-twentyfive-xbtc) (mint-xbtc (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-ten-xbtc) (mint-xbtc (list true true true true true true true true true true)))

(define-private (mint-xbtc (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-xbtc orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-xbtc orders)
      )
    )))

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

;; Alt Minting Mintpass
(define-data-var total-price-usda uint u10)

(define-read-only (get-price-usda)
  (ok (var-get total-price-usda)))

(define-public (claim-usda)
  (mint-usda (list true)))

(define-public (claim-three-usda) (mint-usda (list true true true)))

(define-public (claim-twentyfive-usda) (mint-usda (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-ten-usda) (mint-usda (list true true true true true true true true true true)))

(define-private (mint-usda (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-usda orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-usda orders)
      )
    )))

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

(map-set mint-passes 'SP14PVWDVKVK1P1SZV72MJQMNX5N5XDZ8AGNG9M0C u2)
(map-set mint-passes 'SP16W7S76K0A7HAM176B73RQ8MD75E9VJ8VM256WH u2)
(map-set mint-passes 'SP16YA5N2VE52JRDYXKFZ2TF7T2CBRB4SH8NYKJX1 u2)
(map-set mint-passes 'SP187S0WS0HHYPHWPPVAH5XN6RD4S2NXN7Y103688 u2)
(map-set mint-passes 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 u2)
(map-set mint-passes 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA u2)
(map-set mint-passes 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR u2)
(map-set mint-passes 'SP1DY2QDFZAR8VK5S9DMYW2AW0WXQ16NNRG3PJDTX u2)
(map-set mint-passes 'SP1DZJ3P3XEZPQ3WRESFG4A1ZB0DQ1XXBT07542JP u2)
(map-set mint-passes 'SP1ENAX51WA6VP691GT9100V72Y3CCY1YZW0TA3B1 u2)
(map-set mint-passes 'SP1FV4FZ8D32S7GKYRPFWK6YHRJE5BZEYKABK72Q3 u2)
(map-set mint-passes 'SP1G9PZMQSFRQ7Q98XP7JMNE2C22RXK1W61RXTNKP u2)
(map-set mint-passes 'SP1HQ9YQXNGTRC5AVVTJAPBTFRY7TFH3XDJDC9N88 u2)
(map-set mint-passes 'SP1M5XE7YDTB611NVT6TQ9BRMB999NK4G6XDT5PTN u2)
(map-set mint-passes 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 u2)
(map-set mint-passes 'SP1QCMFS4X8RM65FQP02M7WGDHBZR5BXN8NJ741ME u2)
(map-set mint-passes 'SP1SA9ZTHB8QWNWJAYX54RZKA1EGB3R6YZDN4RWNJ u2)
(map-set mint-passes 'SP1SXFE323XBDFEK6D5BV7P20BD3B4Y8W1RFN759H u2)
(map-set mint-passes 'SP1V681WYM8J4TC66EFQT8R9NE1FAX9TFK42BG1P1 u2)
(map-set mint-passes 'SP1X34E47XW77TWYFG6GX8G1SEN5E538T0WGBXZK6 u2)
(map-set mint-passes 'SP1XRFVSKEY954TPX1XED41VDEKH9EVVQWTMAWR3Y u2)
(map-set mint-passes 'SP1YVF9EWSK6HM0JZR4B3KCM7V3NKVE18VVNFSQV5 u2)
(map-set mint-passes 'SP1Z8M48EK5KFVSKW0VMX0J4A4KKKQHKS95NSS7QW u2)
(map-set mint-passes 'SP21APAHZW3224CFPS534V56XFACAY3C661NMEHPE u2)
(map-set mint-passes 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T u2)
(map-set mint-passes 'SP23FCMK31M19E0NNRQ8BXZK0J3KMWF2Q4WMGJJQ2 u2)
(map-set mint-passes 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K u2)
(map-set mint-passes 'SP2778AQXRYX13JAYFXVXZ2DB8TM993SF2DR3ZMBS u2)
(map-set mint-passes 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N u2)
(map-set mint-passes 'SP295QANJTGHJJ9TSHJ4WH28Z52VDKWDW68VT8KAH u2)
(map-set mint-passes 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H u2)
(map-set mint-passes 'SP2DG03SMAV8Q8JTDHF9F32Y7B3523ZJYM0Q3MK3Y u2)
(map-set mint-passes 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D u2)
(map-set mint-passes 'SP2FTZQX1V9FPPNH485Z49JE914YNQYGT4XVGNR4S u2)
(map-set mint-passes 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR u2)
(map-set mint-passes 'SP2KF0WXYN5XC2J9K9B1X1S4KGNR5XNPAQ2XPB38A u2)
(map-set mint-passes 'SP2KSNCT9MF74MFCXKDNDCAJ0B0CZ2JZQ20QBCX45 u2)
(map-set mint-passes 'SP2PNN7Z0FB0EQZ8CE0NJE0HH09T19P5WE0GQT0W3 u2)
(map-set mint-passes 'SP2Q0K5VAYGTHVMKFJZ3Z4N28VEAJQN6ZHR7EXFKE u2)
(map-set mint-passes 'SP2S7Y7BMX7Y73FHV3SV9W1EE63EQ98BE95PZ4C4E u2)
(map-set mint-passes 'SP2S872HVH23Q1M1VQ6Z55VM11V8Z7YG8V3TZTR96 u2)
(map-set mint-passes 'SP2TV9WT5FM6TEDCS5C10X7P7R813MTA3W5GAGJHQ u2)
(map-set mint-passes 'SP2VS41C9A89KXKS23J7B3SZ46H8SY1595KJHS6W3 u2)
(map-set mint-passes 'SP2XXMH2DHP5S0CS1VB8C6TV75510YDQA527CAPG0 u2)
(map-set mint-passes 'SP2Z0DE9N41R5C5YEXVF6JV5Z13DFKVYWDMJ5PH46 u2)
(map-set mint-passes 'SP2ZCER0Z8VVMCDA3817SDFVES833XD9ACYDAFH1T u2)
(map-set mint-passes 'SP30BTV3905TS3A83CENN271AHZHGM4C3FDZX3JNR u2)
(map-set mint-passes 'SP30GAHN5E5S2X1H4TKDGG0V524SMHR05FWKZVA1P u2)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u2)
(map-set mint-passes 'SP32ZVVEPXW3K2D6F71RBJ97HB06X91Q483ECQDSD u2)
(map-set mint-passes 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN u2)
(map-set mint-passes 'SP33K7FH6RDA22TZZVNQA9Z84VH6N1H1DGWEC85E7 u2)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u2)
(map-set mint-passes 'SP368YRZ81XA52ZX2WGXBCZVFZVZSYX203RD2J4CY u2)
(map-set mint-passes 'SP36MCQHXPP0DZ2KPC1KEY6ERC8GKB6QVCAK0PQYG u2)
(map-set mint-passes 'SP38AW9PW8KRA971F5ZT0XH0YGA24QPDP4GB6WEP5 u2)
(map-set mint-passes 'SP3BBTH6PQXSHFM2ZM9J8Q819HS02WKBQ6ZG3HCTZ u2)
(map-set mint-passes 'SP3C27ZAE4K2RE9M5WNRTN7W2626H4CZDGE2TPDWF u2)
(map-set mint-passes 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES u2)
(map-set mint-passes 'SP3EKY8XPBFNTFJY4Y3V926HDK5AJD33Z30RZTX1G u2)
(map-set mint-passes 'SP3FHNTPZ8HYZNFER6EWJ7DZ6Q3WNPVKFWJST7GYR u2)
(map-set mint-passes 'SP3GRJ1FJT7QC7N51PQGR6PZXMXZH5SKQ8B4JRW1D u2)
(map-set mint-passes 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 u2)
(map-set mint-passes 'SP3NAZN83MAM6FVES9RP9MD2DC38Y7NTBFGJETQRG u2)
(map-set mint-passes 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH u2)
(map-set mint-passes 'SP3TF77S4XWBMZ455YTYWRMRMHTM7AZDM6258ACR3 u2)
(map-set mint-passes 'SP3TVVJEEH3X9R7SD0CCCJXNPS8KKVRAQYA5RWEC3 u2)
(map-set mint-passes 'SP3XMYSS7VHPQV9YP2083D3VN8VDH8ZYZYD7XAR6E u2)
(map-set mint-passes 'SP4J5RTF6FS49D5SZ2WCQYBZQ15T22ZHKRFKGBFB u2)
(map-set mint-passes 'SP5X5PTDRCBM5GX2JA4KS2F7ZDDK0ZW1ZH5K5JGQ u2)
(map-set mint-passes 'SP6Z0QQR7WBY4MDSY4F59V5YCT29B9KPQJT0TF45 u2)
(map-set mint-passes 'SP9748CXTYEWCSTAQRQ1KHDV08AC37JCNW95NKMJ u2)
(map-set mint-passes 'SPDAV1G8FQ0TMEWKVE0A9WS8RNDJ7K808X2MY22E u2)
(map-set mint-passes 'SPGYN0JFKZVEKB6KE4X5YTZATPG0M42A0Y1F8DMG u2)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u2)
(map-set mint-passes 'SPM3GE47QTMMVBT6DH0XFBXYS1AJHSSAQMYSB4J8 u2)
(map-set mint-passes 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D u2)
(map-set mint-passes 'SPR6RNTSP1TRMNXG17DHN7S2EVQ4AVDK9Y38MK88 u2)
(map-set mint-passes 'SPRK19EE5AHEGYG6MVVPSMSW00WQEF85HP19DKR7 u2)
(map-set mint-passes 'SPRN8QHNVERT98BEJA3HF7BEXS081TTKV9D10EK0 u2)
(map-set mint-passes 'SPSN6K776CXQBFSVM74W4SAR8W7HCQD6844FA4XC u2)
(map-set mint-passes 'SPTJ1VH1NSPCHJ1E0JHXXCK7EHC1MZW6BT51MCBX u2)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u2)
(map-set mint-passes 'SPV45W9T2ME5M1GKYD4T7W86PE3EYT14WSVG89A1 u2)
(map-set mint-passes 'SPXKPY2NMKPQW7W5PCNKD1YG67GVBJKATQKNA1ZH u2)
(map-set mint-passes 'SPYWT3H4JQG72G0PVZW4E2M6FAK997KN6PDC26GM u2)
(map-set mint-passes 'SPZJ58JKC6R04918DQQ9NT94B9DQJCVRBNVX4NHA u2)
(map-set mint-passes 'SPZJSY1EQ6P4KMX1NX5CDFYJBEPWECFM4V58XB2G u2)
(map-set mint-passes 'SP11M5XSC1C37PJ3BC6NEW81ND2PR5SA5Q0C8NS11 u2)
(map-set mint-passes 'SP143YHR805B8S834BWJTMZVFR1WP5FFC03WZE4BF u2)
(map-set mint-passes 'SP274C9SKTRQV06W86GVVC0MGSNJ1EMXYK8E46PXT u2)
(map-set mint-passes 'SP3G29VGS5YT8RJ7BY3NPEFHKPK1GNFYXCATCAQYB u2)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u2)
(map-set mint-passes 'SP3N9GSEWX710RE5PSD110APZGKSD1EFMBEWSBZJC u2)
(map-set mint-passes 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW u2)
(map-set mint-passes 'SPHSQGVCANXPHGE3XS2JMQXP4H2V31TCDJR6SKGP u2)
(map-set mint-passes 'SPQCAMFRAXV93WNZHWXSDHSZGZ72G9RJPHXQ8CXN u2)
(map-set mint-passes 'SP11M5XSC1C37PJ3BC6NEW81ND2PR5SA5Q0C8NS11 u2)
(map-set mint-passes 'SP143YHR805B8S834BWJTMZVFR1WP5FFC03WZE4BF u2)
(map-set mint-passes 'SP14PVWDVKVK1P1SZV72MJQMNX5N5XDZ8AGNG9M0C u2)
(map-set mint-passes 'SP16YA5N2VE52JRDYXKFZ2TF7T2CBRB4SH8NYKJX1 u2)
(map-set mint-passes 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 u2)
(map-set mint-passes 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA u2)
(map-set mint-passes 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR u2)
(map-set mint-passes 'SP1HQ9YQXNGTRC5AVVTJAPBTFRY7TFH3XDJDC9N88 u2)
(map-set mint-passes 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 u2)
(map-set mint-passes 'SP1XRFVSKEY954TPX1XED41VDEKH9EVVQWTMAWR3Y u2)
(map-set mint-passes 'SP274C9SKTRQV06W86GVVC0MGSNJ1EMXYK8E46PXT u2)
(map-set mint-passes 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N u2)
(map-set mint-passes 'SP295QANJTGHJJ9TSHJ4WH28Z52VDKWDW68VT8KAH u2)
(map-set mint-passes 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR u2)
(map-set mint-passes 'SP2PNN7Z0FB0EQZ8CE0NJE0HH09T19P5WE0GQT0W3 u2)
(map-set mint-passes 'SP2XXMH2DHP5S0CS1VB8C6TV75510YDQA527CAPG0 u2)
(map-set mint-passes 'SP30BTV3905TS3A83CENN271AHZHGM4C3FDZX3JNR u2)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u2)
(map-set mint-passes 'SP36MCQHXPP0DZ2KPC1KEY6ERC8GKB6QVCAK0PQYG u2)
(map-set mint-passes 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES u2)
(map-set mint-passes 'SP3G29VGS5YT8RJ7BY3NPEFHKPK1GNFYXCATCAQYB u2)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u2)
(map-set mint-passes 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 u2)
(map-set mint-passes 'SP3N9GSEWX710RE5PSD110APZGKSD1EFMBEWSBZJC u2)
(map-set mint-passes 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH u2)
(map-set mint-passes 'SP3TF77S4XWBMZ455YTYWRMRMHTM7AZDM6258ACR3 u2)
(map-set mint-passes 'SP3XMYSS7VHPQV9YP2083D3VN8VDH8ZYZYD7XAR6E u2)
(map-set mint-passes 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW u2)
(map-set mint-passes 'SP6Z0QQR7WBY4MDSY4F59V5YCT29B9KPQJT0TF45 u2)
(map-set mint-passes 'SPHSQGVCANXPHGE3XS2JMQXP4H2V31TCDJR6SKGP u2)
(map-set mint-passes 'SPQCAMFRAXV93WNZHWXSDHSZGZ72G9RJPHXQ8CXN u2)
(map-set mint-passes 'SPXKPY2NMKPQW7W5PCNKD1YG67GVBJKATQKNA1ZH u2)
(map-set mint-passes 'SPZJ58JKC6R04918DQQ9NT94B9DQJCVRBNVX4NHA u2)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u0) 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR))
      (map-set token-count 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR (+ (get-balance 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u1) 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T))
      (map-set token-count 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T (+ (get-balance 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u2) 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N))
      (map-set token-count 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N (+ (get-balance 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u3) 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES))
      (map-set token-count 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES (+ (get-balance 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u4) 'SP3XMYSS7VHPQV9YP2083D3VN8VDH8ZYZYD7XAR6E))
      (map-set token-count 'SP3XMYSS7VHPQV9YP2083D3VN8VDH8ZYZYD7XAR6E (+ (get-balance 'SP3XMYSS7VHPQV9YP2083D3VN8VDH8ZYZYD7XAR6E) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u5) 'SP3Y43V5ADNCGMBEY2N29VJSG8AE35W1SG5KK8DMB))
      (map-set token-count 'SP3Y43V5ADNCGMBEY2N29VJSG8AE35W1SG5KK8DMB (+ (get-balance 'SP3Y43V5ADNCGMBEY2N29VJSG8AE35W1SG5KK8DMB) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u6) 'SPKKH2MBR4FA5XWTTCE3NJZ85EDTBS283B9S2BFR))
      (map-set token-count 'SPKKH2MBR4FA5XWTTCE3NJZ85EDTBS283B9S2BFR (+ (get-balance 'SPKKH2MBR4FA5XWTTCE3NJZ85EDTBS283B9S2BFR) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u7) 'SPPCHF5474M4X5ZS79TCKSNRKJ24Y71J77ZKTAP3))
      (map-set token-count 'SPPCHF5474M4X5ZS79TCKSNRKJ24Y71J77ZKTAP3 (+ (get-balance 'SPPCHF5474M4X5ZS79TCKSNRKJ24Y71J77ZKTAP3) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u8) 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS))
      (map-set token-count 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS (+ (get-balance 'SP1PJ0M4N981B47GT6KERPKHN1APJH2T5NWZSV7GS) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u9) 'SP35MEYYBHSFCFXY296YGP7NAT6Y4XBJW2VETR8AV))
      (map-set token-count 'SP35MEYYBHSFCFXY296YGP7NAT6Y4XBJW2VETR8AV (+ (get-balance 'SP35MEYYBHSFCFXY296YGP7NAT6Y4XBJW2VETR8AV) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u10) 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR))
      (map-set token-count 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR (+ (get-balance 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u11) 'SP1FBDV7183BMRESDSKYAA712WVGZA9M95H06VG1W))
      (map-set token-count 'SP1FBDV7183BMRESDSKYAA712WVGZA9M95H06VG1W (+ (get-balance 'SP1FBDV7183BMRESDSKYAA712WVGZA9M95H06VG1W) u1))
      (try! (nft-mint? nandi-sisters (+ last-nft-id u12) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))

      (var-set last-id (+ last-nft-id u13))
      (var-set airdrop-called true)
      (ok true))))