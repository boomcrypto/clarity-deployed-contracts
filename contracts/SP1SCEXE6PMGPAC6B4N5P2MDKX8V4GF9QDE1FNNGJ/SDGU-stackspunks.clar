;; SDGU StacksPunks
;; Stacks Degens Gaming Universe StacksPunks


;; Non Fungible Token, using sip-009
;;
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-non-fungible-token SDGU-stackspunks uint)


;; constants
;;
(define-constant contract-owner tx-sender)
(define-constant mint-limit u10000)


;; define errors
;;
(define-constant err-mint-limit-passed (err u400))
(define-constant err-invalid-user (err u500))
(define-constant err-not-whitelisted (err u600))
(define-constant err-not-existing-on-other-contract (err u700))
(define-constant err-from-unwrapping-the-other-contract (err 100))
(define-constant err-not-minted-on-the-other-contract (err 101))


;; data maps and vars
;;
(define-data-var price uint u14200000)
(define-data-var minted-number uint u0)
(define-data-var free-claims uint u0)
(define-data-var commission uint u250)
(define-data-var commission-address principal 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG)
(define-data-var ipfs-root (string-ascii 80) "https://stacksdegens.com/SDGU/StacksPunks/jsons/")
(define-map whitelisted principal bool)


;; private functions
;;
(define-private (mint (recipient principal) (id uint))
    (begin
        (asserts! (> mint-limit id) err-mint-limit-passed) ;; less than 10000
        (asserts! (not (is-eq (unwrap-panic (get-owner-other-contract-id id)) none)) err-not-existing-on-other-contract)  ;; verify if minted on the other contract
        (asserts! (is-eq (unwrap-panic (unwrap! (get-owner-other-contract-id id) err-invalid-user)) recipient) err-invalid-user) ;; verify owner of stackspunk with the tx-sender
        (if (and (not (is-err (is-whitelisted recipient))) (is-eq true (unwrap-panic (is-whitelisted recipient))))
          (begin
           (var-set free-claims (+ (var-get free-claims) u1))
           (mint-helper recipient id))
          (begin           
           (try! (stx-transfer? (/ (* (var-get price) (var-get commission)) u10000) tx-sender (var-get commission-address)))
           (try! (stx-transfer? (- (var-get price) (/ (* (var-get price) (var-get commission)) u10000)) tx-sender contract-owner))
           (mint-helper recipient id))
        )
    )
)


(define-private (mint-helper (new-owner principal) (id uint))
    (match (nft-mint? SDGU-stackspunks id new-owner)
            success
              (begin
              (var-set minted-number (+ (var-get minted-number) u1))
                (ok true))
            error (err error)))


;; public functions
;;
(define-read-only (get-minted-number)
    (ok (var-get minted-number)))
    
(define-read-only (get-free-claims)
    (ok (var-get free-claims)))
    
(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) (unwrap-panic (contract-call? .conversion10000 lookup token-id))) ".json"))))

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? SDGU-stackspunks token-id)))

(define-read-only (get-last-token-id)
    (ok (var-get minted-number)))

(define-read-only (get-commission)
    (ok (var-get commission)))

(define-read-only (get-price)
    (ok (var-get price)))

(define-read-only (is-whitelisted (address principal))
  (ok (unwrap! (map-get? whitelisted address) err-not-whitelisted)))


(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-invalid-user)
        (nft-transfer? SDGU-stackspunks token-id sender recipient)))

(define-public (get-owner-other-contract-id (token-id uint))
    (ok (unwrap! (contract-call? 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-v3 get-owner token-id) err-not-minted-on-the-other-contract)))

(define-public (claim (id uint))
    (mint tx-sender id))
    
(define-public (whitelist (address principal))
    (begin
    (asserts! (is-eq tx-sender contract-owner) err-invalid-user)      
    (ok (map-set whitelisted address true))))

(define-public (set-commission (new-commission uint))
  (if (is-eq tx-sender contract-owner)
    (begin
      (var-set commission new-commission)
      (ok true))
    (err err-invalid-user)))

(define-public (set-price (new-price uint))
  (if (is-eq tx-sender contract-owner)
    (begin 
      (var-set price new-price)
      (ok true))
    (err err-invalid-user)))

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
    (if (is-eq tx-sender contract-owner)
      (begin 
        (var-set ipfs-root new-ipfs-root)
        (ok true))
      (err err-invalid-user)))

(map-set whitelisted tx-sender true) 
(map-set whitelisted 'SP201VQDZD54J2RM07N8283D80X7SY15ZBGCMRB8T true)
(map-set whitelisted 'SP71N7X6G8KYGQPHZW7TB4PD1JZ6ND9AESF9JPZ8 true)
(map-set whitelisted 'SP31R29Q0D8JVN5WTDB0EV3A2M1FV2DVEV35VZV66 true)
(map-set whitelisted 'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68 true)
(map-set whitelisted 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS true)
(map-set whitelisted 'SP11YZYQYZB6KHD99KNVGZ9KM16P5BJKVP5MZD948 true)
(map-set whitelisted 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP true)
(map-set whitelisted 'SP3A5VJWA3CH4BM7W08APVJKJ8MQ7PXXFACWAYA2J true)
(map-set whitelisted 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE true)
(map-set whitelisted 'SP3BWAHYMTHQZHSB8N49AXQNTYWBACQBAN8Z4QFRD true)
(map-set whitelisted 'SP1P637C9NB6GSK9TY8AT8SN3QKH1WSV5ZVCZZSKS true)
(map-set whitelisted 'SP3VH4DZ7HJYVHJYWE3JZ6A6XV5YEZW0TZFP55FVJ true)
(map-set whitelisted 'SPN9JGFGXFJZD7AM5VF2S7BRATNCQYVHVWG3087B true)
(map-set whitelisted 'SP110TAR7RZE8ZTHMTMZYN76KT4440CS1KADFCG2B true)
(map-set whitelisted 'SP3N8VF6CDC3144BS1J9GDGA57BVXDYEY666WTRGN true)
(map-set whitelisted 'SP3CW7TC10NY7BFC53MJJZ1NQ12P4NGSBM90SH7Z8 true)
(map-set whitelisted 'SPH2CYE44SEP0964994SHRH09TDV3WAMF51HXVMH true)
(map-set whitelisted 'SP10WX7YZBTRA5C8PK1RCNZWWB9QXZZCAZRYNKKD9 true)
(map-set whitelisted 'SP1PKK6KJPM826D0X6AMCJ63KEH2M456M4T22WAPQ true)
(map-set whitelisted 'SP2F1QFS7H3GFNGBX4CRY9KRXGBSABQSVQTXANQ1Y true)
(map-set whitelisted 'SP2HVP68NY5BD2RDFX0JNXSYRS8AA6R7S30N08NJZ true)
(map-set whitelisted 'SP12FXX43RDKMHD2BNQTT6XYQX4AMEEG52XT36N9S true)
(map-set whitelisted 'SPSHJE4F0D0ZKJZ1DVXEDFFD6AKHHKF31H3M77B8 true)
(map-set whitelisted 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V true)
(map-set whitelisted 'SP17MF5SZF5MSY8TQXK01SZB3VAJTC61QK78WFPHC true)
(map-set whitelisted 'SP26ZSXREMGCD8M71Y4FVA17QBC42EV0VM3HPVXYQ true)
(map-set whitelisted 'SP1DY2QDFZAR8VK5S9DMYW2AW0WXQ16NNRG3PJDTX true)
(map-set whitelisted 'SPEJDX32VPD59F3WG0H5S47WZ1VXCRX6JEBJ1SCH true)
(map-set whitelisted 'SP1GHMBR6NKXC8HMWWMPKGRZJ6WTZXX1SYJJNJZJA true)
(map-set whitelisted 'SP39MP76SSQK9H94BD4CS92788HG41CQTP2T3D34R true)
(map-set whitelisted 'SP1KNK0HP2ZTGHEE1YAPM85HTDHF89G2MCEJCP08G true)
(map-set whitelisted 'SPTW2MGMYZEY903JWY79HADBPF2EBFV7D019R1PZ true)
(map-set whitelisted 'SP2WY40NKKKPPJA6P2W1MXJHN4DNFMVVMNK4D5AFQ true)
(map-set whitelisted 'SPJYE321XPCZ73EKM5GHZGC5ACBPS4KHGB4E4GGJ true)
(map-set whitelisted 'SP325GSC37A1BP5N4ST16FX5821H9MTK7WPVWTS0P true)
(map-set whitelisted 'SP28R593JKNFH8PTWNECR84A83EESKC3CC5P826R5 true)
(map-set whitelisted 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY true)
(map-set whitelisted 'SP3W7FMHDG1XFH99KP9K4TP39GCZ8SAABBKJQDJNY true)
(map-set whitelisted 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C true)
(map-set whitelisted 'SP10AZC9MXS77B5JWFZE47K23NKXBMF4F5F8V4Y82 true)
(map-set whitelisted 'SP3KCAE82ZYFB5DMJE9TW9K9ZQPJYCD9Q02PFB2C8 true)
(map-set whitelisted 'SP3XZVBXAPVVBKV0C0AMR875E8Q7545YX227WNHMN true)
(map-set whitelisted 'SP3910KBW2WAXNDM5VXWGH0JR3JFD245YWM9BA5HE true)
(map-set whitelisted 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 true)
(map-set whitelisted 'SP2PNN7Z0FB0EQZ8CE0NJE0HH09T19P5WE0GQT0W3 true)
(map-set whitelisted 'SPJXWDR6YPME7X4BZ8PK6WDG76B7DZVHKEPAACF3 true)
(map-set whitelisted 'SP3W00ZZE6PN11NHFH5KVEY6Q4P7YCYPTAWM7M9DX true)
(map-set whitelisted 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD true)
(map-set whitelisted 'SP3QE6S262BKTV4WV0N80WBFXXKA5CKMH8TGQB3EG true)
(map-set whitelisted 'SP1FCVMBP2XWJFXJ2VJJ5P2MBD4PKK9R5SPG87EB8 true)
(map-set whitelisted 'SPH6QZB392YWWTPCS6NX2R4R3YBAV7SHQ0QRGB6R true)
(map-set whitelisted 'SP2BAPW5YCZMYZ37X6BQY4YXSG6AY3PYMB1PSBK4F true)
(map-set whitelisted 'SP0194E00ZDH74PFA1J6444W1320WQ3XFQX14DM7 true)
(map-set whitelisted 'SP1E4798MP7RNHPVSBM954MSS5EJNM1AC3R53DC31 true)
(map-set whitelisted 'SPKDKR58FY2MAWRRJ5R56BKJM9R1868276K73KWJ true)
(map-set whitelisted 'SP3N66VSF1HAH9BP36XEAT2JZWZ45TDJXWENGS7Y5 true)
(map-set whitelisted 'SP2QV18K6HB5NBE2RWHKH1HY2A3HKJ4NVW7KYN2SY true)
(map-set whitelisted 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ true)
(map-set whitelisted 'SPT7J3VXH570NNCKRVJ7YEMBB5S7F2418RMH4KHM true)
(map-set whitelisted 'SP2MN9BT5230AM8YPXK4JVYRMAXJ6G3VZ206ZS8X1 true)
(map-set whitelisted 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 true)
(map-set whitelisted 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF true)
(map-set whitelisted 'SP3731FXN86HFJ5SH525315DD37AA9NV5TBZ2ZKWX true)
(map-set whitelisted 'SPS6543QSVCWM0B1CQYD67RV4QP3MGFPJEHG4FHS true)
(map-set whitelisted 'SP2DFX28F1S3CB46B5XH9M5JQ7N4SMCE7CQY1TNYS true)
(map-set whitelisted 'SP1QRFVDS76WFV5XCDHAR7FQYTSNM4M1P4TGFZRK1 true)
(map-set whitelisted 'SPCD0QPKVDYE1VBK616J8RM65W6RHP7ZV5Q49GYX true)
(map-set whitelisted 'SP2CHC7GM2Y8RMMSRC7DSDJW3Y7CNYC2Q9EVFSSHV true)
(map-set whitelisted 'SPKTEXGCMJEQ7DG12ADXMAEKSNNSH3H8E2NHA141 true)
(map-set whitelisted 'SP5MJB2231XSTW82MEX7S7HRHAAM918CVJETR0K4 true)
(map-set whitelisted 'SP3Q1F1P3NYBAJEMPR57WAX7FKV5NSZEAGXC39BPT true)
(map-set whitelisted 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ true)
(map-set whitelisted 'SP3Z20WVS6BXDV2CAD65D55CNY7C62HKQ9HGF1882 true)
(map-set whitelisted 'SP2P4AZKTXSKZABSNY1PS4KVWJTF9YGANY9EAKQQS true)
(map-set whitelisted 'SPY914WERKVS8B46P6BDKY1V0J1HTKH8EPWETJSE true)
(map-set whitelisted 'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0 true)
(map-set whitelisted 'SP1V50HFY8CRC7N65HFH6S778CJEW5GQRBH3YW7BK true)
(map-set whitelisted 'SP3HN2AE3EDYXHP7CARQXVPWRA7CWDKJB23S0ZRQJ true)
