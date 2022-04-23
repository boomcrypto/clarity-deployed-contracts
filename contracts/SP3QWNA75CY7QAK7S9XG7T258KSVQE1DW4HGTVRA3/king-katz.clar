;; king-katz

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token king-katz uint)

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
(define-data-var mint-limit uint u355)
(define-data-var last-id uint u1)
(define-data-var total-price uint u25000000)
(define-data-var artist-address principal 'SP3QWNA75CY7QAK7S9XG7T258KSVQE1DW4HGTVRA3)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmTg7HpXT9qkWBnDu6YLiudiWukLAXgLGZGBHYET4sZ77f/json/")
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

(define-public (claim-three) (mint (list true true true)))

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
      (unwrap! (nft-mint? king-katz next-id tx-sender) next-id)
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
    (nft-burn? king-katz token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? king-katz token-id) false)))

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
  (ok (nft-get-owner? king-katz token-id)))

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
  (match (nft-transfer? king-katz id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? king-katz id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? king-katz id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA u3)
(map-set mint-passes 'SPCWXTK34AG7S9SW8H3HN8F1TFDR7N4AY0THG5KC u3)
(map-set mint-passes 'SP349J1ZTEE71M1J5D4YS0BPQCCFJ3YSNM1P8BJY4 u2)
(map-set mint-passes 'SPAX2SZCDFTVV76SR4JY4RYEPC5PBH2QAHEJXHTF u2)
(map-set mint-passes 'SP1J4SFHSMMT5Z0PG3WDD1TNGZVCWMB5QBYHNFECG u2)
(map-set mint-passes 'SP3KTNQFHQ4N5DH40F1164TGYMX3QG2N8NA5VKN4X u2)
(map-set mint-passes 'SP2V0BTG3PA4WM2VS1BDEQJJPTENT9DDF27EV4WD2 u2)
(map-set mint-passes 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G u2)
(map-set mint-passes 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ u2)
(map-set mint-passes 'SP2H6HVZK6X3Z8F4PKF284AZJR6FH4H9J4W6KVV8T u3)
(map-set mint-passes 'SP3B7A59TCS2FE4A2Z74AD97TG3PXYSY068Z16AE9 u2)
(map-set mint-passes 'SP279X3F51M2N9FXTFWXCRJQ2BBQNFHGGKBBQCE6Y u2)
(map-set mint-passes 'SP2SW9VG6E7ZT0X1NEAF989JKKBCTQ5XHFKEGP55Z u2)
(map-set mint-passes 'SP2DW9RTN82J2MR2FHQXY5EE0Y616JJ076RYG8PTY u2)
(map-set mint-passes 'SP14E544B2FY8BSKTV5V7W8NCRYX2B7NXRQ7B7NJ9 u2)
(map-set mint-passes 'SP3JE4MY4Z91VRE9DWPH98Y6BRRA1YS5RDK9BA6Y7 u2)
(map-set mint-passes 'SPDAV1G8FQ0TMEWKVE0A9WS8RNDJ7K808X2MY22E u2)
(map-set mint-passes 'SPMCASGEFH0TTYF24183K6ZAM56CNZE1RTPD4BF9 u2)
(map-set mint-passes 'SPSN6K776CXQBFSVM74W4SAR8W7HCQD6844FA4XC u3)
(map-set mint-passes 'SP2Z0DE9N41R5C5YEXVF6JV5Z13DFKVYWDMJ5PH46 u2)
(map-set mint-passes 'SP23NK4EGQSWEZMS8WC1X9AGH85JV6BGB9DD7RK80 u2)
(map-set mint-passes 'SPC4KZE8PZ82XG79TYGFXMWMNFY0TPFEFESYWFS7 u2)
(map-set mint-passes 'SP36R55F5WWZMYHJZJ2QNKEHT5QA1VJNR399ETMG8 u2)
(map-set mint-passes 'SP21EJNMZXP92ZDVQP339P2Q8SZD4W918TK8AS72N u3)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u2)
(map-set mint-passes 'SP2DW9RTN82J2MR2FHQXY5EE0Y616JJ076RYG8PTY u3)
(map-set mint-passes 'SP1JERBJV7YZPWXKNK5YAJ814K3KZ9N6RWHH387XW u2)
(map-set mint-passes 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G u2)
(map-set mint-passes 'SPCGYWGKWZ9P21Y31H3GC1BYDEFQ1MJJYM3G34EK u2)
(map-set mint-passes 'SP349J1ZTEE71M1J5D4YS0BPQCCFJ3YSNM1P8BJY4 u2)
(map-set mint-passes 'SP3HY8Z7BBPVJH7PKP3VBCEA9DE8XATR9ENR39QB3 u2)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? king-katz (+ last-nft-id u0) 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA))
      (map-set token-count 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA (+ (get-balance 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u1) 'SPK7DG4XGAFC8G000K34MK8N7JRX9NEWG7J1Q6F0))
      (map-set token-count 'SPK7DG4XGAFC8G000K34MK8N7JRX9NEWG7J1Q6F0 (+ (get-balance 'SPK7DG4XGAFC8G000K34MK8N7JRX9NEWG7J1Q6F0) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u2) 'SP29D96J97BQTKJ6YP7JX7FC2DYBGYRCXR62C1EFV))
      (map-set token-count 'SP29D96J97BQTKJ6YP7JX7FC2DYBGYRCXR62C1EFV (+ (get-balance 'SP29D96J97BQTKJ6YP7JX7FC2DYBGYRCXR62C1EFV) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u3) 'SP2556V9PQN1204Q19708PD4KEY0DTYD22SG9EHXG))
      (map-set token-count 'SP2556V9PQN1204Q19708PD4KEY0DTYD22SG9EHXG (+ (get-balance 'SP2556V9PQN1204Q19708PD4KEY0DTYD22SG9EHXG) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u4) 'SP2MVJFBXNRH5DV5Y6NXS70AAPAVCZ0RXK2CNVWAR))
      (map-set token-count 'SP2MVJFBXNRH5DV5Y6NXS70AAPAVCZ0RXK2CNVWAR (+ (get-balance 'SP2MVJFBXNRH5DV5Y6NXS70AAPAVCZ0RXK2CNVWAR) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u5) 'SP2NGF32FDBRC2FXYDNRYFX60B97N2FZGYK0MEYX9))
      (map-set token-count 'SP2NGF32FDBRC2FXYDNRYFX60B97N2FZGYK0MEYX9 (+ (get-balance 'SP2NGF32FDBRC2FXYDNRYFX60B97N2FZGYK0MEYX9) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u6) 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G))
      (map-set token-count 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G (+ (get-balance 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u7) 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G))
      (map-set token-count 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G (+ (get-balance 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u8) 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G))
      (map-set token-count 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G (+ (get-balance 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u9) 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G))
      (map-set token-count 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G (+ (get-balance 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u10) 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G))
      (map-set token-count 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G (+ (get-balance 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G) u1))
      (try! (nft-mint? king-katz (+ last-nft-id u11) 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G))
      (map-set token-count 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G (+ (get-balance 'SP1WY2NB1DXCV4K2H5H88D4G1QNKKZ3VZ398CET8G) u1))

      (var-set last-id (+ last-nft-id u12))
      (var-set airdrop-called true)
      (ok true))))