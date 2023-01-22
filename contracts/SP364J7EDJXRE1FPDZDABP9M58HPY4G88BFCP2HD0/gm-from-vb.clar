;; gm-from-vb
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token gm-from-vb uint)

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
(define-data-var mint-limit uint u100)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmXepBfJcndMFdo2hin6jEXHaNLPqEEpBjAb1Yg2vj1fFx/json/")
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
      (unwrap! (nft-mint? gm-from-vb next-id tx-sender) next-id)
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
    (nft-burn? gm-from-vb token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? gm-from-vb token-id) false)))

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
  (ok (nft-get-owner? gm-from-vb token-id)))

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
  (match (nft-transfer? gm-from-vb id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? gm-from-vb id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? gm-from-vb id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 u1)
(map-set mint-passes 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH u1)
(map-set mint-passes 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX u1)
(map-set mint-passes 'SP12VXAS7H2MT7R8116F4RA1FCS21DZ86B4DTN80J u1)
(map-set mint-passes 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 u1)
(map-set mint-passes 'SP1RW8644DAFE03DTPS4MMJ83TCVBCBEMVAQG62T6 u1)
(map-set mint-passes 'SP1RW8644DAFE03DTPS4MMJ83TCVBCBEMVAQG62T6 u1)
(map-set mint-passes 'SP1V19KW8DVQ5D8YPBVHBF9NZXWMC0Q4FGG7S9NRY u1)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u1)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u1)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u1)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u1)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u1)
(map-set mint-passes 'SP1YVF9EWSK6HM0JZR4B3KCM7V3NKVE18VVNFSQV5 u1)
(map-set mint-passes 'SP1YVF9EWSK6HM0JZR4B3KCM7V3NKVE18VVNFSQV5 u1)
(map-set mint-passes 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV u1)
(map-set mint-passes 'SP1YVF9EWSK6HM0JZR4B3KCM7V3NKVE18VVNFSQV5 u1)
(map-set mint-passes 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8 u1)
(map-set mint-passes 'SP24X692XB6CZB0Z70ZGWRNCY22PZ5FED3P9KBGS8 u1)
(map-set mint-passes 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N u1)
(map-set mint-passes 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N u1)
(map-set mint-passes 'SP28JM4X6GWB3X9KFF01TE8FFND2V9GFRBS1PJGZN u1)
(map-set mint-passes 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC u1)
(map-set mint-passes 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC u1)
(map-set mint-passes 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC u1)
(map-set mint-passes 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC u1)
(map-set mint-passes 'SP295QANJTGHJJ9TSHJ4WH28Z52VDKWDW68VT8KAH u1)
(map-set mint-passes 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ u1)
(map-set mint-passes 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u1)
(map-set mint-passes 'SP2RQ9MEEQA2E3DZ7DQY24D3F1XESVR4721PZZ63Q u1)
(map-set mint-passes 'SP2S1JA1G39BAS9C6W48P7TX01ABJCDJ8ETR32T4J u1)
(map-set mint-passes 'SP2S1JA1G39BAS9C6W48P7TX01ABJCDJ8ETR32T4J u1)
(map-set mint-passes 'SP2X5KYYXWFCCH30FHQSAP1XVVAVXFT8P8FS44VRY u1)
(map-set mint-passes 'SP2X5KYYXWFCCH30FHQSAP1XVVAVXFT8P8FS44VRY u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 u1)
(map-set mint-passes 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2 u1)
(map-set mint-passes 'SP3866CAJYT8HXF36JT0B24DD6WPFSSEWA9CSA1W9 u1)
(map-set mint-passes 'SP3866CAJYT8HXF36JT0B24DD6WPFSSEWA9CSA1W9 u1)
(map-set mint-passes 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 u1)
(map-set mint-passes 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 u1)
(map-set mint-passes 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES u1)
(map-set mint-passes 'SP3C5JYPB8YE5H9WC2SM196RVJ0JXN2GHCWXJWSES u1)
(map-set mint-passes 'SP3DXVC12KG5PV0545PJF15VQVN6CZ641QH82GYYQ u1)
(map-set mint-passes 'SP3FHNTPZ8HYZNFER6EWJ7DZ6Q3WNPVKFWJST7GYR u1)
(map-set mint-passes 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10 u1)
(map-set mint-passes 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10 u1)
(map-set mint-passes 'SP3GNAE8V8KZ24T31JC10TT184F6NQ4YDYHGVFZ10 u1)
(map-set mint-passes 'SP3JK6D2D6MC8PWVCZ0Q9N1786E5PMY744XS1CVGN u1)
(map-set mint-passes 'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY u1)
(map-set mint-passes 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF u1)
(map-set mint-passes 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW u1)
(map-set mint-passes 'SP3YSG653BZZNTJVFHFMBSQCTP3GK6NAQEHC82TNK u1)
(map-set mint-passes 'SP3Z2QT1HN3CQE03XY2CRRC0TFM8QYSKKV0ETB96N u1)
(map-set mint-passes 'SP3ZCZ0CDR5EH8XYYXQ9H6P5G43N6YYCYYYX0BTMJ u1)
(map-set mint-passes 'SP3ZCZ0CDR5EH8XYYXQ9H6P5G43N6YYCYYYX0BTMJ u1)
(map-set mint-passes 'SP3ZCZ0CDR5EH8XYYXQ9H6P5G43N6YYCYYYX0BTMJ u1)
(map-set mint-passes 'SP3ZCZ0CDR5EH8XYYXQ9H6P5G43N6YYCYYYX0BTMJ u1)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG u1)
(map-set mint-passes 'SP6VV2AFXM7ZMT5V3ZAE8M6JXK9EA5N1GPFHJC4M u1)
(map-set mint-passes 'SP6VV2AFXM7ZMT5V3ZAE8M6JXK9EA5N1GPFHJC4M u1)
(map-set mint-passes 'SP6YAN6MV4SS2YJRMA3HQ2PYVQGVHV4W08D8HZ3V u1)
(map-set mint-passes 'SP84C5YVBTBSXZ8KS39R97QDKX1YNSXXR8814ET7 u1)
(map-set mint-passes 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558 u1)
(map-set mint-passes 'SPCRDMAJ0RJYPQ3BMNN9VV01BFSCG1SQ1WJZB558 u1)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u1)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u1)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u1)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u1)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u1)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u1)
