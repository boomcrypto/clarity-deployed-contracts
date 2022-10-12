;; war-all-arc8
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token war-all-arc8 uint)

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
(define-data-var mint-limit uint u25)
(define-data-var last-id uint u1)
(define-data-var total-price uint u175000000)
(define-data-var artist-address principal 'SP2BN54RFN13H1VVV7E651G77D4FM9B5GX1RTH2TS)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmPpLSLMFYtHbKZpeMwxjpkxKuCmq3vWKn6NkzwkiEfYVW/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u3)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

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
      (unwrap! (nft-mint? war-all-arc8 next-id tx-sender) next-id)
      (unwrap! (nft-transfer? war-all-arc8 next-id tx-sender recipient) next-id)
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
      (unwrap! (nft-mint? war-all-arc8 next-id tx-sender) next-id)
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
    (nft-burn? war-all-arc8 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? war-all-arc8 token-id) false)))

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
  (ok (nft-get-owner? war-all-arc8 token-id)))

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
  (match (nft-transfer? war-all-arc8 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? war-all-arc8 id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? war-all-arc8 id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP29SFB03X2KN1WG2WNJAXPQC57865FFDGN7W8XMM u1)
(map-set mint-passes 'SP12CT0D5ZKV4EVE9T24CQPQJDWSVQA4CMH2G0XZ1 u1)
(map-set mint-passes 'SP14PVWDVKVK1P1SZV72MJQMNX5N5XDZ8AGNG9M0C u1)
(map-set mint-passes 'SP15W83Y5K9X0H96RGX050GX2YFXVFCZTKAAT00H5 u1)
(map-set mint-passes 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 u1)
(map-set mint-passes 'SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH u1)
(map-set mint-passes 'SP1C229KSRFAYC1RR1R00MJ6295N7E2NXKABGBZGH u1)
(map-set mint-passes 'SP1G9PZMQSFRQ7Q98XP7JMNE2C22RXK1W61RXTNKP u1)
(map-set mint-passes 'SP1Q8P693A21HF064B8WZZPQZPDB5AKFRQ3F9KCWX u1)
(map-set mint-passes 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 u1)
(map-set mint-passes 'SP1XA04SDW26E4CDVJGF17SHKF1TJQPB1J62JDWC u1)
(map-set mint-passes 'SP1ZPQQGCXE57YTE86WSJPGP8TTXEGRPFDDJR808P u1)
(map-set mint-passes 'SP1Z84TMVM83HXE5VFHTXF27JPF73HPWT618RR26Y u1)
(map-set mint-passes 'SP21Q7X7CC354SR0PHANAF9M0XV6H77JN4QC2GW8M u1)
(map-set mint-passes 'SP228WEAEMYX21RW0TT5T38THPNDYPPGGVW2RP570 u1)
(map-set mint-passes 'SP23DZ9XYT3YNF70MHAV9Y3622H8B3DX10WMWT2T9 u1)
(map-set mint-passes 'SP2AZZWG7H99G9JW0PJAAC1JDANZ02GZ9CWGEJQC4 u1)
(map-set mint-passes 'SP2B0MVR8AEGRC3P0Z5KSC4ZR7VRXTXX0QVB1E946 u1)
(map-set mint-passes 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ u1)
(map-set mint-passes 'SP2RKX6NQJFF9EB0M324K5X98SSYFX7NNG31N6HK9 u1)
(map-set mint-passes 'SP2ZKD8WSMET2BQ42FV30Y7JPNVQANZ0KYV0FJEB5 u1)
(map-set mint-passes 'SP356FWK3AT63THK7P49RNQTS8XK3JV27V7PN0PGF u1)
(map-set mint-passes 'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2 u1)
(map-set mint-passes 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY u1)
(map-set mint-passes 'SP3D5EHK8SMJ3MMJWYCAKWJ2H4F1JQX85E33ZJDB9 u1)
(map-set mint-passes 'SP3GDZ8P094M16XA5ECQ5XMCNX8VZFDA3K3W3PPFM u1)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u1)
(map-set mint-passes 'SP3QAHBHA9DDJ6GZ8PGA8QTW4PJV9REXR0MZPZ9X8 u1)
(map-set mint-passes 'SP3RGQB4KTSAFKB2BN7R247QVETSYXC65A1509QCK u1)
(map-set mint-passes 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF u1)
(map-set mint-passes 'SP3TF77S4XWBMZ455YTYWRMRMHTM7AZDM6258ACR3 u1)
(map-set mint-passes 'SP3T4BBPBXQHCFJECE2VV3P12XRH4NRM3YKBVB6ND u1)
(map-set mint-passes 'SP3ZKZEFX3K4HD9JXKCKAE0QGBHG0WZ50BRAG78D5 u1)
(map-set mint-passes 'SP6Y9FQ6HE0HZ4G5XVT9PG0XZJJM2WWN0SXCY8YV u1)
(map-set mint-passes 'SP7E34QCWBZKMWMAHZJ7GEYYZR10986KAVPPZWYZ u1)
(map-set mint-passes 'SPB5WYPWH98CH5ETP22VM51DJ24WW11K2SPNTW5K u1)
(map-set mint-passes 'SPHN1E2QH69PWXBWAFWP2QHSN0H7WWMTTZ9H4RZ2 u1)
(map-set mint-passes 'SPJM94R5WR9BT0HR9HWTBK3A2JPS06V3PHCP8M01 u1)
(map-set mint-passes 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG u1)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u1)
(map-set mint-passes 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S u1)
(map-set mint-passes 'SPPY2Z3DB3YYFK0GV4WHENJKWTNM9MPBPNYJ7RMC u1)
(map-set mint-passes 'SPQCAMFRAXV93WNZHWXSDHSZGZ72G9RJPHXQ8CXN u1)
(map-set mint-passes 'SPQD1ME7HP53DASF8QP92KSZEPJZ8TP4G167VRBQ u1)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u1)
(map-set mint-passes 'SPWD8WYK25NJZNRZZMWQXYPXDW3ZGF7HX8PRR5VJ u1)
(map-set mint-passes 'SPZ7YBW5J8Z43T6VKR4JSY4GV222RM5QXETBWA6Z u1)
(map-set mint-passes 'SPZKBCMMR5EZ66V8P2V8TTP6QHKC8MXF6CNRE8TH u1)
