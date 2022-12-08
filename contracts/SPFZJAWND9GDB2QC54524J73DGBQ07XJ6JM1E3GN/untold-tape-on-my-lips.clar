;; untold-tape-on-my-lips
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token untold-tape-on-my-lips uint)

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
(define-data-var mint-limit uint u37)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmaK3KeN4qBQWM1s17CHbzE2rTBdxUjBv9tTSQboJdGz5r/json/")
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
      (unwrap! (nft-mint? untold-tape-on-my-lips next-id tx-sender) next-id)
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
    (nft-burn? untold-tape-on-my-lips token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? untold-tape-on-my-lips token-id) false)))

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
  (ok (nft-get-owner? untold-tape-on-my-lips token-id)))

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
  (match (nft-transfer? untold-tape-on-my-lips id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? untold-tape-on-my-lips id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? untold-tape-on-my-lips id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u0) 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV))
      (map-set token-count 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV (+ (get-balance 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u1) 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ))
      (map-set token-count 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ (+ (get-balance 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u2) 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG))
      (map-set token-count 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG (+ (get-balance 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u3) 'SP2Q15VXSQ6TKTYFFV3M31H3S09JWMYX8GWEKMS0Z))
      (map-set token-count 'SP2Q15VXSQ6TKTYFFV3M31H3S09JWMYX8GWEKMS0Z (+ (get-balance 'SP2Q15VXSQ6TKTYFFV3M31H3S09JWMYX8GWEKMS0Z) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u4) 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864))
      (map-set token-count 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864 (+ (get-balance 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u5) 'SP27KNMGQMKHP0EBT1FPC1W302BXKNZ3VRQK938A3))
      (map-set token-count 'SP27KNMGQMKHP0EBT1FPC1W302BXKNZ3VRQK938A3 (+ (get-balance 'SP27KNMGQMKHP0EBT1FPC1W302BXKNZ3VRQK938A3) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u6) 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80))
      (map-set token-count 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80 (+ (get-balance 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u7) 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY))
      (map-set token-count 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY (+ (get-balance 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u8) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u9) 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP))
      (map-set token-count 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP (+ (get-balance 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u10) 'SP3WFDD787ES26F96H67T7CNC6D8QZ9X6KM5YBVJK))
      (map-set token-count 'SP3WFDD787ES26F96H67T7CNC6D8QZ9X6KM5YBVJK (+ (get-balance 'SP3WFDD787ES26F96H67T7CNC6D8QZ9X6KM5YBVJK) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u11) 'SP205ASZ0WCCMVBZG82TRJESV3DT9S4V2K8QK8RE0))
      (map-set token-count 'SP205ASZ0WCCMVBZG82TRJESV3DT9S4V2K8QK8RE0 (+ (get-balance 'SP205ASZ0WCCMVBZG82TRJESV3DT9S4V2K8QK8RE0) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u12) 'SPXXY25GXNG9B50HN9JFW69D0SVKXKQ9MX5QHQR1))
      (map-set token-count 'SPXXY25GXNG9B50HN9JFW69D0SVKXKQ9MX5QHQR1 (+ (get-balance 'SPXXY25GXNG9B50HN9JFW69D0SVKXKQ9MX5QHQR1) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u13) 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ))
      (map-set token-count 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ (+ (get-balance 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u14) 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN))
      (map-set token-count 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN (+ (get-balance 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u15) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u16) 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44))
      (map-set token-count 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44 (+ (get-balance 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u17) 'SP1W3XEG461WD5BQ0M4PF9WZ2HGT5TR0STJB7WNG5))
      (map-set token-count 'SP1W3XEG461WD5BQ0M4PF9WZ2HGT5TR0STJB7WNG5 (+ (get-balance 'SP1W3XEG461WD5BQ0M4PF9WZ2HGT5TR0STJB7WNG5) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u18) 'SP2Q15VXSQ6TKTYFFV3M31H3S09JWMYX8GWEKMS0Z))
      (map-set token-count 'SP2Q15VXSQ6TKTYFFV3M31H3S09JWMYX8GWEKMS0Z (+ (get-balance 'SP2Q15VXSQ6TKTYFFV3M31H3S09JWMYX8GWEKMS0Z) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u19) 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN))
      (map-set token-count 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN (+ (get-balance 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u20) 'SP1SE73VJ07WQSZSFJ1QP3SX7TVRPVJGYP0S89WWH))
      (map-set token-count 'SP1SE73VJ07WQSZSFJ1QP3SX7TVRPVJGYP0S89WWH (+ (get-balance 'SP1SE73VJ07WQSZSFJ1QP3SX7TVRPVJGYP0S89WWH) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u21) 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN))
      (map-set token-count 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN (+ (get-balance 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u22) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u23) 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S))
      (map-set token-count 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S (+ (get-balance 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u24) 'SP14YEEA2S46F5EE11G6Z7PJFDW5JAZFG86BACFXB))
      (map-set token-count 'SP14YEEA2S46F5EE11G6Z7PJFDW5JAZFG86BACFXB (+ (get-balance 'SP14YEEA2S46F5EE11G6Z7PJFDW5JAZFG86BACFXB) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u25) 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D))
      (map-set token-count 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D (+ (get-balance 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u26) 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4))
      (map-set token-count 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4 (+ (get-balance 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u27) 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85))
      (map-set token-count 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 (+ (get-balance 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u28) 'SP3F50PNGA4PY5PVB590SKY4WE8NHZEYQKRDBSJX8))
      (map-set token-count 'SP3F50PNGA4PY5PVB590SKY4WE8NHZEYQKRDBSJX8 (+ (get-balance 'SP3F50PNGA4PY5PVB590SKY4WE8NHZEYQKRDBSJX8) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u29) 'SP24GYRG3M7T0S6FZE9RVVP9PNNZQJQ614650G590))
      (map-set token-count 'SP24GYRG3M7T0S6FZE9RVVP9PNNZQJQ614650G590 (+ (get-balance 'SP24GYRG3M7T0S6FZE9RVVP9PNNZQJQ614650G590) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u30) 'SP2CKGVBDCNHW215M2RDEVDNHGZVF38FKHR6JT056))
      (map-set token-count 'SP2CKGVBDCNHW215M2RDEVDNHGZVF38FKHR6JT056 (+ (get-balance 'SP2CKGVBDCNHW215M2RDEVDNHGZVF38FKHR6JT056) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u31) 'SP2N3EAQCAT8MHZCAVDP0A5AMR4FZ58PZWW96BB08))
      (map-set token-count 'SP2N3EAQCAT8MHZCAVDP0A5AMR4FZ58PZWW96BB08 (+ (get-balance 'SP2N3EAQCAT8MHZCAVDP0A5AMR4FZ58PZWW96BB08) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u32) 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN))
      (map-set token-count 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN (+ (get-balance 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u33) 'SP2PWAZ7FFGGEFA53MG4M8HG3KNAH3Q5TMMG66GJA))
      (map-set token-count 'SP2PWAZ7FFGGEFA53MG4M8HG3KNAH3Q5TMMG66GJA (+ (get-balance 'SP2PWAZ7FFGGEFA53MG4M8HG3KNAH3Q5TMMG66GJA) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u34) 'SP398XE371G08T84A99TCBD8XKWY3S7VVX6JKJWKY))
      (map-set token-count 'SP398XE371G08T84A99TCBD8XKWY3S7VVX6JKJWKY (+ (get-balance 'SP398XE371G08T84A99TCBD8XKWY3S7VVX6JKJWKY) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u35) 'SP38REZNW2QD8CSSQ3PZKWJZ84TTBTXDJDD20GKW4))
      (map-set token-count 'SP38REZNW2QD8CSSQ3PZKWJZ84TTBTXDJDD20GKW4 (+ (get-balance 'SP38REZNW2QD8CSSQ3PZKWJZ84TTBTXDJDD20GKW4) u1))
      (try! (nft-mint? untold-tape-on-my-lips (+ last-nft-id u36) 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB))
      (map-set token-count 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB (+ (get-balance 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB) u1))

      (var-set last-id (+ last-nft-id u37))
      (var-set airdrop-called true)
      (ok true))))