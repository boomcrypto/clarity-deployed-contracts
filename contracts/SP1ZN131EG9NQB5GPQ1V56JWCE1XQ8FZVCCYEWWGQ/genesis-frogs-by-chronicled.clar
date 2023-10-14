;; genesis-frogs-by-chronicled
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token genesis-frogs-by-chronicled uint)

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
(define-data-var mint-limit uint u69)
(define-data-var last-id uint u1)
(define-data-var total-price uint u10000000)
(define-data-var artist-address principal 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmXTzMMaDFxhTKHVAKcTtxE4wCfxBLLQ2eyHYym2JEBSmQ/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u40)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

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
      (unwrap! (nft-mint? genesis-frogs-by-chronicled next-id tx-sender) next-id)
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
    (nft-burn? genesis-frogs-by-chronicled token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? genesis-frogs-by-chronicled token-id) false)))

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
  (ok (nft-get-owner? genesis-frogs-by-chronicled token-id)))

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
  (match (nft-transfer? genesis-frogs-by-chronicled id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? genesis-frogs-by-chronicled id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? genesis-frogs-by-chronicled id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W u2)
(map-set mint-passes 'SP3MQWTZTFFTN01N94MBAAJQQGG0QA3FZV84YT7FV u2)
(map-set mint-passes 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND u8)
(map-set mint-passes 'SPA88SX7PYTTEQ9NBPGEY17Y0BZSBMTW47SGW7QC u4)
(map-set mint-passes 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX u2)
(map-set mint-passes 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0 u2)
(map-set mint-passes 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27 u2)
(map-set mint-passes 'SP1HXVYG71K90BCW2VGBDV6Q6AVT539WKAAKWARK5 u2)
(map-set mint-passes 'SP192SNSBH4WZBCT672S5B4948TF50ETH9YFG3QW4 u2)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u6)
(map-set mint-passes 'SP38WCGSSQJBFAKH77R93AMTHBBEF83DQ6EJ358F2 u2)
(map-set mint-passes 'SP2AB8Q2MMPP1S2NM13N3NNBE0KA6CG94FK7MZ41H u2)
(map-set mint-passes 'SP249H1JFV31H5ZXP4AAQ137HPCQSQ5D37WMQJ4T5 u2)
(map-set mint-passes 'SP3PX4H4TAH8CBPPQQPHB8SC454PSQ20QVPQWB5VT u4)
(map-set mint-passes 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 u6)
(map-set mint-passes 'SP2RKVC8PYANWJ40VSRCK2K935HSN4H0AHTVHD73D u2)
(map-set mint-passes 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV u2)
(map-set mint-passes 'SPMB00CAGKF8VF1H7WGE9A6HHPWGN6QAQMDN2D69 u2)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u0) 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W))
      (map-set token-count 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W (+ (get-balance 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u1) 'SP3MQWTZTFFTN01N94MBAAJQQGG0QA3FZV84YT7FV))
      (map-set token-count 'SP3MQWTZTFFTN01N94MBAAJQQGG0QA3FZV84YT7FV (+ (get-balance 'SP3MQWTZTFFTN01N94MBAAJQQGG0QA3FZV84YT7FV) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u2) 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND))
      (map-set token-count 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND (+ (get-balance 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u3) 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND))
      (map-set token-count 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND (+ (get-balance 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u4) 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND))
      (map-set token-count 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND (+ (get-balance 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u5) 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND))
      (map-set token-count 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND (+ (get-balance 'SP2YQCF4DMRWRPKD0EVNDY3AJ0BBS9FQH548GCHND) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u6) 'SPA88SX7PYTTEQ9NBPGEY17Y0BZSBMTW47SGW7QC))
      (map-set token-count 'SPA88SX7PYTTEQ9NBPGEY17Y0BZSBMTW47SGW7QC (+ (get-balance 'SPA88SX7PYTTEQ9NBPGEY17Y0BZSBMTW47SGW7QC) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u7) 'SPA88SX7PYTTEQ9NBPGEY17Y0BZSBMTW47SGW7QC))
      (map-set token-count 'SPA88SX7PYTTEQ9NBPGEY17Y0BZSBMTW47SGW7QC (+ (get-balance 'SPA88SX7PYTTEQ9NBPGEY17Y0BZSBMTW47SGW7QC) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u8) 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX))
      (map-set token-count 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX (+ (get-balance 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u9) 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0))
      (map-set token-count 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0 (+ (get-balance 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u10) 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27))
      (map-set token-count 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27 (+ (get-balance 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u11) 'SP1HXVYG71K90BCW2VGBDV6Q6AVT539WKAAKWARK5))
      (map-set token-count 'SP1HXVYG71K90BCW2VGBDV6Q6AVT539WKAAKWARK5 (+ (get-balance 'SP1HXVYG71K90BCW2VGBDV6Q6AVT539WKAAKWARK5) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u12) 'SP192SNSBH4WZBCT672S5B4948TF50ETH9YFG3QW4))
      (map-set token-count 'SP192SNSBH4WZBCT672S5B4948TF50ETH9YFG3QW4 (+ (get-balance 'SP192SNSBH4WZBCT672S5B4948TF50ETH9YFG3QW4) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u13) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u14) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u15) 'SP38WCGSSQJBFAKH77R93AMTHBBEF83DQ6EJ358F2))
      (map-set token-count 'SP38WCGSSQJBFAKH77R93AMTHBBEF83DQ6EJ358F2 (+ (get-balance 'SP38WCGSSQJBFAKH77R93AMTHBBEF83DQ6EJ358F2) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u16) 'SP2AB8Q2MMPP1S2NM13N3NNBE0KA6CG94FK7MZ41H))
      (map-set token-count 'SP2AB8Q2MMPP1S2NM13N3NNBE0KA6CG94FK7MZ41H (+ (get-balance 'SP2AB8Q2MMPP1S2NM13N3NNBE0KA6CG94FK7MZ41H) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u17) 'SP249H1JFV31H5ZXP4AAQ137HPCQSQ5D37WMQJ4T5))
      (map-set token-count 'SP249H1JFV31H5ZXP4AAQ137HPCQSQ5D37WMQJ4T5 (+ (get-balance 'SP249H1JFV31H5ZXP4AAQ137HPCQSQ5D37WMQJ4T5) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u18) 'SP3PX4H4TAH8CBPPQQPHB8SC454PSQ20QVPQWB5VT))
      (map-set token-count 'SP3PX4H4TAH8CBPPQQPHB8SC454PSQ20QVPQWB5VT (+ (get-balance 'SP3PX4H4TAH8CBPPQQPHB8SC454PSQ20QVPQWB5VT) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u19) 'SP3PX4H4TAH8CBPPQQPHB8SC454PSQ20QVPQWB5VT))
      (map-set token-count 'SP3PX4H4TAH8CBPPQQPHB8SC454PSQ20QVPQWB5VT (+ (get-balance 'SP3PX4H4TAH8CBPPQQPHB8SC454PSQ20QVPQWB5VT) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u20) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u21) 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7))
      (map-set token-count 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 (+ (get-balance 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u22) 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7))
      (map-set token-count 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 (+ (get-balance 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7) u1))
      (try! (nft-mint? genesis-frogs-by-chronicled (+ last-nft-id u23) 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7))
      (map-set token-count 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 (+ (get-balance 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7) u1))

      (var-set last-id (+ last-nft-id u24))
      (var-set airdrop-called true)
      (ok true))))