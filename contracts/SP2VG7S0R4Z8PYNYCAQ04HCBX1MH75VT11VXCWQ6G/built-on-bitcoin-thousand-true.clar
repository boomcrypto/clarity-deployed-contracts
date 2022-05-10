;; built-on-bitcoin-thousand-true

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token built-on-bitcoin-thousand-true uint)

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
(define-data-var mint-limit uint u100)
(define-data-var last-id uint u1)
(define-data-var total-price uint u50000000)
(define-data-var artist-address principal 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmRV9GD22djkbhTcFvtyEft17BzETgKfrNG97NpiXh4bAw/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u3)

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
      (unwrap! (nft-mint? built-on-bitcoin-thousand-true next-id tx-sender) next-id)
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
    (nft-burn? built-on-bitcoin-thousand-true token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? built-on-bitcoin-thousand-true token-id) false)))

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
  (ok (nft-get-owner? built-on-bitcoin-thousand-true token-id)))

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
  (match (nft-transfer? built-on-bitcoin-thousand-true id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? built-on-bitcoin-thousand-true id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? built-on-bitcoin-thousand-true id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP1JKNQA5JVZ58NVJXKM2A0R6NF513FX5AQTN2NFB u1)
(map-set mint-passes 'SP2RQ3AMJGQBJDV987P7EYMPECR3ZT96WZ2P2447N u1)
(map-set mint-passes 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9 u1)
(map-set mint-passes 'SP1ARWZD4G0SZPADBFQ5DVSK93B6QKQ6DHK9G452P u1)
(map-set mint-passes 'SP35X0JGSJ6A0E7SXX51Z8MQ6NZ13DXYH6V8TNAPM u1)
(map-set mint-passes 'SP2RT9J3FYQXRG8V3YCT8P85QJ9XWNNS2Z19EYCNV u1)
(map-set mint-passes 'SP3SSRH8JTAB535A4315MNKY01BY125X007Y5MEBT u1)
(map-set mint-passes 'SPK8785ECMV8E8Q94KQF94JVZ50TH8FTS5TMQV7Y u1)
(map-set mint-passes 'SP3F0KB3SEBMRHWMSHYWFP2PKDX7NEK6405VP4MQA u1)
(map-set mint-passes 'SPX4947FK9BR7FF4Y6Q639TSFR01AZWZZE9SY011 u1)
(map-set mint-passes 'SPPXHPRQWAWTR92N3XSA0MFMB4402YKQY15HEYVQ u1)
(map-set mint-passes 'SP2MAWMYQPPVD3KH8SXC9M0HHERQ45YAKJFTWKXQ1 u1)
(map-set mint-passes 'SP37STB2F8DKFMF6XS4DHJ35NYR3PHAAA1JFJ7M4K u1)
(map-set mint-passes 'SP21PM5KTNHMM4TZ9B8CRKTED4FXTEHKYWWDRHGXX u1)
(map-set mint-passes 'SP80RD68VJCGFQCYCBFF0JX4T4MJV6RANSDWFWEK u1)
(map-set mint-passes 'SP2FYQ7FP7PF8JBN84J58194CZ24K05ZY6E4JPC6W u1)
(map-set mint-passes 'SP26RZ9T8D2MQA10QC2T125E3WCHG90KXRNW1TSMT u1)
(map-set mint-passes 'SP2HVHSREB1S086WH086KYBKJT96XWBYB0CTGZMAP u1)
(map-set mint-passes 'SPKDKR58FY2MAWRRJ5R56BKJM9R1868276K73KWJ u1)
(map-set mint-passes 'SP3633GDVYMBYNRTVGGJNR0S1ZXN0CTJGHVY6APNV u1)
(map-set mint-passes 'SP2JJFBDEGY6B8TVZJ5H0J0H2VQ6W8Q467A8S7YNM u1)
(map-set mint-passes 'SP9J5XBFEBZTZDWHXM9XP671PBFJ94ABHYMJYXW8 u1)
(map-set mint-passes 'SP3WCH7F52H16SD60RYAZ0604PM3W5RSWWCW3GVBK u1)
(map-set mint-passes 'SPVHB3W1VD7JC7HE2HFFJ2SJFJX9PV79GPRW78T u1)
(map-set mint-passes 'SP17Q8MQJNAZEQHNM00VFM3KGYBN9KPWZ7WDF0EFS u1)
(map-set mint-passes 'SPP3HM2E4JXGT26G1QRWQ2YTR5WT040S5NKXZYFC u1)
(map-set mint-passes 'SPXAJBWBFHSHDV9QA7JSBFRJE4DCDSNRMFZ3D8KE u1)
(map-set mint-passes 'SP1RG85FRQRYHY8HBSSN85CTR5A42GSCGR8K9BGGN u1)
(map-set mint-passes 'SPBERM5NW6ZMJ7242DK2XVSVX9V910GBQ69BYANC u1)
(map-set mint-passes 'SP349J1ZTEE71M1J5D4YS0BPQCCFJ3YSNM1P8BJY4 u1)
(map-set mint-passes 'SP3R8MBSTGZ2PDS3Y28SH1HRHKH5F7PDYG3K364ZW u1)
(map-set mint-passes 'SPPJ6YQD4H56Q5DCKTRAH1DGB1968T8TQG7YHHNV u1)
(map-set mint-passes 'SP10H16Y8MZVMP46G24G782061BKBSH1RBRHEGCKV u1)
(map-set mint-passes 'SP071PX9YCR4MJPZR96RT5FQ3Y9R180D76RY6S18 u1)
(map-set mint-passes 'SP1E0N94M5QSTBSFPS12X7C36Z7GJV19HEAF5H2Z1 u1)
(map-set mint-passes 'SP2TZE09GHARKG0B8NTT9X77QXBTQPQ2J1579T0D8 u1)
(map-set mint-passes 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW u1)
(map-set mint-passes 'SP16QT5M1MWN31PC0T1BR56G02X5HBHMTVEEERHS3 u1)
(map-set mint-passes 'SP1386044X5N01AJAGN50NGKE87K4Q72P7DHVXF3F u1)
(map-set mint-passes 'SPXMP4Z9B7R6KVDVB0DG7R7M8RZ4CNVQGBASDYB7 u1)
(map-set mint-passes 'SPFR997HTA8QKKFXGKZJTZ7BT0V5KCA5EFPCW17Z u1)
(map-set mint-passes 'SPZMD4YE1R8TN84BPWXGTJZ7B8P6WW7H58ACS99C u1)
(map-set mint-passes 'SP2BDQE2TQT1GK2N23M2EDNFA2VBJ40JCYPXVP76Q u1)
(map-set mint-passes 'SP3KZ1XDJT57BK81JWX1VFT3V70DYSZA8SQYQPAK u1)
(map-set mint-passes 'SP3KNA515JNDP19F11P90G14YSXVMVR6QXVJ54DYX u1)
(map-set mint-passes 'SP2R67ZTEJFJPJZYHCY4VQJ7Z50N88CJPSVKQEPPK u1)
(map-set mint-passes 'SP3JXAXGZA5JJJ4YHTEW6Q46PKX3VMT0Q0F7JDYF7 u1)
(map-set mint-passes 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE u1)
(map-set mint-passes 'SPZ3AFWCMJX73GQ4FN691W25QG3E8QSP8P5KJR5N u1)
(map-set mint-passes 'SP1Y5KTXK6KRV1YTB6QX1ARYDFSK65NKVXKR0HVRF u1)
(map-set mint-passes 'SP1SBTRXDJP4N825PY69B1MKTQ4MSPB0DW9JCQHKE u1)
(map-set mint-passes 'SP04HY05JDPFTQNPS9VAX43YVM2DFME6DPE3B1NJ u1)
(map-set mint-passes 'SP3QFME3CANQFQNR86TYVKQYCFT7QX4PRXN0JJ4B8 u1)
(map-set mint-passes 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9 u1)
(map-set mint-passes 'SP2PY8M4KKZ12X60YTRV10RS3NQ2ZRVKXC7AWV1RA u1)
(map-set mint-passes 'SP1VGN6BA58QRRSS0YMTQWEQ52KXQX3A5C6DGWNRS u1)
(map-set mint-passes 'SP3HJ1VPE5D88NH0D4RSX3SFA8M2EPZ0H5FAG7K9K u1)
(map-set mint-passes 'SPMGK3RNPMZS77VA5XX5FTC0CQEBJ5493K4JVTYS u1)
(map-set mint-passes 'SP8PV28MMTEYT30CWGSR32A028JSRE6GPHXFQD8M u1)
(map-set mint-passes 'SP3ZXAP1QY2728F4F3J02G7BBENG0M5NCSXH63V5N u1)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u1)
(map-set mint-passes 'SP7GZD8FVMV6ZCWS0HSFQ7PR0HR4WBQ3RTN64KTX u1)
(map-set mint-passes 'SP3Z7FNHFRWFWKB9X8P2VJS5EWHV7D4DANP5M1V3J u1)
(map-set mint-passes 'SP2GZANPRD253SBRB6TA20Q5DZJMJFZ5SZRT0FH0F u1)
(map-set mint-passes 'SP2TMYRTVTRG17YFQ63GVB9AAB6Y55X4634KK8NRE u1)
(map-set mint-passes 'SP1MN0MWP68PMEA8HCP3RQYT0ZKZ1JXWT0YGVDP3K u1)
(map-set mint-passes 'SP3QJYN26FKY27ZWY8QZQX2SF003BCR4TMSM1K5GE u1)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u1)
(map-set mint-passes 'SP2NJJ2C4SS8ABMDAVENV7R5V3DVZD95VHGQSPCPS u1)
(map-set mint-passes 'SP1C671AAKE9M5T7BPR7X8F9WRK5W7A4PVMHSSPGZ u1)
(map-set mint-passes 'SP3BWAHYMTHQZHSB8N49AXQNTYWBACQBAN8Z4QFRD u1)
(map-set mint-passes 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW u1)
(map-set mint-passes 'SPBK6BZDK5NCS1W6RBW6TXSVW6KVAGSFR8WPCKP1 u1)
(map-set mint-passes 'SP8SNQZCKVK98VKQPEAWG99Z3SZ4P2ZRCH4PABVD u1)
(map-set mint-passes 'SPCGYWGKWZ9P21Y31H3GC1BYDEFQ1MJJYM3G34EK u1)
(map-set mint-passes 'SP1FCVMBP2XWJFXJ2VJJ5P2MBD4PKK9R5SPG87EB8 u1)
(map-set mint-passes 'SPCJ0JZVB02YYVSR5XVS1JJ17G4ZP1KFGD15B049 u1)
(map-set mint-passes 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE u1)
(map-set mint-passes 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 u1)
(map-set mint-passes 'SP2THDNR3N99F12XQJ39E8HXD3KKYQHDB2KWKGKTD u1)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u1)
(map-set mint-passes 'SP11FB8EHA1KAMEEKEARWRWT059YYSZRNAP75B4PA u1)
(map-set mint-passes 'SP27ZWQ6T8GJ7MH1S0B9G6C38RH9P924A6K503NFZ u1)
(map-set mint-passes 'SP2BQN6Q97C1N2Y16CZWJBGPY408RQK53NHVKE3B u1)
(map-set mint-passes 'SPQBXCJ7086CTMR87Y6NPQZMSTNYYJ9SEQ63PJ3M u1)
(map-set mint-passes 'SP2RNVWK0YGME7PRQRMX0NFCSFYNVD9QD8PPSKBM2 u1)
(map-set mint-passes 'SP1XPCCJE4NR82X6D8PX32NF1KAYYM36B5T83J6GP u1)
(map-set mint-passes 'SP1SAGTEXEGCSJ6C82AN705HKH34ES49H3WBMZBPW u1)
(map-set mint-passes 'SPY0BT5T1FS2GGFG0RVMTP2GRSNBEPM2MWX0VSN9 u1)
(map-set mint-passes 'SP2FSM29506QZYKJMFGNTAF2V6Q58K2Y61DDT7Y0F u1)
(map-set mint-passes 'SP1C0EGYWYDZ2JVJVCGASH1G5HJ2GE2KB2SMN54D u1)
(map-set mint-passes 'SPJ3KZQMYFKB9CNRSB2WHQQK0PRZTFGV9Q6RBSC6 u1)
(map-set mint-passes 'SP1TAF0E1EGNZF8AFC7GE5DRS8NGA5H1MWN30CKP8 u1)
(map-set mint-passes 'SP1FKRSMJADD20VRAZ0FC8EMFZ128GZSF08BEYV86 u1)
(map-set mint-passes 'SP216YJTD76S81ZXKVHEBTJT77PSVR33AZ57548V3 u1)
(map-set mint-passes 'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ u1)
(map-set mint-passes 'SP2S5GCRXKTR2AKX2SMXGP5E5F8TGFM4KC9MVHT3G u1)
(map-set mint-passes 'SPNABE5NZFMY9ESPQRV9MEW6AF68N5BBQSWA49PB u1)
(map-set mint-passes 'SP2YJYYR5GJ0P1NFGGS8YY890CAG85KFP1DM7NSGD u1)
(map-set mint-passes 'SP166C8S3BJD3FD7M7W9Z6Q0QSC3EPTYHTC54A5MP u1)
(map-set mint-passes 'SP19WSDJWTH4CW3YG554XS5CAXJJGAN83P8CFZ4K1 u1)
