;; the-announcement
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token the-announcement uint)

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
(define-data-var mint-limit uint u100)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP12JCJYJJ31C59MV94SNFFM4687H9A04Q3BHTAJM)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmeaNPVjMr21PuGCQ6BEHcEeKTwHUGSXs22ZQqmGLmBxZm/")
(define-data-var mint-paused bool false)
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
      (unwrap! (nft-mint? the-announcement next-id tx-sender) next-id)
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
    (nft-burn? the-announcement token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? the-announcement token-id) false)))

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
  (ok (nft-get-owner? the-announcement token-id)))

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
  (match (nft-transfer? the-announcement id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? the-announcement id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? the-announcement id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? the-announcement (+ last-nft-id u0) 'SP3W71ZJ7BAS6ZXJ3VZA08JF56D2GJ241WWPZFERW))
      (map-set token-count 'SP3W71ZJ7BAS6ZXJ3VZA08JF56D2GJ241WWPZFERW (+ (get-balance 'SP3W71ZJ7BAS6ZXJ3VZA08JF56D2GJ241WWPZFERW) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u1) 'SP12JCJYJJ31C59MV94SNFFM4687H9A04Q3BHTAJM))
      (map-set token-count 'SP12JCJYJJ31C59MV94SNFFM4687H9A04Q3BHTAJM (+ (get-balance 'SP12JCJYJJ31C59MV94SNFFM4687H9A04Q3BHTAJM) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u2) 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC))
      (map-set token-count 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC (+ (get-balance 'SP2HJVJQS0TRBTQ1WAWWN9H9W2HKGDZ7H5EZCEAQC) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u3) 'SP2HY55JTX8P6EXY9JSRKK407MQKZ9MB9VF9X5W6R))
      (map-set token-count 'SP2HY55JTX8P6EXY9JSRKK407MQKZ9MB9VF9X5W6R (+ (get-balance 'SP2HY55JTX8P6EXY9JSRKK407MQKZ9MB9VF9X5W6R) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u4) 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y))
      (map-set token-count 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y (+ (get-balance 'SP2QT9ZMK8PFQAWR461M6SABBCG33XB3H82G1N88Y) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u5) 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558))
      (map-set token-count 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558 (+ (get-balance 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u6) 'SP3A2R2763JHY9FTBX19GA02H58025Y9KVX301NYP))
      (map-set token-count 'SP3A2R2763JHY9FTBX19GA02H58025Y9KVX301NYP (+ (get-balance 'SP3A2R2763JHY9FTBX19GA02H58025Y9KVX301NYP) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u7) 'SP1RYWKCXYWAHWS3RC9QJSFK5EPEH07E4DG1GCFWV))
      (map-set token-count 'SP1RYWKCXYWAHWS3RC9QJSFK5EPEH07E4DG1GCFWV (+ (get-balance 'SP1RYWKCXYWAHWS3RC9QJSFK5EPEH07E4DG1GCFWV) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u8) 'SP3MQKV7B7ZR1MWCDVS47A2J1NA2EFTERQXGW7663))
      (map-set token-count 'SP3MQKV7B7ZR1MWCDVS47A2J1NA2EFTERQXGW7663 (+ (get-balance 'SP3MQKV7B7ZR1MWCDVS47A2J1NA2EFTERQXGW7663) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u9) 'SP2S5QJBSS7GRPDCPG12XW28W8G7TC99WCNR84NJY))
      (map-set token-count 'SP2S5QJBSS7GRPDCPG12XW28W8G7TC99WCNR84NJY (+ (get-balance 'SP2S5QJBSS7GRPDCPG12XW28W8G7TC99WCNR84NJY) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u10) 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C))
      (map-set token-count 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C (+ (get-balance 'SP3VMAHTFVN9ED5FB073MK1B8MGNCZW5VCEHFFD7C) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u11) 'SP3TF77S4XWBMZ455YTYWRMRMHTM7AZDM6258ACR3))
      (map-set token-count 'SP3TF77S4XWBMZ455YTYWRMRMHTM7AZDM6258ACR3 (+ (get-balance 'SP3TF77S4XWBMZ455YTYWRMRMHTM7AZDM6258ACR3) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u12) 'SPACCQ8K3ZKXNAHTH14VEAFWY9E7BDP72DCNCZWP))
      (map-set token-count 'SPACCQ8K3ZKXNAHTH14VEAFWY9E7BDP72DCNCZWP (+ (get-balance 'SPACCQ8K3ZKXNAHTH14VEAFWY9E7BDP72DCNCZWP) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u13) 'SP20M883T8FJ6S63VJQEXE5ZMP91ZMKVR5RN5N0DR))
      (map-set token-count 'SP20M883T8FJ6S63VJQEXE5ZMP91ZMKVR5RN5N0DR (+ (get-balance 'SP20M883T8FJ6S63VJQEXE5ZMP91ZMKVR5RN5N0DR) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u14) 'SP3EMKWJWW9V54X1MGAPDPNBERHRDHG0NM2RREPYW))
      (map-set token-count 'SP3EMKWJWW9V54X1MGAPDPNBERHRDHG0NM2RREPYW (+ (get-balance 'SP3EMKWJWW9V54X1MGAPDPNBERHRDHG0NM2RREPYW) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u15) 'SP3EMKWJWW9V54X1MGAPDPNBERHRDHG0NM2RREPYW))
      (map-set token-count 'SP3EMKWJWW9V54X1MGAPDPNBERHRDHG0NM2RREPYW (+ (get-balance 'SP3EMKWJWW9V54X1MGAPDPNBERHRDHG0NM2RREPYW) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u16) 'SP27G4BAETJAXHDNCGVAC2036476MC3BE9K87CJ2D))
      (map-set token-count 'SP27G4BAETJAXHDNCGVAC2036476MC3BE9K87CJ2D (+ (get-balance 'SP27G4BAETJAXHDNCGVAC2036476MC3BE9K87CJ2D) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u17) 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV))
      (map-set token-count 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV (+ (get-balance 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u18) 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV))
      (map-set token-count 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV (+ (get-balance 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u19) 'SP1MAVN1K5D9JJDVFK6RMJABE6NAV4K67G2SG34ZN))
      (map-set token-count 'SP1MAVN1K5D9JJDVFK6RMJABE6NAV4K67G2SG34ZN (+ (get-balance 'SP1MAVN1K5D9JJDVFK6RMJABE6NAV4K67G2SG34ZN) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u20) 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV))
      (map-set token-count 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV (+ (get-balance 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u21) 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV))
      (map-set token-count 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV (+ (get-balance 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u22) 'SP162W9JMD2CRP9XDF1AJVE2MSTFQNRNPPKCRDA58))
      (map-set token-count 'SP162W9JMD2CRP9XDF1AJVE2MSTFQNRNPPKCRDA58 (+ (get-balance 'SP162W9JMD2CRP9XDF1AJVE2MSTFQNRNPPKCRDA58) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u23) 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X))
      (map-set token-count 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X (+ (get-balance 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u24) 'SP3EJCRT5V10W6JBS8D76J5PXCTF0SD250N1Z1HRS))
      (map-set token-count 'SP3EJCRT5V10W6JBS8D76J5PXCTF0SD250N1Z1HRS (+ (get-balance 'SP3EJCRT5V10W6JBS8D76J5PXCTF0SD250N1Z1HRS) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u25) 'SPXTHZQJX567G3SK245R24BW2403V8XAK8VBW08P))
      (map-set token-count 'SPXTHZQJX567G3SK245R24BW2403V8XAK8VBW08P (+ (get-balance 'SPXTHZQJX567G3SK245R24BW2403V8XAK8VBW08P) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u26) 'SP2K0VG0Y0V5CZA7YBNN07E6A3M1N7KM4QB8KKQRW))
      (map-set token-count 'SP2K0VG0Y0V5CZA7YBNN07E6A3M1N7KM4QB8KKQRW (+ (get-balance 'SP2K0VG0Y0V5CZA7YBNN07E6A3M1N7KM4QB8KKQRW) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u27) 'SP2K0VG0Y0V5CZA7YBNN07E6A3M1N7KM4QB8KKQRW))
      (map-set token-count 'SP2K0VG0Y0V5CZA7YBNN07E6A3M1N7KM4QB8KKQRW (+ (get-balance 'SP2K0VG0Y0V5CZA7YBNN07E6A3M1N7KM4QB8KKQRW) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u28) 'SP27X9GJABE7YC1XSJZ42XNAA518SAP04XBC6Z9MZ))
      (map-set token-count 'SP27X9GJABE7YC1XSJZ42XNAA518SAP04XBC6Z9MZ (+ (get-balance 'SP27X9GJABE7YC1XSJZ42XNAA518SAP04XBC6Z9MZ) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u29) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u30) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u31) 'SMZGPQ1H0D8GSHENJPPD6Q0H2DXK8GQVQCPVTSYD))
      (map-set token-count 'SMZGPQ1H0D8GSHENJPPD6Q0H2DXK8GQVQCPVTSYD (+ (get-balance 'SMZGPQ1H0D8GSHENJPPD6Q0H2DXK8GQVQCPVTSYD) u1))
      (try! (nft-mint? the-announcement (+ last-nft-id u32) 'SP17A1AM4TNYFPAZ75Z84X3D6R2F6DTJBDJ6B0YF))
      (map-set token-count 'SP17A1AM4TNYFPAZ75Z84X3D6R2F6DTJBDJ6B0YF (+ (get-balance 'SP17A1AM4TNYFPAZ75Z84X3D6R2F6DTJBDJ6B0YF) u1))

      (var-set last-id (+ last-nft-id u33))
      (var-set airdrop-called true)
      (ok true))))