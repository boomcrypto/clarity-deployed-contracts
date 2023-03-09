;; artifacts-of-xxiiiii
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token artifacts-of-xxiiiii uint)

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
(define-data-var mint-limit uint u111)
(define-data-var last-id uint u1)
(define-data-var total-price uint u111000000)
(define-data-var artist-address principal 'SPWP8QGG60KA0T3KSZ2RC4M8THZTA0G3DZATMJ6V)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmavSsX4mNSWjKudLaWRSQpaQ5SA1o8xMHfSHSsoeUFdRB/json/")
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
      (unwrap! (nft-mint? artifacts-of-xxiiiii next-id tx-sender) next-id)
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
    (nft-burn? artifacts-of-xxiiiii token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? artifacts-of-xxiiiii token-id) false)))

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
  (ok (nft-get-owner? artifacts-of-xxiiiii token-id)))

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
  (match (nft-transfer? artifacts-of-xxiiiii id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? artifacts-of-xxiiiii id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? artifacts-of-xxiiiii id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u2)
(map-set mint-passes 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 u2)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u2)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u2)
(map-set mint-passes 'SP6DAZJ3X7NCZC0B1JZ7W37PMWHPREVCSMQH995Y u2)
(map-set mint-passes 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27 u2)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u2)
(map-set mint-passes 'SP2HRHRW0J3PCW9B9CMY77HRDQWV4CQ4H0WGJPZ13 u2)
(map-set mint-passes 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV u2)
(map-set mint-passes 'SPWCAYJQV8H4C2REWRZWZQGBPNN3F6TCWZYZASSH u1)
(map-set mint-passes 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG u1)
(map-set mint-passes 'SPZ5DJGRVZHXEEEYYGWEX84KQB8P69GC715ZRNW1 u1)
(map-set mint-passes 'SPRYZ1AP06XWSX90516A8R38QF8HVDXFAK1ZR6RW u1)
(map-set mint-passes 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G u1)
(map-set mint-passes 'SP2YG90T7GPVJDGXQAJ40Y08NB5ZBV4KVASSAQNE8 u1)
(map-set mint-passes 'SPM06DTBFP2E6056NGR0Q3TEE5SW9ZYRA98XZ23S u1)
(map-set mint-passes 'SP2RKVC8PYANWJ40VSRCK2K935HSN4H0AHTVHD73D u1)
(map-set mint-passes 'SP26SH2QHPF52FP60N6BMHWZ6SZYR1FW2MT13JCVZ u1)
(map-set mint-passes 'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E u1)
(map-set mint-passes 'SP2HK7J6617VBSKXQGZWMXP2R64MMDX3S54M0S1Q6 u1)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u1)
(map-set mint-passes 'SPY1HAK2PJ770KFV3CS1SZKSXZACC5P8GR4E09HJ u1)
(map-set mint-passes 'SP31ER8WTA6RM08Z0GNTY786T4PW6SYKFTNMTPRSV u1)
(map-set mint-passes 'SP3Z5H5KFMGBTYB37DYTGEA14VZG8AT32EPDEAKQH u1)
(map-set mint-passes 'SP3ST6K5W36V2MTSNYYXE56SCXR7DGTW9N4NMZHYV u1)
(map-set mint-passes 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY u1)
(map-set mint-passes 'SP2AWYVW1GZT214KDYR1XFF6BEFSH442XF87F7A73 u1)
(map-set mint-passes 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX u1)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u1)
(map-set mint-passes 'SP33N5R751MG99QAM4CN6HQ3MDTYBR71SB4NXVGT1 u1)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u1)
(map-set mint-passes 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 u1)
(map-set mint-passes 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 u1)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u1)
(map-set mint-passes 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX u1)
(map-set mint-passes 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0 u1)
(map-set mint-passes 'SP3A09H1JEB4F85FZ6XEXRSZA210SC6RB7Q7V7DAF u1)
(map-set mint-passes 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44 u1)
(map-set mint-passes 'SP13HCD99ZGR98NXZQFW5PTNT528PG0PPME7CGRN7 u1)
(map-set mint-passes 'SP24T7CS32EFQ89V3BJ73R67708Y01DYF32BT26TV u1)
(map-set mint-passes 'SP1KC3BEGRFE9CNV1Q6G3H3TBAA36Q4TZGRS6J322 u1)
(map-set mint-passes 'SP2W86BWEQEQBR09QZJ067BH5AMX6ZTQAMA9WS8BR u1)
(map-set mint-passes 'SP3BJT5AT0GCBPW5M7KMZ3QEX7AE2HZKDV4CY358K u1)
(map-set mint-passes 'SP3CRGM0QHHD36B57FXZW60EQS7NM6XJK8WC7T34S u1)
(map-set mint-passes 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW u1)
(map-set mint-passes 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX u1)
(map-set mint-passes 'SP2WJXBW24EFSHAJJGXNX4T7QQW9RK88W15GR7DKN u1)
(map-set mint-passes 'SP1012WHN0TRB47B1Q3JGF7VYGMC2Q6DW46WAKPE3 u1)
(map-set mint-passes 'SP2QAG09GBM8Y9HK05MSC30X0A09VW11T23ES27GX u1)
(map-set mint-passes 'SP1TCY25X8K9VVGQ8MZ2GP2H36S9QTGQENJ3A31GJ u1)
(map-set mint-passes 'SP2AVGX0DR4DACDBZABMFBRY34WJ0MBW1RVCPW3DV u1)
(map-set mint-passes 'SP1XAR0A0J2AFWXQXCJ07SPV3TSZV2BCQQAQ6H5B5 u1)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u1)
(map-set mint-passes 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K u1)
(map-set mint-passes 'SP1NFRJJFQAA5AB4R8RDA3F0WEBZHK0HQSKW1PPNY u1)
(map-set mint-passes 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 u1)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u1)
(map-set mint-passes 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR u1)
(map-set mint-passes 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 u1)
(map-set mint-passes 'SP2HRHRW0J3PCW9B9CMY77HRDQWV4CQ4H0WGJPZ13 u1)
(map-set mint-passes 'SP1CMFJW9J8WN7R2XJ26AC90AARGW68R1CWNYDANC u1)
(map-set mint-passes 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR u1)
(map-set mint-passes 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH u1)
(map-set mint-passes 'SP63N5X583MD5ZDMRFWD60WN5R0WR4C22H1MJ9NS u1)
(map-set mint-passes 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV u1)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u1)
(map-set mint-passes 'SP27ZDVAJTRTR6A79AXKEBXWFV6QVSZCY5JGR2BPH u1)
(map-set mint-passes 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV u1)
(map-set mint-passes 'SP27K1498HEGJSSVMFH64NTRJXSWEQN5H22S9TZ8M u1)
(map-set mint-passes 'SPS2RBYAXSCXMVPYXSG724CFY4W2WA2NPG44V191 u1)
(map-set mint-passes 'SP2V4GZ3N1Y72TJPVGWSE73G8S6G9YHD05ZXQ0K9J u1)
(map-set mint-passes 'SPAHTV25EDZPSFPSH3DGKN0ANRSDMEHYFVA1CS3N u1)
(map-set mint-passes 'SPD1FGYTNQE7AZ3CRTH7FTZNC0QHGHJJW56KSTS9 u1)
(map-set mint-passes 'SPNEVN63F423SBVD568MZSK0HT09SGC97SZZAWM2 u1)
(map-set mint-passes 'SP1K8RNFY4X9XGVJ011FTDWHP3Z2HJ692TD25KWY2 u1)
(map-set mint-passes 'SP2EMZSA1CQQCGJEQ9JSDBWBV0NFDJ59EH5P9E56V u1)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u1)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u1)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u1)
(map-set mint-passes 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106 u1)
(map-set mint-passes 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV u1)
(map-set mint-passes 'SP1FW0F2ZYZHXT1BVV8HX8ZXG3MRM0ZVH73QE9VSV u1)
(map-set mint-passes 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC u1)
(map-set mint-passes 'SP1B7FFVFHHBCB466DVJR02BQ7PS9TNW02YA29DR3 u1)
