;; cryptomayors

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token cryptomayors uint)

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
(define-data-var mint-limit uint u14)
(define-data-var last-id uint u1)
(define-data-var total-price uint u220000000)
(define-data-var artist-address principal 'SP2XMCH1MNJX1307QXM16FE2929MCPCG3K41SV66J)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmUdTe9P5sX5HBkPfYsTdPnEjunAtfo9DwrzhmpQNaDWxR/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)

(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-three)
  (mint (list true true true)))

(define-public (claim-five)
  (mint (list true true true true true)))

(define-public (claim-ten)
  (mint (list true true true true true true true true true true)))

;; Default Minting
(define-private (mint (orders (list 10 bool)))
  (mint-many orders))

(define-private (mint-many (orders (list 10 bool )))  
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
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? cryptomayors next-id tx-sender) next-id)
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

;; Default SIP-009 transfer fuction
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR-INVALID-USER))
    (nft-transfer? cryptomayors token-id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? cryptomayors token-id)))

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




  
;; Alt Minting Default
(define-data-var total-price-mia uint u42123)

(define-read-only (get-price-mia)
  (ok (var-get total-price-mia)))

(define-public (set-price-mia (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set total-price-mia price))))

(define-public (claim-mia)
  (mint-mia (list true)))

(define-public (claim-three-mia)
  (mint-mia (list true true true)))

(define-public (claim-five-mia)
  (mint-mia (list true true true true true)))

(define-public (claim-ten-mia)
  (mint-mia (list true true true true true true true true true true)))

(define-private (mint-mia (orders (list 10 bool)))
  (mint-many-mia orders))

(define-private (mint-many-mia (orders (list 10 bool )))  
  (let 
    (
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
      )    
    )
    (ok id-reached)))

;; Alt Minting Default
(define-data-var total-price-nyc uint u125000)

(define-read-only (get-price-nyc)
  (ok (var-get total-price-nyc)))

(define-public (set-price-nyc (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set total-price-nyc price))))

(define-public (claim-nyc)
  (mint-nyc (list true)))

(define-public (claim-three-nyc)
  (mint-nyc (list true true true)))

(define-public (claim-five-nyc)
  (mint-nyc (list true true true true true)))

(define-public (claim-ten-nyc)
  (mint-nyc (list true true true true true true true true true true)))

(define-private (mint-nyc (orders (list 10 bool)))
  (mint-many-nyc orders))

(define-private (mint-many-nyc (orders (list 10 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-nyc) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        
      )
      (begin
        (var-set last-id id-reached)
        
        (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))
