;; the-funworld-1
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token the-funworld-1 uint)

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
(define-data-var mint-limit uint u2500)
(define-data-var last-id uint u1)
(define-data-var total-price uint u5000000)
(define-data-var artist-address principal 'SP9C39XV8GD9XBQ41JDYG37ZP7PFPHYHQ89HHRAA)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmUN7gh1mBhQ7TWxJWEmSw49pa8ZHbNgmfmHr3DwbePySC/json/")
(define-data-var mint-paused bool false)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u50)

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
      (unwrap! (nft-mint? the-funworld-1 next-id tx-sender) next-id)
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
    (nft-burn? the-funworld-1 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? the-funworld-1 token-id) false)))

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
  (ok (nft-get-owner? the-funworld-1 token-id)))

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
  (match (nft-transfer? the-funworld-1 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? the-funworld-1 id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? the-funworld-1 id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP117B1ASC3ECDJY45D0XZ0S056QBN1EPB181ZRYE u2)
(map-set mint-passes 'SPA3KR1NM8TM4T8AEJ47K3MM7YF97F22PXJWYCSR u2)
(map-set mint-passes 'SP20QS4PBRFWRQFHVKQHBR3C8TETC6H89QMXBQB8M u2)
(map-set mint-passes 'SP371DE1X38QGARG75DX5VFJRRHX3RWTN8PF6J4MZ u2)
(map-set mint-passes 'SP1C8ZG23WE412GV4GJ32AK82CCR1HYD6T9XRCA61 u2)
(map-set mint-passes 'SP1ERZ9JS6WJACN1AGZ3KDEMMCDFGYXBYX37YPF90 u2)
(map-set mint-passes 'SP3HXYJ9WBTTQPJ7KA0R3SSFYRPC7FC21X9NKAV82 u2)
(map-set mint-passes 'SP11EY3Q9JHMJQG0X8CQYPG4EH143C6W4RQWJ9HXQ u2)
(map-set mint-passes 'SP1VEHWR3SVWZWN24YQTHS3CVSMWEHK39CBM6Z3F5 u2)
(map-set mint-passes 'SP3WYQMPRNTX8VTKKD4TVS2W7PEYYP3V3Y24KNQ4F u2)
(map-set mint-passes 'SP1P59JCMGD6KPP1MPZ7G0561T69T7GBNP77HMQKY u2)
(map-set mint-passes 'SPNC2PDJG1SXA8ABKEH583Q46N73PBKJDQ7NN8FY u2)
(map-set mint-passes 'SPNMMG0PN9FZ97DHP93JQBGJ0XAVR976DZDRTYME u2)
(map-set mint-passes 'SP1VEHWR3SVWZWN24YQTHS3CVSMWEHK39CBM6Z3F5 u2)
(map-set mint-passes 'SP3YS96DAJ71KR5AX9DNZ5TV5MRJNR7TF91JGRAAD u2)
(map-set mint-passes 'SP3EMZ5XM95XZRVFWB5M8JH3VRMMPJ8661WTT1M3T u2)
(map-set mint-passes 'SP14YJ2XTPGK7MAGFFEFQEAQNY4MSZQAX76TRY35V u2)
(map-set mint-passes 'SPV23A00HS4HZ0BMK0E41BQKEEMJSN8NHHD5D3DK u2)
(map-set mint-passes 'SP22VMFQQYSGY8DJ9AKE7ZJVRXZ0VA20PMHSQHXG2 u2)
(map-set mint-passes 'SP2ZM0FFZGQ64SX8G287QJEPH2KYF0EZRDJ15PSYC u2)
(map-set mint-passes 'SP71MTEW4CRKYW2QNFR7N51T5JCF48J4PW5FTMH0 u2)
(map-set mint-passes 'SPFPA79NV316NDZVEXEZV2ZY51JMMTN1W6R3SV1P u2)
(map-set mint-passes 'SP1XFW2RK5EG9A6DE101NRVRZ284GJT7VH03GB4CQ u2)
(map-set mint-passes 'SP1MP4A2TZBX935NS93V5QP8ESG8534XARQFQPCMG u2)
(map-set mint-passes 'SP2ZMWSVZT0NZVZNJVE00JJK1SKK6JS2WJXFN835M u2)
(map-set mint-passes 'SP31M4GNKZBE8170FK77B79K10SMJ1TY4WXRWBKCH u2)
(map-set mint-passes 'SP22BKD06TYSSNGRFP5C1ER60YNB82D6EXCFH8V9W u2)
(map-set mint-passes 'SP1TWCXW6SY2GHSS5JF7P626DSQ4GF69DM0KW5AD1 u2)
(map-set mint-passes 'SP332VYKHEQ5H9Z9JNG33R4QCHVCY37FHBT3272C3 u2)
(map-set mint-passes 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ u2)
(map-set mint-passes 'SP2NTZ5ABMMMX1KYEHK3KYK5ZV6FKWV01CXRNYT44 u2)
(map-set mint-passes 'SP3J3WXWS5QTABAE0S14XX8BXPW76RJMADGAX3FR6 u2)
(map-set mint-passes 'SP2YDZB938V1QNSRN2XCCP8YTWEXVC89HK9DFYDCP u2)
(map-set mint-passes 'SP3SYA6GERCVS6W1YT1W6YBTD8CT2B3VP1D3A3QXB u2)
(map-set mint-passes 'SP2N7DTS8E7NZ4V2SX054F55NSZ4E50MSJ1T93T1C u2)
(map-set mint-passes 'SPWR61YRMNPGX6JASY3ZR6SSE79ACV143YW1PCAN u2)
(map-set mint-passes 'SP3G66A44EY1W1ZJPCPYEAZFRAHKP1VFMQHXVGC3K u2)
(map-set mint-passes 'SP1F3GP5V3S7BCDXZAJKY7WAVQPD78PF3MV7W3QT4 u2)
(map-set mint-passes 'SP36P1SGYN80RJ5P396F484Z4TX51C43925Z98CN6 u2)
(map-set mint-passes 'SP2VWCSY0H6J2RGB1FZPE5JH5NYK9ESZ7N7X7R9SQ u2)
(map-set mint-passes 'SP17YS93R5XNDCJBGERPKEZP0YZK6AX3S30H9KHWB u2)
(map-set mint-passes 'SP71MTEW4CRKYW2QNFR7N51T5JCF48J4PW5FTMH0 u2)
(map-set mint-passes 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ u2)
(map-set mint-passes 'SP1Y0XCBGSE39Z7552QM0XM7XC76W6QA5TD6XZPHB u2)
(map-set mint-passes 'SP36P1SGYN80RJ5P396F484Z4TX51C43925Z98CN6 u2)
(map-set mint-passes 'SP1ARC8PTHHY7C9P076ZHH5MM6WDWA0XP2EXKVZJE u2)
(map-set mint-passes 'SP1VCQ86R56HYM1ZW74VQ1175H63QZ35J2NBKCH0 u2)
(map-set mint-passes 'SP71MTEW4CRKYW2QNFR7N51T5JCF48J4PW5FTMH0 u2)
(map-set mint-passes 'SP2G0FBXM561SBEC35CANQYQ5R58XE5K3T0V1QZKB u2)
(map-set mint-passes 'SP2ERDW562DCZFY3F8GCPN4KZCEZGYH8P1XYNTYQ1 u2)
(map-set mint-passes 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ u2)
(map-set mint-passes 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ u2)
(map-set mint-passes 'SP36P1SGYN80RJ5P396F484Z4TX51C43925Z98CN6 u2)
(map-set mint-passes 'SP9C39XV8GD9XBQ41JDYG37ZP7PFPHYHQ89HHRAA u2)
(map-set mint-passes 'SP36XNA335HA6Z0NSDW859R4NGF631HGH14FZ6HX9 u2)
(map-set mint-passes 'SP36P1SGYN80RJ5P396F484Z4TX51C43925Z98CN6 u2)
(map-set mint-passes 'SP36P1SGYN80RJ5P396F484Z4TX51C43925Z98CN6 u2)
(map-set mint-passes 'SPA3KR1NM8TM4T8AEJ47K3MM7YF97F22PXJWYCSR u2)
(map-set mint-passes 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ u2)
(map-set mint-passes 'SPY4D6C43JJ9JHEYJKV9YNT5BE7GNN42DSTCBH10 u2)
