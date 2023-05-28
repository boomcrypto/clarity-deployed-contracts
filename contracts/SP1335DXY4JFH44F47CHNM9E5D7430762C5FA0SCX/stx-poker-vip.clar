;; stx-poker-vip
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stx-poker-vip uint)

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
(define-data-var mint-limit uint u69)
(define-data-var last-id uint u1)
(define-data-var total-price uint u69000000)
(define-data-var artist-address principal 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmPRTq6XeVrE4VXghAwhV4WA8omKjKe7qe6A7BLYN4tH1P/json/")
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
      (unwrap! (nft-mint? stx-poker-vip next-id tx-sender) next-id)
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
    (nft-burn? stx-poker-vip token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stx-poker-vip token-id) false)))

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
  (ok (nft-get-owner? stx-poker-vip token-id)))

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

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/3")
(define-data-var license-name (string-ascii 40) "COMMERCIAL-NO-HATE")

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
  (match (nft-transfer? stx-poker-vip id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? stx-poker-vip id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? stx-poker-vip id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u0) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u1) 'SP2RWS7D7RW6DDZCTXJC0VTK86CKD0TF445116V8A))
      (map-set token-count 'SP2RWS7D7RW6DDZCTXJC0VTK86CKD0TF445116V8A (+ (get-balance 'SP2RWS7D7RW6DDZCTXJC0VTK86CKD0TF445116V8A) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u2) 'SP2Y6E7CEZG1G4V038FFWAPKXB8WKEWR9929KWR6P))
      (map-set token-count 'SP2Y6E7CEZG1G4V038FFWAPKXB8WKEWR9929KWR6P (+ (get-balance 'SP2Y6E7CEZG1G4V038FFWAPKXB8WKEWR9929KWR6P) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u3) 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB))
      (map-set token-count 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB (+ (get-balance 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u4) 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN))
      (map-set token-count 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN (+ (get-balance 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u5) 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P))
      (map-set token-count 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P (+ (get-balance 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u6) 'SP28KECCXDDH072GG38Y9P2KTAF97YECZVHWPYDG))
      (map-set token-count 'SP28KECCXDDH072GG38Y9P2KTAF97YECZVHWPYDG (+ (get-balance 'SP28KECCXDDH072GG38Y9P2KTAF97YECZVHWPYDG) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u7) 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV))
      (map-set token-count 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV (+ (get-balance 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u8) 'SP2GHCPM134Y28EZKNKEMF7SBK0BQ1QW1QASYWS6Z))
      (map-set token-count 'SP2GHCPM134Y28EZKNKEMF7SBK0BQ1QW1QASYWS6Z (+ (get-balance 'SP2GHCPM134Y28EZKNKEMF7SBK0BQ1QW1QASYWS6Z) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u9) 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM))
      (map-set token-count 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM (+ (get-balance 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u10) 'SP3WKZWBE7F7GR91GPFDNTT65A2J8WA8KZC9MFKQJ))
      (map-set token-count 'SP3WKZWBE7F7GR91GPFDNTT65A2J8WA8KZC9MFKQJ (+ (get-balance 'SP3WKZWBE7F7GR91GPFDNTT65A2J8WA8KZC9MFKQJ) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u11) 'SP1QJBY8XZF6HVFSHBH5C8DGKK9BK4BC4ZHT944CB))
      (map-set token-count 'SP1QJBY8XZF6HVFSHBH5C8DGKK9BK4BC4ZHT944CB (+ (get-balance 'SP1QJBY8XZF6HVFSHBH5C8DGKK9BK4BC4ZHT944CB) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u12) 'SP3NPM49B0MNKWYH05DP567H5NJ1QN91PEF4E2Z2D))
      (map-set token-count 'SP3NPM49B0MNKWYH05DP567H5NJ1QN91PEF4E2Z2D (+ (get-balance 'SP3NPM49B0MNKWYH05DP567H5NJ1QN91PEF4E2Z2D) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u13) 'SP2MMF30WNFRQRB3H6PKZR07BA5W4YQ6XY2JF8X5R))
      (map-set token-count 'SP2MMF30WNFRQRB3H6PKZR07BA5W4YQ6XY2JF8X5R (+ (get-balance 'SP2MMF30WNFRQRB3H6PKZR07BA5W4YQ6XY2JF8X5R) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u14) 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D))
      (map-set token-count 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D (+ (get-balance 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u15) 'SP32728WFVK74FQXC0BD48QD6BNW5A3MJ8HB5YADR))
      (map-set token-count 'SP32728WFVK74FQXC0BD48QD6BNW5A3MJ8HB5YADR (+ (get-balance 'SP32728WFVK74FQXC0BD48QD6BNW5A3MJ8HB5YADR) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u16) 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH))
      (map-set token-count 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH (+ (get-balance 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u17) 'SP2MCPE4ACC1W9FY1JC3BK2FMYSNWYDEADFEJH2MY))
      (map-set token-count 'SP2MCPE4ACC1W9FY1JC3BK2FMYSNWYDEADFEJH2MY (+ (get-balance 'SP2MCPE4ACC1W9FY1JC3BK2FMYSNWYDEADFEJH2MY) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u18) 'SP1GYWMYK320ASBBAERSC40TA3PA99ZHV3GF256T8))
      (map-set token-count 'SP1GYWMYK320ASBBAERSC40TA3PA99ZHV3GF256T8 (+ (get-balance 'SP1GYWMYK320ASBBAERSC40TA3PA99ZHV3GF256T8) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u19) 'SP2YQ53PTAD8GNT27FWCKVZKE0BMSWKW25P5YV6FM))
      (map-set token-count 'SP2YQ53PTAD8GNT27FWCKVZKE0BMSWKW25P5YV6FM (+ (get-balance 'SP2YQ53PTAD8GNT27FWCKVZKE0BMSWKW25P5YV6FM) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u20) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u21) 'SP9R1DTP15B10S5WFPZVM8W2FDS6VXP27VA96CEZ))
      (map-set token-count 'SP9R1DTP15B10S5WFPZVM8W2FDS6VXP27VA96CEZ (+ (get-balance 'SP9R1DTP15B10S5WFPZVM8W2FDS6VXP27VA96CEZ) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u22) 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF))
      (map-set token-count 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF (+ (get-balance 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u23) 'SP1ZVX0C3PEHFV1GBYXSH1S6N8XVS6GKS14R9N0QK))
      (map-set token-count 'SP1ZVX0C3PEHFV1GBYXSH1S6N8XVS6GKS14R9N0QK (+ (get-balance 'SP1ZVX0C3PEHFV1GBYXSH1S6N8XVS6GKS14R9N0QK) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u24) 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99))
      (map-set token-count 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99 (+ (get-balance 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u25) 'SP3JCN7W79KNRJBBPBRPKJZ7TRCVAK1NGV2FX4ZH))
      (map-set token-count 'SP3JCN7W79KNRJBBPBRPKJZ7TRCVAK1NGV2FX4ZH (+ (get-balance 'SP3JCN7W79KNRJBBPBRPKJZ7TRCVAK1NGV2FX4ZH) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u26) 'SP2XJCFE0MZB33AAP91ZY8TXJ03HMXCJPJD71AJCM))
      (map-set token-count 'SP2XJCFE0MZB33AAP91ZY8TXJ03HMXCJPJD71AJCM (+ (get-balance 'SP2XJCFE0MZB33AAP91ZY8TXJ03HMXCJPJD71AJCM) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u27) 'SP2QPKZPPEBZ7ZB7E558TTW15X75S9VDHC09M9SJF))
      (map-set token-count 'SP2QPKZPPEBZ7ZB7E558TTW15X75S9VDHC09M9SJF (+ (get-balance 'SP2QPKZPPEBZ7ZB7E558TTW15X75S9VDHC09M9SJF) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u28) 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294))
      (map-set token-count 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294 (+ (get-balance 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u29) 'SP1VRHC4B8M5QSEA005GBQ3MXRP68RNG097SKEXHS))
      (map-set token-count 'SP1VRHC4B8M5QSEA005GBQ3MXRP68RNG097SKEXHS (+ (get-balance 'SP1VRHC4B8M5QSEA005GBQ3MXRP68RNG097SKEXHS) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u30) 'SP2ZGWWTAA2D9B1JARMAX0DA5B7XH260WV097GTSZ))
      (map-set token-count 'SP2ZGWWTAA2D9B1JARMAX0DA5B7XH260WV097GTSZ (+ (get-balance 'SP2ZGWWTAA2D9B1JARMAX0DA5B7XH260WV097GTSZ) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u31) 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB))
      (map-set token-count 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB (+ (get-balance 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u32) 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5))
      (map-set token-count 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5 (+ (get-balance 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u33) 'SP12HKVJ66B3VE40RN6WV85FRGNB2G6NWXHVK62G4))
      (map-set token-count 'SP12HKVJ66B3VE40RN6WV85FRGNB2G6NWXHVK62G4 (+ (get-balance 'SP12HKVJ66B3VE40RN6WV85FRGNB2G6NWXHVK62G4) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u34) 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E))
      (map-set token-count 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E (+ (get-balance 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u35) 'SP16Z3TD3R9H71EN1MR74AAB17ZMZ5YWP5FB92296))
      (map-set token-count 'SP16Z3TD3R9H71EN1MR74AAB17ZMZ5YWP5FB92296 (+ (get-balance 'SP16Z3TD3R9H71EN1MR74AAB17ZMZ5YWP5FB92296) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u36) 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV))
      (map-set token-count 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV (+ (get-balance 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u37) 'SP1ZSJSS6NMJ5YW13NBK4ZEG398GENVSXKXKTK62F))
      (map-set token-count 'SP1ZSJSS6NMJ5YW13NBK4ZEG398GENVSXKXKTK62F (+ (get-balance 'SP1ZSJSS6NMJ5YW13NBK4ZEG398GENVSXKXKTK62F) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u38) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u39) 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN))
      (map-set token-count 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN (+ (get-balance 'SP334EMSM2K8SXDXC8GR1BYVW0T6DN95X5R3H3DFN) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u40) 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2))
      (map-set token-count 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 (+ (get-balance 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u41) 'SP15TF0R1GCEFA84WSSRFPWM8XDQSQAJN7QAB31BE))
      (map-set token-count 'SP15TF0R1GCEFA84WSSRFPWM8XDQSQAJN7QAB31BE (+ (get-balance 'SP15TF0R1GCEFA84WSSRFPWM8XDQSQAJN7QAB31BE) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u42) 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG))
      (map-set token-count 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG (+ (get-balance 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u43) 'SP3YPMD71E1Q0WRW0949AT5MQ4M72GMP915CX1XTW))
      (map-set token-count 'SP3YPMD71E1Q0WRW0949AT5MQ4M72GMP915CX1XTW (+ (get-balance 'SP3YPMD71E1Q0WRW0949AT5MQ4M72GMP915CX1XTW) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u44) 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4))
      (map-set token-count 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4 (+ (get-balance 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u45) 'SP2Z2AQM22D9AZ5YZKZPWYBFWKJ7YGVVWT1C5M66P))
      (map-set token-count 'SP2Z2AQM22D9AZ5YZKZPWYBFWKJ7YGVVWT1C5M66P (+ (get-balance 'SP2Z2AQM22D9AZ5YZKZPWYBFWKJ7YGVVWT1C5M66P) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u46) 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864))
      (map-set token-count 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864 (+ (get-balance 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u47) 'SP5DVYVM5FMWGAQNP2KE9HGXAY4N3F3CNTMSRGM8))
      (map-set token-count 'SP5DVYVM5FMWGAQNP2KE9HGXAY4N3F3CNTMSRGM8 (+ (get-balance 'SP5DVYVM5FMWGAQNP2KE9HGXAY4N3F3CNTMSRGM8) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u48) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u49) 'SP2RKVC8PYANWJ40VSRCK2K935HSN4H0AHTVHD73D))
      (map-set token-count 'SP2RKVC8PYANWJ40VSRCK2K935HSN4H0AHTVHD73D (+ (get-balance 'SP2RKVC8PYANWJ40VSRCK2K935HSN4H0AHTVHD73D) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u50) 'SP1S0B05BFW099N2C30W7T788QE4645M72EP6AV3X))
      (map-set token-count 'SP1S0B05BFW099N2C30W7T788QE4645M72EP6AV3X (+ (get-balance 'SP1S0B05BFW099N2C30W7T788QE4645M72EP6AV3X) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u51) 'SP3VGV6K1NC5BTK82S06FD9YK3FPZ4KD6YNRJCV2R))
      (map-set token-count 'SP3VGV6K1NC5BTK82S06FD9YK3FPZ4KD6YNRJCV2R (+ (get-balance 'SP3VGV6K1NC5BTK82S06FD9YK3FPZ4KD6YNRJCV2R) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u52) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u53) 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191))
      (map-set token-count 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191 (+ (get-balance 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u54) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u55) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u56) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u57) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u58) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u59) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u60) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u61) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u62) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u63) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u64) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u65) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u66) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u67) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))
      (try! (nft-mint? stx-poker-vip (+ last-nft-id u68) 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX))
      (map-set token-count 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX (+ (get-balance 'SP1335DXY4JFH44F47CHNM9E5D7430762C5FA0SCX) u1))

      (var-set last-id (+ last-nft-id u69))
      (var-set airdrop-called true)
      (ok true))))