;; stacks-parrots-proof-of-phoenix
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stacks-parrots-proof-of-phoenix uint)

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
(define-constant ERR-CONTRACT-LOCKED u115)

;; Internal variables
(define-data-var mint-limit uint u42)
(define-data-var last-id uint u1)
(define-data-var total-price uint u99000000)
(define-data-var artist-address principal 'SP467VFDYHV185JSQ98V9VTA7JS3PFJ3DM8PXD20)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmZ67HxpkiDrRoRfVMmZ7BDSQGk4GS9PE5uuGL8M1q2ATf/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)
(define-data-var locked bool false)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (lock-contract)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
    (var-set locked true)
    (ok true)))

(define-public (claim) 
  (mint (list true)))

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

(define-private (mint-many (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (or (is-eq (var-get mint-limit) u0) (<= last-nft-id (var-get mint-limit))) (err ERR-NO-MORE-NFTS)))
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
    (asserts! (is-eq (var-get locked) false) (err ERR-CONTRACT-LOCKED))
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
  (if (or (is-eq (var-get mint-limit) u0) (<= next-id (var-get mint-limit)))
    (begin
      (unwrap! (nft-mint? stacks-parrots-proof-of-phoenix next-id tx-sender) next-id)
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
    (nft-burn? stacks-parrots-proof-of-phoenix token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stacks-parrots-proof-of-phoenix token-id) false)))

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
  (ok (nft-get-owner? stacks-parrots-proof-of-phoenix token-id)))

(define-read-only (get-last-token-id)
  (ok (- (var-get last-id) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get ipfs-root))))

(define-read-only (get-paused)
  (ok (var-get mint-paused)))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-artist-address)
  (ok (var-get artist-address)))

(define-read-only (get-locked)
  (ok (var-get locked)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-mint-limit)
  (ok (var-get mint-limit)))

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/5")
(define-data-var license-name (string-ascii 40) "PERSONAL-NO-HATE")

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
  (match (nft-transfer? stacks-parrots-proof-of-phoenix id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? stacks-parrots-proof-of-phoenix id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? stacks-parrots-proof-of-phoenix id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u0) 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG))
      (map-set token-count 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG (+ (get-balance 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u1) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u2) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u3) 'SP1TH8Y1953C1484KDFC8R1NAA0E925CFG7W4Y46G))
      (map-set token-count 'SP1TH8Y1953C1484KDFC8R1NAA0E925CFG7W4Y46G (+ (get-balance 'SP1TH8Y1953C1484KDFC8R1NAA0E925CFG7W4Y46G) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u4) 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5))
      (map-set token-count 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5 (+ (get-balance 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u5) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u6) 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY))
      (map-set token-count 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY (+ (get-balance 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u7) 'SP3HFSDK6A9VQT1QE7TFXZX5K71VFXQ823KDKA5PY))
      (map-set token-count 'SP3HFSDK6A9VQT1QE7TFXZX5K71VFXQ823KDKA5PY (+ (get-balance 'SP3HFSDK6A9VQT1QE7TFXZX5K71VFXQ823KDKA5PY) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u8) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u9) 'SP3HTFPB135F5ZSAYYXR8JWNZKAE8X195KD1FAVYG))
      (map-set token-count 'SP3HTFPB135F5ZSAYYXR8JWNZKAE8X195KD1FAVYG (+ (get-balance 'SP3HTFPB135F5ZSAYYXR8JWNZKAE8X195KD1FAVYG) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u10) 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS))
      (map-set token-count 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS (+ (get-balance 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u11) 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ))
      (map-set token-count 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ (+ (get-balance 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u12) 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN))
      (map-set token-count 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN (+ (get-balance 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u13) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u14) 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX))
      (map-set token-count 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX (+ (get-balance 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u15) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u16) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u17) 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX))
      (map-set token-count 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX (+ (get-balance 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u18) 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S))
      (map-set token-count 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S (+ (get-balance 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u19) 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP))
      (map-set token-count 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP (+ (get-balance 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u20) 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85))
      (map-set token-count 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 (+ (get-balance 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u21) 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C))
      (map-set token-count 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C (+ (get-balance 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u22) 'SP23B41ZYGNSJ22JCWJJ4P39KQC5RW10E1R4Q8PJW))
      (map-set token-count 'SP23B41ZYGNSJ22JCWJJ4P39KQC5RW10E1R4Q8PJW (+ (get-balance 'SP23B41ZYGNSJ22JCWJJ4P39KQC5RW10E1R4Q8PJW) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u23) 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR))
      (map-set token-count 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR (+ (get-balance 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u24) 'SP1TS6MC7DTJ538F6F4F6ZB2K376DT1GTTY552FCW))
      (map-set token-count 'SP1TS6MC7DTJ538F6F4F6ZB2K376DT1GTTY552FCW (+ (get-balance 'SP1TS6MC7DTJ538F6F4F6ZB2K376DT1GTTY552FCW) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u25) 'SP1C5N37KPVY75A42VKVFD10V8N04TA0YFNEGQET1))
      (map-set token-count 'SP1C5N37KPVY75A42VKVFD10V8N04TA0YFNEGQET1 (+ (get-balance 'SP1C5N37KPVY75A42VKVFD10V8N04TA0YFNEGQET1) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u26) 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV))
      (map-set token-count 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV (+ (get-balance 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u27) 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191))
      (map-set token-count 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191 (+ (get-balance 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u28) 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ))
      (map-set token-count 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ (+ (get-balance 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u29) 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P))
      (map-set token-count 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P (+ (get-balance 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u30) 'SP2C8P3MM137K1A48D1SRENG67KHEVPZV4K36G3JY))
      (map-set token-count 'SP2C8P3MM137K1A48D1SRENG67KHEVPZV4K36G3JY (+ (get-balance 'SP2C8P3MM137K1A48D1SRENG67KHEVPZV4K36G3JY) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u31) 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV))
      (map-set token-count 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV (+ (get-balance 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u32) 'SP36WZAANJF0DBV7D7487SMAX8TJ1EEGKMTX1ZRV6))
      (map-set token-count 'SP36WZAANJF0DBV7D7487SMAX8TJ1EEGKMTX1ZRV6 (+ (get-balance 'SP36WZAANJF0DBV7D7487SMAX8TJ1EEGKMTX1ZRV6) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u33) 'SPV9HNVRJ6833QJVN3KD9T1FSXRJSN842M9PJ02V))
      (map-set token-count 'SPV9HNVRJ6833QJVN3KD9T1FSXRJSN842M9PJ02V (+ (get-balance 'SPV9HNVRJ6833QJVN3KD9T1FSXRJSN842M9PJ02V) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u34) 'SP1YT6QRRHPGJVDKQY89MSGGFHYAETD4FKVTBRH1P))
      (map-set token-count 'SP1YT6QRRHPGJVDKQY89MSGGFHYAETD4FKVTBRH1P (+ (get-balance 'SP1YT6QRRHPGJVDKQY89MSGGFHYAETD4FKVTBRH1P) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u35) 'SP1YBP35K01SG2G8NG7NHSDXFSVEAKWKFEHF09PMG))
      (map-set token-count 'SP1YBP35K01SG2G8NG7NHSDXFSVEAKWKFEHF09PMG (+ (get-balance 'SP1YBP35K01SG2G8NG7NHSDXFSVEAKWKFEHF09PMG) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u36) 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ))
      (map-set token-count 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ (+ (get-balance 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u37) 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX))
      (map-set token-count 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX (+ (get-balance 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u38) 'SP3N2Y4A98AQZBDPDG4A73CZVMBNKGDHTXNN9JP06))
      (map-set token-count 'SP3N2Y4A98AQZBDPDG4A73CZVMBNKGDHTXNN9JP06 (+ (get-balance 'SP3N2Y4A98AQZBDPDG4A73CZVMBNKGDHTXNN9JP06) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u39) 'SP1YXXHFWESW7GY7CRT2RB98WEMHSXKDPBQ7EXN1R))
      (map-set token-count 'SP1YXXHFWESW7GY7CRT2RB98WEMHSXKDPBQ7EXN1R (+ (get-balance 'SP1YXXHFWESW7GY7CRT2RB98WEMHSXKDPBQ7EXN1R) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u40) 'SP3WHR1CECQPMJE7KZ4X2CNYSYRXA00KSR8SYTXCS))
      (map-set token-count 'SP3WHR1CECQPMJE7KZ4X2CNYSYRXA00KSR8SYTXCS (+ (get-balance 'SP3WHR1CECQPMJE7KZ4X2CNYSYRXA00KSR8SYTXCS) u1))
      (try! (nft-mint? stacks-parrots-proof-of-phoenix (+ last-nft-id u41) 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ))
      (map-set token-count 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ (+ (get-balance 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ) u1))

      (var-set last-id (+ last-nft-id u42))
      (var-set airdrop-called true)
      (ok true))))