;; Welsh Punk
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token welsh-punk uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant ERR-NO-MORE-NFTS u100)
(define-constant ERR-PUBLIC-SALE-DISABLED u102)
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
(define-data-var mint-limit uint u5000)
(define-data-var last-id uint u1)
(define-data-var total-spoints-price uint u1050000000)
(define-data-var total-welsh-price uint u200000000)
(define-data-var artist-address principal 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH)
(define-data-var burn-address principal 'SP000000000000000000002Q6VF78)
(define-data-var ipfs-root (string-ascii 100) "ipfs://ipfs/bafybeid54petpvfoejqtjsd5egmy4cvh5kyfqybaxearqlklylmgcl2xee/")
(define-data-var mint-paused bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var mint-cap uint u0)
(define-data-var airdrop-called bool false)
(define-map mints-per-user principal uint)

(define-public (welsh-claim) (welsh-mint (list true)))

(define-public (welsh-claim-two) (welsh-mint (list true true)))

(define-public (spoints-claim (spc-id uint)) (spoint-mint spc-id (list true)))

(define-public (spoints-claim-two (spc-id uint)) (spoint-mint spc-id (list true true)))

(define-public (spoints-claim-three (spc-id uint)) (spoint-mint spc-id (list true true true)))

(define-public (spoints-claim-four (spc-id uint)) (spoint-mint spc-id (list true true true true)))

(define-private (spoint-mint (spc-id uint) (orders (list 4 bool)))
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-spoints-price) (- id-reached last-nft-id)))
      (current-balance (get-balance tx-sender))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ (len orders) user-mints))) (err ERR-NO-MORE-MINTS))
    (map-set mints-per-user tx-sender (+ (len orders) user-mints))
    (var-set last-id id-reached)
    (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
    (unwrap-panic (contract-call? 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV.spoints spend spc-id price))
    (ok id-reached)))

(define-private (welsh-mint (orders (list 2 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (burn-addr (var-get burn-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-welsh-price) (- id-reached last-nft-id)))
      (current-balance (get-balance tx-sender))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender (var-get artist-address)) (>= (var-get mint-cap) (+ (len orders) user-mints))) (err ERR-NO-MORE-MINTS))
    (map-set mints-per-user tx-sender (+ (len orders) user-mints))
    (var-set last-id id-reached)
    (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
    (unwrap-panic (contract-call? 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token transfer price tx-sender burn-addr none))
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? welsh-punk next-id tx-sender) next-id)
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
    (ok (var-set total-welsh-price price))))

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
    (nft-burn? welsh-punk token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? welsh-punk token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 100)))
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

(define-public (reveal-artwork (new-base-uri (string-ascii 100)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

;; Non-custodial SIP-009 transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; Read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? welsh-punk token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-welsh-price)))

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
  (match (nft-transfer? welsh-punk id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? welsh-punk id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? welsh-punk id) (err ERR-NOT-FOUND)))
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
    
(define-data-var royalty-percent uint u250)

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
      (sale (not (var-get sale-enabled)))
    )
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set sale-enabled sale)
    (print { sale: sale })
    (ok true)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))  

;;Admin Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? welsh-punk (+ last-nft-id u0) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u1) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u2) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u3) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u4) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u5) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u6) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u7) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u8) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u9) 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH))
      (map-set token-count 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH (+ (get-balance 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u10) 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK))
      (map-set token-count 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK (+ (get-balance 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u11) 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK))
      (map-set token-count 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK (+ (get-balance 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u12) 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK))
      (map-set token-count 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK (+ (get-balance 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u13) 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK))
      (map-set token-count 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK (+ (get-balance 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u14) 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK))
      (map-set token-count 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK (+ (get-balance 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u15) 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV))
      (map-set token-count 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV (+ (get-balance 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u16) 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV))
      (map-set token-count 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV (+ (get-balance 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u17) 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV))
      (map-set token-count 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV (+ (get-balance 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u18) 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV))
      (map-set token-count 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV (+ (get-balance 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u19) 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV))
      (map-set token-count 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV (+ (get-balance 'SP217FZ8AZYTGPKMERWZ6FYRAK4ZZ6YHMJ7XQXGEV) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u20) 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99))
      (map-set token-count 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99 (+ (get-balance 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u21) 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99))
      (map-set token-count 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99 (+ (get-balance 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u22) 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99))
      (map-set token-count 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99 (+ (get-balance 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u23) 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99))
      (map-set token-count 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99 (+ (get-balance 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u24) 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99))
      (map-set token-count 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99 (+ (get-balance 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u25) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u26) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u27) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u28) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u29) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u30) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u31) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u32) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u33) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u34) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u35) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u36) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u37) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u38) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u39) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u40) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u41) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u42) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u43) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u44) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u45) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u46) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u47) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u48) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (try! (nft-mint? welsh-punk (+ last-nft-id u49) 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS))
      (map-set token-count 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS (+ (get-balance 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS) u1))
      (var-set last-id (+ last-nft-id u50))
      (var-set airdrop-called true)
      (ok true))))