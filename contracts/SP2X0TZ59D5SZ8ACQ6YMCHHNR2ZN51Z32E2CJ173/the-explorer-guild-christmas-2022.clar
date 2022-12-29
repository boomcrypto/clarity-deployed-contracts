;; the-explorer-guild-christmas-2022
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token the-explorer-guild-christmas-2022 uint)

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
(define-data-var mint-limit uint u77)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmTUv4EBttDKjMaqnrrgEyVtBHQjmL7o6h4yXMikaktr36/")
(define-data-var mint-paused bool true)
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

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

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
      (unwrap! (nft-mint? the-explorer-guild-christmas-2022 next-id tx-sender) next-id)
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
    (nft-burn? the-explorer-guild-christmas-2022 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? the-explorer-guild-christmas-2022 token-id) false)))

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
  (ok (nft-get-owner? the-explorer-guild-christmas-2022 token-id)))

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

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/2")
(define-data-var license-name (string-ascii 40) "COMMERCIAL")

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
  (match (nft-transfer? the-explorer-guild-christmas-2022 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? the-explorer-guild-christmas-2022 id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? the-explorer-guild-christmas-2022 id) (err ERR-NOT-FOUND)))
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
  

;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (asserts! (is-eq false (var-get airdrop-called)) (err ERR-AIRDROP-CALLED))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u0) 'SP1Y6ZAD2ZZFKNWN58V8EA42R3VRWFJSGWFAD9C36))
      (map-set token-count 'SP1Y6ZAD2ZZFKNWN58V8EA42R3VRWFJSGWFAD9C36 (+ (get-balance 'SP1Y6ZAD2ZZFKNWN58V8EA42R3VRWFJSGWFAD9C36) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u1) 'SP21CYC2GKWTVK3FHFF4VVJNKVNQDMRY5GQS27XQB))
      (map-set token-count 'SP21CYC2GKWTVK3FHFF4VVJNKVNQDMRY5GQS27XQB (+ (get-balance 'SP21CYC2GKWTVK3FHFF4VVJNKVNQDMRY5GQS27XQB) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u2) 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D))
      (map-set token-count 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D (+ (get-balance 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u3) 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR))
      (map-set token-count 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR (+ (get-balance 'SP1VCG4HXMG02BMJCSAZDBS1WR4N2YG3RPHMNP9WR) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u4) 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F))
      (map-set token-count 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F (+ (get-balance 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u5) 'SP1FD33S5AD9MW9C57BN1R4SWMG72M9667J6BZ2P7))
      (map-set token-count 'SP1FD33S5AD9MW9C57BN1R4SWMG72M9667J6BZ2P7 (+ (get-balance 'SP1FD33S5AD9MW9C57BN1R4SWMG72M9667J6BZ2P7) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u6) 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB))
      (map-set token-count 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB (+ (get-balance 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u7) 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W))
      (map-set token-count 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W (+ (get-balance 'SP3QK75VP0Y64SAJNKTNH5WBBR798C8XAR8T4PJ6W) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u8) 'SP3W40MRS2BYEK9DEXAZQD5P08F4XR521621HMHTS))
      (map-set token-count 'SP3W40MRS2BYEK9DEXAZQD5P08F4XR521621HMHTS (+ (get-balance 'SP3W40MRS2BYEK9DEXAZQD5P08F4XR521621HMHTS) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u9) 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN))
      (map-set token-count 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN (+ (get-balance 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u10) 'SP26BGW8S8J4PZRWAR0YFDPY21T1EFZ39FBMKTHC9))
      (map-set token-count 'SP26BGW8S8J4PZRWAR0YFDPY21T1EFZ39FBMKTHC9 (+ (get-balance 'SP26BGW8S8J4PZRWAR0YFDPY21T1EFZ39FBMKTHC9) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u11) 'SP21XGA9DKVQSPSDKXT6X3QM9K9BGTVER5EF76G2P))
      (map-set token-count 'SP21XGA9DKVQSPSDKXT6X3QM9K9BGTVER5EF76G2P (+ (get-balance 'SP21XGA9DKVQSPSDKXT6X3QM9K9BGTVER5EF76G2P) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u12) 'SP2YG90T7GPVJDGXQAJ40Y08NB5ZBV4KVASSAQNE8))
      (map-set token-count 'SP2YG90T7GPVJDGXQAJ40Y08NB5ZBV4KVASSAQNE8 (+ (get-balance 'SP2YG90T7GPVJDGXQAJ40Y08NB5ZBV4KVASSAQNE8) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u13) 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1))
      (map-set token-count 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 (+ (get-balance 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u14) 'SP3BCZN307DECNR5PRMV6HY4P37AJ9N48JP0VE547))
      (map-set token-count 'SP3BCZN307DECNR5PRMV6HY4P37AJ9N48JP0VE547 (+ (get-balance 'SP3BCZN307DECNR5PRMV6HY4P37AJ9N48JP0VE547) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u15) 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ))
      (map-set token-count 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ (+ (get-balance 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u16) 'SP22W7TM6NG3PJ2XVVND2E06D50K3DDNREBTKGFD3))
      (map-set token-count 'SP22W7TM6NG3PJ2XVVND2E06D50K3DDNREBTKGFD3 (+ (get-balance 'SP22W7TM6NG3PJ2XVVND2E06D50K3DDNREBTKGFD3) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u17) 'SPQS1J3X9FJ6N4E9K2MW81W5DNBSCC8ZPHR6K2YA))
      (map-set token-count 'SPQS1J3X9FJ6N4E9K2MW81W5DNBSCC8ZPHR6K2YA (+ (get-balance 'SPQS1J3X9FJ6N4E9K2MW81W5DNBSCC8ZPHR6K2YA) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u18) 'SP30AEXNHBE87E97QZAG0A3SC6GNM6QJ6QN2NN7B0))
      (map-set token-count 'SP30AEXNHBE87E97QZAG0A3SC6GNM6QJ6QN2NN7B0 (+ (get-balance 'SP30AEXNHBE87E97QZAG0A3SC6GNM6QJ6QN2NN7B0) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u19) 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD))
      (map-set token-count 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD (+ (get-balance 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u20) 'SP1S7NH168W3GMJXAJAHVVF19N0PVRA5S6M5TAZ89))
      (map-set token-count 'SP1S7NH168W3GMJXAJAHVVF19N0PVRA5S6M5TAZ89 (+ (get-balance 'SP1S7NH168W3GMJXAJAHVVF19N0PVRA5S6M5TAZ89) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u21) 'SP3A6MXM03SG0WCMP4BH81NVTDNDS5FMWH3QH1KED))
      (map-set token-count 'SP3A6MXM03SG0WCMP4BH81NVTDNDS5FMWH3QH1KED (+ (get-balance 'SP3A6MXM03SG0WCMP4BH81NVTDNDS5FMWH3QH1KED) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u22) 'SP27NY6K2J9SE09A7E2ZJQT9ZWVCHE2EJCGDWSS0K))
      (map-set token-count 'SP27NY6K2J9SE09A7E2ZJQT9ZWVCHE2EJCGDWSS0K (+ (get-balance 'SP27NY6K2J9SE09A7E2ZJQT9ZWVCHE2EJCGDWSS0K) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u23) 'SP3477JMVDZ9CED6XVXVK1GYZBDYR2TVS32XTAC35))
      (map-set token-count 'SP3477JMVDZ9CED6XVXVK1GYZBDYR2TVS32XTAC35 (+ (get-balance 'SP3477JMVDZ9CED6XVXVK1GYZBDYR2TVS32XTAC35) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u24) 'SP1H71QS9G5C91219EGBCHSRCX6SP9BQ73ZXM3NJR))
      (map-set token-count 'SP1H71QS9G5C91219EGBCHSRCX6SP9BQ73ZXM3NJR (+ (get-balance 'SP1H71QS9G5C91219EGBCHSRCX6SP9BQ73ZXM3NJR) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u25) 'SP1RC32FVFFG9300BDV5GAB8YAHH26PHPP2WXBE49))
      (map-set token-count 'SP1RC32FVFFG9300BDV5GAB8YAHH26PHPP2WXBE49 (+ (get-balance 'SP1RC32FVFFG9300BDV5GAB8YAHH26PHPP2WXBE49) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u26) 'SP36XZQS7QBZ3GTVD1EAV44P4ZRE74ABWJJDBSKGY))
      (map-set token-count 'SP36XZQS7QBZ3GTVD1EAV44P4ZRE74ABWJJDBSKGY (+ (get-balance 'SP36XZQS7QBZ3GTVD1EAV44P4ZRE74ABWJJDBSKGY) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u27) 'SP224YKZ55F25SBYVR8HZXQ7G89CC8WYKAGMZHQ0A))
      (map-set token-count 'SP224YKZ55F25SBYVR8HZXQ7G89CC8WYKAGMZHQ0A (+ (get-balance 'SP224YKZ55F25SBYVR8HZXQ7G89CC8WYKAGMZHQ0A) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u28) 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6))
      (map-set token-count 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6 (+ (get-balance 'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u29) 'SP17TK9D2MWWSE1GWD3Q8SFT5AMT8TTDGQHZ023M6))
      (map-set token-count 'SP17TK9D2MWWSE1GWD3Q8SFT5AMT8TTDGQHZ023M6 (+ (get-balance 'SP17TK9D2MWWSE1GWD3Q8SFT5AMT8TTDGQHZ023M6) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u30) 'SP3A78PJNJSTT13CD6AMCVGGBZW3A3PE7ZPQYEGV3))
      (map-set token-count 'SP3A78PJNJSTT13CD6AMCVGGBZW3A3PE7ZPQYEGV3 (+ (get-balance 'SP3A78PJNJSTT13CD6AMCVGGBZW3A3PE7ZPQYEGV3) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u31) 'SPK75AE4F1N16SDBG8RHHRGXZJGF96F6SFRXBZ6X))
      (map-set token-count 'SPK75AE4F1N16SDBG8RHHRGXZJGF96F6SFRXBZ6X (+ (get-balance 'SPK75AE4F1N16SDBG8RHHRGXZJGF96F6SFRXBZ6X) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u32) 'SP9J6BTSPCXGQ5HC066NRYQPK43S48V7K299PTQX))
      (map-set token-count 'SP9J6BTSPCXGQ5HC066NRYQPK43S48V7K299PTQX (+ (get-balance 'SP9J6BTSPCXGQ5HC066NRYQPK43S48V7K299PTQX) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u33) 'SP1MB7PNBSC413BYFV3Y9C8EMDNYXTYGR9609HSEE))
      (map-set token-count 'SP1MB7PNBSC413BYFV3Y9C8EMDNYXTYGR9609HSEE (+ (get-balance 'SP1MB7PNBSC413BYFV3Y9C8EMDNYXTYGR9609HSEE) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u34) 'SPTKM7MPCBFMN12DR9FR2ANJ67EHTH1RHKNQXQZ2))
      (map-set token-count 'SPTKM7MPCBFMN12DR9FR2ANJ67EHTH1RHKNQXQZ2 (+ (get-balance 'SPTKM7MPCBFMN12DR9FR2ANJ67EHTH1RHKNQXQZ2) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u35) 'SP2ABRYMZ38D5BHDMWPX6V0PKYA733W2T755DKQ72))
      (map-set token-count 'SP2ABRYMZ38D5BHDMWPX6V0PKYA733W2T755DKQ72 (+ (get-balance 'SP2ABRYMZ38D5BHDMWPX6V0PKYA733W2T755DKQ72) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u36) 'SP1M0CADMZCHH410WV41JAP6AB27KS11P4E56Q0M8))
      (map-set token-count 'SP1M0CADMZCHH410WV41JAP6AB27KS11P4E56Q0M8 (+ (get-balance 'SP1M0CADMZCHH410WV41JAP6AB27KS11P4E56Q0M8) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u37) 'SP2ZRVGFW8QYW9HXTMEABGZTPX0PV10E6D7KDNMA))
      (map-set token-count 'SP2ZRVGFW8QYW9HXTMEABGZTPX0PV10E6D7KDNMA (+ (get-balance 'SP2ZRVGFW8QYW9HXTMEABGZTPX0PV10E6D7KDNMA) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u38) 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR))
      (map-set token-count 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR (+ (get-balance 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u39) 'SPD1306AT35DBQJBJ2CPV6F2Y8NWD9720ZQBDQF6))
      (map-set token-count 'SPD1306AT35DBQJBJ2CPV6F2Y8NWD9720ZQBDQF6 (+ (get-balance 'SPD1306AT35DBQJBJ2CPV6F2Y8NWD9720ZQBDQF6) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u40) 'SP3J4WEWR42Q5919MR8CBV4X4ZC19SSA0Q7PKHZVG))
      (map-set token-count 'SP3J4WEWR42Q5919MR8CBV4X4ZC19SSA0Q7PKHZVG (+ (get-balance 'SP3J4WEWR42Q5919MR8CBV4X4ZC19SSA0Q7PKHZVG) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u41) 'SPWHS9SQ9YXWYNRCS6REAE8MAJG1HQ55PBS5XEFM))
      (map-set token-count 'SPWHS9SQ9YXWYNRCS6REAE8MAJG1HQ55PBS5XEFM (+ (get-balance 'SPWHS9SQ9YXWYNRCS6REAE8MAJG1HQ55PBS5XEFM) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u42) 'SP1MX63HP0YD1TFAR0J6N6VYN3KVED5AF5JHPH1B7))
      (map-set token-count 'SP1MX63HP0YD1TFAR0J6N6VYN3KVED5AF5JHPH1B7 (+ (get-balance 'SP1MX63HP0YD1TFAR0J6N6VYN3KVED5AF5JHPH1B7) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u43) 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7))
      (map-set token-count 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7 (+ (get-balance 'SP1FJN5P7V9W2K96VN7YWGH7VP36RB5K5JW1R9HF7) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u44) 'SP3NESGVGJE860NK0CD8N03WZPRAD9QNYSRG57XQ1))
      (map-set token-count 'SP3NESGVGJE860NK0CD8N03WZPRAD9QNYSRG57XQ1 (+ (get-balance 'SP3NESGVGJE860NK0CD8N03WZPRAD9QNYSRG57XQ1) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u45) 'SP2EVYKET55QH40RAZE5PVZ363QX0X6BSRP4C7H0W))
      (map-set token-count 'SP2EVYKET55QH40RAZE5PVZ363QX0X6BSRP4C7H0W (+ (get-balance 'SP2EVYKET55QH40RAZE5PVZ363QX0X6BSRP4C7H0W) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u46) 'SP7Y8N2RQ371ENBV3W1PE6SBDHWZ98EJ3XB44M1V))
      (map-set token-count 'SP7Y8N2RQ371ENBV3W1PE6SBDHWZ98EJ3XB44M1V (+ (get-balance 'SP7Y8N2RQ371ENBV3W1PE6SBDHWZ98EJ3XB44M1V) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u47) 'SP3R6A3JVZ75PPVGRJBGYHVN5829RJ4XDSP96G3TQ))
      (map-set token-count 'SP3R6A3JVZ75PPVGRJBGYHVN5829RJ4XDSP96G3TQ (+ (get-balance 'SP3R6A3JVZ75PPVGRJBGYHVN5829RJ4XDSP96G3TQ) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u48) 'SP1XWMPQJCHR9QVWMF5Y22T3JHFYEGSAZNVHRQ5NW))
      (map-set token-count 'SP1XWMPQJCHR9QVWMF5Y22T3JHFYEGSAZNVHRQ5NW (+ (get-balance 'SP1XWMPQJCHR9QVWMF5Y22T3JHFYEGSAZNVHRQ5NW) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u49) 'SPV0C8Z3TZCPPXEQWP5QDH5EYMXDX55K3A37E7Q3))
      (map-set token-count 'SPV0C8Z3TZCPPXEQWP5QDH5EYMXDX55K3A37E7Q3 (+ (get-balance 'SPV0C8Z3TZCPPXEQWP5QDH5EYMXDX55K3A37E7Q3) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u50) 'SP3M51V1NX5SAB93VR5SSPVQA0PSAM2CVYTS6YV9X))
      (map-set token-count 'SP3M51V1NX5SAB93VR5SSPVQA0PSAM2CVYTS6YV9X (+ (get-balance 'SP3M51V1NX5SAB93VR5SSPVQA0PSAM2CVYTS6YV9X) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u51) 'SP3SWN50J1YN2TPM6HB7JQAFE2QVXKBH1Q3A7TYX8))
      (map-set token-count 'SP3SWN50J1YN2TPM6HB7JQAFE2QVXKBH1Q3A7TYX8 (+ (get-balance 'SP3SWN50J1YN2TPM6HB7JQAFE2QVXKBH1Q3A7TYX8) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u52) 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27))
      (map-set token-count 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27 (+ (get-balance 'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u53) 'SPBE74MS6ESXAN80S6622KEKNXJ9FHNBW42X04VN))
      (map-set token-count 'SPBE74MS6ESXAN80S6622KEKNXJ9FHNBW42X04VN (+ (get-balance 'SPBE74MS6ESXAN80S6622KEKNXJ9FHNBW42X04VN) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u54) 'SPFE66GRB81A049NK6AP99FZC4QZMNE1K898DN1J))
      (map-set token-count 'SPFE66GRB81A049NK6AP99FZC4QZMNE1K898DN1J (+ (get-balance 'SPFE66GRB81A049NK6AP99FZC4QZMNE1K898DN1J) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u55) 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4))
      (map-set token-count 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4 (+ (get-balance 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u56) 'SP3J0Z8YSJD20TGEBE6M992CWFDG18VB0PR599VY9))
      (map-set token-count 'SP3J0Z8YSJD20TGEBE6M992CWFDG18VB0PR599VY9 (+ (get-balance 'SP3J0Z8YSJD20TGEBE6M992CWFDG18VB0PR599VY9) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u57) 'SP31SXJHBV3YN94HQX7NR7TV9RBM8NSNYAGXG9R6X))
      (map-set token-count 'SP31SXJHBV3YN94HQX7NR7TV9RBM8NSNYAGXG9R6X (+ (get-balance 'SP31SXJHBV3YN94HQX7NR7TV9RBM8NSNYAGXG9R6X) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u58) 'SP3GAHKNWW53M6D0YYCXN618QS66X3NG3STR6KPWW))
      (map-set token-count 'SP3GAHKNWW53M6D0YYCXN618QS66X3NG3STR6KPWW (+ (get-balance 'SP3GAHKNWW53M6D0YYCXN618QS66X3NG3STR6KPWW) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u59) 'SPQF1PRMSNTK0FJ18SW731N5RGVKCMG3H4NS52AK))
      (map-set token-count 'SPQF1PRMSNTK0FJ18SW731N5RGVKCMG3H4NS52AK (+ (get-balance 'SPQF1PRMSNTK0FJ18SW731N5RGVKCMG3H4NS52AK) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u60) 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV))
      (map-set token-count 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV (+ (get-balance 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u61) 'SP18FMD61A5D7H9G6KEEBKNAC7Y31JQ34DMXJSQ7B))
      (map-set token-count 'SP18FMD61A5D7H9G6KEEBKNAC7Y31JQ34DMXJSQ7B (+ (get-balance 'SP18FMD61A5D7H9G6KEEBKNAC7Y31JQ34DMXJSQ7B) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u62) 'SP3CES9R2SAE5MMB5A8ADK3TPRTYCXJZ9WTFJ5ZA3))
      (map-set token-count 'SP3CES9R2SAE5MMB5A8ADK3TPRTYCXJZ9WTFJ5ZA3 (+ (get-balance 'SP3CES9R2SAE5MMB5A8ADK3TPRTYCXJZ9WTFJ5ZA3) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u63) 'SP11NVBTTWKXK78KFMAYJAB1DE7GEH788RS2Q5W5T))
      (map-set token-count 'SP11NVBTTWKXK78KFMAYJAB1DE7GEH788RS2Q5W5T (+ (get-balance 'SP11NVBTTWKXK78KFMAYJAB1DE7GEH788RS2Q5W5T) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u64) 'SP1MHY15EK4JA9JJRBM0A3KWS6YB5FK1304SR2Q99))
      (map-set token-count 'SP1MHY15EK4JA9JJRBM0A3KWS6YB5FK1304SR2Q99 (+ (get-balance 'SP1MHY15EK4JA9JJRBM0A3KWS6YB5FK1304SR2Q99) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u65) 'SPK9FHX9HT1ZX2B57Q8VJ5RG59TTNVRA9SSVPJYM))
      (map-set token-count 'SPK9FHX9HT1ZX2B57Q8VJ5RG59TTNVRA9SSVPJYM (+ (get-balance 'SPK9FHX9HT1ZX2B57Q8VJ5RG59TTNVRA9SSVPJYM) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u66) 'SP2JZ9JWWGSMJTZCME7RZ75CGN1C1XPKW7EVPVGQ0))
      (map-set token-count 'SP2JZ9JWWGSMJTZCME7RZ75CGN1C1XPKW7EVPVGQ0 (+ (get-balance 'SP2JZ9JWWGSMJTZCME7RZ75CGN1C1XPKW7EVPVGQ0) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u67) 'SPA5SMCSGBNYETEHZPJ7BVPSG327P5DK18ZXQXH5))
      (map-set token-count 'SPA5SMCSGBNYETEHZPJ7BVPSG327P5DK18ZXQXH5 (+ (get-balance 'SPA5SMCSGBNYETEHZPJ7BVPSG327P5DK18ZXQXH5) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u68) 'SP3FW1DJAT60F3D63FHVB1W031SXKKB4T864MG5ET))
      (map-set token-count 'SP3FW1DJAT60F3D63FHVB1W031SXKKB4T864MG5ET (+ (get-balance 'SP3FW1DJAT60F3D63FHVB1W031SXKKB4T864MG5ET) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u69) 'SP1A93YZ5T5XQC57RGV2FKSRB5RM9RZ87TTM1KC67))
      (map-set token-count 'SP1A93YZ5T5XQC57RGV2FKSRB5RM9RZ87TTM1KC67 (+ (get-balance 'SP1A93YZ5T5XQC57RGV2FKSRB5RM9RZ87TTM1KC67) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u70) 'SP3VCX5NFQ8VCHFS9M6N40ZJNVTRT4HZ62WFH5C4Q))
      (map-set token-count 'SP3VCX5NFQ8VCHFS9M6N40ZJNVTRT4HZ62WFH5C4Q (+ (get-balance 'SP3VCX5NFQ8VCHFS9M6N40ZJNVTRT4HZ62WFH5C4Q) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u71) 'SP24GYRG3M7T0S6FZE9RVVP9PNNZQJQ614650G590))
      (map-set token-count 'SP24GYRG3M7T0S6FZE9RVVP9PNNZQJQ614650G590 (+ (get-balance 'SP24GYRG3M7T0S6FZE9RVVP9PNNZQJQ614650G590) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u72) 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173))
      (map-set token-count 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173 (+ (get-balance 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u73) 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173))
      (map-set token-count 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173 (+ (get-balance 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u74) 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173))
      (map-set token-count 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173 (+ (get-balance 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u75) 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173))
      (map-set token-count 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173 (+ (get-balance 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173) u1))
      (try! (nft-mint? the-explorer-guild-christmas-2022 (+ last-nft-id u76) 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173))
      (map-set token-count 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173 (+ (get-balance 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173) u1))

      (var-set last-id (+ last-nft-id u77))
      (var-set airdrop-called true)
      (ok true))))