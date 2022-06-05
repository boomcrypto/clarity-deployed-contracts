;; hungry-artist-ea-badge

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token hungry-artist-ea-badge uint)

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
(define-data-var mint-limit uint u1)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP1V19KW8DVQ5D8YPBVHBF9NZXWMC0Q4FGG7S9NRY)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmUhYBi7NMkoSNkHfBmSpjJpxJa91ffNoQGkEcbN7dFGCJ/json/")
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
      (unwrap! (nft-mint? hungry-artist-ea-badge next-id tx-sender) next-id)
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
    (nft-burn? hungry-artist-ea-badge token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? hungry-artist-ea-badge token-id) false)))

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
  (ok (nft-get-owner? hungry-artist-ea-badge token-id)))

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
  (match (nft-transfer? hungry-artist-ea-badge id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? hungry-artist-ea-badge id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? hungry-artist-ea-badge id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
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
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u0) 'SP14XAQNMBVPY6YFARA3SHMBVVZ7BK5R7G4KS7V9H))
      (map-set token-count 'SP14XAQNMBVPY6YFARA3SHMBVVZ7BK5R7G4KS7V9H (+ (get-balance 'SP14XAQNMBVPY6YFARA3SHMBVVZ7BK5R7G4KS7V9H) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u1) 'SP1J4SFHSMMT5Z0PG3WDD1TNGZVCWMB5QBYHNFECG))
      (map-set token-count 'SP1J4SFHSMMT5Z0PG3WDD1TNGZVCWMB5QBYHNFECG (+ (get-balance 'SP1J4SFHSMMT5Z0PG3WDD1TNGZVCWMB5QBYHNFECG) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u2) 'SP1J4SFHSMMT5Z0PG3WDD1TNGZVCWMB5QBYHNFECG))
      (map-set token-count 'SP1J4SFHSMMT5Z0PG3WDD1TNGZVCWMB5QBYHNFECG (+ (get-balance 'SP1J4SFHSMMT5Z0PG3WDD1TNGZVCWMB5QBYHNFECG) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u3) 'SP1M282N6WDN0C3M38B9G710S7YWGFS0GX8HATZHP))
      (map-set token-count 'SP1M282N6WDN0C3M38B9G710S7YWGFS0GX8HATZHP (+ (get-balance 'SP1M282N6WDN0C3M38B9G710S7YWGFS0GX8HATZHP) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u4) 'SP1S6Y45D7M0DV4E29H7ZZ4XGTQ2WW3RB9JC0QSQ2))
      (map-set token-count 'SP1S6Y45D7M0DV4E29H7ZZ4XGTQ2WW3RB9JC0QSQ2 (+ (get-balance 'SP1S6Y45D7M0DV4E29H7ZZ4XGTQ2WW3RB9JC0QSQ2) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u5) 'SP1YMH93HAPEX7ZX51N1J76M0WCMKM1Y7F4W1Y9CT))
      (map-set token-count 'SP1YMH93HAPEX7ZX51N1J76M0WCMKM1Y7F4W1Y9CT (+ (get-balance 'SP1YMH93HAPEX7ZX51N1J76M0WCMKM1Y7F4W1Y9CT) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u6) 'SP25HAV8ZKNE8B7QCT1FPKPD8JQF2KK06VKQE6JSE))
      (map-set token-count 'SP25HAV8ZKNE8B7QCT1FPKPD8JQF2KK06VKQE6JSE (+ (get-balance 'SP25HAV8ZKNE8B7QCT1FPKPD8JQF2KK06VKQE6JSE) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u7) 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC))
      (map-set token-count 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC (+ (get-balance 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u8) 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G))
      (map-set token-count 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G (+ (get-balance 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u9) 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ))
      (map-set token-count 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ (+ (get-balance 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u10) 'SPPDZ2TGEK5SGT93M2Z31MV8538DFMQKJNWKP9QF))
      (map-set token-count 'SPPDZ2TGEK5SGT93M2Z31MV8538DFMQKJNWKP9QF (+ (get-balance 'SPPDZ2TGEK5SGT93M2Z31MV8538DFMQKJNWKP9QF) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u11) 'SP3MCBTS2V2AJCKBAHZSMJM16RF0TEQBZMRWSSK3Q))
      (map-set token-count 'SP3MCBTS2V2AJCKBAHZSMJM16RF0TEQBZMRWSSK3Q (+ (get-balance 'SP3MCBTS2V2AJCKBAHZSMJM16RF0TEQBZMRWSSK3Q) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u12) 'SP2C12A775FJB1PZRC84RMTDVXZZXGPT1CPV5YBFY))
      (map-set token-count 'SP2C12A775FJB1PZRC84RMTDVXZZXGPT1CPV5YBFY (+ (get-balance 'SP2C12A775FJB1PZRC84RMTDVXZZXGPT1CPV5YBFY) u1))
      (try! (nft-mint? hungry-artist-ea-badge (+ last-nft-id u13) 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W))
      (map-set token-count 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W (+ (get-balance 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W) u1))

      (var-set last-id (+ last-nft-id u14))
      (var-set airdrop-called true)
      (ok true))))