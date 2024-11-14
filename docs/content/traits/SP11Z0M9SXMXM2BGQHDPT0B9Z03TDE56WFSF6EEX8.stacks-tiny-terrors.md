---
title: "Trait stacks-tiny-terrors"
draft: true
---
```
;; stacks-tiny-terrors
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token stacks-tiny-terrors uint)

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
(define-data-var mint-limit uint u444)
(define-data-var last-id uint u1)
(define-data-var total-price uint u5000000)
(define-data-var artist-address principal 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmWsYRcmUmpijvGDHnC78LcxexhjWfqvMyJSDHE2U6eShZ/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u69)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-six) (mint (list true true true true true true)))

(define-public (claim-nine) (mint (list true true true true true true true true true)))

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
      (unwrap! (nft-mint? stacks-tiny-terrors next-id tx-sender) next-id)
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
    (nft-burn? stacks-tiny-terrors token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? stacks-tiny-terrors token-id) false)))

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
  (ok (nft-get-owner? stacks-tiny-terrors token-id)))

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
  (match (nft-transfer? stacks-tiny-terrors id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? stacks-tiny-terrors id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? stacks-tiny-terrors id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u0) 'SP3PSRA8PV42GEB8K70CESKHPZFG9MRB4FZANS2KA))
      (map-set token-count 'SP3PSRA8PV42GEB8K70CESKHPZFG9MRB4FZANS2KA (+ (get-balance 'SP3PSRA8PV42GEB8K70CESKHPZFG9MRB4FZANS2KA) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u1) 'SPQR4T6XTFY0H9KDF0912KEVJMW20JTDZSRSM7SB))
      (map-set token-count 'SPQR4T6XTFY0H9KDF0912KEVJMW20JTDZSRSM7SB (+ (get-balance 'SPQR4T6XTFY0H9KDF0912KEVJMW20JTDZSRSM7SB) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u2) 'SPDB8P0BAN4FGBEPGXSKX388YK2228NER7BQEXCN))
      (map-set token-count 'SPDB8P0BAN4FGBEPGXSKX388YK2228NER7BQEXCN (+ (get-balance 'SPDB8P0BAN4FGBEPGXSKX388YK2228NER7BQEXCN) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u3) 'SP30VW9FV7R36VY7D5Z4A3HYDWA13EAGHQQ5DSJD5))
      (map-set token-count 'SP30VW9FV7R36VY7D5Z4A3HYDWA13EAGHQQ5DSJD5 (+ (get-balance 'SP30VW9FV7R36VY7D5Z4A3HYDWA13EAGHQQ5DSJD5) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u4) 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY))
      (map-set token-count 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY (+ (get-balance 'SP2J6Y09JMFWWZCT4VJX0BA5W7A9HZP5EX96Y6VZY) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u5) 'SP1WCJ02AAPKMXPK81KFKGJ7MJDET11FPQG1RHB0S))
      (map-set token-count 'SP1WCJ02AAPKMXPK81KFKGJ7MJDET11FPQG1RHB0S (+ (get-balance 'SP1WCJ02AAPKMXPK81KFKGJ7MJDET11FPQG1RHB0S) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u6) 'SP2V42A0NYSA3ZBT1KJ6GFV14F5A3WWNYP969HHVB))
      (map-set token-count 'SP2V42A0NYSA3ZBT1KJ6GFV14F5A3WWNYP969HHVB (+ (get-balance 'SP2V42A0NYSA3ZBT1KJ6GFV14F5A3WWNYP969HHVB) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u7) 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75))
      (map-set token-count 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75 (+ (get-balance 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u8) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u9) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u10) 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8))
      (map-set token-count 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8 (+ (get-balance 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u11) 'SP2ZXDBYT1RSP98ZZXXRDGKX3TMXCCCGERNBD5YMY))
      (map-set token-count 'SP2ZXDBYT1RSP98ZZXXRDGKX3TMXCCCGERNBD5YMY (+ (get-balance 'SP2ZXDBYT1RSP98ZZXXRDGKX3TMXCCCGERNBD5YMY) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u12) 'SP2HNR813RVPNSSA4P0DJ0D6GP0ET5J53HKED5BMW))
      (map-set token-count 'SP2HNR813RVPNSSA4P0DJ0D6GP0ET5J53HKED5BMW (+ (get-balance 'SP2HNR813RVPNSSA4P0DJ0D6GP0ET5J53HKED5BMW) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u13) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u14) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u15) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u16) 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8))
      (map-set token-count 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8 (+ (get-balance 'SP11Z0M9SXMXM2BGQHDPT0B9Z03TDE56WFSF6EEX8) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u17) 'SP870RFTKDBMC8WJ9CE89ZKVEJBGF57ZAV3T87Z1))
      (map-set token-count 'SP870RFTKDBMC8WJ9CE89ZKVEJBGF57ZAV3T87Z1 (+ (get-balance 'SP870RFTKDBMC8WJ9CE89ZKVEJBGF57ZAV3T87Z1) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u18) 'SP2GV9G7QQW86A3K7ZZWKC3A0608YHNKNYSQCGJVM))
      (map-set token-count 'SP2GV9G7QQW86A3K7ZZWKC3A0608YHNKNYSQCGJVM (+ (get-balance 'SP2GV9G7QQW86A3K7ZZWKC3A0608YHNKNYSQCGJVM) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u19) 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7))
      (map-set token-count 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7 (+ (get-balance 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u20) 'SP177JV93RYPWWTX5F0MK9NVQ3YTXB4YQZGBPP6H4))
      (map-set token-count 'SP177JV93RYPWWTX5F0MK9NVQ3YTXB4YQZGBPP6H4 (+ (get-balance 'SP177JV93RYPWWTX5F0MK9NVQ3YTXB4YQZGBPP6H4) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u21) 'SPWJ4BEX6W11B953S7635M93PGW4SGG1KAEPJ690))
      (map-set token-count 'SPWJ4BEX6W11B953S7635M93PGW4SGG1KAEPJ690 (+ (get-balance 'SPWJ4BEX6W11B953S7635M93PGW4SGG1KAEPJ690) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u22) 'SP1EMXT9RET8W5TXQ325BG3TJ6X15NXV5GKEGVQE6))
      (map-set token-count 'SP1EMXT9RET8W5TXQ325BG3TJ6X15NXV5GKEGVQE6 (+ (get-balance 'SP1EMXT9RET8W5TXQ325BG3TJ6X15NXV5GKEGVQE6) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u23) 'SP2APSACXGB1F89Q06CK20FJGV5A3WWP55VTMHX8H))
      (map-set token-count 'SP2APSACXGB1F89Q06CK20FJGV5A3WWP55VTMHX8H (+ (get-balance 'SP2APSACXGB1F89Q06CK20FJGV5A3WWP55VTMHX8H) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u24) 'SP2T14SW2NQ3A5B1C038CRWA206ZGDN52QKW139EG))
      (map-set token-count 'SP2T14SW2NQ3A5B1C038CRWA206ZGDN52QKW139EG (+ (get-balance 'SP2T14SW2NQ3A5B1C038CRWA206ZGDN52QKW139EG) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u25) 'SP3AFSKPE2BQ84WXEZ03PQ2E18B02A8ZZWK6190KW))
      (map-set token-count 'SP3AFSKPE2BQ84WXEZ03PQ2E18B02A8ZZWK6190KW (+ (get-balance 'SP3AFSKPE2BQ84WXEZ03PQ2E18B02A8ZZWK6190KW) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u26) 'SP3RNGGB8R14DXRTQW6290ZV4R7P7Z6PW7TDM7ES0))
      (map-set token-count 'SP3RNGGB8R14DXRTQW6290ZV4R7P7Z6PW7TDM7ES0 (+ (get-balance 'SP3RNGGB8R14DXRTQW6290ZV4R7P7Z6PW7TDM7ES0) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u27) 'SP35CYK4JMN5HEHNEB6DJXV93V0AHE0WRDZ4WH9HA))
      (map-set token-count 'SP35CYK4JMN5HEHNEB6DJXV93V0AHE0WRDZ4WH9HA (+ (get-balance 'SP35CYK4JMN5HEHNEB6DJXV93V0AHE0WRDZ4WH9HA) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u28) 'SP1TC21ASZ57YQFC9THB85HSMDH6P1BNVPACWATRB))
      (map-set token-count 'SP1TC21ASZ57YQFC9THB85HSMDH6P1BNVPACWATRB (+ (get-balance 'SP1TC21ASZ57YQFC9THB85HSMDH6P1BNVPACWATRB) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u29) 'SP22B8YVKK20Y53B2XZQVP84C9WM2SZ91K8EMSY4T))
      (map-set token-count 'SP22B8YVKK20Y53B2XZQVP84C9WM2SZ91K8EMSY4T (+ (get-balance 'SP22B8YVKK20Y53B2XZQVP84C9WM2SZ91K8EMSY4T) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u30) 'SP2KQZN2BDCM34GH94FP2W3312BYYV42P3CRJMTPZ))
      (map-set token-count 'SP2KQZN2BDCM34GH94FP2W3312BYYV42P3CRJMTPZ (+ (get-balance 'SP2KQZN2BDCM34GH94FP2W3312BYYV42P3CRJMTPZ) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u31) 'SP250T71VBB3HR5GDY4D0K3JXPF46YMTZJ1AJAJ1T))
      (map-set token-count 'SP250T71VBB3HR5GDY4D0K3JXPF46YMTZJ1AJAJ1T (+ (get-balance 'SP250T71VBB3HR5GDY4D0K3JXPF46YMTZJ1AJAJ1T) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u32) 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8))
      (map-set token-count 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8 (+ (get-balance 'SPSQ4W56BY5XKZR8YJMXYP1CKJ64TT4CQ04GFQT8) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u33) 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C))
      (map-set token-count 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C (+ (get-balance 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u34) 'SP1MWNNY8VC8T5NTPYBB3EH9V3KHH140QWJDSCEFH))
      (map-set token-count 'SP1MWNNY8VC8T5NTPYBB3EH9V3KHH140QWJDSCEFH (+ (get-balance 'SP1MWNNY8VC8T5NTPYBB3EH9V3KHH140QWJDSCEFH) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u35) 'SP236BC8GENYXZYDT2R7905F9871VBNKCH28QM079))
      (map-set token-count 'SP236BC8GENYXZYDT2R7905F9871VBNKCH28QM079 (+ (get-balance 'SP236BC8GENYXZYDT2R7905F9871VBNKCH28QM079) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u36) 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93))
      (map-set token-count 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93 (+ (get-balance 'SPXW8BXG2S88SX7C1CJ3BVFEGR51SFGRF8DMYC93) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u37) 'SP2QH5QETSYAZ2VGQAZ42AK3ZN15EF4R3P76XDAR2))
      (map-set token-count 'SP2QH5QETSYAZ2VGQAZ42AK3ZN15EF4R3P76XDAR2 (+ (get-balance 'SP2QH5QETSYAZ2VGQAZ42AK3ZN15EF4R3P76XDAR2) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u38) 'SPFFPBH1JDV47KER3TBK8W87QQARAE47YVFTA3NQ))
      (map-set token-count 'SPFFPBH1JDV47KER3TBK8W87QQARAE47YVFTA3NQ (+ (get-balance 'SPFFPBH1JDV47KER3TBK8W87QQARAE47YVFTA3NQ) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u39) 'SP2H8CEZRSK22DR7APBSZ689SBKCQ6NXKWWFKA6E9))
      (map-set token-count 'SP2H8CEZRSK22DR7APBSZ689SBKCQ6NXKWWFKA6E9 (+ (get-balance 'SP2H8CEZRSK22DR7APBSZ689SBKCQ6NXKWWFKA6E9) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u40) 'SPM2JZ5R7M6AZQTXKEM94K63E2CN95TT6AMMA5PP))
      (map-set token-count 'SPM2JZ5R7M6AZQTXKEM94K63E2CN95TT6AMMA5PP (+ (get-balance 'SPM2JZ5R7M6AZQTXKEM94K63E2CN95TT6AMMA5PP) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u41) 'SPG6CHDSFHSXQ3ESBBF2MEDS42GH131SRH6JGFQA))
      (map-set token-count 'SPG6CHDSFHSXQ3ESBBF2MEDS42GH131SRH6JGFQA (+ (get-balance 'SPG6CHDSFHSXQ3ESBBF2MEDS42GH131SRH6JGFQA) u1))
      (try! (nft-mint? stacks-tiny-terrors (+ last-nft-id u42) 'SP1XN5RY49QDBB1HKYN7YDFB477XTAN5777S4P3QY))
      (map-set token-count 'SP1XN5RY49QDBB1HKYN7YDFB477XTAN5777S4P3QY (+ (get-balance 'SP1XN5RY49QDBB1HKYN7YDFB477XTAN5777S4P3QY) u1))

      (var-set last-id (+ last-nft-id u43))
      (var-set airdrop-called true)
      (ok true))))
```
