;; genesis-block-heads
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token genesis-block-heads uint)

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
(define-data-var mint-limit uint u69)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmQqr1QvaVrhqkjtQmy5bGsLWaLR4AiK5Br6su6bfkJAYs/json/")
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
      (unwrap! (nft-mint? genesis-block-heads next-id tx-sender) next-id)
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
    (nft-burn? genesis-block-heads token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? genesis-block-heads token-id) false)))

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
  (ok (nft-get-owner? genesis-block-heads token-id)))

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
  (match (nft-transfer? genesis-block-heads id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? genesis-block-heads id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? genesis-block-heads id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SM2JTZ2DHHQFS6J3KVFTPCV72MCN0C03J2ZH6K039 u1)
(map-set mint-passes 'SPWK34YZPVW724K9C8NRZA6VT4YDA2PB5SSD1VYF u1)
(map-set mint-passes 'SPCDCWBEZ9ZEK49BNMDE2MDMJ0E01W02H9SA4TVZ u1)
(map-set mint-passes 'SP3SXDY1H1WY6KTSCYS9GJY14BWPYXZ7FBY50J3VV u1)
(map-set mint-passes 'SP17TWX4K4RXM54Y7E5EM4Z8449J9S626RQJDS9PX u1)
(map-set mint-passes 'SP2RPTD5Q3XZG1KTQYWT8FNEJ9Y7Z60659R6DAAP6 u1)
(map-set mint-passes 'SP1W7DQEJS2E6APJ6CYN8S7Q5QBFXC16E6252P8VR u1)
(map-set mint-passes 'SPW0CHYR5S4J0DM03ACH2PH9ZHPFJ776Z1EQBPSV u1)
(map-set mint-passes 'SP3VES970E3ZGHQEZ69R8PY62VP3R0C8CTQ8DAMQW u1)
(map-set mint-passes 'SP1R152QRXSPH66F8EZNDRQZ8JT867GGDCQYJSXV3 u1)
(map-set mint-passes 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 u69)
(map-set mint-passes 'SP2S7VQN3HW9PRJGVH25DD42Y5RYA1EVE0K4T6V2R u1)
(map-set mint-passes 'SP2C72R5ZP035N7F6EC72P4AM314H8EJNB2R3B70J u1)
(map-set mint-passes 'SP1KNRNZET8ZC5Q9P6F1FFW8YQH45CKMNY132B36S u1)
(map-set mint-passes 'SP3YEFH1QD78NDDM3AJDP83NA0G44SD0YYHDGN50W u1)
(map-set mint-passes 'SP260B53FBVFGPWE48QXZMJWP2QK9MYF47CFB7FYA u1)
(map-set mint-passes 'SP3BQG7P2529G8MY7TFBW16SDB9JXDB0KP7S6XMBR u1)
(map-set mint-passes 'SPGNH14RQWAT05PVG8CEXCM7BGC5PPR01XVGQXPZ u1)
(map-set mint-passes 'SP3QEMQF4T07QM8FTEVK5KN06QBAFTESJ6V56EHT8 u1)
(map-set mint-passes 'SP2RJ3W9P8612G79D421TYPBFB37X47K0NXVJRMF3 u1)
(map-set mint-passes 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P u1)
(map-set mint-passes 'SP08YG111N936KQXZDR6A63857NN3PFSTWS9HFHH u1)
(map-set mint-passes 'SP1RB1V65A1PAAXYT8PVFFFC6T1FN9E8RQX7HMDKC u1)
(map-set mint-passes 'SP356NM5TVNNY3JG2GFD9ZQJ2VFZKZW42WQ10NASG u1)
(map-set mint-passes 'SP3WAAYXPC6WZNEC7SHGR36D32RJPZVXRR1BG0QSY u1)
(map-set mint-passes 'SP2RCT57F74YP0R3YDT7518RRN58M3KQCE4XBS9FP u1)
(map-set mint-passes 'SPB8WMDS3XY2SVY0DEE4YX78PJ7T3MWCZVNSBXAH u1)
(map-set mint-passes 'SP2YJGGD8YZ5F0XZAXERZ0DDNYSGG7SJHTGG9MWV8 u1)
(map-set mint-passes 'SP2WHDYQZA6PGTAZSYVZT8D4YWAKQEMWCP677SDMH u1)
(map-set mint-passes 'SP2Q29784Y6HBASQFKW2TE2E114B3R1XCPXMXM2SP u1)
(map-set mint-passes 'SP20BWCXEXWMWQ0VBNNEAS58FCNNPTHR1T2BHMAMY u1)
(map-set mint-passes 'SP292C3YC61MZR0WKCX941H4TGJPJR14KPHX7XQ79 u1)
(map-set mint-passes 'SP38ZPHD5CXCR97T8SYZHT4Y2EZRG0E9E71XX87D7 u1)
(map-set mint-passes 'SP1BNRS2PKZQFXNC20T71QGVWBB3GTGVHF7HRJ1FX u1)
(map-set mint-passes 'SP2ANTKF09R9B3FTEZE8SDHH4A3HW89NQFPVTXXJY u1)
(map-set mint-passes 'SP4BFY10R39WQKAB3HT2VADFEAR2JQN6VF7FHZ6B u1)
(map-set mint-passes 'SPJ8BB075HDQTA3PHBG5BGRBQ0CXTTY5VJWH05YQ u1)
(map-set mint-passes 'SP25DP4A9QDM42KC40EXTYQPMQCT1P0R5243GWEGS u1)
(map-set mint-passes 'SPBHXX642GM1P1YPBGKAE9PEG5QC2F1FYPPC3TX1 u1)
(map-set mint-passes 'SP1W5YQQ375XGC1Q14D8GZ22MJZMR6QYG9YAYSBC u1)
(map-set mint-passes 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9 u1)
(map-set mint-passes 'SP22ZJRC926622B5PZCP0PCJ3Z913VRH27AAEFCJF u1)
(map-set mint-passes 'SP1WY6GSNF3GQT6ZGE90SC5EGNQGP9HVHAZ8F3KQN u1)
(map-set mint-passes 'SP247EWGY9X06WMKZ83JNY0TAFSXAAX5KHEDBBND u1)
(map-set mint-passes 'SP3EVSTZBE5BKHBREY4RMX5EVH3PJDTPKBG73A6QA u1)
(map-set mint-passes 'SP2Z8YZ7F4PNQ8ZX1PA96KC2DMBBS9GGD2CPM8JZ4 u1)
(map-set mint-passes 'SP1H28CYV71AJJKNXDSF9VTGTGK97KMXZ8C2WP05R u1)
(map-set mint-passes 'SP3731FXN86HFJ5SH525315DD37AA9NV5TBZ2ZKWX u1)
(map-set mint-passes 'SP1FA9SHWCYDVPKEVSTY7CX21CWCJ7S8FS4K3YQMZ u1)
(map-set mint-passes 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK u1)
(map-set mint-passes 'SPNFDGPASBB91FVB0FCRAZ0XCPSSZ4Y56M2AEWDZ u1)
(map-set mint-passes 'SP2YHM8WK50C6BC1HZHR25AQZ07S6ZPHPDMQ43348 u1)
(map-set mint-passes 'SP1ET2F3ARW365ADA90NPV9SJHEBWAVVNNHQGT1PH u1)
(map-set mint-passes 'SP3NE0MZWEGR6146AGB246T0TP4443SNXJ4R4YT21 u1)
(map-set mint-passes 'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D u1)
(map-set mint-passes 'SP1REGTTRBMCV355TCW4C5V2ZC8EVA9YV58P9HY9K u1)
(map-set mint-passes 'SP2352EC7BPEH5ZWT5J3P7PE59FVGAPN0R3SPF2QK u1)
(map-set mint-passes 'SPY3VW50YQCEWD905SSBPVF55D1E502ZV24TE2M6 u1)
(map-set mint-passes 'SP2DVB9HBEYB5CKWZJBQWE1FD5HD5FBKTT5WGKX2E u1)
(map-set mint-passes 'SP2MYQF316JWNY0M6MBGRFPZS17GJKRA26ZPB35HM u1)
(map-set mint-passes 'SPTETYQFT9B9CK357K88PCF52TBZQ1WP9S3AR4S3 u1)
(map-set mint-passes 'SP2C9S8TX2PTGA7VHASYQR2YTMEM8Y7YY7TP5SS77 u1)
(map-set mint-passes 'SP17BW15G6T4J235NZ2AJGT1GGFASTWZRHMACJTVB u1)
(map-set mint-passes 'SP3XAE8ZCDPVHMQAHFD3AH0V9QZGRDSY4RJ4WGG06 u1)
(map-set mint-passes 'SP3BEQ90BXKTCWKQ1W26Q7K5TXV6C3J1JRY6WSCF6 u1)
(map-set mint-passes 'SP1VYAAXRND04WVXHBXE1PWAY0K6NSSKVDTEYB02H u1)
(map-set mint-passes 'SP2HP27QTECKF97ZNWYEF9QFS4HJTTZTR8CJPBMMA u1)
(map-set mint-passes 'SPSTE5R54386QDCDNJJWH2EXQFST44QYZW3RPMD3 u1)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? genesis-block-heads (+ last-nft-id u0) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))

      (var-set last-id (+ last-nft-id u1))
      (var-set airdrop-called true)
      (ok true))))