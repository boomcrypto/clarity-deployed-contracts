;; bitcoin-pepe
;; contractType: public custom

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token bitcoin-pepe uint)

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
(define-data-var mint-limit uint u2089)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)

;; Mint and Secondary payouts 
;; 100% mint + 50% secondary
(define-data-var artist-address principal 'SM2J5VCY4DCFX6VZYDANHMXA3VN9DMWYCEK7Y8D93)
;; 50% secondary only
(define-data-var royalty-address-1 principal 'SP3ANWNWTHJAH4E1WNQ9RT7V07ERJN5S4DA7X6XEW)

(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmRNSQYjHXoohquaPbmc6DFH6kmc3s3rgMsNpUBvgojEpE/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u3)

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
      (unwrap! (nft-mint? bitcoin-pepe next-id tx-sender) next-id)
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
    (nft-burn? bitcoin-pepe token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? bitcoin-pepe token-id) false)))

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

(define-public (reveal-artwork (new-base-uri (string-ascii 80)))
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

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? bitcoin-pepe token-id)))

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

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/5")
(define-data-var license-name (string-ascii 40) "PERSONAL-NO-HATE")

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
  (match (nft-transfer? bitcoin-pepe id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? bitcoin-pepe id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? bitcoin-pepe id) (err ERR-NOT-FOUND)))
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
      (royalty-amount-artist (/ (* price (/ (* royalty u500) u1000)) u10000))
      (royalty-amount-1 (/ (* price (/ (* royalty u500) u1000)) u10000))
  )
  (if (and (> royalty-amount-artist u0) (not (is-eq tx-sender (var-get artist-address))))
    (try! (stx-transfer? royalty-amount-artist tx-sender (var-get artist-address)))
    (print false)
  )

  (if (and (> royalty-amount-1 u0) (not (is-eq tx-sender (var-get royalty-address-1))))
    (try! (stx-transfer? royalty-amount-1 tx-sender (var-get royalty-address-1)))
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

(define-public (clear-mintpasses (addresses (list 2000 principal)))
  (let 
    (
      (index-reached (fold clear-mintpasses-iter addresses u0))
    )
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (print {
      total-mintpasses-cleared: index-reached,
    })
    (ok true)))

(define-public (add-mintpasses (addresses (list 2000 principal)))
  (let 
    (
      (index-reached (fold add-mintpasses-iter addresses u0))
    )
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (print {
      total-mintpasses-added: index-reached,
    })
    (ok true)))

(define-private (clear-mintpasses-iter (address principal) (next-index uint))
  (begin 
    (map-delete mint-passes address)    
    (+ next-index u1)))

(define-private (add-mintpasses-iter (address principal) (next-index uint))
  (let 
    (
      (mintpass-count (get-passes address))
    ) 
    (map-set mint-passes address (+ mintpass-count u1))
    (+ next-index u1)))


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

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u0) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u1) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u2) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u3) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u4) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u5) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u6) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u7) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u8) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u9) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u10) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u11) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u12) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u13) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u14) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u15) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u16) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u17) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u18) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u19) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u20) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u21) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u22) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u23) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u24) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u25) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u26) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u27) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u28) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u29) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u30) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u31) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u32) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u33) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u34) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u35) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u36) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u37) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u38) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u39) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u40) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u41) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u42) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u43) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u44) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u45) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u46) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u47) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))
      (try! (nft-mint? bitcoin-pepe (+ last-nft-id u48) 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2))
      (map-set token-count 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2 (+ (get-balance 'SPSC35NSP4BMQNYDAFQBEGV13ZP4YBS41WASJ0E2) u1))

      (var-set last-id (+ last-nft-id u49))
      (var-set airdrop-called true)
      (ok true))))