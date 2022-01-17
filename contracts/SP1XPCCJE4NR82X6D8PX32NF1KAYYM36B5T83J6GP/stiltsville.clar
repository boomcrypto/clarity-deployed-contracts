;; stiltsville

;; testnet
;; (impl-trait 'ST1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XZ54PKG7.nft-trait.nft-trait)
;; mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stiltsville uint)

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

;; Internal variables
(define-data-var mint-limit uint u5)
(define-data-var last-id uint u1)
(define-data-var total-price uint u100000000)
(define-data-var artist-address principal 'SP1XPCCJE4NR82X6D8PX32NF1KAYYM36B5T83J6GP)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmfHSLbSyGdLE8C8dVLHk7gb1b2nVtjeM96D8iYLkbBK5o/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)

(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true))
)

(define-public (claim-three)
  (mint (list true true true))
)

(define-public (claim-five)
  (mint (list true true true true true))
)

(define-public (claim-ten)
  (mint (list true true true true true true true true true true))
)

;; Default Minting
(define-private (mint (orders (list 10 bool)))
    (mint-many orders)
)

(define-private (mint-many (orders (list 10 bool )))  
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      
      (total-artist (- price total-commission))
    )
    (asserts! (is-eq false (var-get mint-paused)) (err ERR-PAUSED))
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
    (ok id-reached)
  )
)

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? stiltsville next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id
  )
)

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))
  )
)

(define-public (set-price (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set total-price price))
  )
)

(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))
  )
)

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))
  )
)

;; Default SIP-009 transfer fuction
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? stiltsville token-id sender recipient)
  )
)

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? stiltsville token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))




  
;; MiamiCoin Minting Default
(define-data-var total-price-mia uint u12500)

(define-public (claim-mia)
  (mint-mia (list true))
)

(define-public (claim-three-mia)
  (mint-mia (list true true true))
)

(define-public (claim-five-mia)
  (mint-mia (list true true true true true))
)

(define-public (claim-ten-mia)
  (mint-mia (list true true true true true true true true true true))
)

(define-private (mint-mia (orders (list 10 bool)))
    (mint-many-mia orders)
)

(define-private (mint-many-mia (orders (list 10 bool )))  
  (let (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-mia) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        
      )
      (begin
        (var-set last-id id-reached)
        
        (try! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
        ;;(try! (stx-transfer? total-artist tx-sender (var-get artist-address)))
        ;;(try! (stx-transfer? total-commission tx-sender COMM-ADDR))
      )    
    )
    (ok id-reached)
  )
)


