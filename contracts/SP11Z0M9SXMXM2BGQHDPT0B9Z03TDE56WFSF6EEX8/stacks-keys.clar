;; stacks-keys
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stacks-keys uint)

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
(define-data-var mint-limit uint u101)
(define-data-var last-id uint u1)
(define-data-var total-price uint u10000000)
(define-data-var artist-address principal 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmPZbPAw4mnNiU9gGDZTeYpc6dWmobmP45YSczR8B8so1Y/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u2)

(define-map mints-per-user principal uint)
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
      (unwrap! (nft-mint? stacks-keys next-id tx-sender) next-id)
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
    (nft-burn? stacks-keys token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stacks-keys token-id) false)))

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
  (ok (nft-get-owner? stacks-keys token-id)))

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

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/2")
(define-data-var license-name (string-ascii 40) "COMMERCIAL")

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
  (match (nft-transfer? stacks-keys id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? stacks-keys id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? stacks-keys id) (err ERR-NOT-FOUND)))
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

;; Alt Minting Mintpass
(define-data-var total-price-alex uint u7300000000)

(define-read-only (get-price-alex)
  (ok (var-get total-price-alex)))

(define-public (set-price-alex (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-alex price))))

(define-public (claim-alex)
  (mint-alex (list true)))

(define-private (mint-alex (orders (list 25 bool)))
  (let 
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-alex orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-alex orders)
      )
    )))

(define-private (mint-many-alex (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-alex) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer total-artist tx-sender (var-get artist-address) (some 0x00)))
        (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )    
    )
    (ok id-reached)))

(map-set mint-passes 'SP3CJ9STRZYEZEACN92WBKY9404AF9JM95RADD78Q u2)
(map-set mint-passes 'SP3W79C3AK8S0WKEPP2FARXZRJ65WT0E04SX1QQ05 u2)
(map-set mint-passes 'SP2QH5QETSYAZ2VGQAZ42AK3ZN15EF4R3P76XDAR2 u2)
(map-set mint-passes 'SPG6CHDSFHSXQ3ESBBF2MEDS42GH131SRH6JGFQA u2)
(map-set mint-passes 'SP2M18QBG7DJKGYVDTKQ1TK77QH0DWSYPY6WQRNZ6 u2)
(map-set mint-passes 'SP3SNEZTWXE2FM941CRDYR12AYHX7CE33P24JMBE4 u2)
(map-set mint-passes 'SPM2JZ5R7M6AZQTXKEM94K63E2CN95TT6AMMA5PP u2)
(map-set mint-passes 'SP1XN5RY49QDBB1HKYN7YDFB477XTAN5777S4P3QY u2)
(map-set mint-passes 'SP2ZXDBYT1RSP98ZZXXRDGKX3TMXCCCGERNBD5YMY u2)
(map-set mint-passes 'SPFFPBH1JDV47KER3TBK8W87QQARAE47YVFTA3NQ u2)
(map-set mint-passes 'SPGSAT9239F29KSHM56PSTJHYWD7M792FV7Z48RA u2)
(map-set mint-passes 'SPEW42NMB4F832CDN4GDFQV8D7JD33B22VRFF7WY u2)
(map-set mint-passes 'SP1F81CCCJ1CNXS9WBCTZKM25YWNVJ61G8SZ5YJWY u2)
(map-set mint-passes 'SP2H8CEZRSK22DR7APBSZ689SBKCQ6NXKWWFKA6E9 u2)
(map-set mint-passes 'SP85PA3Y9HPVNC0RCMQ0K1TP5AH4G3J0Y14ZN2Z8 u2)
(map-set mint-passes 'SP10XWJT6JK9ZJ6NJ47C6SA749WFTZJQ5NX28BA9Q u2)
(map-set mint-passes 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0 u2)
(map-set mint-passes 'SP127T68F65CPDWA18X87A0XRQ7Q48QQQH9KF7HZX u2)
(map-set mint-passes 'SPCZE13Q283T7QE17EE77K1ST76BEKWZXD0AFH8N u2)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? stacks-keys (+ last-nft-id u0) 'SP2QH5QETSYAZ2VGQAZ42AK3ZN15EF4R3P76XDAR2))
      (map-set token-count 'SP2QH5QETSYAZ2VGQAZ42AK3ZN15EF4R3P76XDAR2 (+ (get-balance 'SP2QH5QETSYAZ2VGQAZ42AK3ZN15EF4R3P76XDAR2) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u1) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u2) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u3) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u4) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u5) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u6) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u7) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u8) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u9) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u10) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u11) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u12) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u13) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u14) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))
      (try! (nft-mint? stacks-keys (+ last-nft-id u15) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))

      (var-set last-id (+ last-nft-id u16))
      (var-set airdrop-called true)
      (ok true))))