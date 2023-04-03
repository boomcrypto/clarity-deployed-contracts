;; degen-hyena-pack
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token degen-hyena-pack uint)

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
(define-data-var mint-limit uint u444)
(define-data-var last-id uint u1)
(define-data-var total-price uint u20000000)
(define-data-var artist-address principal 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmQd9NGJFYSxY8FFTLTRLHCGkHn9WU8BtK4wodcQ8GakPm/json/")
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

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

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
      (unwrap! (nft-mint? degen-hyena-pack next-id tx-sender) next-id)
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
    (nft-burn? degen-hyena-pack token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? degen-hyena-pack token-id) false)))

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
  (ok (nft-get-owner? degen-hyena-pack token-id)))

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
  (match (nft-transfer? degen-hyena-pack id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? degen-hyena-pack id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? degen-hyena-pack id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP37S6ASV5A45JJ9MQWD1GG53W0CYMKXQZ6D9BR2P u4)
(map-set mint-passes 'SP1HE3BWMBXADAHA1BWN0QC50CEZDYZ2VEWWNZE24 u3)
(map-set mint-passes 'SP1T5Q45P74BD1YX55X45Q5727TZFQF005KWMSBQ6 u3)
(map-set mint-passes 'SP3QZ9VDXBC7KXC7CSTT97TE201JNH189JFGH6YD7 u5)
(map-set mint-passes 'SP3RKRKGAW47KZWMMHNS9RFRDX4VM0W1M8D8PWZXJ u3)
(map-set mint-passes 'SP1S0B05BFW099N2C30W7T788QE4645M72EP6AV3X u5)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u3)
(map-set mint-passes 'SP2YQ53PTAD8GNT27FWCKVZKE0BMSWKW25P5YV6FM u5)
(map-set mint-passes 'SP3Q908CXM9E5CZB5P81BWXVNP8GRBFK793DW2685 u3)
(map-set mint-passes 'SP2RKVC8PYANWJ40VSRCK2K935HSN4H0AHTVHD73D u3)
(map-set mint-passes 'SPPDZ2G6ZCY2VHVTTRVPVZS5KCG4JG8T6WEHTC7Z u5)
(map-set mint-passes 'SP3X438JHXE9ZDMPTH58EHJM6MD7QRS304FW8982 u3)
(map-set mint-passes 'SP1BFMJZ9QMGAA682FSKGHKQ7ADWMK7V23GHFR9R6 u5)
(map-set mint-passes 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106 u3)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u3)
(map-set mint-passes 'SPKF5WM8G0KZJGAGVR24RHQJ2AT2D0HGD4ZNCFVB u3)
(map-set mint-passes 'SP1K8RG4PV202FHT8J9023G1WJRPFTSZXN9TPNEJX u3)
(map-set mint-passes 'SP2K2XWM4CRNQGWAEGX5G0R9ZE9YPJC7D58RPJQE4 u3)
(map-set mint-passes 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 u3)
(map-set mint-passes 'SPVS8CQ247EVN8VXE8SC087DTFCXR52YF4HXATZQ u3)
(map-set mint-passes 'SP231KPESDNPMVGP5A95EBR2MSCGB6H884AWTK38E u3)
(map-set mint-passes 'SP14NSM2BAB9MGMYNXJB93NY4EF4NFRW3G3EFBZDX u6)
(map-set mint-passes 'SP2GHCPM134Y28EZKNKEMF7SBK0BQ1QW1QASYWS6Z u4)
(map-set mint-passes 'SP1FQNG7YRAH5M7GV79T5415YS347XV1FRWVDG0BF u3)
(map-set mint-passes 'SPAFPBD7M89973WDEN68FKYW761RQVYNHSEFQZB9 u3)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u3)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u3)
(map-set mint-passes 'SPAX2SZCDFTVV76SR4JY4RYEPC5PBH2QAHEJXHTF u3)
(map-set mint-passes 'SP2C0AWNV4FEMZ51F0YYDWZ50GKVAW38SF6N18HPP u3)
(map-set mint-passes 'SPBNAM3RV2ZTXAYRV70PETHWSJ65NA319JXCQX08 u4)
(map-set mint-passes 'SP9R1DTP15B10S5WFPZVM8W2FDS6VXP27VA96CEZ u3)
(map-set mint-passes 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S u3)
(map-set mint-passes 'SP28NCDY6V4T7NJBMYGTJ55NHMXMC0GG806JW1ZTB u3)
(map-set mint-passes 'SP15BRQ6EZ8XXR29PS5GKCGK4PTMPS9SNYF4G525F u4)
(map-set mint-passes 'SP1VES0WGZ4SWFW3SX2TDP7ERJGX8JZ34F8BYJTM6 u4)
(map-set mint-passes 'SP1HDZ821JH49VB8T7W2WRJGVW51BHN11C6AGMYYD u4)
(map-set mint-passes 'SP2J9MAHFVWY6VNP23VJCKX5E0CEE98TA9ENZECRM u4)
(map-set mint-passes 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 u3)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u4)
(map-set mint-passes 'SP2NPNHH5ZHC8XQ047EB16NHGJ0VC7XZB00PJ41B1 u3)
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u0) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u1) 'SP5DZEC4897YG12ZSYETN84AWX5TEANJHYZV15DJ))
      (map-set token-count 'SP5DZEC4897YG12ZSYETN84AWX5TEANJHYZV15DJ (+ (get-balance 'SP5DZEC4897YG12ZSYETN84AWX5TEANJHYZV15DJ) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u2) 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ))
      (map-set token-count 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ (+ (get-balance 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u3) 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1))
      (map-set token-count 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1 (+ (get-balance 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u4) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u5) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u6) 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1))
      (map-set token-count 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 (+ (get-balance 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u7) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u8) 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ))
      (map-set token-count 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ (+ (get-balance 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u9) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u10) 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC))
      (map-set token-count 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC (+ (get-balance 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u11) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u12) 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC))
      (map-set token-count 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC (+ (get-balance 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u13) 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ))
      (map-set token-count 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ (+ (get-balance 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u14) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u15) 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1))
      (map-set token-count 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1 (+ (get-balance 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u16) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u17) 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1))
      (map-set token-count 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1 (+ (get-balance 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u18) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u19) 'SP3RKRKGAW47KZWMMHNS9RFRDX4VM0W1M8D8PWZXJ))
      (map-set token-count 'SP3RKRKGAW47KZWMMHNS9RFRDX4VM0W1M8D8PWZXJ (+ (get-balance 'SP3RKRKGAW47KZWMMHNS9RFRDX4VM0W1M8D8PWZXJ) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u20) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u21) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u22) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u23) 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ))
      (map-set token-count 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ (+ (get-balance 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u24) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u25) 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC))
      (map-set token-count 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC (+ (get-balance 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u26) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u27) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u28) 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1))
      (map-set token-count 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1 (+ (get-balance 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u29) 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ))
      (map-set token-count 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ (+ (get-balance 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u30) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u31) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u32) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u33) 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC))
      (map-set token-count 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC (+ (get-balance 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u34) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u35) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u36) 'SP1HDZ821JH49VB8T7W2WRJGVW51BHN11C6AGMYYD))
      (map-set token-count 'SP1HDZ821JH49VB8T7W2WRJGVW51BHN11C6AGMYYD (+ (get-balance 'SP1HDZ821JH49VB8T7W2WRJGVW51BHN11C6AGMYYD) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u37) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u38) 'SP2MCPE4ACC1W9FY1JC3BK2FMYSNWYDEADFEJH2MY))
      (map-set token-count 'SP2MCPE4ACC1W9FY1JC3BK2FMYSNWYDEADFEJH2MY (+ (get-balance 'SP2MCPE4ACC1W9FY1JC3BK2FMYSNWYDEADFEJH2MY) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u39) 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ))
      (map-set token-count 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ (+ (get-balance 'SP3ND58XNTVXG677YM4E4QXMMS0ZDTGRNHAF9TCQJ) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u40) 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC))
      (map-set token-count 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC (+ (get-balance 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u41) 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N))
      (map-set token-count 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N (+ (get-balance 'SP1VH0AZXCJ9HE8CQJNSAFX2CF6Q038DDTTQZ6C8N) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u42) 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1))
      (map-set token-count 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1 (+ (get-balance 'SPBTZ6ZFDBF2JNNBKXAJ2N9B972ST5GNSG3G0TX1) u1))
      (try! (nft-mint? degen-hyena-pack (+ last-nft-id u43) 'SP1VES0WGZ4SWFW3SX2TDP7ERJGX8JZ34F8BYJTM6))
      (map-set token-count 'SP1VES0WGZ4SWFW3SX2TDP7ERJGX8JZ34F8BYJTM6 (+ (get-balance 'SP1VES0WGZ4SWFW3SX2TDP7ERJGX8JZ34F8BYJTM6) u1))

      (var-set last-id (+ last-nft-id u44))
      (var-set airdrop-called true)
      (ok true))))