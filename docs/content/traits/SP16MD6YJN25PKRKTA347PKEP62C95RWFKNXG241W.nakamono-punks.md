---
title: "Trait nakamono-punks"
draft: true
---
```
;; nakamono-punks
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token nakamono-punks uint)

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
(define-data-var mint-limit uint u75)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP16MD6YJN25PKRKTA347PKEP62C95RWFKNXG241W)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmWFDsBxNr3NAgpLZfKBUJkGgogqkxupsgz1pwWMjiqL9Q/json/")
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
      (unwrap! (nft-mint? nakamono-punks next-id tx-sender) next-id)
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
    (nft-burn? nakamono-punks token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? nakamono-punks token-id) false)))

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
  (ok (nft-get-owner? nakamono-punks token-id)))

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
  (match (nft-transfer? nakamono-punks id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? nakamono-punks id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? nakamono-punks id) (err ERR-NOT-FOUND)))
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
  

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u0) 'SP25970HDK6B2NXDE34KZVY7JBXNQTFW8BME9SCB))
      (map-set token-count 'SP25970HDK6B2NXDE34KZVY7JBXNQTFW8BME9SCB (+ (get-balance 'SP25970HDK6B2NXDE34KZVY7JBXNQTFW8BME9SCB) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u1) 'SP25970HDK6B2NXDE34KZVY7JBXNQTFW8BME9SCB))
      (map-set token-count 'SP25970HDK6B2NXDE34KZVY7JBXNQTFW8BME9SCB (+ (get-balance 'SP25970HDK6B2NXDE34KZVY7JBXNQTFW8BME9SCB) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u2) 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C))
      (map-set token-count 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C (+ (get-balance 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u3) 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C))
      (map-set token-count 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C (+ (get-balance 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u4) 'SP2M9X1PCZKBBFGTM85XH6YDT24A288MCBNY2DDB5))
      (map-set token-count 'SP2M9X1PCZKBBFGTM85XH6YDT24A288MCBNY2DDB5 (+ (get-balance 'SP2M9X1PCZKBBFGTM85XH6YDT24A288MCBNY2DDB5) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u5) 'SP2M9X1PCZKBBFGTM85XH6YDT24A288MCBNY2DDB5))
      (map-set token-count 'SP2M9X1PCZKBBFGTM85XH6YDT24A288MCBNY2DDB5 (+ (get-balance 'SP2M9X1PCZKBBFGTM85XH6YDT24A288MCBNY2DDB5) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u6) 'SPDSFW619BMSVYR9G1J1PHYRE2E5DTQTDF5W3NYN))
      (map-set token-count 'SPDSFW619BMSVYR9G1J1PHYRE2E5DTQTDF5W3NYN (+ (get-balance 'SPDSFW619BMSVYR9G1J1PHYRE2E5DTQTDF5W3NYN) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u7) 'SPDSFW619BMSVYR9G1J1PHYRE2E5DTQTDF5W3NYN))
      (map-set token-count 'SPDSFW619BMSVYR9G1J1PHYRE2E5DTQTDF5W3NYN (+ (get-balance 'SPDSFW619BMSVYR9G1J1PHYRE2E5DTQTDF5W3NYN) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u8) 'SP24HJ4AQP1FXAGT7RJNTRMBKYQ6MCPDM1E14VHGE))
      (map-set token-count 'SP24HJ4AQP1FXAGT7RJNTRMBKYQ6MCPDM1E14VHGE (+ (get-balance 'SP24HJ4AQP1FXAGT7RJNTRMBKYQ6MCPDM1E14VHGE) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u9) 'SP24HJ4AQP1FXAGT7RJNTRMBKYQ6MCPDM1E14VHGE))
      (map-set token-count 'SP24HJ4AQP1FXAGT7RJNTRMBKYQ6MCPDM1E14VHGE (+ (get-balance 'SP24HJ4AQP1FXAGT7RJNTRMBKYQ6MCPDM1E14VHGE) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u10) 'SP1RTYKK9GZ96KZ10VEGZ3SEPXK9CXXF2M4EF4HZV))
      (map-set token-count 'SP1RTYKK9GZ96KZ10VEGZ3SEPXK9CXXF2M4EF4HZV (+ (get-balance 'SP1RTYKK9GZ96KZ10VEGZ3SEPXK9CXXF2M4EF4HZV) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u11) 'SP1RTYKK9GZ96KZ10VEGZ3SEPXK9CXXF2M4EF4HZV))
      (map-set token-count 'SP1RTYKK9GZ96KZ10VEGZ3SEPXK9CXXF2M4EF4HZV (+ (get-balance 'SP1RTYKK9GZ96KZ10VEGZ3SEPXK9CXXF2M4EF4HZV) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u12) 'SPV5EJNF3MZQ2GX11636CB4KWR8GVHDZJTM4SQG7))
      (map-set token-count 'SPV5EJNF3MZQ2GX11636CB4KWR8GVHDZJTM4SQG7 (+ (get-balance 'SPV5EJNF3MZQ2GX11636CB4KWR8GVHDZJTM4SQG7) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u13) 'SPV5EJNF3MZQ2GX11636CB4KWR8GVHDZJTM4SQG7))
      (map-set token-count 'SPV5EJNF3MZQ2GX11636CB4KWR8GVHDZJTM4SQG7 (+ (get-balance 'SPV5EJNF3MZQ2GX11636CB4KWR8GVHDZJTM4SQG7) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u14) 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX))
      (map-set token-count 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX (+ (get-balance 'SP1SVK3YQV3S1NA2DCJG2NGADDT34H9SYRGYKD6GX) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u15) 'SP31NMQMST4MYCK8CK2NVCT82H31YX5EE6A21NNB3))
      (map-set token-count 'SP31NMQMST4MYCK8CK2NVCT82H31YX5EE6A21NNB3 (+ (get-balance 'SP31NMQMST4MYCK8CK2NVCT82H31YX5EE6A21NNB3) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u16) 'SP31NMQMST4MYCK8CK2NVCT82H31YX5EE6A21NNB3))
      (map-set token-count 'SP31NMQMST4MYCK8CK2NVCT82H31YX5EE6A21NNB3 (+ (get-balance 'SP31NMQMST4MYCK8CK2NVCT82H31YX5EE6A21NNB3) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u17) 'SP31NMQMST4MYCK8CK2NVCT82H31YX5EE6A21NNB3))
      (map-set token-count 'SP31NMQMST4MYCK8CK2NVCT82H31YX5EE6A21NNB3 (+ (get-balance 'SP31NMQMST4MYCK8CK2NVCT82H31YX5EE6A21NNB3) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u18) 'SP111CS6W8CP0QKHJ51J9WQJPGT3KFMBRABDHATDK))
      (map-set token-count 'SP111CS6W8CP0QKHJ51J9WQJPGT3KFMBRABDHATDK (+ (get-balance 'SP111CS6W8CP0QKHJ51J9WQJPGT3KFMBRABDHATDK) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u19) 'SP111CS6W8CP0QKHJ51J9WQJPGT3KFMBRABDHATDK))
      (map-set token-count 'SP111CS6W8CP0QKHJ51J9WQJPGT3KFMBRABDHATDK (+ (get-balance 'SP111CS6W8CP0QKHJ51J9WQJPGT3KFMBRABDHATDK) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u20) 'SP111CS6W8CP0QKHJ51J9WQJPGT3KFMBRABDHATDK))
      (map-set token-count 'SP111CS6W8CP0QKHJ51J9WQJPGT3KFMBRABDHATDK (+ (get-balance 'SP111CS6W8CP0QKHJ51J9WQJPGT3KFMBRABDHATDK) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u21) 'SPWJVDX5KJY6DZH7E3V7QXRZGW4YRZTKHBM89E7M))
      (map-set token-count 'SPWJVDX5KJY6DZH7E3V7QXRZGW4YRZTKHBM89E7M (+ (get-balance 'SPWJVDX5KJY6DZH7E3V7QXRZGW4YRZTKHBM89E7M) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u22) 'SPWJVDX5KJY6DZH7E3V7QXRZGW4YRZTKHBM89E7M))
      (map-set token-count 'SPWJVDX5KJY6DZH7E3V7QXRZGW4YRZTKHBM89E7M (+ (get-balance 'SPWJVDX5KJY6DZH7E3V7QXRZGW4YRZTKHBM89E7M) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u23) 'SPWJVDX5KJY6DZH7E3V7QXRZGW4YRZTKHBM89E7M))
      (map-set token-count 'SPWJVDX5KJY6DZH7E3V7QXRZGW4YRZTKHBM89E7M (+ (get-balance 'SPWJVDX5KJY6DZH7E3V7QXRZGW4YRZTKHBM89E7M) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u24) 'SP51JSXHAXC70FR7SGPQV4Z15QA42C02RPR2ZR5R))
      (map-set token-count 'SP51JSXHAXC70FR7SGPQV4Z15QA42C02RPR2ZR5R (+ (get-balance 'SP51JSXHAXC70FR7SGPQV4Z15QA42C02RPR2ZR5R) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u25) 'SP51JSXHAXC70FR7SGPQV4Z15QA42C02RPR2ZR5R))
      (map-set token-count 'SP51JSXHAXC70FR7SGPQV4Z15QA42C02RPR2ZR5R (+ (get-balance 'SP51JSXHAXC70FR7SGPQV4Z15QA42C02RPR2ZR5R) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u26) 'SP51JSXHAXC70FR7SGPQV4Z15QA42C02RPR2ZR5R))
      (map-set token-count 'SP51JSXHAXC70FR7SGPQV4Z15QA42C02RPR2ZR5R (+ (get-balance 'SP51JSXHAXC70FR7SGPQV4Z15QA42C02RPR2ZR5R) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u27) 'SP1BJRVV3G5JZ6Y1ARMYMVMFTW70N6MDWMP2GJW5B))
      (map-set token-count 'SP1BJRVV3G5JZ6Y1ARMYMVMFTW70N6MDWMP2GJW5B (+ (get-balance 'SP1BJRVV3G5JZ6Y1ARMYMVMFTW70N6MDWMP2GJW5B) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u28) 'SP1BJRVV3G5JZ6Y1ARMYMVMFTW70N6MDWMP2GJW5B))
      (map-set token-count 'SP1BJRVV3G5JZ6Y1ARMYMVMFTW70N6MDWMP2GJW5B (+ (get-balance 'SP1BJRVV3G5JZ6Y1ARMYMVMFTW70N6MDWMP2GJW5B) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u29) 'SP1BJRVV3G5JZ6Y1ARMYMVMFTW70N6MDWMP2GJW5B))
      (map-set token-count 'SP1BJRVV3G5JZ6Y1ARMYMVMFTW70N6MDWMP2GJW5B (+ (get-balance 'SP1BJRVV3G5JZ6Y1ARMYMVMFTW70N6MDWMP2GJW5B) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u30) 'SP3ZY598C98XG2YDN0P9FMACD9C2NB3W7XY7C466Q))
      (map-set token-count 'SP3ZY598C98XG2YDN0P9FMACD9C2NB3W7XY7C466Q (+ (get-balance 'SP3ZY598C98XG2YDN0P9FMACD9C2NB3W7XY7C466Q) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u31) 'SP3ZY598C98XG2YDN0P9FMACD9C2NB3W7XY7C466Q))
      (map-set token-count 'SP3ZY598C98XG2YDN0P9FMACD9C2NB3W7XY7C466Q (+ (get-balance 'SP3ZY598C98XG2YDN0P9FMACD9C2NB3W7XY7C466Q) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u32) 'SP3ZY598C98XG2YDN0P9FMACD9C2NB3W7XY7C466Q))
      (map-set token-count 'SP3ZY598C98XG2YDN0P9FMACD9C2NB3W7XY7C466Q (+ (get-balance 'SP3ZY598C98XG2YDN0P9FMACD9C2NB3W7XY7C466Q) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u33) 'SP1TPCN12XJCFPWQ53BC6B9NTSFWY93Z0ADFZF168))
      (map-set token-count 'SP1TPCN12XJCFPWQ53BC6B9NTSFWY93Z0ADFZF168 (+ (get-balance 'SP1TPCN12XJCFPWQ53BC6B9NTSFWY93Z0ADFZF168) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u34) 'SP1TPCN12XJCFPWQ53BC6B9NTSFWY93Z0ADFZF168))
      (map-set token-count 'SP1TPCN12XJCFPWQ53BC6B9NTSFWY93Z0ADFZF168 (+ (get-balance 'SP1TPCN12XJCFPWQ53BC6B9NTSFWY93Z0ADFZF168) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u35) 'SP1TPCN12XJCFPWQ53BC6B9NTSFWY93Z0ADFZF168))
      (map-set token-count 'SP1TPCN12XJCFPWQ53BC6B9NTSFWY93Z0ADFZF168 (+ (get-balance 'SP1TPCN12XJCFPWQ53BC6B9NTSFWY93Z0ADFZF168) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u36) 'SP19QGC4HA384ZRYEWXEPJ6EAQHPQW38M63EAJE3F))
      (map-set token-count 'SP19QGC4HA384ZRYEWXEPJ6EAQHPQW38M63EAJE3F (+ (get-balance 'SP19QGC4HA384ZRYEWXEPJ6EAQHPQW38M63EAJE3F) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u37) 'SP19QGC4HA384ZRYEWXEPJ6EAQHPQW38M63EAJE3F))
      (map-set token-count 'SP19QGC4HA384ZRYEWXEPJ6EAQHPQW38M63EAJE3F (+ (get-balance 'SP19QGC4HA384ZRYEWXEPJ6EAQHPQW38M63EAJE3F) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u38) 'SP19QGC4HA384ZRYEWXEPJ6EAQHPQW38M63EAJE3F))
      (map-set token-count 'SP19QGC4HA384ZRYEWXEPJ6EAQHPQW38M63EAJE3F (+ (get-balance 'SP19QGC4HA384ZRYEWXEPJ6EAQHPQW38M63EAJE3F) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u39) 'SP24XM9AEHWZM7YTTESPX5Q7J3YE495ZRJJQ4MQ6V))
      (map-set token-count 'SP24XM9AEHWZM7YTTESPX5Q7J3YE495ZRJJQ4MQ6V (+ (get-balance 'SP24XM9AEHWZM7YTTESPX5Q7J3YE495ZRJJQ4MQ6V) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u40) 'SP24XM9AEHWZM7YTTESPX5Q7J3YE495ZRJJQ4MQ6V))
      (map-set token-count 'SP24XM9AEHWZM7YTTESPX5Q7J3YE495ZRJJQ4MQ6V (+ (get-balance 'SP24XM9AEHWZM7YTTESPX5Q7J3YE495ZRJJQ4MQ6V) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u41) 'SP24XM9AEHWZM7YTTESPX5Q7J3YE495ZRJJQ4MQ6V))
      (map-set token-count 'SP24XM9AEHWZM7YTTESPX5Q7J3YE495ZRJJQ4MQ6V (+ (get-balance 'SP24XM9AEHWZM7YTTESPX5Q7J3YE495ZRJJQ4MQ6V) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u42) 'SPDAHYCYSZBKN5VT35WJWZV4XKS4Y0J3HSXC8HCY))
      (map-set token-count 'SPDAHYCYSZBKN5VT35WJWZV4XKS4Y0J3HSXC8HCY (+ (get-balance 'SPDAHYCYSZBKN5VT35WJWZV4XKS4Y0J3HSXC8HCY) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u43) 'SPDAHYCYSZBKN5VT35WJWZV4XKS4Y0J3HSXC8HCY))
      (map-set token-count 'SPDAHYCYSZBKN5VT35WJWZV4XKS4Y0J3HSXC8HCY (+ (get-balance 'SPDAHYCYSZBKN5VT35WJWZV4XKS4Y0J3HSXC8HCY) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u44) 'SPDAHYCYSZBKN5VT35WJWZV4XKS4Y0J3HSXC8HCY))
      (map-set token-count 'SPDAHYCYSZBKN5VT35WJWZV4XKS4Y0J3HSXC8HCY (+ (get-balance 'SPDAHYCYSZBKN5VT35WJWZV4XKS4Y0J3HSXC8HCY) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u45) 'SP16S85SPEWCY3QVTC2J8060361HF3F0V02NAC9JM))
      (map-set token-count 'SP16S85SPEWCY3QVTC2J8060361HF3F0V02NAC9JM (+ (get-balance 'SP16S85SPEWCY3QVTC2J8060361HF3F0V02NAC9JM) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u46) 'SP16S85SPEWCY3QVTC2J8060361HF3F0V02NAC9JM))
      (map-set token-count 'SP16S85SPEWCY3QVTC2J8060361HF3F0V02NAC9JM (+ (get-balance 'SP16S85SPEWCY3QVTC2J8060361HF3F0V02NAC9JM) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u47) 'SP16S85SPEWCY3QVTC2J8060361HF3F0V02NAC9JM))
      (map-set token-count 'SP16S85SPEWCY3QVTC2J8060361HF3F0V02NAC9JM (+ (get-balance 'SP16S85SPEWCY3QVTC2J8060361HF3F0V02NAC9JM) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u48) 'SP256DVX8ZMGSTRCW8DF1FBJ6Q6W874XVGBBNBD9Z))
      (map-set token-count 'SP256DVX8ZMGSTRCW8DF1FBJ6Q6W874XVGBBNBD9Z (+ (get-balance 'SP256DVX8ZMGSTRCW8DF1FBJ6Q6W874XVGBBNBD9Z) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u49) 'SP256DVX8ZMGSTRCW8DF1FBJ6Q6W874XVGBBNBD9Z))
      (map-set token-count 'SP256DVX8ZMGSTRCW8DF1FBJ6Q6W874XVGBBNBD9Z (+ (get-balance 'SP256DVX8ZMGSTRCW8DF1FBJ6Q6W874XVGBBNBD9Z) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u50) 'SP256DVX8ZMGSTRCW8DF1FBJ6Q6W874XVGBBNBD9Z))
      (map-set token-count 'SP256DVX8ZMGSTRCW8DF1FBJ6Q6W874XVGBBNBD9Z (+ (get-balance 'SP256DVX8ZMGSTRCW8DF1FBJ6Q6W874XVGBBNBD9Z) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u51) 'SP2AA9G9C18NSAWM3RDG826953FVX8VZ3TTD7SCFK))
      (map-set token-count 'SP2AA9G9C18NSAWM3RDG826953FVX8VZ3TTD7SCFK (+ (get-balance 'SP2AA9G9C18NSAWM3RDG826953FVX8VZ3TTD7SCFK) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u52) 'SP2AA9G9C18NSAWM3RDG826953FVX8VZ3TTD7SCFK))
      (map-set token-count 'SP2AA9G9C18NSAWM3RDG826953FVX8VZ3TTD7SCFK (+ (get-balance 'SP2AA9G9C18NSAWM3RDG826953FVX8VZ3TTD7SCFK) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u53) 'SP2AA9G9C18NSAWM3RDG826953FVX8VZ3TTD7SCFK))
      (map-set token-count 'SP2AA9G9C18NSAWM3RDG826953FVX8VZ3TTD7SCFK (+ (get-balance 'SP2AA9G9C18NSAWM3RDG826953FVX8VZ3TTD7SCFK) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u54) 'SP11CH5QE7HFYYZWQ0580QYJKNSKQGV3ESCQBX6KR))
      (map-set token-count 'SP11CH5QE7HFYYZWQ0580QYJKNSKQGV3ESCQBX6KR (+ (get-balance 'SP11CH5QE7HFYYZWQ0580QYJKNSKQGV3ESCQBX6KR) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u55) 'SP11CH5QE7HFYYZWQ0580QYJKNSKQGV3ESCQBX6KR))
      (map-set token-count 'SP11CH5QE7HFYYZWQ0580QYJKNSKQGV3ESCQBX6KR (+ (get-balance 'SP11CH5QE7HFYYZWQ0580QYJKNSKQGV3ESCQBX6KR) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u56) 'SP11CH5QE7HFYYZWQ0580QYJKNSKQGV3ESCQBX6KR))
      (map-set token-count 'SP11CH5QE7HFYYZWQ0580QYJKNSKQGV3ESCQBX6KR (+ (get-balance 'SP11CH5QE7HFYYZWQ0580QYJKNSKQGV3ESCQBX6KR) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u57) 'SP2ZCGA5AKACD9EHXAHY2PVPPSJ7S39W0DMF3GW2Z))
      (map-set token-count 'SP2ZCGA5AKACD9EHXAHY2PVPPSJ7S39W0DMF3GW2Z (+ (get-balance 'SP2ZCGA5AKACD9EHXAHY2PVPPSJ7S39W0DMF3GW2Z) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u58) 'SP2ZCGA5AKACD9EHXAHY2PVPPSJ7S39W0DMF3GW2Z))
      (map-set token-count 'SP2ZCGA5AKACD9EHXAHY2PVPPSJ7S39W0DMF3GW2Z (+ (get-balance 'SP2ZCGA5AKACD9EHXAHY2PVPPSJ7S39W0DMF3GW2Z) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u59) 'SP2ZCGA5AKACD9EHXAHY2PVPPSJ7S39W0DMF3GW2Z))
      (map-set token-count 'SP2ZCGA5AKACD9EHXAHY2PVPPSJ7S39W0DMF3GW2Z (+ (get-balance 'SP2ZCGA5AKACD9EHXAHY2PVPPSJ7S39W0DMF3GW2Z) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u60) 'SP2TM9375TFB6BJYQACPE5NW8BEN0HY7KST7M1Z3S))
      (map-set token-count 'SP2TM9375TFB6BJYQACPE5NW8BEN0HY7KST7M1Z3S (+ (get-balance 'SP2TM9375TFB6BJYQACPE5NW8BEN0HY7KST7M1Z3S) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u61) 'SP2TM9375TFB6BJYQACPE5NW8BEN0HY7KST7M1Z3S))
      (map-set token-count 'SP2TM9375TFB6BJYQACPE5NW8BEN0HY7KST7M1Z3S (+ (get-balance 'SP2TM9375TFB6BJYQACPE5NW8BEN0HY7KST7M1Z3S) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u62) 'SPMSSC7PP70MVV76KWGXMDYXH6VFET8G8MPX2PSZ))
      (map-set token-count 'SPMSSC7PP70MVV76KWGXMDYXH6VFET8G8MPX2PSZ (+ (get-balance 'SPMSSC7PP70MVV76KWGXMDYXH6VFET8G8MPX2PSZ) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u63) 'SPMSSC7PP70MVV76KWGXMDYXH6VFET8G8MPX2PSZ))
      (map-set token-count 'SPMSSC7PP70MVV76KWGXMDYXH6VFET8G8MPX2PSZ (+ (get-balance 'SPMSSC7PP70MVV76KWGXMDYXH6VFET8G8MPX2PSZ) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u64) 'SPMSSC7PP70MVV76KWGXMDYXH6VFET8G8MPX2PSZ))
      (map-set token-count 'SPMSSC7PP70MVV76KWGXMDYXH6VFET8G8MPX2PSZ (+ (get-balance 'SPMSSC7PP70MVV76KWGXMDYXH6VFET8G8MPX2PSZ) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u65) 'SP3STCXTRGSTPKZVGSRMMD8N64ANE82YQNM2F3J0Q))
      (map-set token-count 'SP3STCXTRGSTPKZVGSRMMD8N64ANE82YQNM2F3J0Q (+ (get-balance 'SP3STCXTRGSTPKZVGSRMMD8N64ANE82YQNM2F3J0Q) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u66) 'SP3STCXTRGSTPKZVGSRMMD8N64ANE82YQNM2F3J0Q))
      (map-set token-count 'SP3STCXTRGSTPKZVGSRMMD8N64ANE82YQNM2F3J0Q (+ (get-balance 'SP3STCXTRGSTPKZVGSRMMD8N64ANE82YQNM2F3J0Q) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u67) 'SP3STCXTRGSTPKZVGSRMMD8N64ANE82YQNM2F3J0Q))
      (map-set token-count 'SP3STCXTRGSTPKZVGSRMMD8N64ANE82YQNM2F3J0Q (+ (get-balance 'SP3STCXTRGSTPKZVGSRMMD8N64ANE82YQNM2F3J0Q) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u68) 'SP2TM9375TFB6BJYQACPE5NW8BEN0HY7KST7M1Z3S))
      (map-set token-count 'SP2TM9375TFB6BJYQACPE5NW8BEN0HY7KST7M1Z3S (+ (get-balance 'SP2TM9375TFB6BJYQACPE5NW8BEN0HY7KST7M1Z3S) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u69) 'SPSPPDPTS6G3HBJBH8JSDP3HMX4DG61WKRVPP9GC))
      (map-set token-count 'SPSPPDPTS6G3HBJBH8JSDP3HMX4DG61WKRVPP9GC (+ (get-balance 'SPSPPDPTS6G3HBJBH8JSDP3HMX4DG61WKRVPP9GC) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u70) 'SPSPPDPTS6G3HBJBH8JSDP3HMX4DG61WKRVPP9GC))
      (map-set token-count 'SPSPPDPTS6G3HBJBH8JSDP3HMX4DG61WKRVPP9GC (+ (get-balance 'SPSPPDPTS6G3HBJBH8JSDP3HMX4DG61WKRVPP9GC) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u71) 'SPSPPDPTS6G3HBJBH8JSDP3HMX4DG61WKRVPP9GC))
      (map-set token-count 'SPSPPDPTS6G3HBJBH8JSDP3HMX4DG61WKRVPP9GC (+ (get-balance 'SPSPPDPTS6G3HBJBH8JSDP3HMX4DG61WKRVPP9GC) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u72) 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C))
      (map-set token-count 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C (+ (get-balance 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u73) 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C))
      (map-set token-count 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C (+ (get-balance 'SP1WAN2CN7J3YC3B21K10Z33JDDP89XKAAHE0SD7C) u1))
      (try! (nft-mint? nakamono-punks (+ last-nft-id u74) 'SP2M9X1PCZKBBFGTM85XH6YDT24A288MCBNY2DDB5))
      (map-set token-count 'SP2M9X1PCZKBBFGTM85XH6YDT24A288MCBNY2DDB5 (+ (get-balance 'SP2M9X1PCZKBBFGTM85XH6YDT24A288MCBNY2DDB5) u1))

      (var-set last-id (+ last-nft-id u75))
      (var-set airdrop-called true)
      (ok true))))
```
