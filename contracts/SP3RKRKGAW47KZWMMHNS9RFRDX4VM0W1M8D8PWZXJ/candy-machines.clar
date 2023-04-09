;; candy-machines
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token candy-machines uint)

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
(define-data-var mint-limit uint u1980)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP3RKRKGAW47KZWMMHNS9RFRDX4VM0W1M8D8PWZXJ)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmYu1QsQNQ1J41T37EGvSJTbqerPjhzs9prxG8CJKGvzw3/json/")
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

(define-public (claim-fifteen) (mint (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty) (mint (list true true true true true true true true true true true true true true true true true true true true)))

(define-public (claim-twentyfive) (mint (list true true true true true true true true true true true true true true true true true true true true true true true true true)))

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
      (unwrap! (nft-mint? candy-machines next-id tx-sender) next-id)
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
    (nft-burn? candy-machines token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? candy-machines token-id) false)))

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
  (ok (nft-get-owner? candy-machines token-id)))

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
  (match (nft-transfer? candy-machines id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? candy-machines id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? candy-machines id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SPBT99HP63WJVRCTN8PET0YDA3F4C7H6FR65RF43 u71)
(map-set mint-passes 'SP2GY6KXK8KVK1NDJCT94F7XRR4M3PMAEZHFP39SG u42)
(map-set mint-passes 'SP1KQEX2HT2MMD1QX4W7T30KMA3Z8YA7GCK8P0QZF u28)
(map-set mint-passes 'SP33KB2G3283036G86GNDY12XQYMPPCT19AWQSSPK u25)
(map-set mint-passes 'SPEPFVG7XP2NMHVHV2VV0CKSRMDAA2ZY3HCER735 u25)
(map-set mint-passes 'SP2QHYNHA6B6E3BEJ3F8EWXM0B4SX8HYB47HY4Y4T u20)
(map-set mint-passes 'SP9E56K8HSXJX2MH8SYYW6P5GC1XVNMS9R3EFPK1 u20)
(map-set mint-passes 'SP1HQVECAMXDNDYMYMJ7B3NDEX8PZWP4QTNMXCAS7 u20)
(map-set mint-passes 'SP1AP53C10NS69WKAXJBV6KH3S4BGYYDMJ9FGKJQR u20)
(map-set mint-passes 'SP11XPKEMW4VE67C738A62Z6J2CHKVV5F0N1TBH0B u20)
(map-set mint-passes 'SP16J8T38SKQ5M1TZ87XJ4DB35QATTC61B83CEF8H u20)
(map-set mint-passes 'SP16QH0F35PF78B34CRRQS35NSQ8S0V1ESQSNQTCD u20)
(map-set mint-passes 'SP2N4P4HH1Q7Q6FGPY2X0YS7YDQCG2VQB2HXRJMTH u20)
(map-set mint-passes 'SP3FW89Y04KA8RC5NR45AP6Z2192XXAP5Q3WJDVJ3 u20)
(map-set mint-passes 'SP1Z8G2N0SCZWJX3PWP95K4J4QX9ERASMB3PS8EK2 u20)
(map-set mint-passes 'SP29P3AC5AG5G5PCNFQ2MP5W1NT3KE1PPDN84JQX9 u20)
(map-set mint-passes 'SP3KM2GJ82AHHT2X5129KFG6EFQE6G6DSFPD0F72T u20)
(map-set mint-passes 'SP2GE85H1TMSGQ8CHTFD0R7QBW1NPX1WZVSHYDTD9 u20)
(map-set mint-passes 'SP3CTXJS1RC1QXNMMXGZRDN3AP0SVAJ68R3TH33RR u20)
(map-set mint-passes 'SP23TJ243GSNPEGEPF194GF2K8D6NC66FFKQ9B6BD u20)
(map-set mint-passes 'SP1WN0DX921K3CN9WJ747AX2HFEE71J2NSS5HVS12 u20)
(map-set mint-passes 'SP32CQDHPAN97PGRZ42D2Y5FA138VHYZZH0JNZ3MV u20)
(map-set mint-passes 'SP3VK6PT17QWV7ZXHVQFSY614QS2ZD0CSCTV5RXZ u20)
(map-set mint-passes 'SPG19T6VE5REY80FAZYMQS5RWC4HSY1WB327VHCN u20)
(map-set mint-passes 'SPFNY9QN7AQ0C6YRSDP62P3C5T5B1PWS8FZFPPPT u20)
(map-set mint-passes 'SPYV3R6Z83CMH3XD199EY3HWTXMZ6QXWMZZ8E2EV u20)
(map-set mint-passes 'SP2303Y0D4EEWMS83EVMFPB5HY0TC0KY886E5JTXC u20)
(map-set mint-passes 'SP1Z81PKE996PQDP52K8GNY35P2FS96G4D7K4VSJJ u20)
(map-set mint-passes 'SPDJTG93XPMGQD8820NAGJ6A9FJ8XM0Z780HBHZG u20)
(map-set mint-passes 'SP1C1CZ5DVEWT20PCVJPP6601EY3EQ0807Z2TS9QP u20)
(map-set mint-passes 'SP39DR42FAAV8SZYHC5N30VHD6XFYQ7K8VZHQEPHF u20)
(map-set mint-passes 'SP1WRSN61Y64J41AF5KR1S3CCB51NXT3RE2VWHT9K u20)
(map-set mint-passes 'SPZ9TTR7VC1WPCWAY9ZSF94KNEW1TVVSTKXN19VS u20)
(map-set mint-passes 'SP39RYKMMA1RNVMRE3SZGJTRAFG37YKZFFZSHN0KY u20)
(map-set mint-passes 'SP2B4PWMT2BVSKA8XRDHSCPTYG62WHHGMVTC32B07 u20)
(map-set mint-passes 'SP2Q72G1NWV8DNJ7FFFRR5E8PZ0REFW9H79M8D4XX u20)
(map-set mint-passes 'SP2DYVDNHJCBCWS058W9AVHQHEB9SC8DWZF7DYPAN u20)
(map-set mint-passes 'SP32KNMV86F5V4PMDPWYNCF63HWZSDC79QT4C9MXC u20)
(map-set mint-passes 'SP2GABYAVP2PBM2NST2KG2B8B7WBGJB3PWRHVWVT3 u20)
(map-set mint-passes 'SP1CR5KFKKH9SG9ZZAAGZCHTQ2KC3GXJMFX7MTCW4 u20)
(map-set mint-passes 'SP3JYMPHKF9ZD4S6MJDC29QN45F884J3TA5V9P75F u20)
(map-set mint-passes 'SP1JE4XNVM0A842Z596KBY8GYVSM7BXJV4PDK5XGJ u20)
(map-set mint-passes 'SP33D7CVZ6MQB2R93SDZFWNXVT5VFGPAPYF3JDA1B u20)
(map-set mint-passes 'SP3XNFR830HPK5S9PN8DVJ2Q717VKXQG3MRD38NV5 u20)
(map-set mint-passes 'SP1DC40A0W9YZF975SW2T4W04Z301RJP8KR60QPSZ u20)
(map-set mint-passes 'SP2ZJPW4MBFVDQNDXQ9KVTMF8YKHBYW8S1YCS355Q u20)
(map-set mint-passes 'SP3ABNV67MV57NT80RK8K8QE5ANJRRXJ67SRX00FQ u20)
(map-set mint-passes 'SP1JVRDTM09TXH2ZPNPT9CZ28363D7ZQFP02NX7AJ u20)
(map-set mint-passes 'SP287KXFH68MG7GJB7CKZP6CDTNBN1VGW75DWXF6S u20)
(map-set mint-passes 'SP3M8S7CWEFS0SN6S5RA24KRDAJRB9JA4MQ3CS2H6 u20)
(map-set mint-passes 'SP18CEBV2MR6QQGJJ6TR910MXAQEKMSWP2BX5C9W5 u20)
(map-set mint-passes 'SP48RDHNMEBN7A4ZA2BJ0TTE36Z3AM88PH2JCDZM u20)
(map-set mint-passes 'SP3TMJ7CADP4YAWNBQSSYJ5Z6W0SQFX1CM2HR4GZ8 u20)
(map-set mint-passes 'SPWVW7CC4K3KJ4C0N2HXF4ETB6QQW12RNS3PJS20 u20)
(map-set mint-passes 'SP35RGAF2QEMEE8D0CW39AMA0A7AQT65RYRQ5N7TR u20)
(map-set mint-passes 'SP3R9TXW2355P6G2Q2F4JJ1QZXPJ6Q056DGQSQZ7D u20)
(map-set mint-passes 'SP372DK5NNN95JRC48EKC1VJXA64YYHJJSJJ3NH43 u20)
(map-set mint-passes 'SP1C80BTHBPKR5GZVJD28VT3967RX58XCP8Y0HD33 u20)
(map-set mint-passes 'SP60WTVM3NVD3TGY7TSQ0XK9CJ5X99SSVWET1376 u20)
(map-set mint-passes 'SP2QWX5Q8QPC7CXFCA982CY6AFYA6ZSGHK29JRTJH u20)
(map-set mint-passes 'SP381SKDFV7RD8KY9E80355NMXFV68PXVB7PRGDV9 u20)
(map-set mint-passes 'SPEHYD6MGE8KXQ6QYYN12C7X7S8G4WJE812MGDPZ u20)
(map-set mint-passes 'SP19ZBJZ180MTN5V5BXN5E9PYPQ935ZDJYAHHE6ZN u20)
(map-set mint-passes 'SP1A2G4PPQX8QZJXEDXAVR41N0THY5EWQP35W1AKA u19)
(map-set mint-passes 'SP1EDT7P1HG93FCGNX19BQYA68SX2V1PVBDAAB79M u19)
(map-set mint-passes 'SPK8637VR1RY02R2WHA8E5KZNY418F7YEA42HV2S u19)
(map-set mint-passes 'SP2W8G35SMSWRMXXBCQ74MJQS7BHY9EN47MX13FZC u18)
(map-set mint-passes 'SP375NBE6HZFVZTDPQ2H895JGCJV7KZ97YBGR17MM u17)
(map-set mint-passes 'SP3RKRKGAW47KZWMMHNS9RFRDX4VM0W1M8D8PWZXJ u17)
(map-set mint-passes 'SP37XV1AFPN559MHVGNGE97764Z0XGNC5HT6PKG81 u14)
(map-set mint-passes 'SP1KT90149338B5KY9X8KD1V0TWVN8A594CWQP5PD u11)
(map-set mint-passes 'SP3P8PMKMYJQ9V16A6EZW2XHH1P29JN58R31VQ4VJ u10)
(map-set mint-passes 'SPWPS5CRDVJFVJJ53ZH8CP7RZNQY9EGTQVE5ENNT u9)
(map-set mint-passes 'SPQPGTADAXTM1SDBBW3A2E5D6YB9GVG6QHPRAT9W u8)
(map-set mint-passes 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N u7)
(map-set mint-passes 'SPBNAM3RV2ZTXAYRV70PETHWSJ65NA319JXCQX08 u6)
(map-set mint-passes 'SPY9DW12N3ZEQFC3Z3XDXRRM1C6KW08XK2FGBHD4 u5)
(map-set mint-passes 'SP2J9MAHFVWY6VNP23VJCKX5E0CEE98TA9ENZECRM u5)
(map-set mint-passes 'SP1BFMJZ9QMGAA682FSKGHKQ7ADWMK7V23GHFR9R6 u5)
(map-set mint-passes 'SP6GT5H78G88AWVCFCGPMAGPJ98X4777HHV0GX1T u5)
(map-set mint-passes 'SP1MBPA56XD15H6XFSH4EH1CGSRXADZEP6Z38D4T8 u4)
(map-set mint-passes 'SP14NSM2BAB9MGMYNXJB93NY4EF4NFRW3G3EFBZDX u4)
(map-set mint-passes 'SP2RNHHQDTHGHPEVX83291K4AQZVGWEJ7WCQQDA9R u4)
(map-set mint-passes 'SP3NZQ62TW5P6NHP55VCQVDMPCAM8XBN01VFN08ND u4)
(map-set mint-passes 'SP1FHC2XXJW3CQFNFZX60633E5WPWST4DBW8JFP66 u4)
(map-set mint-passes 'SPPDZ2G6ZCY2VHVTTRVPVZS5KCG4JG8T6WEHTC7Z u3)
(map-set mint-passes 'SPKF5WM8G0KZJGAGVR24RHQJ2AT2D0HGD4ZNCFVB u3)
(map-set mint-passes 'SP1D4H9504M5ZQC1P2JYCDPP3159R4R7YYWPWTJE8 u3)
(map-set mint-passes 'SP1RR941EJWD105F07TAS0J2RJBNHNWWJZCY51VTC u3)
(map-set mint-passes 'SP2GHCPM134Y28EZKNKEMF7SBK0BQ1QW1QASYWS6Z u3)
(map-set mint-passes 'SPAFPBD7M89973WDEN68FKYW761RQVYNHSEFQZB9 u3)
(map-set mint-passes 'SP15BRQ6EZ8XXR29PS5GKCGK4PTMPS9SNYF4G525F u3)
(map-set mint-passes 'SP2B93T7B69V2RX15CDTPAQGWGFN9Z236YBCZD4QZ u2)
(map-set mint-passes 'SPFG2SXNYF6PYNRPXMMZWYEC16YKECSZY05230E3 u2)
(map-set mint-passes 'SP9Q05TCQNH0B2HCFPYS5A41XTGC57G177VPK6RJ u2)
(map-set mint-passes 'SP2YCWKYB5GCYTQM5RFERSXMZNBEZPNPBDVS9A88S u2)
(map-set mint-passes 'SP2EFVYVAN1B3JNDSBGGBQ3J93DDGJXZ190FFJXQM u2)
(map-set mint-passes 'SP1VES0WGZ4SWFW3SX2TDP7ERJGX8JZ34F8BYJTM6 u2)
(map-set mint-passes 'SP3T156FGQ9J6H9A6AZY2BA6SJJCCHPZB0Z97STDF u2)
(map-set mint-passes 'SP231KPESDNPMVGP5A95EBR2MSCGB6H884AWTK38E u2)
(map-set mint-passes 'SP1S0B05BFW099N2C30W7T788QE4645M72EP6AV3X u2)
(map-set mint-passes 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S u2)
(map-set mint-passes 'SP2JXPJC6T0EP852YPDCA4V7NBHZ6MYV6GAQ434W3 u2)
(map-set mint-passes 'SP2SVZF7V1SHMK66N1B81XS1KJKNW6M9D8CM10MV u1)
(map-set mint-passes 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1 u1)
(map-set mint-passes 'SP32VXA20ZGV3EQNRWGRDDF204GWACTM3T3H2RWMT u1)
(map-set mint-passes 'SP28SSAJE27D5AVT99F00X4A6BFRXZ4CJTW4FD61G u1)
(map-set mint-passes 'SP3XE1GCCEVW4DW334Q7VQX3S07AZBA0YWM0PQNRH u1)
(map-set mint-passes 'SP22NMA8APQ8PNHZGS2B5JWTHFQWXJRXAP6ZVM93S u1)
(map-set mint-passes 'SP3WSJCKJRAHNWQ3W7PPMMHZGBZ9VXJ7N6TEYXWWZ u1)
(map-set mint-passes 'SP2AEAYP3KBKR3CNE8GPQSWW24HYZHAYEBJH03QY3 u1)
(map-set mint-passes 'SPBNDRXQ0KMB8C1ZMR51Z6XNWQ1VES3FHX4BZ7EQ u1)
(map-set mint-passes 'SP1DK0Y2WS2JEN0EDRNT2K60C5F20FGHAF06VTP6P u1)
(map-set mint-passes 'SP3QZ9VDXBC7KXC7CSTT97TE201JNH189JFGH6YD7 u1)
(map-set mint-passes 'SP1HDZ821JH49VB8T7W2WRJGVW51BHN11C6AGMYYD u1)
(map-set mint-passes 'SP2FH2AGPPZ23GZ3RPMD1SHV5Y34AEDGP3KHGS6MV u1)
(map-set mint-passes 'SP2NQW8VBE2F31XFY8R4FHA3ZRCGZT8SGKKFPVA3M u1)
(map-set mint-passes 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC u1)
(map-set mint-passes 'SP3X438JHXE9ZDMPTH58EHJM6MD7QRS304FW8982 u1)
(map-set mint-passes 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 u1)
(map-set mint-passes 'SPYJF7AM2ZDMMEB01M425SEWH083VGB7Z2MVG1RW u1)
(map-set mint-passes 'SP1K8RG4PV202FHT8J9023G1WJRPFTSZXN9TPNEJX u1)
(map-set mint-passes 'SP2W759AWBSYJ7HCA8K5CRV06DN1WGPH7C926YHJ3 u1)
(map-set mint-passes 'SP1FVRY1HAP2CAY6B0CX6ZS9C8C6TGXKWQWBTTNX2 u1)
(map-set mint-passes 'SP3DSCWD2P59NZEV0N07GEZ74SRBP9HMKKZQB2ZCQ u1)
(map-set mint-passes 'SP1XJ6GNTDVF6HR1VHPQDMFZJY87D9W6TGMH3QCP u1)
(map-set mint-passes 'SPEXAF3YRNCR01Z4DFZ567Z0FB4RKPHM88DMKJSQ u1)
(map-set mint-passes 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX u1)
(map-set mint-passes 'SPJPPQK1DNTWNAXT98ADARAFENKJCX1NFMK2EFQC u1)
