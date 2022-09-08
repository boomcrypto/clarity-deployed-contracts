;; neoswap-anthem-team-edition
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token neoswap-anthem-team-edition uint)

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
(define-data-var mint-limit uint u20)
(define-data-var last-id uint u1)
(define-data-var total-price uint u10000000000)
(define-data-var artist-address principal 'SP3Z3KVR3T0F255SC8170SZY7YB52YPY9H9TNZ9PM)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmXpVgY2Cpk5yJqYpXjDMema34djVpAMrnyf2PBuXXrNcc/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u10)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-public (mint-for-many (recipients (list 25 principal)))
  (let
    (
      (next-id (var-get last-id))
      (id-reached (fold mint-for-many-iter recipients next-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (var-set last-id id-reached)
      (ok id-reached))))

(define-private (mint-for-many-iter (recipient principal) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? neoswap-anthem-team-edition next-id tx-sender) next-id)
      (unwrap! (nft-transfer? neoswap-anthem-team-edition next-id tx-sender recipient) next-id)
      (map-set token-count recipient (+ (get-balance recipient) u1))      
      (+ next-id u1)
    )
    next-id))

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
      (unwrap! (nft-mint? neoswap-anthem-team-edition next-id tx-sender) next-id)
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
    (nft-burn? neoswap-anthem-team-edition token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? neoswap-anthem-team-edition token-id) false)))

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
  (ok (nft-get-owner? neoswap-anthem-team-edition token-id)))

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
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? neoswap-anthem-team-edition id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? neoswap-anthem-team-edition id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? neoswap-anthem-team-edition id) (err ERR-NOT-FOUND)))
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
  (if (> royalty-amount u0)
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
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u0) 'SP3BTPH354JEM3E8AYAHQS9SWJ591TJQYD9QK0MCF))
      (map-set token-count 'SP3BTPH354JEM3E8AYAHQS9SWJ591TJQYD9QK0MCF (+ (get-balance 'SP3BTPH354JEM3E8AYAHQS9SWJ591TJQYD9QK0MCF) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u1) 'SP15B9DHAWWBDNNAF7B63T1TXJYQMB3FQTGWMQRGG))
      (map-set token-count 'SP15B9DHAWWBDNNAF7B63T1TXJYQMB3FQTGWMQRGG (+ (get-balance 'SP15B9DHAWWBDNNAF7B63T1TXJYQMB3FQTGWMQRGG) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u2) 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES))
      (map-set token-count 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES (+ (get-balance 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u3) 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403))
      (map-set token-count 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403 (+ (get-balance 'SP1Q6N226KFMA496MVWSB0VZC0T0R9FSKTYYYZ403) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u4) 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW))
      (map-set token-count 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW (+ (get-balance 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u5) 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N))
      (map-set token-count 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N (+ (get-balance 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u6) 'SP21C94648068TV7RSTNWQ1FSECGAZ7PYTT2GAD63))
      (map-set token-count 'SP21C94648068TV7RSTNWQ1FSECGAZ7PYTT2GAD63 (+ (get-balance 'SP21C94648068TV7RSTNWQ1FSECGAZ7PYTT2GAD63) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u7) 'SP3FANVZX232AW5DZVHV8KQ0SEAQAVK1X8S8EXK4K))
      (map-set token-count 'SP3FANVZX232AW5DZVHV8KQ0SEAQAVK1X8S8EXK4K (+ (get-balance 'SP3FANVZX232AW5DZVHV8KQ0SEAQAVK1X8S8EXK4K) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u8) 'SP3BH9700MJEX25GWJYTCDNZB50QC786T9QM8NM3B))
      (map-set token-count 'SP3BH9700MJEX25GWJYTCDNZB50QC786T9QM8NM3B (+ (get-balance 'SP3BH9700MJEX25GWJYTCDNZB50QC786T9QM8NM3B) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u9) 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J))
      (map-set token-count 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J (+ (get-balance 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u10) 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2))
      (map-set token-count 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 (+ (get-balance 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u11) 'SP1N41GX5EVPR9SD7JM8T1165YP5G279JE9V9XFH0))
      (map-set token-count 'SP1N41GX5EVPR9SD7JM8T1165YP5G279JE9V9XFH0 (+ (get-balance 'SP1N41GX5EVPR9SD7JM8T1165YP5G279JE9V9XFH0) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u12) 'SP1HHSDYJ0SGAM6K2W01ZF5K7AJFKWMJNH365ZWS9))
      (map-set token-count 'SP1HHSDYJ0SGAM6K2W01ZF5K7AJFKWMJNH365ZWS9 (+ (get-balance 'SP1HHSDYJ0SGAM6K2W01ZF5K7AJFKWMJNH365ZWS9) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u13) 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES))
      (map-set token-count 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES (+ (get-balance 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u14) 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES))
      (map-set token-count 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES (+ (get-balance 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u15) 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES))
      (map-set token-count 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES (+ (get-balance 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u16) 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES))
      (map-set token-count 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES (+ (get-balance 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u17) 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES))
      (map-set token-count 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES (+ (get-balance 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u18) 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES))
      (map-set token-count 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES (+ (get-balance 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES) u1))
      (try! (nft-mint? neoswap-anthem-team-edition (+ last-nft-id u19) 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES))
      (map-set token-count 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES (+ (get-balance 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES) u1))

      (var-set last-id (+ last-nft-id u20))
      (var-set airdrop-called true)
      (ok true))))