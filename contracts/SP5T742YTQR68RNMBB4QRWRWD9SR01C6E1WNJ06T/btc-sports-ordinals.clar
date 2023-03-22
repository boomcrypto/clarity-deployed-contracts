;; btc-sports-ordinals
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token btc-sports-ordinals uint)

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
(define-data-var mint-limit uint u99)
(define-data-var last-id uint u1)
(define-data-var total-price uint u222000000)
(define-data-var artist-address principal 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmRa3eAD73tE5xB92UBEJ4GGkJ74c8S1GN6Ef7Bixvjpmk/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

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
      (unwrap! (nft-mint? btc-sports-ordinals next-id tx-sender) next-id)
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
    (nft-burn? btc-sports-ordinals token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? btc-sports-ordinals token-id) false)))

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
  (ok (nft-get-owner? btc-sports-ordinals token-id)))

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
  (match (nft-transfer? btc-sports-ordinals id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? btc-sports-ordinals id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? btc-sports-ordinals id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u6)
(map-set mint-passes 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 u6)
(map-set mint-passes 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X u6)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u6)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u6)
(map-set mint-passes 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF u6)
(map-set mint-passes 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG u6)
(map-set mint-passes 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0 u4)
(map-set mint-passes 'SP9R1DTP15B10S5WFPZVM8W2FDS6VXP27VA96CEZ u3)
(map-set mint-passes 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S u3)
(map-set mint-passes 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW u2)
(map-set mint-passes 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS u2)
(map-set mint-passes 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR u2)
(map-set mint-passes 'SPRXRB7J5SF0N0XQJF1FK332H5VZ67ZA5Y9Q036S u2)
(map-set mint-passes 'SP32728WFVK74FQXC0BD48QD6BNW5A3MJ8HB5YADR u2)
(map-set mint-passes 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27 u2)
(map-set mint-passes 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ u2)
(map-set mint-passes 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY u2)
(map-set mint-passes 'SP1CA9W3C35F6WH2MH1D5Z1XQG9595Q1C3P7Z2NYY u2)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u2)
(map-set mint-passes 'SP2QPKZPPEBZ7ZB7E558TTW15X75S9VDHC09M9SJF u1)
(map-set mint-passes 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 u1)
(map-set mint-passes 'SP3GD9W8CX9V7CVY01WNTHT94H6K07EDFHRC89QP u1)
(map-set mint-passes 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR u1)
(map-set mint-passes 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4 u1)
(map-set mint-passes 'SP25A4G4V7W3XQVCAQW2SJG1END8F1AS6CNTR25Q1 u1)
(map-set mint-passes 'SPF42XNA138JDVDD11Q3WNZQBW8XJPWPXJGTTTB4 u1)
(map-set mint-passes 'SP16PRV5FEZRH1KNFWNJTZ9HHZGWMPFB6G1QKE607 u1)
(map-set mint-passes 'SP3VJCMXAGTVF4BJ81JGTYVEBCXWZARFN60D8VSKG u1)
(map-set mint-passes 'SP1FTE6BCZ14AHW7025F8B7AS6GQT4ZRNG4V209WH u1)
(map-set mint-passes 'SP2TGN9DJWTV02B9HRGX6Z43Y7052DTZW6FZVZH0S u1)
(map-set mint-passes 'SP2SFZX1WJSKT1GA2STDT6E5NWDX44GW4BB8DW4DJ u1)
(map-set mint-passes 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV u1)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u1)
(map-set mint-passes 'SP2M63YGBZCTWBWBCG77RET0RMP42C08T73MKAPNP u1)
(map-set mint-passes 'SP31SJ2X5683KDX8P58HWRA2DXY3ED4WZ6Z3DM0A9 u1)
(map-set mint-passes 'SP1TRJR66FTZZGJWDG3ZK6VCS4SNQ10CHWTTMHMHZ u1)
(map-set mint-passes 'SP3FE7R844ZQ77162SYAYYPD059E9PYA39VX0BMQB u1)
(map-set mint-passes 'SP5GX6PQVGYQKBFA3E9EWWVPM65SN5Z0XDDX3YW7 u1)
(map-set mint-passes 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV u1)
(map-set mint-passes 'SP7VCY0S1WZF3XDGSMPQ67SDQQ4DCW1DWBR29G19 u1)
(map-set mint-passes 'SP2XJCFE0MZB33AAP91ZY8TXJ03HMXCJPJD71AJCM u1)
(map-set mint-passes 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5 u1)
(map-set mint-passes 'SP3S06J8XYDN6K0GAGHEM507V24KZD8BR65CJA7T5 u1)
(map-set mint-passes 'SP3YKKE23MAQA1CSQJGWXBKYXMVGGH3G6AYHHBXHR u1)
(map-set mint-passes 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG u1)
(map-set mint-passes 'SP1S2RQV0JCQ1P4PZYFHK1J0D5R1WNPH089EYJAF u1)
(map-set mint-passes 'SP262CK3VPG6PDF4S96TTXFBVV9Y9Z75F51A6G83N u1)
(map-set mint-passes 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1 u1)
(map-set mint-passes 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D u1)
(map-set mint-passes 'SP3WKZWBE7F7GR91GPFDNTT65A2J8WA8KZC9MFKQJ u1)
(map-set mint-passes 'SP2W0KJMJB2601KK53Y7F8W9FV5YJ1QVCT0GBJHTA u1)
(map-set mint-passes 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2 u1)
(map-set mint-passes 'SP3H0DJMGJFXJ6HP30B74YGK19ADYMD9H13ECSPZJ u1)
(map-set mint-passes 'SP2Z4MCB2488PSASQHWDA2J3G2CG7TDETT8TK5QA0 u1)
(map-set mint-passes 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH u1)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u1)
(map-set mint-passes 'SP2Y3VZAWWAR1XYAXDDZAC3AZQWS97AVY81DP633A u1)
(map-set mint-passes 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX u1)
(map-set mint-passes 'SPHWY482ANTWNTW2618HYHQSDY1WCW7P20BW5F7Y u1)
(map-set mint-passes 'SP31QFBF2M32B94JQQMDE5JGRT4T9R0E0HHJ48QKV u1)
(map-set mint-passes 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 u1)
(map-set mint-passes 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0 u1)
(map-set mint-passes 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE u1)
(map-set mint-passes 'SP3E545ADCKY56EVCXZPA87525VM0ZA8DQQAEP77Z u1)
(map-set mint-passes 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8 u1)
(map-set mint-passes 'SP38AJ28GP1Q3E40QD8K3WA7JR315794Y29YWKAP1 u1)
(map-set mint-passes 'SP152CGECH11CBS16N55WKKDRAWFMYK1XN3MNBZFP u1)
(map-set mint-passes 'SP2VH7GSHWSC84PXN3FA6YDMXZEMXXD6W4KK053RD u1)
(map-set mint-passes 'SPEJ2JKG5SVZD793CEWFZQ0VDPEGZ6QVP39QFAHM u1)
(map-set mint-passes 'SP2YCRG9VNTAECNP2NMPWWZD9K95SGS9PJDYYVHAJ u1)
(map-set mint-passes 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ u1)
(map-set mint-passes 'SP35ZPRFSCA52PW0P9N52D2AWP9QWTFH8RFM23G44 u1)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX u1)
(map-set mint-passes 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ u1)
(map-set mint-passes 'SP2SSHDSGHHEQN1A7Z0RP0YJ6QECE8TGQTYN594PM u1)
(map-set mint-passes 'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294 u1)
(map-set mint-passes 'SP2WM2CT5HGE9B791XQVH4FD5MWC65XKG4YFFH1WC u1)
(map-set mint-passes 'SPM06DTBFP2E6056NGR0Q3TEE5SW9ZYRA98XZ23S u1)
(map-set mint-passes 'SP3HY8Z7BBPVJH7PKP3VBCEA9DE8XATR9ENR39QB3 u1)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u1)
(map-set mint-passes 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 u1)
(map-set mint-passes 'SP3ZQ324JA8CPZ5X38S7Q7ZCC0MM9F3PKRDJA0PC3 u1)
(map-set mint-passes 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV u1)
(map-set mint-passes 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 u1)
(map-set mint-passes 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q u1)
(map-set mint-passes 'SP3BHB4TVD918RX3MDHNZWSWKVXEV92CE10VQ97PQ u1)
(map-set mint-passes 'SP13WHS2BT5N25HN6DZWZXTQ3952W9HC6KAQ2EDG8 u1)
(map-set mint-passes 'SP1ZN131EG9NQB5GPQ1V56JWCE1XQ8FZVCCYEWWGQ u1)
(map-set mint-passes 'SP1JY766Q0PM5R5MC3J603NTK27SW7Y7GKXM2T946 u1)
(map-set mint-passes 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV u1)
(map-set mint-passes 'SP2DP1DV0R099CGRYZRAMV4GGXA14TXDW0BK3VMEA u1)
(map-set mint-passes 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7 u1)
(map-set mint-passes 'SP2N65XG5NHHZQB50X119YMZ018AP0FCSXDJPNE05 u1)
(map-set mint-passes 'SPR0ERQGYW544QPS4Q97A2SVDG2JBBCBJJ71MA6C u1)
(map-set mint-passes 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E u1)
(map-set mint-passes 'SP2DP70FRC4FFCZR5B2F6S112NK79WAFWHCWPYKQZ u1)
(map-set mint-passes 'SP21HR7CWEWR27AY7W63566RTN82QVRSGF74S6XXV u1)
(map-set mint-passes 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX u1)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u1)
(map-set mint-passes 'SP26ZSXREMGCD8M71Y4FVA17QBC42EV0VM3HPVXYQ u1)
(map-set mint-passes 'SP1FKP2KHZKXSPY7ZFMXBCZS19E149T2S936EJYVJ u1)
(map-set mint-passes 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27 u1)
(map-set mint-passes 'SP2RH3J2MJ4E5RQ4MNQSBCEQMGVS9XCTNCCP2DN2W u1)
(map-set mint-passes 'SP33N5R751MG99QAM4CN6HQ3MDTYBR71SB4NXVGT1 u1)
(map-set mint-passes 'SPM4JKECG23CJGXC93BDXX7579WVH5NR7E2XVC5H u1)
(map-set mint-passes 'SP22AE9KH2KXQT8Q4RSH24QKKFE6YYV38WE1CWM1Q u1)
(map-set mint-passes 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ u1)
(map-set mint-passes 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS u1)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u0) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u1) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u2) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u3) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u4) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u5) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u6) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u7) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u8) 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S))
      (map-set token-count 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S (+ (get-balance 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u9) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u10) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u11) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u12) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u13) 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM))
      (map-set token-count 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM (+ (get-balance 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u14) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u15) 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS))
      (map-set token-count 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS (+ (get-balance 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u16) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u17) 'SP9R1DTP15B10S5WFPZVM8W2FDS6VXP27VA96CEZ))
      (map-set token-count 'SP9R1DTP15B10S5WFPZVM8W2FDS6VXP27VA96CEZ (+ (get-balance 'SP9R1DTP15B10S5WFPZVM8W2FDS6VXP27VA96CEZ) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u18) 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ))
      (map-set token-count 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ (+ (get-balance 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u19) 'SP3VJCMXAGTVF4BJ81JGTYVEBCXWZARFN60D8VSKG))
      (map-set token-count 'SP3VJCMXAGTVF4BJ81JGTYVEBCXWZARFN60D8VSKG (+ (get-balance 'SP3VJCMXAGTVF4BJ81JGTYVEBCXWZARFN60D8VSKG) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u20) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u21) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u22) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u23) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u24) 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
      (map-set token-count 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T (+ (get-balance 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T) u1))
      (try! (nft-mint? btc-sports-ordinals (+ last-nft-id u25) 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS))
      (map-set token-count 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS (+ (get-balance 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS) u1))

      (var-set last-id (+ last-nft-id u26))
      (var-set airdrop-called true)
      (ok true))))