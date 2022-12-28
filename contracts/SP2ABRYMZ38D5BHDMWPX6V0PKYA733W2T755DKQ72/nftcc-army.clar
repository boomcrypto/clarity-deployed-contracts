;; nftcc-army
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token nftcc-army uint)

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
(define-data-var mint-limit uint u156)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP2ABRYMZ38D5BHDMWPX6V0PKYA733W2T755DKQ72)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmeaDM33gRy93247XPNUdfYSEAjTc1hib4A2HupjtKpcBi/json/")
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
      (unwrap! (nft-mint? nftcc-army next-id tx-sender) next-id)
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
    (nft-burn? nftcc-army token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? nftcc-army token-id) false)))

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
  (ok (nft-get-owner? nftcc-army token-id)))

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
  (match (nft-transfer? nftcc-army id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? nftcc-army id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? nftcc-army id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? nftcc-army (+ last-nft-id u0) 'SPYR6A6GHM79DQH41F1Q2717AAGSF131FXE8TW32))
      (map-set token-count 'SPYR6A6GHM79DQH41F1Q2717AAGSF131FXE8TW32 (+ (get-balance 'SPYR6A6GHM79DQH41F1Q2717AAGSF131FXE8TW32) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u1) 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG))
      (map-set token-count 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG (+ (get-balance 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u2) 'SP2S872HVH23Q1M1VQ6Z55VM11V8Z7YG8V3TZTR96))
      (map-set token-count 'SP2S872HVH23Q1M1VQ6Z55VM11V8Z7YG8V3TZTR96 (+ (get-balance 'SP2S872HVH23Q1M1VQ6Z55VM11V8Z7YG8V3TZTR96) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u3) 'SP6K8CTMC52XBCNG9TRCF3JBE76S2BFYS985DANQ))
      (map-set token-count 'SP6K8CTMC52XBCNG9TRCF3JBE76S2BFYS985DANQ (+ (get-balance 'SP6K8CTMC52XBCNG9TRCF3JBE76S2BFYS985DANQ) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u4) 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK))
      (map-set token-count 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK (+ (get-balance 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u5) 'SP643H4YMDRDNAE89EHY4B65S9K047XWX3QNW3W9))
      (map-set token-count 'SP643H4YMDRDNAE89EHY4B65S9K047XWX3QNW3W9 (+ (get-balance 'SP643H4YMDRDNAE89EHY4B65S9K047XWX3QNW3W9) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u6) 'SP26C9TWJYK6DTCD4T6HKBC76DPMK2DXXRNWS3E2D))
      (map-set token-count 'SP26C9TWJYK6DTCD4T6HKBC76DPMK2DXXRNWS3E2D (+ (get-balance 'SP26C9TWJYK6DTCD4T6HKBC76DPMK2DXXRNWS3E2D) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u7) 'SP2ZRVGFW8QYW9HXTMEABGZTPX0PV10E6D7KDNMA))
      (map-set token-count 'SP2ZRVGFW8QYW9HXTMEABGZTPX0PV10E6D7KDNMA (+ (get-balance 'SP2ZRVGFW8QYW9HXTMEABGZTPX0PV10E6D7KDNMA) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u8) 'SP1QJDCZ0J9NRPPPZ9186GGBFQZEZM86VKCE19D4T))
      (map-set token-count 'SP1QJDCZ0J9NRPPPZ9186GGBFQZEZM86VKCE19D4T (+ (get-balance 'SP1QJDCZ0J9NRPPPZ9186GGBFQZEZM86VKCE19D4T) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u9) 'SP2QFXPC7ESM7NVPSP7M7M711VEJFE7GBASSJMRTP))
      (map-set token-count 'SP2QFXPC7ESM7NVPSP7M7M711VEJFE7GBASSJMRTP (+ (get-balance 'SP2QFXPC7ESM7NVPSP7M7M711VEJFE7GBASSJMRTP) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u10) 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP))
      (map-set token-count 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP (+ (get-balance 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u11) 'SP1B8CHAEDJH87WCC78K8BZ1DF4DJG0DTG3FCMSQB))
      (map-set token-count 'SP1B8CHAEDJH87WCC78K8BZ1DF4DJG0DTG3FCMSQB (+ (get-balance 'SP1B8CHAEDJH87WCC78K8BZ1DF4DJG0DTG3FCMSQB) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u12) 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C))
      (map-set token-count 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C (+ (get-balance 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u13) 'SPJ6RD5PYMM75KQNGH588RHE153JMWRMCSWP4Q2H))
      (map-set token-count 'SPJ6RD5PYMM75KQNGH588RHE153JMWRMCSWP4Q2H (+ (get-balance 'SPJ6RD5PYMM75KQNGH588RHE153JMWRMCSWP4Q2H) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u14) 'SP2G4M87CA0AACNS5ZHG0FPGQ77WXERZJE8DGA878))
      (map-set token-count 'SP2G4M87CA0AACNS5ZHG0FPGQ77WXERZJE8DGA878 (+ (get-balance 'SP2G4M87CA0AACNS5ZHG0FPGQ77WXERZJE8DGA878) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u15) 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV))
      (map-set token-count 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV (+ (get-balance 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u16) 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB))
      (map-set token-count 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB (+ (get-balance 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u17) 'SP398XE371G08T84A99TCBD8XKWY3S7VVX6JKJWKY))
      (map-set token-count 'SP398XE371G08T84A99TCBD8XKWY3S7VVX6JKJWKY (+ (get-balance 'SP398XE371G08T84A99TCBD8XKWY3S7VVX6JKJWKY) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u18) 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX))
      (map-set token-count 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX (+ (get-balance 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u19) 'SP384CVPNDTYA0E92TKJZQTYXQHNZSWGCAG7SAPVB))
      (map-set token-count 'SP384CVPNDTYA0E92TKJZQTYXQHNZSWGCAG7SAPVB (+ (get-balance 'SP384CVPNDTYA0E92TKJZQTYXQHNZSWGCAG7SAPVB) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u20) 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X))
      (map-set token-count 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X (+ (get-balance 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u21) 'SP3WVWGYZ9NPFJ44Q0D1MNQ3P1XCQAQ0A1KEFKSQD))
      (map-set token-count 'SP3WVWGYZ9NPFJ44Q0D1MNQ3P1XCQAQ0A1KEFKSQD (+ (get-balance 'SP3WVWGYZ9NPFJ44Q0D1MNQ3P1XCQAQ0A1KEFKSQD) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u22) 'SPSG97KXE3GHAAK2TMFC9VKE9KB0JBM47YY84Y8C))
      (map-set token-count 'SPSG97KXE3GHAAK2TMFC9VKE9KB0JBM47YY84Y8C (+ (get-balance 'SPSG97KXE3GHAAK2TMFC9VKE9KB0JBM47YY84Y8C) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u23) 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG))
      (map-set token-count 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG (+ (get-balance 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u24) 'SPKFSJ4T8T39ZJN455QBY7TJX4DYF47J7344HNNF))
      (map-set token-count 'SPKFSJ4T8T39ZJN455QBY7TJX4DYF47J7344HNNF (+ (get-balance 'SPKFSJ4T8T39ZJN455QBY7TJX4DYF47J7344HNNF) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u25) 'SP265DNHNK1NHX7FE9MZKCCA4G1VS7TT3BMES5TR))
      (map-set token-count 'SP265DNHNK1NHX7FE9MZKCCA4G1VS7TT3BMES5TR (+ (get-balance 'SP265DNHNK1NHX7FE9MZKCCA4G1VS7TT3BMES5TR) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u26) 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ))
      (map-set token-count 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ (+ (get-balance 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u27) 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0))
      (map-set token-count 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0 (+ (get-balance 'SP3AJC728JY0Y43E8RT6K4VDWPT265RDMXJ8M0VH0) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u28) 'SP2H6HVZK6X3Z8F4PKF284AZJR6FH4H9J4W6KVV8T))
      (map-set token-count 'SP2H6HVZK6X3Z8F4PKF284AZJR6FH4H9J4W6KVV8T (+ (get-balance 'SP2H6HVZK6X3Z8F4PKF284AZJR6FH4H9J4W6KVV8T) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u29) 'SP1CQF008B5KJ477RQQQQJAQZZG4B0KHDHMJ4W444))
      (map-set token-count 'SP1CQF008B5KJ477RQQQQJAQZZG4B0KHDHMJ4W444 (+ (get-balance 'SP1CQF008B5KJ477RQQQQJAQZZG4B0KHDHMJ4W444) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u30) 'SPZ5DJGRVZHXEEEYYGWEX84KQB8P69GC715ZRNW1))
      (map-set token-count 'SPZ5DJGRVZHXEEEYYGWEX84KQB8P69GC715ZRNW1 (+ (get-balance 'SPZ5DJGRVZHXEEEYYGWEX84KQB8P69GC715ZRNW1) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u31) 'SP3PPBWF44PSCFN9BPVFZYZD6R8JJNQW0CPDPYB6D))
      (map-set token-count 'SP3PPBWF44PSCFN9BPVFZYZD6R8JJNQW0CPDPYB6D (+ (get-balance 'SP3PPBWF44PSCFN9BPVFZYZD6R8JJNQW0CPDPYB6D) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u32) 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ))
      (map-set token-count 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ (+ (get-balance 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u33) 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA))
      (map-set token-count 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA (+ (get-balance 'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u34) 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0))
      (map-set token-count 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0 (+ (get-balance 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u35) 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN))
      (map-set token-count 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN (+ (get-balance 'SPFZJAWND9GDB2QC54524J73DGBQ07XJ6JM1E3GN) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u36) 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S))
      (map-set token-count 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S (+ (get-balance 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u37) 'SP1RWWPH1DMKVHK22ZHC008T5RARCZMM4GCBA78TX))
      (map-set token-count 'SP1RWWPH1DMKVHK22ZHC008T5RARCZMM4GCBA78TX (+ (get-balance 'SP1RWWPH1DMKVHK22ZHC008T5RARCZMM4GCBA78TX) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u38) 'SPYWT3H4JQG72G0PVZW4E2M6FAK997KN6PDC26GM))
      (map-set token-count 'SPYWT3H4JQG72G0PVZW4E2M6FAK997KN6PDC26GM (+ (get-balance 'SPYWT3H4JQG72G0PVZW4E2M6FAK997KN6PDC26GM) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u39) 'SP1JM5Y9J4T7J5XY9NX34SG1Z1BNAJT4H4NBHTPYD))
      (map-set token-count 'SP1JM5Y9J4T7J5XY9NX34SG1Z1BNAJT4H4NBHTPYD (+ (get-balance 'SP1JM5Y9J4T7J5XY9NX34SG1Z1BNAJT4H4NBHTPYD) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u40) 'SPQ5X8FFGQGAVPX0FJJKB472XMT04TFJCDHFN3DH))
      (map-set token-count 'SPQ5X8FFGQGAVPX0FJJKB472XMT04TFJCDHFN3DH (+ (get-balance 'SPQ5X8FFGQGAVPX0FJJKB472XMT04TFJCDHFN3DH) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u41) 'SP349J1ZTEE71M1J5D4YS0BPQCCFJ3YSNM1P8BJY4))
      (map-set token-count 'SP349J1ZTEE71M1J5D4YS0BPQCCFJ3YSNM1P8BJY4 (+ (get-balance 'SP349J1ZTEE71M1J5D4YS0BPQCCFJ3YSNM1P8BJY4) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u42) 'SPEXAF3YRNCR01Z4DFZ567Z0FB4RKPHM88DMKJSQ))
      (map-set token-count 'SPEXAF3YRNCR01Z4DFZ567Z0FB4RKPHM88DMKJSQ (+ (get-balance 'SPEXAF3YRNCR01Z4DFZ567Z0FB4RKPHM88DMKJSQ) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u43) 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ))
      (map-set token-count 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ (+ (get-balance 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u44) 'SP1XBS03PFDTV1HSD7BY02V6VG16VTNRDP9N1QZAV))
      (map-set token-count 'SP1XBS03PFDTV1HSD7BY02V6VG16VTNRDP9N1QZAV (+ (get-balance 'SP1XBS03PFDTV1HSD7BY02V6VG16VTNRDP9N1QZAV) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u45) 'SP36WZAANJF0DBV7D7487SMAX8TJ1EEGKMTX1ZRV6))
      (map-set token-count 'SP36WZAANJF0DBV7D7487SMAX8TJ1EEGKMTX1ZRV6 (+ (get-balance 'SP36WZAANJF0DBV7D7487SMAX8TJ1EEGKMTX1ZRV6) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u46) 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD))
      (map-set token-count 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD (+ (get-balance 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u47) 'SP3P8PMKMYJQ9V16A6EZW2XHH1P29JN58R31VQ4VJ))
      (map-set token-count 'SP3P8PMKMYJQ9V16A6EZW2XHH1P29JN58R31VQ4VJ (+ (get-balance 'SP3P8PMKMYJQ9V16A6EZW2XHH1P29JN58R31VQ4VJ) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u48) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u49) 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4))
      (map-set token-count 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4 (+ (get-balance 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u50) 'SP25HAV8ZKNE8B7QCT1FPKPD8JQF2KK06VKQE6JSE))
      (map-set token-count 'SP25HAV8ZKNE8B7QCT1FPKPD8JQF2KK06VKQE6JSE (+ (get-balance 'SP25HAV8ZKNE8B7QCT1FPKPD8JQF2KK06VKQE6JSE) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u51) 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ))
      (map-set token-count 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ (+ (get-balance 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u52) 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864))
      (map-set token-count 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864 (+ (get-balance 'SP3RW6BW9F5STYG2K8XS5EP5PM33E0DNQT4XEG864) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u53) 'SP2WPTFTP17PGJM8328QWG3SNV9EZ9W1C7EGTD5BQ))
      (map-set token-count 'SP2WPTFTP17PGJM8328QWG3SNV9EZ9W1C7EGTD5BQ (+ (get-balance 'SP2WPTFTP17PGJM8328QWG3SNV9EZ9W1C7EGTD5BQ) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u54) 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN))
      (map-set token-count 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN (+ (get-balance 'SP3273YEPG4QZWX0ENQ98FBT1N2Y06XW820STP7NN) u1))
      (try! (nft-mint? nftcc-army (+ last-nft-id u55) 'SP1TVCFTMQ6SXX08DSQ7ECZ7XKSF00RWPNYQM43T1))
      (map-set token-count 'SP1TVCFTMQ6SXX08DSQ7ECZ7XKSF00RWPNYQM43T1 (+ (get-balance 'SP1TVCFTMQ6SXX08DSQ7ECZ7XKSF00RWPNYQM43T1) u1))

      (var-set last-id (+ last-nft-id u56))
      (var-set airdrop-called true)
      (ok true))))