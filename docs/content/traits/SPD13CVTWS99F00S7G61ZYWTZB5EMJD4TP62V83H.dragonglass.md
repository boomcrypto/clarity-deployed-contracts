---
title: "Trait dragonglass"
draft: true
---
```
;; dragonglass
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token dragonglass uint)

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
(define-data-var mint-limit uint u640)
(define-data-var last-id uint u1)
(define-data-var total-price uint u2000000)
(define-data-var artist-address principal 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmdLWtFSes4KmRVtV3ZpkcvcTSQtQ69wdTVTECmc9bLonD/json/")
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
      (unwrap! (nft-mint? dragonglass next-id tx-sender) next-id)
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
    (nft-burn? dragonglass token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? dragonglass token-id) false)))

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
  (ok (nft-get-owner? dragonglass token-id)))

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
  (match (nft-transfer? dragonglass id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? dragonglass id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? dragonglass id) (err ERR-NOT-FOUND)))
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
(define-data-var total-price-xbtc uint u6322)

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
(define-data-var total-price-alex uint u2900000000)

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
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-alex orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-alex orders)
      )
    )))

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

(map-set mint-passes 'SP1Z0JAG083DEE8VQ5H1D5RJDCT5DVEGS212N4XX8 u5)
(map-set mint-passes 'SP1DZ6CVX4TYYNRV39WBPSH18EMA5C6S6TZHBZT75 u5)
(map-set mint-passes 'SP1FHC2XXJW3CQFNFZX60633E5WPWST4DBW8JFP66 u5)
(map-set mint-passes 'SP2GYXR37WGDP11A2CT9T4HBXDPS8SA6YTHQ8A2NH u5)
(map-set mint-passes 'SP3ATFW5VSD0W4N0E3K1E4CGFE8MJXQ9XFFMQ0HBY u5)
(map-set mint-passes 'SPQ5Q6C96DMXJ4E7H5C1R2J9ZE3CESW2NWDPVGDP u5)
(map-set mint-passes 'SP14NSM2BAB9MGMYNXJB93NY4EF4NFRW3G3EFBZDX u5)
(map-set mint-passes 'SP3M6ZYGZJ69R83D4HQBDSXR3MH60B52G18V7XKTT u5)
(map-set mint-passes 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY u5)
(map-set mint-passes 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX u5)
(map-set mint-passes 'SPVAZAK0M3MYRNVJZB5E6TQMYD45R3Q48B66T4EG u5)
(map-set mint-passes 'SP129BVWPY2JQV0HZMGHD201GSWVM6S6MD1JWWGNV u5)
(map-set mint-passes 'SP3QKAQS3J0YS3ZAZPSZM5ZSZZRYRYV72N6A9ZPZT u5)
(map-set mint-passes 'SP9Q5F8EQRZ3N5DE80QW8AVAQ08JGAYZDMAMTG5C u5)
(map-set mint-passes 'SP1JH7MN029C04YV8ZQS3VH5TMN012PDC4S4C66A9 u5)
(map-set mint-passes 'SP3J7Y4C6XGJ5DAWMAKVDT4YTSH5FJP1THCZ2NYY4 u5)
(map-set mint-passes 'SP3H8DZ5PV4XGA4ZZ2ZXZXN3XSNNANATZKMB7AJ9V u5)
(map-set mint-passes 'SPBRCX7VZ559A20A3JF2P6RBSRFZ9MDSN6ZSRDTM u5)
(map-set mint-passes 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN u5)
(map-set mint-passes 'SP9TVMYQR4BSQXJSH6Y27EBGAFDXEB1JB8ZYE4NP u5)
(map-set mint-passes 'SP24478XYAB7DZF7850JWVYQRGGRKDWXF7WKKRY30 u5)
(map-set mint-passes 'SP177JV93RYPWWTX5F0MK9NVQ3YTXB4YQZGBPP6H4 u5)
(map-set mint-passes 'SP2BJ0RE1JX3X7158KSY6VR4DVD364AS5X6V5E8SH u5)
(map-set mint-passes 'SP1YC3V7R7HWC5NQH1Q7SMC6BQMX9Z3AESZFWZ94M u5)
(map-set mint-passes 'SP26RMN84H52GHBEB8GBA89PBST9WRR7FX6MVGHVD u5)
(map-set mint-passes 'SP1CKB57B1V4983HC3DTA05825P8RVQSVV9JN404S u5)
(map-set mint-passes 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 u5)
(map-set mint-passes 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8 u5)
(map-set mint-passes 'SP1TC21ASZ57YQFC9THB85HSMDH6P1BNVPACWATRB u5)
(map-set mint-passes 'SP35ZPRFSCA52PW0P9N52D2AWP9QWTFH8RFM23G44 u5)
(map-set mint-passes 'SP10MJMD78XV08EK1A9BWV9CGZZCAB7XTXQFZ9PMN u5)
(map-set mint-passes 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R u5)
(map-set mint-passes 'SP2X99P771E66NBW4WFSFS9FDCRWDFQYX5R90ST26 u5)
(map-set mint-passes 'SPCD0ZWMQ75ZJ152PB0C2Q1S69P0GDFYBAS3Q315 u5)
(map-set mint-passes 'SP13H6Y64BQM1SE17PVQAVGWWXRH4SBCSYM61JFG3 u5)
(map-set mint-passes 'SP2H4DZR0C5Y2X0HTC3PW79PEHNRQHPP7GGHX35P6 u5)
(map-set mint-passes 'SP2X99P771E66NBW4WFSFS9FDCRWDFQYX5R90ST26 u5)
(map-set mint-passes 'SP2SF1JY2TTZ6ZBR869XXH13WZ1B8RQYXY3QBBEHV u5)
(map-set mint-passes 'SP35ZPRFSCA52PW0P9N52D2AWP9QWTFH8RFM23G44 u5)
(map-set mint-passes 'SP2DY9G2WMTNDYTXEZ8W3EYK7H1Y970FCXS1KHX6F u5)
(map-set mint-passes 'SP2X99P771E66NBW4WFSFS9FDCRWDFQYX5R90ST26 u5)
(map-set mint-passes 'SPCD0ZWMQ75ZJ152PB0C2Q1S69P0GDFYBAS3Q315 u5)
(map-set mint-passes 'SPBNJ6AE40H35XR2FWBRCMYMAB2FCXQX56W8M7QP u5)
(map-set mint-passes 'SP15DJNA3BRATX8W73MAWDBQ68FHKMB4GENEZ1243 u5)
(map-set mint-passes 'SP16C7B7B6ZPXCTT5MHSG00WB0JG0R87YH12PDV6T u5)
(map-set mint-passes 'SP12S5AWKQCKJ43BG25R397FH2X8BVVCSG7B9DT3H u5)
(map-set mint-passes 'SP14NE4KPJQ0KWP1K6CGGVBY08J4E1A2GETFRG2ZT u5)
(map-set mint-passes 'SP1TXNDK4CH2SB794Z390G7P28WZ0S7JY9VWAAWBK u5)
(map-set mint-passes 'SP12S5AWKQCKJ43BG25R397FH2X8BVVCSG7B9DT3H u5)
(map-set mint-passes 'SP13H6Y64BQM1SE17PVQAVGWWXRH4SBCSYM61JFG3 u5)
(map-set mint-passes 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C u5)
(map-set mint-passes 'SP3J6Q1KGB2CCMD0EN5K29E95DYWAHYCDA0KJK09G u5)
(map-set mint-passes 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN u5)
(map-set mint-passes 'SP3Y42Z26Z8WQ5FF4ZKDW7K7PJ0JEYFRC98QY9N1E u5)
(map-set mint-passes 'SP1Q9FNT1EJEGDBS98JYNCW4WCDEK8YNBCVFZQN7X u5)
(map-set mint-passes 'SP1XS458RNMG4CCHGH9FZY21GFY3EDCQ766CSGHSP u5)
(map-set mint-passes 'SP17B475SHGM98Y39AR2AVZ3ZFTWV61MKDPFCGF3A u5)
(map-set mint-passes 'SP156CPYZP5VV2C09NWYWQT4CP0T9EWJP76Y18E3T u5)
(map-set mint-passes 'SP1NQT9PMVBWHZHSM13RD6CYF86G4YA99JR5Q1NM5 u5)
(map-set mint-passes 'SP34XFG92G0Q8TK9X766PVE3RNS8NJAA16Z2962K6 u5)
(map-set mint-passes 'SP388WVM5SA4B6MJ6J2TB04F7JY1P8H417A8GWTE0 u5)
(map-set mint-passes 'SP282MPCBMDEMB6ZJ2GRV1FE5HC1PZN96GHD8A99K u5)
(map-set mint-passes 'SPVN6PSK8PNH2QZ9M06W2A1KQQQA6J1FF267VCWC u5)
(map-set mint-passes 'SP9Q5F8EQRZ3N5DE80QW8AVAQ08JGAYZDMAMTG5C u5)
(map-set mint-passes 'SP3FSM25KBPTD475NY3F9FDC5KW1W1Q5WXNKCE6GP u5)
(map-set mint-passes 'SP1NSXWERJC93TFTGC8X1TWMWZS500KNHT6SC99T3 u5)
(map-set mint-passes 'SP1MAVN1K5D9JJDVFK6RMJABE6NAV4K67G2SG34ZN u5)
(map-set mint-passes 'SP9Q5F8EQRZ3N5DE80QW8AVAQ08JGAYZDMAMTG5C u5)
(map-set mint-passes 'SP1S8M0JGYMEANDY36P6KBYJV2PY6P4KQE66FGFSC u5)
(map-set mint-passes 'SP313MRFF9AK07W9P1WETX32ZTH3V9MQ6VVM8BF62 u5)
(map-set mint-passes 'SP103BZSXCX2YF8HXMN8DDP5Z46DN4A0HPRDYJXDD u5)
(map-set mint-passes 'SP296K1JB7V6E2S8WHYHBAE4MVR0PFCATQXYVYVJ8 u5)
(map-set mint-passes 'SP32TQ74B1AQPS9BMKYKYXW6C8RMPF304CF771G4P u5)
(map-set mint-passes 'SP3R2V4GPGK60VHXXCNW7D2W959993F428TJ99V4X u5)
(map-set mint-passes 'SP2RWVYPRJAJY35179GS0JNXXX2K9K380J7F563N0 u5)
(map-set mint-passes 'SP1QXW6GXYZNEE5NX9B1K7CPHKRVT7FFHSB23BK7D u5)
(map-set mint-passes 'SP2T1Y6XZYJFMRXCZ3DBE6SD5YBJP8WK2PXG96ZG u5)
(map-set mint-passes 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R u5)
(map-set mint-passes 'SP2QWQXA0RH5ZXKEAPR1QD26WFKG7PW4D4SEH7W4 u5)
(map-set mint-passes 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R u5)
(map-set mint-passes 'SPAC3NW7MN2KDAYBNVYK20MADGW3QF2M8K2FJ6ZG u5)
(map-set mint-passes 'SP2EAQVBM0B9ND5TZ96RSVXE5DHJB4YZ9VTYY9HPR u5)
(map-set mint-passes 'SP1DY3DQMVAA1F8JJAJBKPQ0HKQ1FZG67JG0YD5P3 u5)
(map-set mint-passes 'SP19B7JPCGVBP2TEZ32FYHVQPWD9JGVGVBWZJNFCX u5)
(map-set mint-passes 'SPP5KZXDTQKQ9E3QEDYCF4H7A1WSXSBCPZ9J4WRH u5)
(map-set mint-passes 'SP238X3JD22HJBMWR8E7CKTF4JCBQ73BG9YS1DBH8 u5)
(map-set mint-passes 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3 u5)
(map-set mint-passes 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R u5)
(map-set mint-passes 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX u5)
(map-set mint-passes 'SP17D2C9PE4WAV8J8GAY1DBWZ9G4KQY68KKMFC9CD u5)
(map-set mint-passes 'SP1YC3V7R7HWC5NQH1Q7SMC6BQMX9Z3AESZFWZ94M u5)
(map-set mint-passes 'SP39N5WF0FHVJFJYSEP5YSGKCN1PZQMKC62RQTYDX u5)
(map-set mint-passes 'SP1AQDVJF18XEFVXMWTRAW9TQ0N2DCN0178FKW03R u5)
(map-set mint-passes 'SPPX9WTKW73D3152J90080NCGYJJVFG8HTVMJFTX u5)
(map-set mint-passes 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW u5)
(map-set mint-passes 'SP2RPTD5Q3XZG1KTQYWT8FNEJ9Y7Z60659R6DAAP6 u5)
(map-set mint-passes 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC u5)
(map-set mint-passes 'SP1X9WS1VTYBV9MR0YR0X8934C9575K1X3Q6YSTH9 u5)

```
