;; hooch-haus-creature-feature

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token hooch-haus-creature-feature uint)

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

;; Internal variables
(define-data-var mint-limit uint u69)
(define-data-var last-id uint u1)
(define-data-var total-price uint u42000000)
(define-data-var artist-address principal 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmagbGsZxguUbdR3jmaCCt6V6oHqvf7YoUBspFVDNtkhbq/json/")
(define-data-var mint-paused bool false)
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
      (unwrap! (nft-mint? hooch-haus-creature-feature next-id tx-sender) next-id)
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
    (nft-burn? hooch-haus-creature-feature token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? hooch-haus-creature-feature token-id) false)))

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
  (ok (nft-get-owner? hooch-haus-creature-feature token-id)))

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
(define-trait commission-trait
  ((pay (uint uint) (response bool uint))))

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? hooch-haus-creature-feature id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? hooch-haus-creature-feature id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
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
  (let ((owner (unwrap! (nft-get-owner? hooch-haus-creature-feature id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
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

(map-set mint-passes 'SP4JRVAABXMXVNSA023C4KW3MEHND6BGRPQK51NB u2)
(map-set mint-passes 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 u1)
(map-set mint-passes 'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX u3)
(map-set mint-passes 'SP33M3AQ6B8STAYN0W807WMMDD0BV5ETW8ZWY1E4W u1)
(map-set mint-passes 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH u3)
(map-set mint-passes 'SPS6543QSVCWM0B1CQYD67RV4QP3MGFPJEHG4FHS u2)
(map-set mint-passes 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W u1)
(map-set mint-passes 'SP2WGW1GPCYM0KXEFW3EK9CEW8ZWRRDPM7GS7DS6F u1)
(map-set mint-passes 'SP2KJC2WBNJPGVRB0GG30666PQW96MAKH7YWGPWB0 u2)
(map-set mint-passes 'SP2069715QFEA9GK8Q2E7QREFABGKRP78C08NTDTK u1)
(map-set mint-passes 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY u2)
(map-set mint-passes 'SP2ZD78CEHCFPJ71SB8R0EK0ZMVAGB3NTHK947F06 u2)
(map-set mint-passes 'SPDXC0NM3YQDHV1HN3V9P5Y4P26QWY709NB86EYB u2)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u3)
(map-set mint-passes 'SPZ5DJGRVZHXEEEYYGWEX84KQB8P69GC715ZRNW1 u2)
(map-set mint-passes 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ u1)
(map-set mint-passes 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79 u1)
(map-set mint-passes 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV u2)
(map-set mint-passes 'SP2HK7J6617VBSKXQGZWMXP2R64MMDX3S54M0S1Q6 u3)
(map-set mint-passes 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D u2)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP17YP1HGWK7DP5Q69GRG14W34E078S4D78YM1FA5 u1)
(map-set mint-passes 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A u1)
(map-set mint-passes 'SP13ZDF0VZBZSJ19W7DXNHWJDBCS9WSZB880PQXQS u1)
(map-set mint-passes 'SPCRHA45AXN05RYBDYY5WZK5F7J5SH574F0R0VR6 u2)
(map-set mint-passes 'SP3ST6K5W36V2MTSNYYXE56SCXR7DGTW9N4NMZHYV u1)
(map-set mint-passes 'SPQJN9008GBDXCPVS2CZSPXAPYV8251GZX1GX64R u1)
(map-set mint-passes 'SP1ZTC41HNC5PS8A7K444GBHN4104JXJ5EWRHTDM8 u1)
(map-set mint-passes 'SP30KD0JV9B3XX6DSPXSH90J621R7VBSSY2GNBC26 u1)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u1)
(map-set mint-passes 'SP79JMAGQVWMVWRXG2AE5GF8Z27VF1W4KZ3J03WG u1)
(map-set mint-passes 'SP26C9TWJYK6DTCD4T6HKBC76DPMK2DXXRNWS3E2D u1)
(map-set mint-passes 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH u1)
(map-set mint-passes 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR u1)
(map-set mint-passes 'SP3HYFVG35TW1RF47N6RKYYDNPX6T47J6ZJB3B4PE u1)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u1)
(map-set mint-passes 'SP3WKZWBE7F7GR91GPFDNTT65A2J8WA8KZC9MFKQJ u1)
(map-set mint-passes 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ u1)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u1)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u1)
(map-set mint-passes 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV u1)
(map-set mint-passes 'SPKFSJ4T8T39ZJN455QBY7TJX4DYF47J7344HNNF u1)
(map-set mint-passes 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF u1)
(map-set mint-passes 'SP3T7SA543GTWEPD3022B66RYN2WZ4SQW64S686AA u1)
(map-set mint-passes 'SP23Z3QX3CPAF7ARD2N1YP4BR5ATZW9X2Z6J0740J u1)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u1)
(map-set mint-passes 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u1)
(map-set mint-passes 'SPYAX2RNZA18KQA8Y0S5G393QBE8SWPNZ6R08XNH u1)
(map-set mint-passes 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 u1)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u1)
(map-set mint-passes 'SP2AYJHP9H3JM3T26ZBW0SKBCXJ9S4JW03VQBP7K1 u1)
