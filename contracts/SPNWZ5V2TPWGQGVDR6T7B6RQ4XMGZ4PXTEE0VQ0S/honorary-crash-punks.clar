;; honorary-crash-punks

 
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

 
(define-non-fungible-token honorary-crash-punks uint)

 
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

 
;; Internal variables
(define-data-var mint-limit uint u30)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmQMwvFQvyEjQqyT2bYooxG7Y8vw6oY2QnmtfCmMqA6m4D/json/")
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
     (unwrap! (nft-mint? honorary-crash-punks next-id tx-sender) next-id)
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
   (ok (var-set mint-limit limit))))

 
(define-public (burn (token-id uint))
 (begin
   (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
   (nft-burn? honorary-crash-punks token-id tx-sender)))

 
(define-private (is-owner (token-id uint) (user principal))
   (is-eq user (unwrap! (nft-get-owner? honorary-crash-punks token-id) false)))

 
(define-public (set-base-uri (new-base-uri (string-ascii 80)))
 (begin
   (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
   (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
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
 (ok (nft-get-owner? honorary-crash-punks token-id)))

 
(define-read-only (get-last-token-id)
 (ok (- (var-get last-id) u1)))

 
(define-read-only (get-token-uri (token-id uint))
 (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

 
(define-read-only (get-paused)
 (ok (var-get mint-paused)))

 
(define-read-only (get-price)
 (ok (var-get total-price)))

 
(define-read-only (get-mints (caller principal))
 (default-to u0 (map-get? mints-per-user caller)))

 
(define-read-only (get-mint-limit)
 (ok (var-get mint-limit)))

 
;; Non-custodial marketplace extras
(define-trait commission-trait
 ((pay (uint uint) (response bool uint))))

 
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

 
(define-read-only (get-balance (account principal))
 (default-to u0
   (map-get? token-count account)))

 
(define-private (trnsfr (id uint) (sender principal) (recipient principal))
 (match (nft-transfer? honorary-crash-punks id sender recipient)
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
 (let ((owner (unwrap! (nft-get-owner? honorary-crash-punks id) false)))
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
 (let ((owner (unwrap! (nft-get-owner? honorary-crash-punks id) (err ERR-NOT-FOUND)))
     (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
     (price (get price listing)))
   (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
   (try! (stx-transfer? price tx-sender owner))
   (try! (contract-call? comm-trait pay id price))
   (try! (trnsfr id owner tx-sender))
   (map-delete market id)
   (print {a: "buy-in-ustx", id: id})
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
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u0) 'SP16F01GJX02HY3WKQMFSBXMKN4T3QEBQB1R0V5A0))
     (map-set token-count 'SP16F01GJX02HY3WKQMFSBXMKN4T3QEBQB1R0V5A0 (+ (get-balance 'SP16F01GJX02HY3WKQMFSBXMKN4T3QEBQB1R0V5A0) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u1) 'SP8WG5CCXDX83PND4Y03SXQ4FW2R689113ETS24Q))
     (map-set token-count 'SP8WG5CCXDX83PND4Y03SXQ4FW2R689113ETS24Q (+ (get-balance 'SP8WG5CCXDX83PND4Y03SXQ4FW2R689113ETS24Q) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u2) 'SP8XZVDYMK8WQ4EMV6XNM45M2HHJA3CHBVWGT5AP))
     (map-set token-count 'SP8XZVDYMK8WQ4EMV6XNM45M2HHJA3CHBVWGT5AP (+ (get-balance 'SP8XZVDYMK8WQ4EMV6XNM45M2HHJA3CHBVWGT5AP) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u3) 'SP1X11HKCJ46PT9GSRS1PRYA53NB1VZ5P2B7KGASE))
     (map-set token-count 'SP1X11HKCJ46PT9GSRS1PRYA53NB1VZ5P2B7KGASE (+ (get-balance 'SP1X11HKCJ46PT9GSRS1PRYA53NB1VZ5P2B7KGASE) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u4) 'SP1V0JDB6QDN84V4XECGH7JDCHRPS89TPYJMYG6XY))
     (map-set token-count 'SP1V0JDB6QDN84V4XECGH7JDCHRPS89TPYJMYG6XY (+ (get-balance 'SP1V0JDB6QDN84V4XECGH7JDCHRPS89TPYJMYG6XY) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u5) 'SP1JT14AAXH7N3TYRX118GB7ZPMH4Q341TS0HM0VB))
     (map-set token-count 'SP1JT14AAXH7N3TYRX118GB7ZPMH4Q341TS0HM0VB (+ (get-balance 'SP1JT14AAXH7N3TYRX118GB7ZPMH4Q341TS0HM0VB) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u6) 'SP1J5W1FN3P80XV1YK14BKC6A912WWFGJSW9M92HA))
     (map-set token-count 'SP1J5W1FN3P80XV1YK14BKC6A912WWFGJSW9M92HA (+ (get-balance 'SP1J5W1FN3P80XV1YK14BKC6A912WWFGJSW9M92HA) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u7) 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ))
     (map-set token-count 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ (+ (get-balance 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u8) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
     (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u9) 'SPQVP86RFXZB79S5H3DEHB4Q8RV9J6WY26EBV150))
     (map-set token-count 'SPQVP86RFXZB79S5H3DEHB4Q8RV9J6WY26EBV150 (+ (get-balance 'SPQVP86RFXZB79S5H3DEHB4Q8RV9J6WY26EBV150) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u10) 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR))
     (map-set token-count 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR (+ (get-balance 'SP2JWXVBMB0DW53KC1PJ80VC7T6N2ZQDBGCDJDMNR) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u11) 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G))
     (map-set token-count 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G (+ (get-balance 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u12) 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G))
     (map-set token-count 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G (+ (get-balance 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u13) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
     (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u14) 'SPBM9BTEYFTC50HTEGWHG39D7S7JHHBRYQ3Q159V))
     (map-set token-count 'SPBM9BTEYFTC50HTEGWHG39D7S7JHHBRYQ3Q159V (+ (get-balance 'SPBM9BTEYFTC50HTEGWHG39D7S7JHHBRYQ3Q159V) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u15) 'SP2MZJBAJJ5072PTPDJ767ASXKW53KPQ9ZEWJ00S5))
     (map-set token-count 'SP2MZJBAJJ5072PTPDJ767ASXKW53KPQ9ZEWJ00S5 (+ (get-balance 'SP2MZJBAJJ5072PTPDJ767ASXKW53KPQ9ZEWJ00S5) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u16) 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW))
     (map-set token-count 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW (+ (get-balance 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u17) 'SP2GSR4QWHKJMJT9FWS4D8PQH5A98KQV9CHY6K88S))
     (map-set token-count 'SP2GSR4QWHKJMJT9FWS4D8PQH5A98KQV9CHY6K88S (+ (get-balance 'SP2GSR4QWHKJMJT9FWS4D8PQH5A98KQV9CHY6K88S) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u18) 'SP1KATN54MZRH14AJP2D73XA1AXD420MRJ0JH9RQ1))
     (map-set token-count 'SP1KATN54MZRH14AJP2D73XA1AXD420MRJ0JH9RQ1 (+ (get-balance 'SP1KATN54MZRH14AJP2D73XA1AXD420MRJ0JH9RQ1) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u19) 'SP2N3KC4CR7CC0JP592S9RBA9GHVVD30WRA5GXE8G))
     (map-set token-count 'SP2N3KC4CR7CC0JP592S9RBA9GHVVD30WRA5GXE8G (+ (get-balance 'SP2N3KC4CR7CC0JP592S9RBA9GHVVD30WRA5GXE8G) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u20) 'SP1JX2RYKPR0G7H81SQHZQ187H50RR6QSM8GX839X))
     (map-set token-count 'SP1JX2RYKPR0G7H81SQHZQ187H50RR6QSM8GX839X (+ (get-balance 'SP1JX2RYKPR0G7H81SQHZQ187H50RR6QSM8GX839X) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u21) 'SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1))
     (map-set token-count 'SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1 (+ (get-balance 'SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u22) 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G))
     (map-set token-count 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G (+ (get-balance 'SPQE8N8BHMT462W2XPK028GDM4RMQBSHAAY8D37G) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u23) 'SPSEBFRZZEZSHGRKRR1Z55RX5AWHER3CYM0H9BMW))
     (map-set token-count 'SPSEBFRZZEZSHGRKRR1Z55RX5AWHER3CYM0H9BMW (+ (get-balance 'SPSEBFRZZEZSHGRKRR1Z55RX5AWHER3CYM0H9BMW) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u24) 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227))
     (map-set token-count 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227 (+ (get-balance 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u25) 'SP2E89CRFYKHTWVZBQ2R6KH19CJWMABYZA60XFWNW))
     (map-set token-count 'SP2E89CRFYKHTWVZBQ2R6KH19CJWMABYZA60XFWNW (+ (get-balance 'SP2E89CRFYKHTWVZBQ2R6KH19CJWMABYZA60XFWNW) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u26) 'SPJ1D3Z6X3PK4MZBN693KNW87DQ0H5WN2SHM9ET7))
     (map-set token-count 'SPJ1D3Z6X3PK4MZBN693KNW87DQ0H5WN2SHM9ET7 (+ (get-balance 'SPJ1D3Z6X3PK4MZBN693KNW87DQ0H5WN2SHM9ET7) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u27) 'SP3ESBKP1EDKAA0083DA2MAM1TYPF93MFME2MRE2B))
     (map-set token-count 'SP3ESBKP1EDKAA0083DA2MAM1TYPF93MFME2MRE2B (+ (get-balance 'SP3ESBKP1EDKAA0083DA2MAM1TYPF93MFME2MRE2B) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u28) 'SP9CMJ7S8XR25H6ZKAJXT4M7KSPQ1B8PPVSYJRTC))
     (map-set token-count 'SP9CMJ7S8XR25H6ZKAJXT4M7KSPQ1B8PPVSYJRTC (+ (get-balance 'SP9CMJ7S8XR25H6ZKAJXT4M7KSPQ1B8PPVSYJRTC) u1))
     (try! (nft-mint? honorary-crash-punks (+ last-nft-id u29) 'SPJT8G4DA24ZDF35WMY5FZEQ9YJNK38DBN2D48QH))
     (map-set token-count 'SPJT8G4DA24ZDF35WMY5FZEQ9YJNK38DBN2D48QH (+ (get-balance 'SPJT8G4DA24ZDF35WMY5FZEQ9YJNK38DBN2D48QH) u1))

 
     (var-set last-id (+ last-nft-id u30))
     (var-set airdrop-called true)
     (ok true))))