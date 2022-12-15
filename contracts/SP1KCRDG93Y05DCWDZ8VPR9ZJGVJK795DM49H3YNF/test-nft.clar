;; weed-monsters
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token weed-monsters uint)

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
(define-data-var mint-limit uint u420)
(define-data-var last-id uint u1)
(define-data-var total-price uint u15000000)
(define-data-var artist-address principal 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmSTgPY1wZK1FMFfbBMfeYwae6mBgeCyiY58DcpXNY296Z/json/")
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

(define-public (mint-for-many (recipients (list 25 principal)))
  (let
    (
      (next-id (var-get last-id))
      (id-reached (fold mint-for-many-iter recipients next-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (var-set last-id id-reached)
      (ok id-reached))))

(define-private (mint-for-many-iter (recipient principal) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? weed-monsters next-id tx-sender) next-id)
      (unwrap! (nft-transfer? weed-monsters next-id tx-sender recipient) next-id)
      (map-set token-count recipient (+ (get-balance recipient) u1))      
      (+ next-id u1)
    )
    next-id))

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
      (unwrap! (nft-mint? weed-monsters next-id tx-sender) next-id)
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
    (nft-burn? weed-monsters token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? weed-monsters token-id) false)))

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
  (ok (nft-get-owner? weed-monsters token-id)))

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
  (match (nft-transfer? weed-monsters id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? weed-monsters id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? weed-monsters id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 u8)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u7)
(map-set mint-passes 'SP2TGN9DJWTV02B9HRGX6Z43Y7052DTZW6FZVZH0S u2)
(map-set mint-passes 'SP3FRT6WTV0NGX5NX8EHJZDA7R79CKGGNQJEC0WQ9 u1)
(map-set mint-passes 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV u2)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u2)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u2)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? weed-monsters (+ last-nft-id u0) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u1) 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP))
      (map-set token-count 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP (+ (get-balance 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u2) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u3) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u4) 'SP2TGN9DJWTV02B9HRGX6Z43Y7052DTZW6FZVZH0S))
      (map-set token-count 'SP2TGN9DJWTV02B9HRGX6Z43Y7052DTZW6FZVZH0S (+ (get-balance 'SP2TGN9DJWTV02B9HRGX6Z43Y7052DTZW6FZVZH0S) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u5) 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP))
      (map-set token-count 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP (+ (get-balance 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u6) 'SP3M72S3S5085CHCMH6KWQG6NGFT9MYFJRZX036P2))
      (map-set token-count 'SP3M72S3S5085CHCMH6KWQG6NGFT9MYFJRZX036P2 (+ (get-balance 'SP3M72S3S5085CHCMH6KWQG6NGFT9MYFJRZX036P2) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u7) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u8) 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X))
      (map-set token-count 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X (+ (get-balance 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u9) 'SP30MX9SS3S6DAY1BRXSQT5SQGQ0PX391MY1YPBF8))
      (map-set token-count 'SP30MX9SS3S6DAY1BRXSQT5SQGQ0PX391MY1YPBF8 (+ (get-balance 'SP30MX9SS3S6DAY1BRXSQT5SQGQ0PX391MY1YPBF8) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u10) 'SP3RRA0RQDNGRQYM0K64EVX8E0MBH0DEPPPN4KQG8))
      (map-set token-count 'SP3RRA0RQDNGRQYM0K64EVX8E0MBH0DEPPPN4KQG8 (+ (get-balance 'SP3RRA0RQDNGRQYM0K64EVX8E0MBH0DEPPPN4KQG8) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u11) 'SP3A09H1JEB4F85FZ6XEXRSZA210SC6RB7Q7V7DAF))
      (map-set token-count 'SP3A09H1JEB4F85FZ6XEXRSZA210SC6RB7Q7V7DAF (+ (get-balance 'SP3A09H1JEB4F85FZ6XEXRSZA210SC6RB7Q7V7DAF) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u12) 'SP1WXMX9PYKSH86XW29Y30PKKSEAS4MKX9XJQ4GTG))
      (map-set token-count 'SP1WXMX9PYKSH86XW29Y30PKKSEAS4MKX9XJQ4GTG (+ (get-balance 'SP1WXMX9PYKSH86XW29Y30PKKSEAS4MKX9XJQ4GTG) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u13) 'SP2JKPKJCCRTEC1K81W8S3HCFXCP0H7PDKTN0CEGS))
      (map-set token-count 'SP2JKPKJCCRTEC1K81W8S3HCFXCP0H7PDKTN0CEGS (+ (get-balance 'SP2JKPKJCCRTEC1K81W8S3HCFXCP0H7PDKTN0CEGS) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u14) 'SP3FRT6WTV0NGX5NX8EHJZDA7R79CKGGNQJEC0WQ9))
      (map-set token-count 'SP3FRT6WTV0NGX5NX8EHJZDA7R79CKGGNQJEC0WQ9 (+ (get-balance 'SP3FRT6WTV0NGX5NX8EHJZDA7R79CKGGNQJEC0WQ9) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u15) 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227))
      (map-set token-count 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227 (+ (get-balance 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u16) 'SP38WZ44X5X4ZYJQ4V9A9R756AY0BAH3S524M81XE))
      (map-set token-count 'SP38WZ44X5X4ZYJQ4V9A9R756AY0BAH3S524M81XE (+ (get-balance 'SP38WZ44X5X4ZYJQ4V9A9R756AY0BAH3S524M81XE) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u17) 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ))
      (map-set token-count 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ (+ (get-balance 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u18) 'SP36MCQHXPP0DZ2KPC1KEY6ERC8GKB6QVCAK0PQYG))
      (map-set token-count 'SP36MCQHXPP0DZ2KPC1KEY6ERC8GKB6QVCAK0PQYG (+ (get-balance 'SP36MCQHXPP0DZ2KPC1KEY6ERC8GKB6QVCAK0PQYG) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u19) 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G))
      (map-set token-count 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G (+ (get-balance 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u20) 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP))
      (map-set token-count 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP (+ (get-balance 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u21) 'SP3FRT6WTV0NGX5NX8EHJZDA7R79CKGGNQJEC0WQ9))
      (map-set token-count 'SP3FRT6WTV0NGX5NX8EHJZDA7R79CKGGNQJEC0WQ9 (+ (get-balance 'SP3FRT6WTV0NGX5NX8EHJZDA7R79CKGGNQJEC0WQ9) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u22) 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV))
      (map-set token-count 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV (+ (get-balance 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u23) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? weed-monsters (+ last-nft-id u24) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))

      (var-set last-id (+ last-nft-id u25))
      (var-set airdrop-called true)
      (ok true))))