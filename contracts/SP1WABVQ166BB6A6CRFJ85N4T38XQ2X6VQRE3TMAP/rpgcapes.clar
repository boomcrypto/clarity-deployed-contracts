;; rpgcapes

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token rpgcapes uint)

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

;; Internal variables
(define-data-var mint-limit uint u100)
(define-data-var last-id uint u101)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmVeqZp7dchkDi3E64KPpyqRwi1joPE14K39JtcGkAwSY4/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)

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
    )
    (asserts! (is-eq false (var-get mint-paused)) (err ERR-PAUSED))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
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
      (unwrap! (nft-mint? rpgcapes next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (set-price (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set total-price price))))

(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (var-set metadata-frozen true)
    (ok true)))


;; Non-custodial SIP-009 transfer fuction
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? market id)) (err ERR-LISTING))
    (trnsfr id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? rpgcapes token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

;; Extra functionality required for mintpass
(define-public (toggle-sale-state)
  (let 
    (
      ;; (premint (not (var-get premint-enabled)))
      (sale (not (var-get sale-enabled)))
    )
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (var-set premint-enabled false)
    (var-set sale-enabled sale)
    (print { sale: sale })
    (ok true)))

(define-public (enable-premint)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled true))))

(define-public (disable-premint)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled false))))

(define-read-only (get-passes (caller principal))
  (default-to u0 (map-get? mint-passes caller)))

(define-read-only (get-premint-enabled)
  (ok (var-get premint-enabled)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))

;; Non-custodial marketplace extras
(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? rpgcapes id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? rpgcapes id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? rpgcapes id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))  

(map-set mint-passes 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP u100)

(define-public (admin-airdrop)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (try! (nft-mint? rpgcapes u1 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u2 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u3 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u4 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u5 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u6 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u7 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u8 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u9 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u10 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u11 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u12 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u13 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u14 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u15 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u16 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u17 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u18 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u19 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u20 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u21 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u22 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u23 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u24 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u25 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u26 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u27 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u28 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u29 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u30 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u31 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u32 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u33 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u34 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u35 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u36 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u37 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u38 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u39 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u40 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u41 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u42 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u43 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u44 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u45 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u46 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u47 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u48 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u49 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u50 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u51 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u52 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u53 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u54 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u55 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u56 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u57 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u58 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u59 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u60 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u61 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u62 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u63 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u64 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u65 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u66 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u67 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u68 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u69 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u70 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u71 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u72 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u73 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u74 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u75 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u76 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u77 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u78 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u79 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u80 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u81 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u82 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u83 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u84 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u85 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u86 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u87 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u88 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u89 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u90 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u91 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u92 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u93 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u94 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u95 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u96 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u97 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u98 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u99 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))
(try! (nft-mint? rpgcapes u100 'SP1WABVQ166BB6A6CRFJ85N4T38XQ2X6VQRE3TMAP))

    (ok true)))