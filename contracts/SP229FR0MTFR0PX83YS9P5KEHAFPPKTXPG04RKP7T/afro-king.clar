;; afro-king

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token afro-king uint)

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
(define-data-var mint-limit uint u450)
(define-data-var last-id uint u1)
(define-data-var total-price uint u5000000)
(define-data-var artist-address principal 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmWLTsgwYFW9NxEhBvcRjfhvsi1mnbBDjvZKkwt3QbKxDi/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)

(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-twentyfive) (mint (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

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
      (unwrap! (nft-mint? afro-king next-id tx-sender) next-id)
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
    (nft-burn? afro-king token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? afro-king token-id) false)))

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
    (nft-transfer? afro-king token-id sender recipient)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? afro-king token-id)))

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
(define-data-var total-price-mia uint u01000)

(define-read-only (get-price-mia)
  (ok (var-get total-price-mia)))

(define-public (set-price-mia (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set total-price-mia price))))

(define-public (claim-mia)
  (mint-mia (list true)))

(define-public (claim-three-mia) (mint-mia (list true true true)))

(define-public (claim-five-mia) (mint-mia (list true true true true true)))

(define-public (claim-ten-mia) (mint-mia (list true true true true true true true true true true)))

(define-public (claim-twentyfive-mia) (mint-mia (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


(define-private (mint-mia (orders (list 25 bool)))
  (mint-many-mia orders))

(define-private (mint-many-mia (orders (list 25 bool )))  
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
(define-data-var total-price-nyc uint u01600)

(define-read-only (get-price-nyc)
  (ok (var-get total-price-nyc)))

(define-public (set-price-nyc (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set total-price-nyc price))))

(define-public (claim-nyc)
  (mint-nyc (list true)))

(define-public (claim-three-nyc) (mint-nyc (list true true true)))

(define-public (claim-five-nyc) (mint-nyc (list true true true true true)))

(define-public (claim-ten-nyc) (mint-nyc (list true true true true true true true true true true)))

(define-public (claim-twentyfive-nyc) (mint-nyc (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


(define-private (mint-nyc (orders (list 25 bool)))
  (mint-many-nyc orders))

(define-private (mint-many-nyc (orders (list 25 bool )))  
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

;; Alt Minting Default
(define-data-var total-price-usda uint u07)

(define-read-only (get-price-usda)
  (ok (var-get total-price-usda)))

(define-public (set-price-usda (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set total-price-usda price))))

(define-public (claim-usda)
  (mint-usda (list true)))

(define-public (claim-three-usda) (mint-usda (list true true true)))

(define-public (claim-five-usda) (mint-usda (list true true true true true)))

(define-public (claim-ten-usda) (mint-usda (list true true true true true true true true true true)))

(define-public (claim-twentyfive-usda) (mint-usda (list true true true true true true true true true true true true true true true true true true true true true true true true true)))


(define-private (mint-usda (orders (list 25 bool)))
  (mint-many-usda orders))

(define-private (mint-many-usda (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-usda) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        
      )
      (begin
        (var-set last-id id-reached)
        
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
      (try! (nft-mint? afro-king (+ last-nft-id u0) 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA))
      (try! (nft-mint? afro-king (+ last-nft-id u1) 'SP14PVWDVKVK1P1SZV72MJQMNX5N5XDZ8AGNG9M0C))
      (try! (nft-mint? afro-king (+ last-nft-id u2) 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N))
      (try! (nft-mint? afro-king (+ last-nft-id u3) 'SP1DMPD0JNAVDRCTY17S2MNHX8F6502NB0Z25RVR))
      (try! (nft-mint? afro-king (+ last-nft-id u4) 'SP30BTV3905TS3A83CENN271AHZHGM4C3FDZX3JNR))
      (try! (nft-mint? afro-king (+ last-nft-id u5) 'SP6Z0QQR7WBY4MDSY4F59V5YCT29B9KPQJT0TF45))
      (try! (nft-mint? afro-king (+ last-nft-id u6) 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR))
      (try! (nft-mint? afro-king (+ last-nft-id u7) 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
      (try! (nft-mint? afro-king (+ last-nft-id u8) 'SPXKPY2NMKPQW7W5PCNKD1YG67GVBJKATQKNA1ZH))
      (try! (nft-mint? afro-king (+ last-nft-id u9) 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0))
      (try! (nft-mint? afro-king (+ last-nft-id u10) 'SP3BBTH6PQXSHFM2ZM9J8Q819HS02WKBQ6ZG3HCTZ))
      (try! (nft-mint? afro-king (+ last-nft-id u11) 'SP1XRFVSKEY954TPX1XED41VDEKH9EVVQWTMAWR3Y))
      (try! (nft-mint? afro-king (+ last-nft-id u12) 'SP2XXMH2DHP5S0CS1VB8C6TV75510YDQA527CAPG0))
      (try! (nft-mint? afro-king (+ last-nft-id u13) 'SP1HQ9YQXNGTRC5AVVTJAPBTFRY7TFH3XDJDC9N88))
      (try! (nft-mint? afro-king (+ last-nft-id u14) 'SP36MCQHXPP0DZ2KPC1KEY6ERC8GKB6QVCAK0PQYG))
      (try! (nft-mint? afro-king (+ last-nft-id u15) 'SP2QND89SYHEPQ63QRE3GVKQZAH1FGXP0YJG2SATE))
      (try! (nft-mint? afro-king (+ last-nft-id u16) 'SP3TVVJEEH3X9R7SD0CCCJXNPS8KKVRAQYA5RWEC3))
      (try! (nft-mint? afro-king (+ last-nft-id u17) 'SP3TF77S4XWBMZ455YTYWRMRMHTM7AZDM6258ACR3))
      (try! (nft-mint? afro-king (+ last-nft-id u18) 'SP16YA5N2VE52JRDYXKFZ2TF7T2CBRB4SH8NYKJX1))
      (try! (nft-mint? afro-king (+ last-nft-id u19) 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7))
      (try! (nft-mint? afro-king (+ last-nft-id u20) 'SP3Q1CZZNXM95DZVTB7VBND4FW4B2E0YXM2KJ7FAH))
      (try! (nft-mint? afro-king (+ last-nft-id u21) 'SP295QANJTGHJJ9TSHJ4WH28Z52VDKWDW68VT8KAH))
      (try! (nft-mint? afro-king (+ last-nft-id u22) 'SP1ENAX51WA6VP691GT9100V72Y3CCY1YZW0TA3B1))
      (try! (nft-mint? afro-king (+ last-nft-id u23) 'SP1NCYAM5CVNZ5CC1YMDEKEXCAX6XB5QGMEX46GHP))
      (try! (nft-mint? afro-king (+ last-nft-id u24) 'SPBW8GGZTH6C9W7H9QAMAFCA44TJS3DA629VZPWP))
      (try! (nft-mint? afro-king (+ last-nft-id u25) 'SP16W7S76K0A7HAM176B73RQ8MD75E9VJ8VM256WH))
      (try! (nft-mint? afro-king (+ last-nft-id u26) 'SP16W7S76K0A7HAM176B73RQ8MD75E9VJ8VM256WH))
      (try! (nft-mint? afro-king (+ last-nft-id u27) 'SP16W7S76K0A7HAM176B73RQ8MD75E9VJ8VM256WH))
      (try! (nft-mint? afro-king (+ last-nft-id u28) 'SP16W7S76K0A7HAM176B73RQ8MD75E9VJ8VM256WH))
      (try! (nft-mint? afro-king (+ last-nft-id u29) 'SP16W7S76K0A7HAM176B73RQ8MD75E9VJ8VM256WH))

      (var-set last-id (+ last-nft-id u30))
      (ok true))))