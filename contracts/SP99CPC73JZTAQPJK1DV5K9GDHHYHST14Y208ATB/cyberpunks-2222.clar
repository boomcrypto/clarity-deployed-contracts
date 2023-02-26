;; cyberpunks-2222
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token cyberpunks-2222 uint)

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
(define-data-var mint-limit uint u2222)
(define-data-var last-id uint u1)
(define-data-var total-price uint u10000000)
(define-data-var artist-address principal 'SP99CPC73JZTAQPJK1DV5K9GDHHYHST14Y208ATB)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmNg7dPnfnDWLPBjEmy1iw766uLNaJgn7v2dwBdNVYkSL3/json/")
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
      (unwrap! (nft-mint? cyberpunks-2222 next-id tx-sender) next-id)
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
    (nft-burn? cyberpunks-2222 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? cyberpunks-2222 token-id) false)))

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
  (ok (nft-get-owner? cyberpunks-2222 token-id)))

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

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/1")
(define-data-var license-name (string-ascii 40) "EXCLUSIVE")

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
  (match (nft-transfer? cyberpunks-2222 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? cyberpunks-2222 id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? cyberpunks-2222 id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u0) 'SP1G9PZMQSFRQ7Q98XP7JMNE2C22RXK1W61RXTNKP))
      (map-set token-count 'SP1G9PZMQSFRQ7Q98XP7JMNE2C22RXK1W61RXTNKP (+ (get-balance 'SP1G9PZMQSFRQ7Q98XP7JMNE2C22RXK1W61RXTNKP) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u1) 'SPTBXT6YRNYZE85F9AZ0W5RMBQQGY0ACBNH7YJR7))
      (map-set token-count 'SPTBXT6YRNYZE85F9AZ0W5RMBQQGY0ACBNH7YJR7 (+ (get-balance 'SPTBXT6YRNYZE85F9AZ0W5RMBQQGY0ACBNH7YJR7) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u2) 'SPY6HFEWRG719Q3Y147N0CBM1XHK0PKQG112JETV))
      (map-set token-count 'SPY6HFEWRG719Q3Y147N0CBM1XHK0PKQG112JETV (+ (get-balance 'SPY6HFEWRG719Q3Y147N0CBM1XHK0PKQG112JETV) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u3) 'SP3E5HW2K0BDRR1QXJW71218FWA5D0WFYXKF9XXQS))
      (map-set token-count 'SP3E5HW2K0BDRR1QXJW71218FWA5D0WFYXKF9XXQS (+ (get-balance 'SP3E5HW2K0BDRR1QXJW71218FWA5D0WFYXKF9XXQS) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u4) 'SP99CPC73JZTAQPJK1DV5K9GDHHYHST14Y208ATB))
      (map-set token-count 'SP99CPC73JZTAQPJK1DV5K9GDHHYHST14Y208ATB (+ (get-balance 'SP99CPC73JZTAQPJK1DV5K9GDHHYHST14Y208ATB) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u5) 'SP22SY7NFM0GZTMZT32DM073ENECYKZ4YBCKY8ZYY))
      (map-set token-count 'SP22SY7NFM0GZTMZT32DM073ENECYKZ4YBCKY8ZYY (+ (get-balance 'SP22SY7NFM0GZTMZT32DM073ENECYKZ4YBCKY8ZYY) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u6) 'SP14X13XTGPK7Z93J2N6FDM7XNREX8721YNVJ7Y9N))
      (map-set token-count 'SP14X13XTGPK7Z93J2N6FDM7XNREX8721YNVJ7Y9N (+ (get-balance 'SP14X13XTGPK7Z93J2N6FDM7XNREX8721YNVJ7Y9N) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u7) 'SPJT3WWPT4Q925GDE9BBZRC5MNZ3SMP8G7VMJSNS))
      (map-set token-count 'SPJT3WWPT4Q925GDE9BBZRC5MNZ3SMP8G7VMJSNS (+ (get-balance 'SPJT3WWPT4Q925GDE9BBZRC5MNZ3SMP8G7VMJSNS) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u8) 'SP2ZVC0QYET82AZJ8XG876SZCZ8XR9JNC4H6HZF2K))
      (map-set token-count 'SP2ZVC0QYET82AZJ8XG876SZCZ8XR9JNC4H6HZF2K (+ (get-balance 'SP2ZVC0QYET82AZJ8XG876SZCZ8XR9JNC4H6HZF2K) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u9) 'SP37F1KJ7YM9SSJS3RQJZMD0MB3T05GKNNE9GPSXR))
      (map-set token-count 'SP37F1KJ7YM9SSJS3RQJZMD0MB3T05GKNNE9GPSXR (+ (get-balance 'SP37F1KJ7YM9SSJS3RQJZMD0MB3T05GKNNE9GPSXR) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u10) 'SP2CQS6J5GF41S78ZK7W3VYV24DYQ1J18G3J0K99D))
      (map-set token-count 'SP2CQS6J5GF41S78ZK7W3VYV24DYQ1J18G3J0K99D (+ (get-balance 'SP2CQS6J5GF41S78ZK7W3VYV24DYQ1J18G3J0K99D) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u11) 'SP3EP97AT4D8JHJCVT5JPBRG3K318FD7NPKYCJ1KP))
      (map-set token-count 'SP3EP97AT4D8JHJCVT5JPBRG3K318FD7NPKYCJ1KP (+ (get-balance 'SP3EP97AT4D8JHJCVT5JPBRG3K318FD7NPKYCJ1KP) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u12) 'SP1TJZFQSP32SRA99C3HNQZN9E912MWSTP5A8YHSY))
      (map-set token-count 'SP1TJZFQSP32SRA99C3HNQZN9E912MWSTP5A8YHSY (+ (get-balance 'SP1TJZFQSP32SRA99C3HNQZN9E912MWSTP5A8YHSY) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u13) 'SP3Y7MP92K8S97AHTNS1DYTV267W74YYHB1BR4S34))
      (map-set token-count 'SP3Y7MP92K8S97AHTNS1DYTV267W74YYHB1BR4S34 (+ (get-balance 'SP3Y7MP92K8S97AHTNS1DYTV267W74YYHB1BR4S34) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u14) 'SP15CWSMA19K926S8JXXN7FNG0X1J4GG484WEV7DM))
      (map-set token-count 'SP15CWSMA19K926S8JXXN7FNG0X1J4GG484WEV7DM (+ (get-balance 'SP15CWSMA19K926S8JXXN7FNG0X1J4GG484WEV7DM) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u15) 'SP1QVSFGCPPDERXY7FGCMF8Z89Q3VE9S197X0A5XW))
      (map-set token-count 'SP1QVSFGCPPDERXY7FGCMF8Z89Q3VE9S197X0A5XW (+ (get-balance 'SP1QVSFGCPPDERXY7FGCMF8Z89Q3VE9S197X0A5XW) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u16) 'SP3P53KJAMZMJEQACWZQ4T7NP2P52T7RZ843JJ0HA))
      (map-set token-count 'SP3P53KJAMZMJEQACWZQ4T7NP2P52T7RZ843JJ0HA (+ (get-balance 'SP3P53KJAMZMJEQACWZQ4T7NP2P52T7RZ843JJ0HA) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u17) 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW))
      (map-set token-count 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW (+ (get-balance 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u18) 'SP3Q92A5FKV3HKCZWFMN0MSQAMP41TZ2582KY93E2))
      (map-set token-count 'SP3Q92A5FKV3HKCZWFMN0MSQAMP41TZ2582KY93E2 (+ (get-balance 'SP3Q92A5FKV3HKCZWFMN0MSQAMP41TZ2582KY93E2) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u19) 'SP33F8SWXJ4EG0BSG6BSFJ488B0XB1JJCT9MG8098))
      (map-set token-count 'SP33F8SWXJ4EG0BSG6BSFJ488B0XB1JJCT9MG8098 (+ (get-balance 'SP33F8SWXJ4EG0BSG6BSFJ488B0XB1JJCT9MG8098) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u20) 'SPYF09YHBXKEKSPSX7K8S4QB7R2GV50TVX2JM5C8))
      (map-set token-count 'SPYF09YHBXKEKSPSX7K8S4QB7R2GV50TVX2JM5C8 (+ (get-balance 'SPYF09YHBXKEKSPSX7K8S4QB7R2GV50TVX2JM5C8) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u21) 'SP26WWKNC1VPT3Z9QBD98QMJ5VM50Z2ZTXRNB25B9))
      (map-set token-count 'SP26WWKNC1VPT3Z9QBD98QMJ5VM50Z2ZTXRNB25B9 (+ (get-balance 'SP26WWKNC1VPT3Z9QBD98QMJ5VM50Z2ZTXRNB25B9) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u22) 'SP2A6A3T4QMNBNSH0WFEGW4T0084K5KZSC4HRVGZE))
      (map-set token-count 'SP2A6A3T4QMNBNSH0WFEGW4T0084K5KZSC4HRVGZE (+ (get-balance 'SP2A6A3T4QMNBNSH0WFEGW4T0084K5KZSC4HRVGZE) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u23) 'SP2TCFDKSD8DA00WM5YABHHQQR10XF0T6RKW4SE2S))
      (map-set token-count 'SP2TCFDKSD8DA00WM5YABHHQQR10XF0T6RKW4SE2S (+ (get-balance 'SP2TCFDKSD8DA00WM5YABHHQQR10XF0T6RKW4SE2S) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u24) 'SP2FRZR8FNEYTV9WM3RDNJ6TADW8XBG857QSK9JPT))
      (map-set token-count 'SP2FRZR8FNEYTV9WM3RDNJ6TADW8XBG857QSK9JPT (+ (get-balance 'SP2FRZR8FNEYTV9WM3RDNJ6TADW8XBG857QSK9JPT) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u25) 'SPT2S8EY6G36J0W5YDPDB3WVVDN4M3SH894P2M51))
      (map-set token-count 'SPT2S8EY6G36J0W5YDPDB3WVVDN4M3SH894P2M51 (+ (get-balance 'SPT2S8EY6G36J0W5YDPDB3WVVDN4M3SH894P2M51) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u26) 'SP3PCHER3WK602NEKMABJRP72WVZEZ93J50TQH7Z3))
      (map-set token-count 'SP3PCHER3WK602NEKMABJRP72WVZEZ93J50TQH7Z3 (+ (get-balance 'SP3PCHER3WK602NEKMABJRP72WVZEZ93J50TQH7Z3) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u27) 'SP3NM7P8HSAT6BXGS2ENT57ZPMM4S6XDME2Z2RFVY))
      (map-set token-count 'SP3NM7P8HSAT6BXGS2ENT57ZPMM4S6XDME2Z2RFVY (+ (get-balance 'SP3NM7P8HSAT6BXGS2ENT57ZPMM4S6XDME2Z2RFVY) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u28) 'SP2YVCK6H9G0EQ195577PQ01B3V6TSNHDGKFE4GMR))
      (map-set token-count 'SP2YVCK6H9G0EQ195577PQ01B3V6TSNHDGKFE4GMR (+ (get-balance 'SP2YVCK6H9G0EQ195577PQ01B3V6TSNHDGKFE4GMR) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u29) 'SP2Z5075M2KDHYZC5BMWF9T4JF7TA2RSCXQEX77T0))
      (map-set token-count 'SP2Z5075M2KDHYZC5BMWF9T4JF7TA2RSCXQEX77T0 (+ (get-balance 'SP2Z5075M2KDHYZC5BMWF9T4JF7TA2RSCXQEX77T0) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u30) 'SP2B1G8DWPT7A6NJ2BDBC6HMME6AX2SSSZMWAVRQ6))
      (map-set token-count 'SP2B1G8DWPT7A6NJ2BDBC6HMME6AX2SSSZMWAVRQ6 (+ (get-balance 'SP2B1G8DWPT7A6NJ2BDBC6HMME6AX2SSSZMWAVRQ6) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u31) 'SP2F93KF26PERSY4QQAN5TW160RJ5JX9B8C43FRDK))
      (map-set token-count 'SP2F93KF26PERSY4QQAN5TW160RJ5JX9B8C43FRDK (+ (get-balance 'SP2F93KF26PERSY4QQAN5TW160RJ5JX9B8C43FRDK) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u32) 'SP2VSY7ZM3WWA57QPMRD92GHKZ19P1BETA5FK9ZG0))
      (map-set token-count 'SP2VSY7ZM3WWA57QPMRD92GHKZ19P1BETA5FK9ZG0 (+ (get-balance 'SP2VSY7ZM3WWA57QPMRD92GHKZ19P1BETA5FK9ZG0) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u33) 'SPY3E2KHZKQBN58SHAC2AWZSQX3823JYC1SS06PQ))
      (map-set token-count 'SPY3E2KHZKQBN58SHAC2AWZSQX3823JYC1SS06PQ (+ (get-balance 'SPY3E2KHZKQBN58SHAC2AWZSQX3823JYC1SS06PQ) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u34) 'SP3FTC4PXE3JVZQTW6AVD6Z1ZVA16218DQ4D9VKGZ))
      (map-set token-count 'SP3FTC4PXE3JVZQTW6AVD6Z1ZVA16218DQ4D9VKGZ (+ (get-balance 'SP3FTC4PXE3JVZQTW6AVD6Z1ZVA16218DQ4D9VKGZ) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u35) 'SP1MGT3X3CJE4936HXGWRFE1SJYWB4571DPS8R694))
      (map-set token-count 'SP1MGT3X3CJE4936HXGWRFE1SJYWB4571DPS8R694 (+ (get-balance 'SP1MGT3X3CJE4936HXGWRFE1SJYWB4571DPS8R694) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u36) 'SP1FMVTETARD05GTBJNT66RGEB353ETSQ4R1KNZJ2))
      (map-set token-count 'SP1FMVTETARD05GTBJNT66RGEB353ETSQ4R1KNZJ2 (+ (get-balance 'SP1FMVTETARD05GTBJNT66RGEB353ETSQ4R1KNZJ2) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u37) 'SP2NSJ2VKJ8PTBVFFJE38F8ENZ0Z0GM4ZAJPXJ7AZ))
      (map-set token-count 'SP2NSJ2VKJ8PTBVFFJE38F8ENZ0Z0GM4ZAJPXJ7AZ (+ (get-balance 'SP2NSJ2VKJ8PTBVFFJE38F8ENZ0Z0GM4ZAJPXJ7AZ) u1))
      (try! (nft-mint? cyberpunks-2222 (+ last-nft-id u38) 'SPZHRFS924KNHW2ADGTWS6TPZDC0QZHS1CFGNSKW))
      (map-set token-count 'SPZHRFS924KNHW2ADGTWS6TPZDC0QZHS1CFGNSKW (+ (get-balance 'SPZHRFS924KNHW2ADGTWS6TPZDC0QZHS1CFGNSKW) u1))

      (var-set last-id (+ last-nft-id u39))
      (var-set airdrop-called true)
      (ok true))))