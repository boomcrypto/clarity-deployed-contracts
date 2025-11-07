;; megapont-stacks-rocks
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token megapont-stacks-rocks uint)

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
(define-data-var mint-limit uint u108)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmXWFBuLrJ9wogjLV3ghRNSjBg8vhMooYPbfNDXy3Eib8u/json/")
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
      (unwrap! (nft-mint? megapont-stacks-rocks next-id tx-sender) next-id)
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
    (nft-burn? megapont-stacks-rocks token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? megapont-stacks-rocks token-id) false)))

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
  (ok (nft-get-owner? megapont-stacks-rocks token-id)))

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
  (match (nft-transfer? megapont-stacks-rocks id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? megapont-stacks-rocks id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? megapont-stacks-rocks id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP059120SJ0FND8DPQ6JRJFSMTRXN5HG249RPDW1 u1)
(map-set mint-passes 'SP3317P4EAGS3AHWPNA9MJJ1R8WPZHH1MTGKQPGMG u1)
(map-set mint-passes 'SP3GKCB51E0CFAVX9VTP9H1ZFBDBVCNKFGFY1A1TR u1)
(map-set mint-passes 'SP5RDMJEBPG7JMBQZY0NANZ7QK7SV896CWMHPSEV u1)
(map-set mint-passes 'SP87Y4CTE1SRE51EJKWJF65XQ7NN47EZKZ0YE0BS u1)
(map-set mint-passes 'SP1WKGH4BFFR0EFHG7XQ1TQM2GX3R9EAMR3HBEBV u1)
(map-set mint-passes 'SP17QM2S9HJAPQ1RVTNHX5KGND34SAAFKRWCSSZP2 u1)
(map-set mint-passes 'SP227MP5547DKQVTK484J01HR3S361JW574Z41DN0 u1)
(map-set mint-passes 'SP18DZN1WDHRGCZK3WP9TBEXSV0E93ZV1HFVZFAQ3 u1)
(map-set mint-passes 'SPF3XEAZJN8082KZ6G7AY2W1RQBM6KSYH7ZB1BWK u1)
(map-set mint-passes 'SPN8S9KXCH882ZQ6GPEY8M09MQP2MHM39JDTZZFS u1)
(map-set mint-passes 'SP1ECEQY0J5B83ZNQ8EGBAEB4W9BX41X9REVSYYYM u1)
(map-set mint-passes 'SP3EPTMJ6RM5FJNGRPXB4TYXCD1KVBKV9DY7HNBXC u1)
(map-set mint-passes 'SP3J3GD9NXPRXWMGMJ41XMQ5DFZ6TY9ZPF9Q6CGSH u1)
(map-set mint-passes 'SP14CR6AWPG3NNFPQKNEZ7T1T7966H20HFB3RKHTG u1)
(map-set mint-passes 'SPPHY8N5X171P7YYMF5HJX2446FGJNSE3WVDAHH6 u1)
(map-set mint-passes 'SP3JA2NVXF0F3DGGFWGJNCAQVDB95SQG2HPET5CVD u1)
(map-set mint-passes 'SP21A5QC5QSHZWFV75KVK6CJTM9TT106H8B0KK3WB u1)
(map-set mint-passes 'SP2DQ48687YAT8T5Q774GZPSY2ECVXZD582JQT62W u1)
(map-set mint-passes 'SP10WVQKJVA63J6ENQNDQTVXWE0PGE2RG6EPWA12A u1)
(map-set mint-passes 'SP1F95B2NME5ESBTK4AV30ST07P8WHM47STFQEB4Z u1)
(map-set mint-passes 'SPB50XY4255SVZJQB38HSKS9HQXV9VTP5Z1E3NBZ u1)
(map-set mint-passes 'SP1FTT6EGHNWQXEMWQ2RXYV1F0M1RKXW1R6J9C2CB u1)
(map-set mint-passes 'SP3VBS4TJCNR4QYV9JTAJ6GYJ063G3H6Q8MR7S8Q9 u1)
(map-set mint-passes 'SPGKGMANFTHA4ZE7DKKNTFC1K9X5HA0D045CYQSK u1)
(map-set mint-passes 'SP3NM1PQ4H7CT992DTSKT006GTDBPMJM4B4W6DWSZ u1)
(map-set mint-passes 'SP3KB0DJ8ESMX4K9CHK4JZG8RNQK85NP9DRKDKB8Z u1)
(map-set mint-passes 'SPWCCR5VE005ZPFMGZZHJF55ZV7HCQ4ZEXZPJTDF u1)
(map-set mint-passes 'SP3TFA72CEB9D0Q5819NBXRNC1P207211P5QZYJPD u1)
(map-set mint-passes 'SP24KFZ331AYT5GHAG7TV4VGFAQ0KPREKV4C0M7V6 u1)
(map-set mint-passes 'SP1VY22ZKJ15AWJ3BQ9DGNSG0MZV8ZAY367WWRM4K u1)
(map-set mint-passes 'SP1AT8GEHHA0KTYXPDWPNB9RHK0EBT65FNGFWYAWA u1)
(map-set mint-passes 'SP2RZDVRZNA2HCXRZ7PKA2N94F77HZTD4SAHB1WFJ u1)
(map-set mint-passes 'SP1GAFF76XSSMW4231N3GHWMBMBPRK60GAQA4S1AE u1)
(map-set mint-passes 'SPGVS9QWQDAC7NHV3F23W75F5H12YM7EKCWE3JQ4 u1)
(map-set mint-passes 'SP2NX0CWK9YXYZHB9T397XDCC8G66F2SZXTCRWBTJ u1)
(map-set mint-passes 'SP2739YJ42SX63GTCF7WBWEVBCCGG59WA5XJV18R8 u1)
(map-set mint-passes 'SP1K7R739817QB4PDPCAAKF3AGT0TZ5K007B6677K u1)
(map-set mint-passes 'SP28X52DFRVDC87R10KT9BXCPZF414MP77C64HWW3 u1)
(map-set mint-passes 'SP6Q5QQG4NFXE4EEXE8YEWTXX0QZR1TXAE03X9E2 u1)
(map-set mint-passes 'SP2C6RV8WVCT18DC0CWME1TJAY4THX6J04RRRFSWM u1)
(map-set mint-passes 'SPWBTK3EYS2B4DCC3PYVYEHXCKRSB2MD441DYADS u1)
(map-set mint-passes 'SP28WBBK28DZ9SFVAGMX1J9MYTQJ1PCNS0NNQ0MQ1 u1)
(map-set mint-passes 'SPZTPMF6PQG4DAKA2FWQ92CYHPJFNTZKY1569GFY u1)
(map-set mint-passes 'SP2Y4MMQE1TA8E76CS021AH4GA6W02CQM3DQ1BBHF u1)
(map-set mint-passes 'SPR3J0BMW0YYYPZE3ZTPE2FBRZWWJ78FMDP1QVDF u1)
(map-set mint-passes 'SP18SS59HFRW1VXD4BQPY8NBMDCXP8HB7C524FMK0 u1)
(map-set mint-passes 'SPDY3FSV9BH6A23YW8C6N16Z9HDZ6RD9NP0YV0BE u1)
(map-set mint-passes 'SP1MRXFQT7H0XH5GG3CKBDV19MGNMN53YTT5DR6TG u1)
(map-set mint-passes 'SP73QBRYYHYE070XXGBBP30WAJBZKRG9RV37E0Y3 u1)
(map-set mint-passes 'SP2V71GJPWSP93H44XG2Q3DZ2ZHV54A61HXRVGD6A u1)
(map-set mint-passes 'SP36C6RP6AJXXJMTS7QGN3HE85R731AB698TXRCGA u1)
(map-set mint-passes 'SP5FS5S843NG50AT5F1RNJB3T1Y51PWAK5RTWVZE u1)
(map-set mint-passes 'SP3VS4BC5PWSERHE2XVR5JQJR27SBGFF7XA7EZ2H2 u1)
(map-set mint-passes 'SP66X8R5FC8G9WW70TJP49W3AMXNXBRH5MT6D6YV u1)
(map-set mint-passes 'SP2TC5GP7PDQS0HK17MHDE3TPZAQB8Q1M7PNYZPGK u1)
(map-set mint-passes 'SP1Q3GG0KQ67C266T53E55E6E3KDS3HF82VRFS48H u1)
(map-set mint-passes 'SPQW7VKPTF1KN6596R6T9RZXZQTERK1M9G1RK2X7 u1)
(map-set mint-passes 'SP3RT5VKN5W5PX3DQ99JVR7G5PJ1MV4RJWWMZHX6P u1)
(map-set mint-passes 'SP2XA2S9RN5DFXM7F3H3A1EFNWQNP58FT164ECD0W u1)
(map-set mint-passes 'SP1VJWFS0FXFTRZBHPXN69CPTG29NYBV3MGRYPHR9 u1)
(map-set mint-passes 'SP30VK6DWV088RM80VWT9R4SYAQK3VGJPZ76CYAR4 u1)
(map-set mint-passes 'SP1QEVK0FZ7VDQM5HANWAJ1E15EBSSS5702JKABCH u1)
(map-set mint-passes 'SP346G43S76WSHGKXTYMX8QAJTBYS0SY1J3V43BW8 u1)
(map-set mint-passes 'SP15QGK9HNY7FJNCKJ9R88N4RJKVZWFV1S5QZY4DH u1)
(map-set mint-passes 'SP1S3WDSFHYQCF1WW7MW85S2KF3T9P6T76FQCA311 u1)
(map-set mint-passes 'SPV4TA28BRR4Z20THQGZ40J4XSA4Q7WP0TK0GXTY u1)
(map-set mint-passes 'SP3HMB29AMBZWE0EC6F46X4QZPG1KRW9S9AYBR9D7 u1)
(map-set mint-passes 'SPG6S05VEYE2YSNMYWN8PGA4NN8X5CTBEXBMDN2N u1)
(map-set mint-passes 'SP24RF7RBNR9EACC0SYKX00Z50355B8SKDPA7YPBD u1)
(map-set mint-passes 'SPN4G9B6BM3JNDWMZ0VDABTR0XEEGST6FTZPD53K u1)
(map-set mint-passes 'SP26Z7NDJ0AENE71HGSV1MCAPQFS5WTNP6WGNBQVD u1)
(map-set mint-passes 'SP5JKN8XJ2W32G8J3C0S86WQGH4ERJP5VQRG33GB u1)
(map-set mint-passes 'SP3FYS7SZRFQJJTQ58KBXE7HSRRGTJSM1YX1JZ4RG u1)
(map-set mint-passes 'SP30FMRVE0MN4AXG4DPX4YEMR0RRBJ2DNSMBRD6GE u1)
(map-set mint-passes 'SP666CP07RTR7BCA0D0JXWP5NSDS11PFMEXZDC6N u1)
(map-set mint-passes 'SPMJBA1GGK2FCBMZWPMX5SNCZJSQFV6GZRP48SRR u1)
(map-set mint-passes 'SP1CJTKVE0BJAXMB2H206KBSCFN9BM4AH3D4AGTAZ u1)
(map-set mint-passes 'SP3QP06B83T654SAHZWWB1PX9VD0K8JM3F4Q2CKW3 u1)
(map-set mint-passes 'SP1FVX0K9BVPSSWEECYWCBTZWVJW8JVRQ5GZ235KG u1)
(map-set mint-passes 'SP1VMYAE5XWDT04EJDWCDSME3YDPVQRSAVRHV21CN u1)
(map-set mint-passes 'SP3WJKAD7280YD6DKFW1276B6VHJPAPQ72W0YSKTT u1)
(map-set mint-passes 'SPM9QEZ6R469Y0XY575J47EZFB7DMQKTFMWV2JE1 u1)
(map-set mint-passes 'SP3ESA2Z7MF2961HKGQPWVWFPYWNR7SW1XWDPEPQ6 u1)
(map-set mint-passes 'SP3EXQF880J9F9A9ADFVH4DH1Q87ZRHBWK4RFJ6HJ u1)
(map-set mint-passes 'SP2B50JSR7CXZZD0VDZSD82MDJ8056JBF0H3A2VR u1)
(map-set mint-passes 'SP23JT37Z63MKGZGE7M8DHJGK4S3R9G56FKVC8TZF u1)
(map-set mint-passes 'SP3X93092MAA6S3F4ZZG5TE6917Q99NA11WJWKWXV u1)
(map-set mint-passes 'SP388EMR5STQM60AZKVDXTQZ6XFDK8GETN0XJFQNV u1)
(map-set mint-passes 'SP2394BZ6WZW7XNPK7A3QQCK4H9H0PF42WGT74WNY u1)
(map-set mint-passes 'SPFRD31MG5KVVN9XCC8NQMYC6YBK1B3YSFS5F4RW u1)
(map-set mint-passes 'SP1FK9S3NKS8FM3JVYAZ3BG2MGZGW4CKNFXSPJCVP u1)
(map-set mint-passes 'SP32S5DJ5M38JGSFXS6F73BH2BMSA7Z1QMEWB2ZVR u1)
(map-set mint-passes 'SP1DQFFN5S4MJE1X82T49ZFFPVP3SMRT4ESEWGF9W u1)
(map-set mint-passes 'SPEXC63AB1J19PVK0EYDD6FX2EYV94Z1F0281EWT u1)
(map-set mint-passes 'SP2JASG7DQGW2R0X61ZA974MBDFA270CAREXQGZMB u1)
(map-set mint-passes 'SP21SY5ABPP5AVWXGTM6SHQYC99GXT25AKEZT3QX8 u1)
(map-set mint-passes 'SP3DP4N0YN83T2R1G0Q3PPRDVRENTW00WVVT0XG85 u1)
(map-set mint-passes 'SP26YPNW86BCQZM338MQA1HHDYNHA7XH758V5M8FT u1)
(map-set mint-passes 'SP6B6NDFSPK8MXK0FMPMBGM6AHYTAKHJW6W6EPV5 u1)
(map-set mint-passes 'SP9E9A8YQ062EED9JQTH9N80QCG4YZWH26K2NH37 u1)
(map-set mint-passes 'SP37PJH13QGJXZ2Z20DVYMZV8RWHXD243G05GYVZD u1)
(map-set mint-passes 'SPQBK8XWB06CZFH0FDZFCJ3NBZVXTWSB9VC5M8J2 u1)
(map-set mint-passes 'SP3E91W4E2DBKFVRD4ACRZH6A063MEW7SVWWE8MZW u1)
(map-set mint-passes 'SPCGABQTDM3DP056W8TTXGHMM6PBDQV945QNETKK u1)
(map-set mint-passes 'SP23D8A5CXFKS2314HSPJ8ZTA2MFNCGENY9NV6DTG u1)
(map-set mint-passes 'SP1NBCK2JP3KNCHGGM8FGWPT7VFWSCBAXGMJ1WMZB u1)
(map-set mint-passes 'SP17WB59VTMRE17M9MY6FKPHWRQK8KPP0DYH00PNG u1)
