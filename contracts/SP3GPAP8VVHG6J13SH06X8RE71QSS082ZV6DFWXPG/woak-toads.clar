;; woak-toads
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token woak-toads uint)

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
(define-data-var total-price uint u250000000000)
(define-data-var artist-address principal 'SP3GPAP8VVHG6J13SH06X8RE71QSS082ZV6DFWXPG)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmbePeMztexiZSWiT8JCcqrQnHPXgJTCp4Fz77Xk1MtCLU/json/")
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

(define-public (claim-two) (mint (list true true)))

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
      (unwrap! (nft-mint? woak-toads next-id tx-sender) next-id)
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
    (nft-burn? woak-toads token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? woak-toads token-id) false)))

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
  (ok (nft-get-owner? woak-toads token-id)))

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
  (match (nft-transfer? woak-toads id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? woak-toads id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? woak-toads id) (err ERR-NOT-FOUND)))
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
(define-data-var total-price-xbtc uint u583271226)

(define-read-only (get-price-xbtc)
  (ok (var-get total-price-xbtc)))

(define-public (set-price-xbtc (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-xbtc price))))

(define-public (claim-xbtc)
  (mint-xbtc (list true)))

(define-public (claim-two-xbtc) (mint-xbtc (list true true)))

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
(define-data-var total-price-mega uint u100)

(define-read-only (get-price-mega)
  (ok (var-get total-price-mega)))

(define-public (set-price-mega (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-mega price))))

(define-public (claim-mega)
  (mint-mega (list true)))

(define-public (claim-two-mega) (mint-mega (list true true)))

(define-private (mint-mega (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-mega orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-mega orders)
      )
    )))

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

(map-set mint-passes 'SPZ5DJGRVZHXEEEYYGWEX84KQB8P69GC715ZRNW1 u3)
(map-set mint-passes 'SP26ZXHQ28WTZG3GKR5AZN2PHTR7S9G1YD555BE4P u3)
(map-set mint-passes 'SP3QKAQS3J0YS3ZAZPSZM5ZSZZRYRYV72N6A9ZPZT u3)
(map-set mint-passes 'SP3NDGET2RK5VKRTM47EJ8444MB3PKKJTJR3RPS0X u3)
(map-set mint-passes 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA u3)
(map-set mint-passes 'SPKR1JG6RKDCA6DHPFC8VV5KSDKMBC28W3DZ89PQ u3)
(map-set mint-passes 'SP68ZBMK5ABVV30DA5X9HVFXC517ZD178R46WHNF u3)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u3)
(map-set mint-passes 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D u3)
(map-set mint-passes 'SP2G51DZCK7DQNHKSD532MGPX3Q8ZEJN1812SS9KR u3)
(map-set mint-passes 'SP1JX2RYKPR0G7H81SQHZQ187H50RR6QSM8GX839X u3)
(map-set mint-passes 'SPQ3YE9A28GKJ6DQPQXVTMNQG2B3KRFA8AFC3V5J u3)
(map-set mint-passes 'SPPT6DNNC9KQW9MXNYTX4FH3CJXWQP90E5B6K64G u3)
(map-set mint-passes 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G u3)
(map-set mint-passes 'SP2F9BGMH0TQ95C38GABBN4P8X61S2JH5ZY5F3REY u3)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? woak-toads (+ last-nft-id u0) 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB))
      (map-set token-count 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB (+ (get-balance 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u1) 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB))
      (map-set token-count 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB (+ (get-balance 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u2) 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB))
      (map-set token-count 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB (+ (get-balance 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u3) 'SP35MEYYBHSFCFXY296YGP7NAT6Y4XBJW2VETR8AV))
      (map-set token-count 'SP35MEYYBHSFCFXY296YGP7NAT6Y4XBJW2VETR8AV (+ (get-balance 'SP35MEYYBHSFCFXY296YGP7NAT6Y4XBJW2VETR8AV) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u4) 'SP1CCC68DRYZZKMPAZPWKE3VP2R7YSVN9DZJG86Y8))
      (map-set token-count 'SP1CCC68DRYZZKMPAZPWKE3VP2R7YSVN9DZJG86Y8 (+ (get-balance 'SP1CCC68DRYZZKMPAZPWKE3VP2R7YSVN9DZJG86Y8) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u5) 'SP1CCC68DRYZZKMPAZPWKE3VP2R7YSVN9DZJG86Y8))
      (map-set token-count 'SP1CCC68DRYZZKMPAZPWKE3VP2R7YSVN9DZJG86Y8 (+ (get-balance 'SP1CCC68DRYZZKMPAZPWKE3VP2R7YSVN9DZJG86Y8) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u6) 'SP1P72Z3704VMT3DMHPP2CB8TGQWGDBHD3RPR9GZS))
      (map-set token-count 'SP1P72Z3704VMT3DMHPP2CB8TGQWGDBHD3RPR9GZS (+ (get-balance 'SP1P72Z3704VMT3DMHPP2CB8TGQWGDBHD3RPR9GZS) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u7) 'SPV4GYHQ2B7R831M3F7ZNN22RDDHEKQ52ZN50CDE))
      (map-set token-count 'SPV4GYHQ2B7R831M3F7ZNN22RDDHEKQ52ZN50CDE (+ (get-balance 'SPV4GYHQ2B7R831M3F7ZNN22RDDHEKQ52ZN50CDE) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u8) 'SPRKDCBZ9FA886BSK7SF70TWZK0RPEY02KMFAXCQ))
      (map-set token-count 'SPRKDCBZ9FA886BSK7SF70TWZK0RPEY02KMFAXCQ (+ (get-balance 'SPRKDCBZ9FA886BSK7SF70TWZK0RPEY02KMFAXCQ) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u9) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u10) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u11) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u12) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u13) 'SP9M7RXPPQ1MZSDQR2NXD4SB28VFSXQX7XZYPXT8))
      (map-set token-count 'SP9M7RXPPQ1MZSDQR2NXD4SB28VFSXQX7XZYPXT8 (+ (get-balance 'SP9M7RXPPQ1MZSDQR2NXD4SB28VFSXQX7XZYPXT8) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u14) 'SP1QA548TFNZ2BDE1A7TSP49PKCRERZWEEG74BKAJ))
      (map-set token-count 'SP1QA548TFNZ2BDE1A7TSP49PKCRERZWEEG74BKAJ (+ (get-balance 'SP1QA548TFNZ2BDE1A7TSP49PKCRERZWEEG74BKAJ) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u15) 'SP17YP1HGWK7DP5Q69GRG14W34E078S4D78YM1FA5))
      (map-set token-count 'SP17YP1HGWK7DP5Q69GRG14W34E078S4D78YM1FA5 (+ (get-balance 'SP17YP1HGWK7DP5Q69GRG14W34E078S4D78YM1FA5) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u16) 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP))
      (map-set token-count 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP (+ (get-balance 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u17) 'SP35DMWWRRY69NBYA8FJN8FY3T70GFP08EP5NN2ZQ))
      (map-set token-count 'SP35DMWWRRY69NBYA8FJN8FY3T70GFP08EP5NN2ZQ (+ (get-balance 'SP35DMWWRRY69NBYA8FJN8FY3T70GFP08EP5NN2ZQ) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u18) 'SP2W3ZFMA5CPFA21FW15ZYD1J0QMR96RWZQEJ2Z00))
      (map-set token-count 'SP2W3ZFMA5CPFA21FW15ZYD1J0QMR96RWZQEJ2Z00 (+ (get-balance 'SP2W3ZFMA5CPFA21FW15ZYD1J0QMR96RWZQEJ2Z00) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u19) 'SPBFEJKY3D335G9R4QX5T7W9K6N4EVF8QC8NN9BG))
      (map-set token-count 'SPBFEJKY3D335G9R4QX5T7W9K6N4EVF8QC8NN9BG (+ (get-balance 'SPBFEJKY3D335G9R4QX5T7W9K6N4EVF8QC8NN9BG) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u20) 'SP2M4TQW8B0KW0YSF1N6GGW36FD1G7G439NTF5CQ))
      (map-set token-count 'SP2M4TQW8B0KW0YSF1N6GGW36FD1G7G439NTF5CQ (+ (get-balance 'SP2M4TQW8B0KW0YSF1N6GGW36FD1G7G439NTF5CQ) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u21) 'SPHP588Y6ES886214AA3S7WPCN6QQR2S3Z8348TC))
      (map-set token-count 'SPHP588Y6ES886214AA3S7WPCN6QQR2S3Z8348TC (+ (get-balance 'SPHP588Y6ES886214AA3S7WPCN6QQR2S3Z8348TC) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u22) 'SPHP588Y6ES886214AA3S7WPCN6QQR2S3Z8348TC))
      (map-set token-count 'SPHP588Y6ES886214AA3S7WPCN6QQR2S3Z8348TC (+ (get-balance 'SPHP588Y6ES886214AA3S7WPCN6QQR2S3Z8348TC) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u23) 'SP146JTSKFPYAXPBHJTWF56D7G3ZHBDJTKVJQXA3D))
      (map-set token-count 'SP146JTSKFPYAXPBHJTWF56D7G3ZHBDJTKVJQXA3D (+ (get-balance 'SP146JTSKFPYAXPBHJTWF56D7G3ZHBDJTKVJQXA3D) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u24) 'SPBW8GGZTH6C9W7H9QAMAFCA44TJS3DA629VZPWP))
      (map-set token-count 'SPBW8GGZTH6C9W7H9QAMAFCA44TJS3DA629VZPWP (+ (get-balance 'SPBW8GGZTH6C9W7H9QAMAFCA44TJS3DA629VZPWP) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u25) 'SP1PG8YC8DEPW1NK8PQRT3TRWGHVFDH1RBHANRSCY))
      (map-set token-count 'SP1PG8YC8DEPW1NK8PQRT3TRWGHVFDH1RBHANRSCY (+ (get-balance 'SP1PG8YC8DEPW1NK8PQRT3TRWGHVFDH1RBHANRSCY) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u26) 'SP2C8P3MM137K1A48D1SRENG67KHEVPZV4K36G3JY))
      (map-set token-count 'SP2C8P3MM137K1A48D1SRENG67KHEVPZV4K36G3JY (+ (get-balance 'SP2C8P3MM137K1A48D1SRENG67KHEVPZV4K36G3JY) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u27) 'SP2SB5G2XKX7H6H5PH6FKWH3FY80821B4JH2S03K4))
      (map-set token-count 'SP2SB5G2XKX7H6H5PH6FKWH3FY80821B4JH2S03K4 (+ (get-balance 'SP2SB5G2XKX7H6H5PH6FKWH3FY80821B4JH2S03K4) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u28) 'SP2SB5G2XKX7H6H5PH6FKWH3FY80821B4JH2S03K4))
      (map-set token-count 'SP2SB5G2XKX7H6H5PH6FKWH3FY80821B4JH2S03K4 (+ (get-balance 'SP2SB5G2XKX7H6H5PH6FKWH3FY80821B4JH2S03K4) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u29) 'SP2SB5G2XKX7H6H5PH6FKWH3FY80821B4JH2S03K4))
      (map-set token-count 'SP2SB5G2XKX7H6H5PH6FKWH3FY80821B4JH2S03K4 (+ (get-balance 'SP2SB5G2XKX7H6H5PH6FKWH3FY80821B4JH2S03K4) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u30) 'SP2HS73HXN7K5X4QJ5GK6S4MGDSPH24QWZ4NVRB3G))
      (map-set token-count 'SP2HS73HXN7K5X4QJ5GK6S4MGDSPH24QWZ4NVRB3G (+ (get-balance 'SP2HS73HXN7K5X4QJ5GK6S4MGDSPH24QWZ4NVRB3G) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u31) 'SPY11X2CFKJ9JG213HJP1Z4JFT2H88079MQFW2MS))
      (map-set token-count 'SPY11X2CFKJ9JG213HJP1Z4JFT2H88079MQFW2MS (+ (get-balance 'SPY11X2CFKJ9JG213HJP1Z4JFT2H88079MQFW2MS) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u32) 'SPF8K98V7GW58RD7D4CEC2F1W6C1Q6TTPPAJQRAB))
      (map-set token-count 'SPF8K98V7GW58RD7D4CEC2F1W6C1Q6TTPPAJQRAB (+ (get-balance 'SPF8K98V7GW58RD7D4CEC2F1W6C1Q6TTPPAJQRAB) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u33) 'SP3J0Z8YSJD20TGEBE6M992CWFDG18VB0PR599VY9))
      (map-set token-count 'SP3J0Z8YSJD20TGEBE6M992CWFDG18VB0PR599VY9 (+ (get-balance 'SP3J0Z8YSJD20TGEBE6M992CWFDG18VB0PR599VY9) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u34) 'SPNC4G6P4V8VSYVTW3CGW8ZQYPZ4M51S35AXX5AC))
      (map-set token-count 'SPNC4G6P4V8VSYVTW3CGW8ZQYPZ4M51S35AXX5AC (+ (get-balance 'SPNC4G6P4V8VSYVTW3CGW8ZQYPZ4M51S35AXX5AC) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u35) 'SP3VGB2FS9FGN6M6SHWYWTCV3F0A08MQ6Q78F7E9))
      (map-set token-count 'SP3VGB2FS9FGN6M6SHWYWTCV3F0A08MQ6Q78F7E9 (+ (get-balance 'SP3VGB2FS9FGN6M6SHWYWTCV3F0A08MQ6Q78F7E9) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u36) 'SP4S033WJCAEKQ474AKEE4GGPWFYEMTGVR7WT4ZS))
      (map-set token-count 'SP4S033WJCAEKQ474AKEE4GGPWFYEMTGVR7WT4ZS (+ (get-balance 'SP4S033WJCAEKQ474AKEE4GGPWFYEMTGVR7WT4ZS) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u37) 'SPX0FKCZ2QNS7AWYT95HQ89S1YGEEY89AYG8ASZ4))
      (map-set token-count 'SPX0FKCZ2QNS7AWYT95HQ89S1YGEEY89AYG8ASZ4 (+ (get-balance 'SPX0FKCZ2QNS7AWYT95HQ89S1YGEEY89AYG8ASZ4) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u38) 'SP1E4798MP7RNHPVSBM954MSS5EJNM1AC3R53DC31))
      (map-set token-count 'SP1E4798MP7RNHPVSBM954MSS5EJNM1AC3R53DC31 (+ (get-balance 'SP1E4798MP7RNHPVSBM954MSS5EJNM1AC3R53DC31) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u39) 'SP2891F1DM9QJ14F711C62NQS3RQG4VFV6ZTEEN60))
      (map-set token-count 'SP2891F1DM9QJ14F711C62NQS3RQG4VFV6ZTEEN60 (+ (get-balance 'SP2891F1DM9QJ14F711C62NQS3RQG4VFV6ZTEEN60) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u40) 'SP20ZAVGZ8QT6SEGWD3XD94NXZ3TA6T2KSKQYVJPA))
      (map-set token-count 'SP20ZAVGZ8QT6SEGWD3XD94NXZ3TA6T2KSKQYVJPA (+ (get-balance 'SP20ZAVGZ8QT6SEGWD3XD94NXZ3TA6T2KSKQYVJPA) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u41) 'SP3MYM8YGM8MVT10WKQ3A19E3MAG2H6PHCW8PMZWT))
      (map-set token-count 'SP3MYM8YGM8MVT10WKQ3A19E3MAG2H6PHCW8PMZWT (+ (get-balance 'SP3MYM8YGM8MVT10WKQ3A19E3MAG2H6PHCW8PMZWT) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u42) 'SP1XA1Z1ZYRMWZAYR5TA756CSDRPP7WN415MZZYHM))
      (map-set token-count 'SP1XA1Z1ZYRMWZAYR5TA756CSDRPP7WN415MZZYHM (+ (get-balance 'SP1XA1Z1ZYRMWZAYR5TA756CSDRPP7WN415MZZYHM) u1))
      (try! (nft-mint? woak-toads (+ last-nft-id u43) 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69))
      (map-set token-count 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69 (+ (get-balance 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69) u1))

      (var-set last-id (+ last-nft-id u44))
      (var-set airdrop-called true)
      (ok true))))