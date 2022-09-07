;; gamma-proof-of-work-collection
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token gamma-proof-of-work-collection uint)

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
(define-data-var mint-limit uint u52)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmXZMf8FxddMcnJFDXM9QLnG6xgcccbAT6RKkQcscMAqHm/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u1)

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
      (unwrap! (nft-mint? gamma-proof-of-work-collection next-id tx-sender) next-id)
      (unwrap! (nft-transfer? gamma-proof-of-work-collection next-id tx-sender recipient) next-id)
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
      (unwrap! (nft-mint? gamma-proof-of-work-collection next-id tx-sender) next-id)
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
    (nft-burn? gamma-proof-of-work-collection token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? gamma-proof-of-work-collection token-id) false)))

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
  (ok (nft-get-owner? gamma-proof-of-work-collection token-id)))

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
  (match (nft-transfer? gamma-proof-of-work-collection id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? gamma-proof-of-work-collection id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? gamma-proof-of-work-collection id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u0) 'SP7QA77Z81S81S85Q7B555S80G1S23Y2YPHT10BA))
      (map-set token-count 'SP7QA77Z81S81S85Q7B555S80G1S23Y2YPHT10BA (+ (get-balance 'SP7QA77Z81S81S85Q7B555S80G1S23Y2YPHT10BA) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u1) 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80))
      (map-set token-count 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80 (+ (get-balance 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u2) 'SP1YXXHFWESW7GY7CRT2RB98WEMHSXKDPBQ7EXN1R))
      (map-set token-count 'SP1YXXHFWESW7GY7CRT2RB98WEMHSXKDPBQ7EXN1R (+ (get-balance 'SP1YXXHFWESW7GY7CRT2RB98WEMHSXKDPBQ7EXN1R) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u3) 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY))
      (map-set token-count 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY (+ (get-balance 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u4) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u5) 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79))
      (map-set token-count 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79 (+ (get-balance 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u6) 'SP15GZEM23JBZ9D5BWXDKPT73CYR3QDH15KT81GC7))
      (map-set token-count 'SP15GZEM23JBZ9D5BWXDKPT73CYR3QDH15KT81GC7 (+ (get-balance 'SP15GZEM23JBZ9D5BWXDKPT73CYR3QDH15KT81GC7) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u7) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u8) 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0))
      (map-set token-count 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0 (+ (get-balance 'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u9) 'SP1VH4R8R3ASSW377GRRB8DK71416ZC3EEEPY140R))
      (map-set token-count 'SP1VH4R8R3ASSW377GRRB8DK71416ZC3EEEPY140R (+ (get-balance 'SP1VH4R8R3ASSW377GRRB8DK71416ZC3EEEPY140R) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u10) 'SP2EWA4BE511DK2KKK71YF1NHFM5NZR3Y2Z1091R1))
      (map-set token-count 'SP2EWA4BE511DK2KKK71YF1NHFM5NZR3Y2Z1091R1 (+ (get-balance 'SP2EWA4BE511DK2KKK71YF1NHFM5NZR3Y2Z1091R1) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u11) 'SPBKDDN9PDGCXKZN3FZQ7FMV47RG8Y4MP6QTPJJ3))
      (map-set token-count 'SPBKDDN9PDGCXKZN3FZQ7FMV47RG8Y4MP6QTPJJ3 (+ (get-balance 'SPBKDDN9PDGCXKZN3FZQ7FMV47RG8Y4MP6QTPJJ3) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u12) 'SP3F50PNGA4PY5PVB590SKY4WE8NHZEYQKRDBSJX8))
      (map-set token-count 'SP3F50PNGA4PY5PVB590SKY4WE8NHZEYQKRDBSJX8 (+ (get-balance 'SP3F50PNGA4PY5PVB590SKY4WE8NHZEYQKRDBSJX8) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u13) 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ))
      (map-set token-count 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ (+ (get-balance 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u14) 'SP3PEK3FAGYAR6H2F9472KVRQAEFK5M2JPWM7GNFF))
      (map-set token-count 'SP3PEK3FAGYAR6H2F9472KVRQAEFK5M2JPWM7GNFF (+ (get-balance 'SP3PEK3FAGYAR6H2F9472KVRQAEFK5M2JPWM7GNFF) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u15) 'SP2QE60HPRY41A767SFT0189KV8JT1MZNFK0BQ3QX))
      (map-set token-count 'SP2QE60HPRY41A767SFT0189KV8JT1MZNFK0BQ3QX (+ (get-balance 'SP2QE60HPRY41A767SFT0189KV8JT1MZNFK0BQ3QX) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u16) 'SP3FNYX415NC2NBVEK2GQ3K22SV7BAQEQXX1AE1RC))
      (map-set token-count 'SP3FNYX415NC2NBVEK2GQ3K22SV7BAQEQXX1AE1RC (+ (get-balance 'SP3FNYX415NC2NBVEK2GQ3K22SV7BAQEQXX1AE1RC) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u17) 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7))
      (map-set token-count 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7 (+ (get-balance 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u18) 'SP3XMYSS7VHPQV9YP2083D3VN8VDH8ZYZYD7XAR6E))
      (map-set token-count 'SP3XMYSS7VHPQV9YP2083D3VN8VDH8ZYZYD7XAR6E (+ (get-balance 'SP3XMYSS7VHPQV9YP2083D3VN8VDH8ZYZYD7XAR6E) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u19) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u20) 'SP31C9QV5F4XE9E5WHFKD9MZZJ05EJKA0S1G3Z3WQ))
      (map-set token-count 'SP31C9QV5F4XE9E5WHFKD9MZZJ05EJKA0S1G3Z3WQ (+ (get-balance 'SP31C9QV5F4XE9E5WHFKD9MZZJ05EJKA0S1G3Z3WQ) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u21) 'SP3M2TWQGB7YWRGZW17XSE3FCESR0EZMGB9H3KRDC))
      (map-set token-count 'SP3M2TWQGB7YWRGZW17XSE3FCESR0EZMGB9H3KRDC (+ (get-balance 'SP3M2TWQGB7YWRGZW17XSE3FCESR0EZMGB9H3KRDC) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u22) 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B))
      (map-set token-count 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B (+ (get-balance 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u23) 'SP2WT2BB1N78J5EXJNG8NFD4JJV8YRB5WT6AM4QAN))
      (map-set token-count 'SP2WT2BB1N78J5EXJNG8NFD4JJV8YRB5WT6AM4QAN (+ (get-balance 'SP2WT2BB1N78J5EXJNG8NFD4JJV8YRB5WT6AM4QAN) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u24) 'SPK75AE4F1N16SDBG8RHHRGXZJGF96F6SFRXBZ6X))
      (map-set token-count 'SPK75AE4F1N16SDBG8RHHRGXZJGF96F6SFRXBZ6X (+ (get-balance 'SPK75AE4F1N16SDBG8RHHRGXZJGF96F6SFRXBZ6X) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u25) 'SP1V19KW8DVQ5D8YPBVHBF9NZXWMC0Q4FGG7S9NRY))
      (map-set token-count 'SP1V19KW8DVQ5D8YPBVHBF9NZXWMC0Q4FGG7S9NRY (+ (get-balance 'SP1V19KW8DVQ5D8YPBVHBF9NZXWMC0Q4FGG7S9NRY) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u26) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u27) 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA))
      (map-set token-count 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA (+ (get-balance 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u28) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u29) 'SP2Z6ZF8M20P1RYFJW0NJFGMMVXM2BQQHKPVBDF9))
      (map-set token-count 'SP2Z6ZF8M20P1RYFJW0NJFGMMVXM2BQQHKPVBDF9 (+ (get-balance 'SP2Z6ZF8M20P1RYFJW0NJFGMMVXM2BQQHKPVBDF9) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u30) 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ))
      (map-set token-count 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ (+ (get-balance 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u31) 'SP1Y8DR7H1Q2GH83E9APMGSH4F5JM00956Z8KRQYA))
      (map-set token-count 'SP1Y8DR7H1Q2GH83E9APMGSH4F5JM00956Z8KRQYA (+ (get-balance 'SP1Y8DR7H1Q2GH83E9APMGSH4F5JM00956Z8KRQYA) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u32) 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227))
      (map-set token-count 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227 (+ (get-balance 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u33) 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W))
      (map-set token-count 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W (+ (get-balance 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u34) 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X))
      (map-set token-count 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X (+ (get-balance 'SP26GZCVY8FYHNZ6C73W68TCFJHS8F8C9E772XX7X) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u35) 'SPH0Y9NJWT9CJWRKY7ETZJ1E7GB15P24EBPZ9AB7))
      (map-set token-count 'SPH0Y9NJWT9CJWRKY7ETZJ1E7GB15P24EBPZ9AB7 (+ (get-balance 'SPH0Y9NJWT9CJWRKY7ETZJ1E7GB15P24EBPZ9AB7) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u36) 'SP20KN42AACFTQ8WEN6S75PABF9V6MM0FQNYWSYR4))
      (map-set token-count 'SP20KN42AACFTQ8WEN6S75PABF9V6MM0FQNYWSYR4 (+ (get-balance 'SP20KN42AACFTQ8WEN6S75PABF9V6MM0FQNYWSYR4) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u37) 'SP2F0DP9Z3KSS0DABDBJN0DA0SHMCVWHXPVTH3PJJ))
      (map-set token-count 'SP2F0DP9Z3KSS0DABDBJN0DA0SHMCVWHXPVTH3PJJ (+ (get-balance 'SP2F0DP9Z3KSS0DABDBJN0DA0SHMCVWHXPVTH3PJJ) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u38) 'SP1B0RHX29DPRTDYNTF2RG4MH32ARMD6T9V3QC03K))
      (map-set token-count 'SP1B0RHX29DPRTDYNTF2RG4MH32ARMD6T9V3QC03K (+ (get-balance 'SP1B0RHX29DPRTDYNTF2RG4MH32ARMD6T9V3QC03K) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u39) 'SP1FKP2KHZKXSPY7ZFMXBCZS19E149T2S936EJYVJ))
      (map-set token-count 'SP1FKP2KHZKXSPY7ZFMXBCZS19E149T2S936EJYVJ (+ (get-balance 'SP1FKP2KHZKXSPY7ZFMXBCZS19E149T2S936EJYVJ) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u40) 'SPQS1J3X9FJ6N4E9K2MW81W5DNBSCC8ZPHR6K2YA))
      (map-set token-count 'SPQS1J3X9FJ6N4E9K2MW81W5DNBSCC8ZPHR6K2YA (+ (get-balance 'SPQS1J3X9FJ6N4E9K2MW81W5DNBSCC8ZPHR6K2YA) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u41) 'SP1WP1GYZV50CRGV6T6AJ5408XV68VSS1WQNRMBXZ))
      (map-set token-count 'SP1WP1GYZV50CRGV6T6AJ5408XV68VSS1WQNRMBXZ (+ (get-balance 'SP1WP1GYZV50CRGV6T6AJ5408XV68VSS1WQNRMBXZ) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u42) 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C))
      (map-set token-count 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C (+ (get-balance 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u43) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u44) 'SP1B4BM1VQB6JYKG43DEKD7ZDRQMRDH4E1TQBKFGX))
      (map-set token-count 'SP1B4BM1VQB6JYKG43DEKD7ZDRQMRDH4E1TQBKFGX (+ (get-balance 'SP1B4BM1VQB6JYKG43DEKD7ZDRQMRDH4E1TQBKFGX) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u45) 'SP3GE33M9QNY3JJH8RWTK6AYD0NXHDDR77Q80HDV6))
      (map-set token-count 'SP3GE33M9QNY3JJH8RWTK6AYD0NXHDDR77Q80HDV6 (+ (get-balance 'SP3GE33M9QNY3JJH8RWTK6AYD0NXHDDR77Q80HDV6) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u46) 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW))
      (map-set token-count 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW (+ (get-balance 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u47) 'SP2966ET85MQR187H8EA4S4YMVCFR2MKZ2F40JQ5))
      (map-set token-count 'SP2966ET85MQR187H8EA4S4YMVCFR2MKZ2F40JQ5 (+ (get-balance 'SP2966ET85MQR187H8EA4S4YMVCFR2MKZ2F40JQ5) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u48) 'SP27X9FMFCMV3B4QZWFY218XHE7E3N7T9BYPY56SM))
      (map-set token-count 'SP27X9FMFCMV3B4QZWFY218XHE7E3N7T9BYPY56SM (+ (get-balance 'SP27X9FMFCMV3B4QZWFY218XHE7E3N7T9BYPY56SM) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u49) 'SP1JA97VDAWN7TSZQHR8AZ7R2D1RD7J4KKZMNKTMH))
      (map-set token-count 'SP1JA97VDAWN7TSZQHR8AZ7R2D1RD7J4KKZMNKTMH (+ (get-balance 'SP1JA97VDAWN7TSZQHR8AZ7R2D1RD7J4KKZMNKTMH) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u50) 'SPK88MYKSGS44GTKR8ZN8G51V40FTR2RY245S401))
      (map-set token-count 'SPK88MYKSGS44GTKR8ZN8G51V40FTR2RY245S401 (+ (get-balance 'SPK88MYKSGS44GTKR8ZN8G51V40FTR2RY245S401) u1))
      (try! (nft-mint? gamma-proof-of-work-collection (+ last-nft-id u51) 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20))
      (map-set token-count 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 (+ (get-balance 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20) u1))

      (var-set last-id (+ last-nft-id u52))
      (var-set airdrop-called true)
      (ok true))))