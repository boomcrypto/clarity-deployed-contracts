;; war-worms
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token war-worms uint)

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
(define-data-var mint-limit uint u2000)
(define-data-var last-id uint u1)
(define-data-var total-price uint u5000000)
(define-data-var artist-address principal 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmPuk1j3njM93JUhYvZCwDzLfkHoVL8wxt6UoksHmdpRy7/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u1000)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-six) (mint (list true true true true true true)))

(define-public (claim-seven) (mint (list true true true true true true true)))

(define-public (claim-eight) (mint (list true true true true true true true true)))

(define-public (claim-nine) (mint (list true true true true true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-fifteen) (mint (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty) (mint (list true true true true true true true true true true true true true true true true true true true true)))

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
      (unwrap! (nft-mint? war-worms next-id tx-sender) next-id)
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
    (nft-burn? war-worms token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? war-worms token-id) false)))

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
  (ok (nft-get-owner? war-worms token-id)))

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

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/0")
(define-data-var license-name (string-ascii 40) "PUBLIC")

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
  (match (nft-transfer? war-worms id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? war-worms id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? war-worms id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? war-worms (+ last-nft-id u0) 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H))
      (map-set token-count 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H (+ (get-balance 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u1) 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H))
      (map-set token-count 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H (+ (get-balance 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u2) 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H))
      (map-set token-count 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H (+ (get-balance 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u3) 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H))
      (map-set token-count 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H (+ (get-balance 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u4) 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H))
      (map-set token-count 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H (+ (get-balance 'SPD13CVTWS99F00S7G61ZYWTZB5EMJD4TP62V83H) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u5) 'SP32ZZ5875W7MKZ17B1JJC5R6Y6ZHYHCGBV4V3JK9))
      (map-set token-count 'SP32ZZ5875W7MKZ17B1JJC5R6Y6ZHYHCGBV4V3JK9 (+ (get-balance 'SP32ZZ5875W7MKZ17B1JJC5R6Y6ZHYHCGBV4V3JK9) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u6) 'SP32ZZ5875W7MKZ17B1JJC5R6Y6ZHYHCGBV4V3JK9))
      (map-set token-count 'SP32ZZ5875W7MKZ17B1JJC5R6Y6ZHYHCGBV4V3JK9 (+ (get-balance 'SP32ZZ5875W7MKZ17B1JJC5R6Y6ZHYHCGBV4V3JK9) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u7) 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN))
      (map-set token-count 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN (+ (get-balance 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u8) 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN))
      (map-set token-count 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN (+ (get-balance 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u9) 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN))
      (map-set token-count 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN (+ (get-balance 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u10) 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN))
      (map-set token-count 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN (+ (get-balance 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u11) 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN))
      (map-set token-count 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN (+ (get-balance 'SP12SS6DZHF4MWBNRJCF5FVWQHHQ1F4D8C773VVMN) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u12) 'SP3DHGRN5N0SHVSAP0YFBCM7T0FV21YSXKADH6G4H))
      (map-set token-count 'SP3DHGRN5N0SHVSAP0YFBCM7T0FV21YSXKADH6G4H (+ (get-balance 'SP3DHGRN5N0SHVSAP0YFBCM7T0FV21YSXKADH6G4H) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u13) 'SP2T6QECNTXZ3JC2BHHEW42C8YHRN9DYTC6AYM7SH))
      (map-set token-count 'SP2T6QECNTXZ3JC2BHHEW42C8YHRN9DYTC6AYM7SH (+ (get-balance 'SP2T6QECNTXZ3JC2BHHEW42C8YHRN9DYTC6AYM7SH) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u14) 'SP29X70NPFB8DZWAR679SFK4RQB7QMQAMNY4839SY))
      (map-set token-count 'SP29X70NPFB8DZWAR679SFK4RQB7QMQAMNY4839SY (+ (get-balance 'SP29X70NPFB8DZWAR679SFK4RQB7QMQAMNY4839SY) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u15) 'SP32V5EAKRWZ66VVA67XGDK18VYMZM5NT7NP98M9))
      (map-set token-count 'SP32V5EAKRWZ66VVA67XGDK18VYMZM5NT7NP98M9 (+ (get-balance 'SP32V5EAKRWZ66VVA67XGDK18VYMZM5NT7NP98M9) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u16) 'SP35R4DXWZRPMPTSNK0FFW714H9HPWH3R35Z4GVJC))
      (map-set token-count 'SP35R4DXWZRPMPTSNK0FFW714H9HPWH3R35Z4GVJC (+ (get-balance 'SP35R4DXWZRPMPTSNK0FFW714H9HPWH3R35Z4GVJC) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u17) 'SP213WS5QEK1RE3XNMQ30SMSH45RD6WJWAFSBXSWA))
      (map-set token-count 'SP213WS5QEK1RE3XNMQ30SMSH45RD6WJWAFSBXSWA (+ (get-balance 'SP213WS5QEK1RE3XNMQ30SMSH45RD6WJWAFSBXSWA) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u18) 'SP1SGWYFVJGHJDVHP90MM89W563DBQGK5N1QJ52T))
      (map-set token-count 'SP1SGWYFVJGHJDVHP90MM89W563DBQGK5N1QJ52T (+ (get-balance 'SP1SGWYFVJGHJDVHP90MM89W563DBQGK5N1QJ52T) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u19) 'SPA0SZQ6KCCYMJV5XVKSNM7Y1DGDXH39A11ZX2Y8))
      (map-set token-count 'SPA0SZQ6KCCYMJV5XVKSNM7Y1DGDXH39A11ZX2Y8 (+ (get-balance 'SPA0SZQ6KCCYMJV5XVKSNM7Y1DGDXH39A11ZX2Y8) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u20) 'SP3JZ29WQ21CMVVKTSPAHTC1ZW8YWZA8JCMEMPH1B))
      (map-set token-count 'SP3JZ29WQ21CMVVKTSPAHTC1ZW8YWZA8JCMEMPH1B (+ (get-balance 'SP3JZ29WQ21CMVVKTSPAHTC1ZW8YWZA8JCMEMPH1B) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u21) 'SP2KXR9180B10JM3437VD7C48BH03NZF371XR61H2))
      (map-set token-count 'SP2KXR9180B10JM3437VD7C48BH03NZF371XR61H2 (+ (get-balance 'SP2KXR9180B10JM3437VD7C48BH03NZF371XR61H2) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u22) 'SP3NGX7HB0RYK8B24AA4KC8SQE5HNRASYN3F2P23Q))
      (map-set token-count 'SP3NGX7HB0RYK8B24AA4KC8SQE5HNRASYN3F2P23Q (+ (get-balance 'SP3NGX7HB0RYK8B24AA4KC8SQE5HNRASYN3F2P23Q) u1))
      (try! (nft-mint? war-worms (+ last-nft-id u23) 'SP324QWEMW7R0BCXCHXG20QNJQ9K1Q7J2CYACTDZD))
      (map-set token-count 'SP324QWEMW7R0BCXCHXG20QNJQ9K1Q7J2CYACTDZD (+ (get-balance 'SP324QWEMW7R0BCXCHXG20QNJQ9K1Q7J2CYACTDZD) u1))

      (var-set last-id (+ last-nft-id u24))
      (var-set airdrop-called true)
      (ok true))))