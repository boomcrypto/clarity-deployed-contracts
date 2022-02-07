;; african-amazons

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token african-amazons uint)

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
(define-data-var mint-limit uint u10)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmV7t7wQnX92gFudnxJHVQswAtYs5B4Z1tFbUEPGCaVwTb/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)

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
      
      (total-artist (- price total-commission))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        
      )
      (begin
        (var-set last-id id-reached)
        
        (try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        (try! (stx-transfer? total-commission tx-sender COMM-ADDR))
      )    
    )
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? african-amazons next-id tx-sender) next-id)
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

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? african-amazons token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? african-amazons token-id) false)))

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

;; Default SIP-009 transfer function
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? african-amazons token-id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? african-amazons token-id)))

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

  

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
      (try! (nft-mint? african-amazons (+ last-nft-id u0) 'SP295QANJTGHJJ9TSHJ4WH28Z52VDKWDW68VT8KAH))
      (try! (nft-mint? african-amazons (+ last-nft-id u1) 'SP1HQ9YQXNGTRC5AVVTJAPBTFRY7TFH3XDJDC9N88))
      (try! (nft-mint? african-amazons (+ last-nft-id u2) 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T))
      (try! (nft-mint? african-amazons (+ last-nft-id u3) 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T))
      (try! (nft-mint? african-amazons (+ last-nft-id u4) 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T))
      (try! (nft-mint? african-amazons (+ last-nft-id u5) 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T))
      (try! (nft-mint? african-amazons (+ last-nft-id u6) 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T))
      (try! (nft-mint? african-amazons (+ last-nft-id u7) 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T))
      (try! (nft-mint? african-amazons (+ last-nft-id u8) 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T))
      (try! (nft-mint? african-amazons (+ last-nft-id u9) 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T))

      (var-set last-id (+ last-nft-id u10))
      (ok true))))