;; anipix-tiger-force
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token anipix-tiger-force uint)

;; Constants
(define-constant DEPLOYER tx-sender)
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
(define-data-var mint-limit uint u50)
(define-data-var last-id uint u1)
(define-data-var total-price uint u45000000)
(define-data-var artist-address principal 'SP1YN8WZ50C237MBJZ6GQD339NNZSKA55RJ9YZ9YQ)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmZaMcDRSTrSQfqwukNyNNnzZ9bXuEY2sbSCcesPzd51Q3/")
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

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-tf) (mint (list  true true true true true true true true true true true true true true true true true true true true true true true true true )))

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
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )
    (asserts! (or (is-eq false (var-get mint-paused)) (is-eq tx-sender DEPLOYER)) (err ERR-PAUSED))
    (asserts! (or (not capped) (is-eq tx-sender DEPLOYER) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ (len orders) user-mints))) (err ERR-NO-MORE-MINTS))
    (map-set mints-per-user tx-sender (+ (len orders) user-mints))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER) (is-eq (var-get total-price) u0000000))
      (begin
        (var-set last-id id-reached)
      )
      (begin
        (var-set last-id id-reached)
        (try! (stx-transfer? price tx-sender (var-get artist-address)))
      )    
    )
    (ok id-reached)))

(define-private (mint-many-iter (ignore bool) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? anipix-tiger-force next-id tx-sender) next-id)
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
    (nft-burn? anipix-tiger-force token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? anipix-tiger-force token-id) false)))

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
  (ok (nft-get-owner? anipix-tiger-force token-id)))

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
  (match (nft-transfer? anipix-tiger-force id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? anipix-tiger-force id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? anipix-tiger-force id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SPHWWE37D0BP84QKP202ZPRC4PSSY3R1WRDK4KBC u50)
(map-set mint-passes 'SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK u50)
(map-set mint-passes 'SP1YN8WZ50C237MBJZ6GQD339NNZSKA55RJ9YZ9YQ u50)

(define-private (air-droping (address principal ) (token uint)) 
  (let 
      (
        (last-nft-id (var-get last-id))
       ) 
       (begin 
        (try! (nft-mint? anipix-tiger-force (+ last-nft-id token) address))
        (map-set token-count address (+ (get-balance address) u1))
        (ok true)
       )       
))

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
             
                    
                 (try! (air-droping  'SP1SJFW3TTRJ9QZM2J53GSNV7C6SDJKCSE32HT9XK u0))      
                 (try! (air-droping  'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u1))      
                 (try! (air-droping  'SP267TMY9MTMP98AW05X8RFQ43JRMTPGDWFKFCPTH u2))      
                 (try! (air-droping  'SP2H667JRMBHX0NRJ3ZMPPDR4R9TH6NM1ZFYW07S6 u3))      
                 (try! (air-droping  'SP2A4R43TCNHZ19AKK44WEBP4R16X7DV4093GQ0X4 u4))      
                 (try! (air-droping  'SP2A4R43TCNHZ19AKK44WEBP4R16X7DV4093GQ0X4 u5))      
                 (try! (air-droping  'SPT8MA3H81X02BKEFX2WF7FJKV2G1FZX1SFR6HX2 u6))      
                 (try! (air-droping  'SP9XD6041FFN5BW6ZR9J3FSESR4S442JPYZJVXBW u7))      
                 (try! (air-droping  'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u8))      
                 (try! (air-droping  'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u9))      
                 (try! (air-droping  'SP2778AQXRYX13JAYFXVXZ2DB8TM993SF2DR3ZMBS u10))      
                 (try! (air-droping  'SP350N4SX832092H6F07YKB1R5X5DM90BV6P97B8N u11))      
                 (try! (air-droping  'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u12))      
                 (try! (air-droping  'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u13))      
                 (try! (air-droping  'SP2P8QYQX5PMKVBXQ9FWK8F96J8DJXXW7NB7AA5DT u14))      
                 (try! (air-droping  'SP3EPS563XJNK170J902C78ZPDPNXVZFWWCN7DGWH u15))      
                 (try! (air-droping  'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68 u16))      
                 (try! (air-droping  'SP2A4R43TCNHZ19AKK44WEBP4R16X7DV4093GQ0X4 u17))      
                 (try! (air-droping  'SPBKC1NGB52EMR5HWXB3P615XKTHD64TXY3D6J1G u18))      
                 (try! (air-droping  'SP9227STGNCZPRTP2T2G3S02M7XB5ENAQB1J82FA u19))      
                 (try! (air-droping  'SP1YN8WZ50C237MBJZ6GQD339NNZSKA55RJ9YZ9YQ u20))      
                 (try! (air-droping  'SP3MB74HT9SDNGENKFDA3AKZEXEMBZWB1FTFSHWBJ u21))      
                 (try! (air-droping  'SPT8MA3H81X02BKEFX2WF7FJKV2G1FZX1SFR6HX2 u22))      
                 (try! (air-droping  'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u23))      
                 (try! (air-droping  'SP1H45JS07GWQWMT57JE20X17AQCNVYAS7NHW2HVR u24))      
                 (try! (air-droping  'SP38AJ28GP1Q3E40QD8K3WA7JR315794Y29YWKAP1 u25))      
                 (try! (air-droping  'SP2GSEVPVKX2PX027NMCQK74XH5Z4FK3M7K62SVCE u26))      
                 (try! (air-droping  'SP1MS7KGA5WESV319PV9GVKW2FFJJ1YNT9ETC6FQC u27))      
                 (try! (air-droping  'SP33SCE1F3J9N6D4ZFY9AA3GR05GS3112GS1VZDFC u28))      
                 (try! (air-droping  'SP9XD6041FFN5BW6ZR9J3FSESR4S442JPYZJVXBW u29))      
                 (try! (air-droping  'SP169VF781ZR743GRXXDZYJBK42204Q61QWS94CD7 u30))      
                 (try! (air-droping  'SP2F7YW4FVV4RY9S6AT7CQ5X7YV12E5QFJBYMPN6B u31))      
                 (try! (air-droping  'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u32))      
                 (try! (air-droping  'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR u33))      
                 (try! (air-droping  'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E u34))      
                 (try! (air-droping  'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u35))      
                 (try! (air-droping  'SP248JDYV1JM1M0Y1SSQZ9GYE0N8G4ZAMNXC039GD u36))      
                 (try! (air-droping  'SP2JS9HG5QCBFKHWN8F0GH2CR2ESRC8Z6BJT93SVG u37))      
                 (try! (air-droping  'SP7AS7797DP3WP2BBWSJB67JEWV63WEQM96VKH3J u38))      
                 (try! (air-droping  'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106 u39))      
                 (try! (air-droping  'SP2KZ24AM4X9HGTG8314MS4VSY1CVAFH0G1KBZZ1D u40))      
                 (try! (air-droping  'SP3QD9EVZB3E7E7Z3FWH7KBDH5RZWA4PYHSQ0FGTQ u41))      
                 (try! (air-droping  'SP12YGGACNA4R43DB1HAQ3AE03PKPJGXZ1BX96CYB u42))      
                 (try! (air-droping  'SP1X34E47XW77TWYFG6GX8G1SEN5E538T0WGBXZK6 u43))      
                 (try! (air-droping  'SP20P02KXAW338AS0ED5HV0M37SNQRFAMPB0F1R51 u44))      
                 (try! (air-droping  'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B u45))      
                 (try! (air-droping  'SP2THE36GG3WJKKXZET8AFEHQJNMZY2WCQ85K7FQJ u46))      
                 (try! (air-droping  'SP33SCE1F3J9N6D4ZFY9AA3GR05GS3112GS1VZDFC u47))      
                 (try! (air-droping  'SP1Y12EG7JB0ZBKABSG232FRDHF4G5ERD26V5KX5X u48))      
                 (try! (air-droping  'SP1FV4FZ8D32S7GKYRPFWK6YHRJE5BZEYKABK72Q3	u49))      
                 

      (var-set last-id (+ last-nft-id u50))
      (var-set airdrop-called true)
      (ok true))))