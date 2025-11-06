;; granite-stone-mason-july-2025
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token granite-stone-mason-july-2025 uint)

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
(define-data-var mint-limit uint u23)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP2BD0MQ2CJGDBXCME9HEG2N1VN82F9301XAD3EHZ)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmdcxZrNhTLUqEkkft3AcyVvZ7cHRhVo6XoYGH2ShMf3QQ/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u1)
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
      (unwrap! (nft-mint? granite-stone-mason-july-2025 next-id tx-sender) next-id)
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
    (nft-burn? granite-stone-mason-july-2025 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? granite-stone-mason-july-2025 token-id) false)))

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
  (ok (nft-get-owner? granite-stone-mason-july-2025 token-id)))

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

(define-data-var license-uri (string-ascii 80) "")
(define-data-var license-name (string-ascii 40) "")

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
  (match (nft-transfer? granite-stone-mason-july-2025 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? granite-stone-mason-july-2025 id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? granite-stone-mason-july-2025 id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u0) 'SP3B52V96034PN40B0XVCNGMFM08W9KEAX5K2M8SD))
      (map-set token-count 'SP3B52V96034PN40B0XVCNGMFM08W9KEAX5K2M8SD (+ (get-balance 'SP3B52V96034PN40B0XVCNGMFM08W9KEAX5K2M8SD) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u1) 'SP24CK56E1002KT9HS8W9VC2T60Q0CC8G6WV18ABS))
      (map-set token-count 'SP24CK56E1002KT9HS8W9VC2T60Q0CC8G6WV18ABS (+ (get-balance 'SP24CK56E1002KT9HS8W9VC2T60Q0CC8G6WV18ABS) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u2) 'SP2W69C81XYZCNBRSDKMVQC7NDQ5WTJX50E472NEV))
      (map-set token-count 'SP2W69C81XYZCNBRSDKMVQC7NDQ5WTJX50E472NEV (+ (get-balance 'SP2W69C81XYZCNBRSDKMVQC7NDQ5WTJX50E472NEV) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u3) 'SP3N8Y7RYHPBHGX0E6EWS7634N4Q2XF665AWQ7ZJ4))
      (map-set token-count 'SP3N8Y7RYHPBHGX0E6EWS7634N4Q2XF665AWQ7ZJ4 (+ (get-balance 'SP3N8Y7RYHPBHGX0E6EWS7634N4Q2XF665AWQ7ZJ4) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u4) 'SPAFRYT831WS7ZRHGZBPMNCBJRBC0ZT884HFXERA))
      (map-set token-count 'SPAFRYT831WS7ZRHGZBPMNCBJRBC0ZT884HFXERA (+ (get-balance 'SPAFRYT831WS7ZRHGZBPMNCBJRBC0ZT884HFXERA) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u5) 'SP1AX9XDJVVY6J25YF403S17J0KZM97SZDR9YW8WK))
      (map-set token-count 'SP1AX9XDJVVY6J25YF403S17J0KZM97SZDR9YW8WK (+ (get-balance 'SP1AX9XDJVVY6J25YF403S17J0KZM97SZDR9YW8WK) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u6) 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ))
      (map-set token-count 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ (+ (get-balance 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u7) 'SPK9J5DD22NTTMK6FMF07CANX81FQW8WE63SAM2Q))
      (map-set token-count 'SPK9J5DD22NTTMK6FMF07CANX81FQW8WE63SAM2Q (+ (get-balance 'SPK9J5DD22NTTMK6FMF07CANX81FQW8WE63SAM2Q) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u8) 'SPSK86Q3EP02Q5618EBPH9H4KSWDD1HDBB9SDSK8))
      (map-set token-count 'SPSK86Q3EP02Q5618EBPH9H4KSWDD1HDBB9SDSK8 (+ (get-balance 'SPSK86Q3EP02Q5618EBPH9H4KSWDD1HDBB9SDSK8) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u9) 'SP1KD2BS98HCAEZQB3A4AXNS2KNAFTXF2CTJBQWF6))
      (map-set token-count 'SP1KD2BS98HCAEZQB3A4AXNS2KNAFTXF2CTJBQWF6 (+ (get-balance 'SP1KD2BS98HCAEZQB3A4AXNS2KNAFTXF2CTJBQWF6) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u10) 'SP2EX6YKM52T7GMCTJ8E2CTGMPVB4YBTJE5R0QZY5))
      (map-set token-count 'SP2EX6YKM52T7GMCTJ8E2CTGMPVB4YBTJE5R0QZY5 (+ (get-balance 'SP2EX6YKM52T7GMCTJ8E2CTGMPVB4YBTJE5R0QZY5) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u11) 'SP1N6QYMS4771B58J5WDQMX917F2ZQJVD48RJH047))
      (map-set token-count 'SP1N6QYMS4771B58J5WDQMX917F2ZQJVD48RJH047 (+ (get-balance 'SP1N6QYMS4771B58J5WDQMX917F2ZQJVD48RJH047) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u12) 'SP2BKBZDH2E5GMGSERKP51WMZPZRCN34H9F50AVBN))
      (map-set token-count 'SP2BKBZDH2E5GMGSERKP51WMZPZRCN34H9F50AVBN (+ (get-balance 'SP2BKBZDH2E5GMGSERKP51WMZPZRCN34H9F50AVBN) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u13) 'SPRPR5TNY0CQAMBQEYCH59W710Z9S3C3QZ1S285C))
      (map-set token-count 'SPRPR5TNY0CQAMBQEYCH59W710Z9S3C3QZ1S285C (+ (get-balance 'SPRPR5TNY0CQAMBQEYCH59W710Z9S3C3QZ1S285C) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u14) 'SP36XNA335HA6Z0NSDW859R4NGF631HGH14FZ6HX9))
      (map-set token-count 'SP36XNA335HA6Z0NSDW859R4NGF631HGH14FZ6HX9 (+ (get-balance 'SP36XNA335HA6Z0NSDW859R4NGF631HGH14FZ6HX9) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u15) 'SP3GPV7YEVS2VNFYYXEJA4HWXA0HFX4SMFK9F12P7))
      (map-set token-count 'SP3GPV7YEVS2VNFYYXEJA4HWXA0HFX4SMFK9F12P7 (+ (get-balance 'SP3GPV7YEVS2VNFYYXEJA4HWXA0HFX4SMFK9F12P7) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u16) 'SP260ZF58NPJZCJGB2K51327RW299BHES24W4ARKE))
      (map-set token-count 'SP260ZF58NPJZCJGB2K51327RW299BHES24W4ARKE (+ (get-balance 'SP260ZF58NPJZCJGB2K51327RW299BHES24W4ARKE) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u17) 'SP2TBW5EM2JEH10756JC1FSG784P0SVYZ9F2ZBJ7K))
      (map-set token-count 'SP2TBW5EM2JEH10756JC1FSG784P0SVYZ9F2ZBJ7K (+ (get-balance 'SP2TBW5EM2JEH10756JC1FSG784P0SVYZ9F2ZBJ7K) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u18) 'SP1T4NWMVC1AMH69FXB9C6GSN51BD2YZ0292QQG75))
      (map-set token-count 'SP1T4NWMVC1AMH69FXB9C6GSN51BD2YZ0292QQG75 (+ (get-balance 'SP1T4NWMVC1AMH69FXB9C6GSN51BD2YZ0292QQG75) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u19) 'SP20QS4PBRFWRQFHVKQHBR3C8TETC6H89QMXBQB8M))
      (map-set token-count 'SP20QS4PBRFWRQFHVKQHBR3C8TETC6H89QMXBQB8M (+ (get-balance 'SP20QS4PBRFWRQFHVKQHBR3C8TETC6H89QMXBQB8M) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u20) 'SP2A0VW071VE5QXZ9699FK29F0XXQ0B8AQ5BSC431))
      (map-set token-count 'SP2A0VW071VE5QXZ9699FK29F0XXQ0B8AQ5BSC431 (+ (get-balance 'SP2A0VW071VE5QXZ9699FK29F0XXQ0B8AQ5BSC431) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u21) 'SP3JDZX69PD5Y4W2PY7XE2E9PW2R5GGKQ2Z7X39ZS))
      (map-set token-count 'SP3JDZX69PD5Y4W2PY7XE2E9PW2R5GGKQ2Z7X39ZS (+ (get-balance 'SP3JDZX69PD5Y4W2PY7XE2E9PW2R5GGKQ2Z7X39ZS) u1))
      (try! (nft-mint? granite-stone-mason-july-2025 (+ last-nft-id u22) 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4))
      (map-set token-count 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4 (+ (get-balance 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4) u1))

      (var-set last-id (+ last-nft-id u23))
      (var-set airdrop-called true)
      (ok true))))