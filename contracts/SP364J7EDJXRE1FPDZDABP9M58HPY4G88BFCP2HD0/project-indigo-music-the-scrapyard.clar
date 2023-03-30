;; project-indigo-music-the-scrapyard
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token project-indigo-music-the-scrapyard uint)

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
(define-data-var mint-limit uint u150)
(define-data-var last-id uint u1)
(define-data-var total-price uint u10000000)
(define-data-var artist-address principal 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmeVHXaQjxMKZzcqTjZq91kgmZAHwZUESQCY4mwjpXqk4u/")
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

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-five) (mint (list true true true true true)))

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
      (unwrap! (nft-mint? project-indigo-music-the-scrapyard next-id tx-sender) next-id)
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
    (nft-burn? project-indigo-music-the-scrapyard token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? project-indigo-music-the-scrapyard token-id) false)))

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
  (ok (nft-get-owner? project-indigo-music-the-scrapyard token-id)))

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
  (match (nft-transfer? project-indigo-music-the-scrapyard id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? project-indigo-music-the-scrapyard id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? project-indigo-music-the-scrapyard id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE u5)
(map-set mint-passes 'SP14814KM6CBCJZMD15JJ58Q3E2S3NCB6SDXM8C79 u5)
(map-set mint-passes 'SP14RTW14ACAFNFBEQZRT46AWSPBVQ9M593HMQ6E8 u5)
(map-set mint-passes 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u5)
(map-set mint-passes 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 u5)
(map-set mint-passes 'SP1A9NAK7RCXN0E47D95X5E0VY0HPAAA0VVC2M322 u5)
(map-set mint-passes 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV u5)
(map-set mint-passes 'SP1DY2QDFZAR8VK5S9DMYW2AW0WXQ16NNRG3PJDTX u5)
(map-set mint-passes 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH u5)
(map-set mint-passes 'SP1J4SFHSMMT5Z0PG3WDD1TNGZVCWMB5QBYHNFECG u5)
(map-set mint-passes 'SP1J5W1FN3P80XV1YK14BKC6A912WWFGJSW9M92HA u5)
(map-set mint-passes 'SP1SB5JJSYM2XF51VJSK0VA8063FDJ0W222DSN6HN u5)
(map-set mint-passes 'SP1TQZS5G1Y47KXWQE8WG2Q606664A7MFMPVCKHRZ u5)
(map-set mint-passes 'SP1VBJ28Y0QB1FF0FZP4WYXY6HY5SHREV2T29KQ45 u5)
(map-set mint-passes 'SP1XGQNEBDY7EYAY7KYNG1R3EAKECR2QNED7TNS02 u5)
(map-set mint-passes 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 u5)
(map-set mint-passes 'SP1YNXNHFA35XKSMAPR5ZDA82MRPZ07GVTK4GNK7W u5)
(map-set mint-passes 'SP23X8JVMHN2A9N1PWSGNW83Q0VV5T7NF2N6PJW9J u5)
(map-set mint-passes 'SP240F75PTECZ9RZB6P2H0RRYEHW455V5N42Q2NC6 u5)
(map-set mint-passes 'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K u5)
(map-set mint-passes 'SP25A4G4V7W3XQVCAQW2SJG1END8F1AS6CNTR25Q1 u5)
(map-set mint-passes 'SP26SB34D9THJ8BMSPT6EJHW9JDGBHWMX74PVDFEN u5)
(map-set mint-passes 'SP28YEDDDBM8GT23KVS9HEEGVRD4X35H542K100SC u5)
(map-set mint-passes 'SP2BB2Y38C8EDNEK8JTR126GWEFYKY97AG9HRW9CW u5)
(map-set mint-passes 'SP2C1NCMMHFJXXTCAK3KYYJVY9VV0XH62RMEJNX92 u5)
(map-set mint-passes 'SP2CZWZR52TG7SC1AHPK74EFW5QQRG8F3R6Y48JFT u5)
(map-set mint-passes 'SP2D6HWR368BC9HZH48JHSBSR1WBFHPN91YAW00SK u5)
(map-set mint-passes 'SP2DFZRT48FTXK4SDYVMYK72TETEQ7W33S9RWK168 u5)
(map-set mint-passes 'SP2DG03SMAV8Q8JTDHF9F32Y7B3523ZJYM0Q3MK3Y u5)
(map-set mint-passes 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9 u5)
(map-set mint-passes 'SP2E62ZJM727VRPNWKGM58HWE0BK7JWPQCC57T16Q u5)
(map-set mint-passes 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ u5)
(map-set mint-passes 'SP2F9BGMH0TQ95C38GABBN4P8X61S2JH5ZY5F3REY u5)
(map-set mint-passes 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D u5)
(map-set mint-passes 'SP2FSM29506QZYKJMFGNTAF2V6Q58K2Y61DDT7Y0F u5)
(map-set mint-passes 'SP2FT1HQM6FF8DVDAB8B0RZNX3A76AR81A9T7DJJ u5)
(map-set mint-passes 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ u5)
(map-set mint-passes 'SP2KHHFABJJHD63DSBX0GGY69D2G22P9F1VDVGRKN u5)
(map-set mint-passes 'SP2MBP1G8G58475ZAMAE838DAXX4NY1YKX1B47AWP u5)
(map-set mint-passes 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ u5)
(map-set mint-passes 'SP2TGBAT4N2X691E3HPCFV0P9AZ2RCKYW5RAHG87 u5)
(map-set mint-passes 'SP2X1GD24FA3TGGV6T4TRPKT8MVZ8F02RZESYWEH5 u5)
(map-set mint-passes 'SP2X5KYYXWFCCH30FHQSAP1XVVAVXFT8P8FS44VRY u5)
(map-set mint-passes 'SP2ZR3MD6VBM689M1ZHQT495ZNX4EZ36P4WT8JANY u5)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u5)
(map-set mint-passes 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE u5)
(map-set mint-passes 'SP32CF0E78JNPK0HYDTH3CCZ8FN76PFX5W0FYBN20 u5)
(map-set mint-passes 'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG u5)
(map-set mint-passes 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 u5)
(map-set mint-passes 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27 u5)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u5)
(map-set mint-passes 'SP36NC0KX6RZGPQXR73AMW8R0CXXHS06DRM487A5G u5)
(map-set mint-passes 'SP39MP76SSQK9H94BD4CS92788HG41CQTP2T3D34R u5)
(map-set mint-passes 'SP39XMB07QV4KN4PB6X3KHNQKWARB0F9AXY6K41E0 u5)
(map-set mint-passes 'SP3BRRCHKMPBR60V8ES9J5YF40VXWMABWXK4SEB9G u5)
(map-set mint-passes 'SP3BWAHYMTHQZHSB8N49AXQNTYWBACQBAN8Z4QFRD u5)
(map-set mint-passes 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY u5)
(map-set mint-passes 'SP3CES9R2SAE5MMB5A8ADK3TPRTYCXJZ9WTFJ5ZA3 u5)
(map-set mint-passes 'SP3DEZ8G52PRAGPHX8V7G063KMHZCPZKA53FYKMS9 u5)
(map-set mint-passes 'SP3E545ADCKY56EVCXZPA87525VM0ZA8DQQAEP77Z u5)
(map-set mint-passes 'SP3H0DJMGJFXJ6HP30B74YGK19ADYMD9H13ECSPZJ u5)
(map-set mint-passes 'SP3H63N559PZEPF226BY1WTM9NJP8M6GCACMS8GVC u5)
(map-set mint-passes 'SP3K99VRCD54RDHCBVE92K1VMNTNCJ2J1D4718AYC u5)
(map-set mint-passes 'SP3KMGHQ0AZY23G1RABGD8VT0BY8P2C91J604AA8G u5)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u5)
(map-set mint-passes 'SP3M1X036A4KCD49JZC4M941S4ZDH140ZDVZEHVBA u5)
(map-set mint-passes 'SP3NAZN83MAM6FVES9RP9MD2DC38Y7NTBFGJETQRG u5)
(map-set mint-passes 'SP3R5TCK97NMBS1V1MARCK0YTDFWG1FKJ94EFQTF4 u5)
(map-set mint-passes 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF u5)
(map-set mint-passes 'SP3TZF64TY080GVMZRT4Z87E383Q8EAKZ5W67FCNY u5)
(map-set mint-passes 'SP3WHGMS4S9B6G6NY2QRC1CVYA34ZHYRHFTXJG5KX u5)
(map-set mint-passes 'SP3X16BR7MQ0K690CZ2BGDK9RXA4BXDXWGAR20VK5 u5)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u5)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u5)
(map-set mint-passes 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV u5)
(map-set mint-passes 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG u5)
(map-set mint-passes 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ u5)
(map-set mint-passes 'SP9R1DTP15B10S5WFPZVM8W2FDS6VXP27VA96CEZ u5)
(map-set mint-passes 'SPCJ0JZVB02YYVSR5XVS1JJ17G4ZP1KFGD15B049 u5)
(map-set mint-passes 'SPCP6QYQG399SWCF2TVAFHVHN302TB3ABRTWHPEH u5)
(map-set mint-passes 'SPDAV1G8FQ0TMEWKVE0A9WS8RNDJ7K808X2MY22E u5)
(map-set mint-passes 'SPH2FHVTD5ZTF0EB4FM9K5S2V54JKNX735WKQYYN u5)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u5)
(map-set mint-passes 'SPHWCHVHRY2Q4884XNNSV8B3J1T41PBN0GQE16A9 u5)
(map-set mint-passes 'SPHWY482ANTWNTW2618HYHQSDY1WCW7P20BW5F7Y u5)
(map-set mint-passes 'SPK9KP81Q281Q84SPGAMK8J12X2AQQJGT0XFPPCX u5)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u5)
(map-set mint-passes 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC u5)
(map-set mint-passes 'SPPXHPRQWAWTR92N3XSA0MFMB4402YKQY15HEYVQ u5)
(map-set mint-passes 'SPPZ2SNVDBKSHZDQ2HBBVMB5HEHAXRC3T8CQ35EA u5)
(map-set mint-passes 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3 u5)
(map-set mint-passes 'SPR7SYCKY7BE8G5MAJXNWDMT99AK0FCD4JTAA6N2 u5)
(map-set mint-passes 'SPS4YJD1K7X3XXH45KY67S4Q9HW4210W2FR8CTJ7 u5)
(map-set mint-passes 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG u5)
(map-set mint-passes 'SPVCMKZTGYMKYJEHFN4FABNFBBYMM02HNF66A6N6 u5)
(map-set mint-passes 'SPWD8WYK25NJZNRZZMWQXYPXDW3ZGF7HX8PRR5VJ u5)
(map-set mint-passes 'SPX5F21SSNTWTM55F24TM03S095QYQM7JARDA1F u5)
(map-set mint-passes 'SPZD3EE1M7YMH3RCKNQE1CGPA4VDTGMDCT2QWGQN u5)
