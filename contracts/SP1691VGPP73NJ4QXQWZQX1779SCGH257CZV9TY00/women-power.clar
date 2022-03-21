;; women-power

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token women-power uint)

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
(define-data-var total-price uint u40000000)
(define-data-var artist-address principal 'SP19FY39F3VFK8N59RBGTNSFKZ7DE01VFVAVXDHHF)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/Qma5TTxLDLi7XTn2reMcVGJjuQ5H5sCsuo6VDnnmvNc5Gi/json/")
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

;; Default Minting
(define-private (mint (orders (list 25 bool)))
  (mint-many orders))

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
      (unwrap! (nft-mint? women-power next-id tx-sender) next-id)
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
    (nft-burn? women-power token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? women-power token-id) false)))

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
  (ok (nft-get-owner? women-power token-id)))

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
  (match (nft-transfer? women-power id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? women-power id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? women-power id) (err ERR-NOT-FOUND)))
      (listing (unwrap! (map-get? market id) (err ERR-LISTING)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err ERR-WRONG-COMMISSION))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
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
      (try! (nft-mint? women-power (+ last-nft-id u0) 'SPZ96YWTJHGP63D1REMQDY7G4NP477ANKA33PPZZ))
      (map-set token-count 'SPZ96YWTJHGP63D1REMQDY7G4NP477ANKA33PPZZ (+ (get-balance 'SPZ96YWTJHGP63D1REMQDY7G4NP477ANKA33PPZZ) u1))
      (try! (nft-mint? women-power (+ last-nft-id u1) 'SPZ96YWTJHGP63D1REMQDY7G4NP477ANKA33PPZZ))
      (map-set token-count 'SPZ96YWTJHGP63D1REMQDY7G4NP477ANKA33PPZZ (+ (get-balance 'SPZ96YWTJHGP63D1REMQDY7G4NP477ANKA33PPZZ) u1))
      (try! (nft-mint? women-power (+ last-nft-id u2) 'SP23FCMK31M19E0NNRQ8BXZK0J3KMWF2Q4WMGJJQ2))
      (map-set token-count 'SP23FCMK31M19E0NNRQ8BXZK0J3KMWF2Q4WMGJJQ2 (+ (get-balance 'SP23FCMK31M19E0NNRQ8BXZK0J3KMWF2Q4WMGJJQ2) u1))
      (try! (nft-mint? women-power (+ last-nft-id u3) 'SP1B9N18RNHJTXV9B8WQWN6PYEP2B7S7TXE7HWZCT))
      (map-set token-count 'SP1B9N18RNHJTXV9B8WQWN6PYEP2B7S7TXE7HWZCT (+ (get-balance 'SP1B9N18RNHJTXV9B8WQWN6PYEP2B7S7TXE7HWZCT) u1))
      (try! (nft-mint? women-power (+ last-nft-id u4) 'SP2MTXD3QZSR7KZJFZ5T8CG9QHDQVKC7QK6QWFFCF))
      (map-set token-count 'SP2MTXD3QZSR7KZJFZ5T8CG9QHDQVKC7QK6QWFFCF (+ (get-balance 'SP2MTXD3QZSR7KZJFZ5T8CG9QHDQVKC7QK6QWFFCF) u1))
      (try! (nft-mint? women-power (+ last-nft-id u5) 'SP1691VGPP73NJ4QXQWZQX1779SCGH257CZV9TY00))
      (map-set token-count 'SP1691VGPP73NJ4QXQWZQX1779SCGH257CZV9TY00 (+ (get-balance 'SP1691VGPP73NJ4QXQWZQX1779SCGH257CZV9TY00) u1))
      (try! (nft-mint? women-power (+ last-nft-id u6) 'SPAT01J1XN77CT1CQM44M9TCS99DNWYZFNMMHXH8))
      (map-set token-count 'SPAT01J1XN77CT1CQM44M9TCS99DNWYZFNMMHXH8 (+ (get-balance 'SPAT01J1XN77CT1CQM44M9TCS99DNWYZFNMMHXH8) u1))
      (try! (nft-mint? women-power (+ last-nft-id u7) 'SP267TMY9MTMP98AW05X8RFQ43JRMTPGDWFKFCPTH))
      (map-set token-count 'SP267TMY9MTMP98AW05X8RFQ43JRMTPGDWFKFCPTH (+ (get-balance 'SP267TMY9MTMP98AW05X8RFQ43JRMTPGDWFKFCPTH) u1))
      (try! (nft-mint? women-power (+ last-nft-id u8) 'SP3KPC43PAJA0ZFEYNGZDWTHKPWKSHF8ARP2CQ6ED))
      (map-set token-count 'SP3KPC43PAJA0ZFEYNGZDWTHKPWKSHF8ARP2CQ6ED (+ (get-balance 'SP3KPC43PAJA0ZFEYNGZDWTHKPWKSHF8ARP2CQ6ED) u1))
      (try! (nft-mint? women-power (+ last-nft-id u9) 'SP2W5AT6FW839WN5VSNCZ6BTTHZRBKC9Y3H2NAZEJ))
      (map-set token-count 'SP2W5AT6FW839WN5VSNCZ6BTTHZRBKC9Y3H2NAZEJ (+ (get-balance 'SP2W5AT6FW839WN5VSNCZ6BTTHZRBKC9Y3H2NAZEJ) u1))
      (try! (nft-mint? women-power (+ last-nft-id u10) 'SP1K5B6SB17HKS422FX9F6NJ4E9RWA6C53HRYF0G9))
      (map-set token-count 'SP1K5B6SB17HKS422FX9F6NJ4E9RWA6C53HRYF0G9 (+ (get-balance 'SP1K5B6SB17HKS422FX9F6NJ4E9RWA6C53HRYF0G9) u1))
      (try! (nft-mint? women-power (+ last-nft-id u11) 'SP2STXMBHNNAVYJG4JQ99GDV3VCYZKN2107ETXA2K))
      (map-set token-count 'SP2STXMBHNNAVYJG4JQ99GDV3VCYZKN2107ETXA2K (+ (get-balance 'SP2STXMBHNNAVYJG4JQ99GDV3VCYZKN2107ETXA2K) u1))
      (try! (nft-mint? women-power (+ last-nft-id u12) 'SPDAV1G8FQ0TMEWKVE0A9WS8RNDJ7K808X2MY22E))
      (map-set token-count 'SPDAV1G8FQ0TMEWKVE0A9WS8RNDJ7K808X2MY22E (+ (get-balance 'SPDAV1G8FQ0TMEWKVE0A9WS8RNDJ7K808X2MY22E) u1))
      (try! (nft-mint? women-power (+ last-nft-id u13) 'SP31SYCQVVS1TE6CHYDTFE89XQ6SVBSM3V6VGBTF5))
      (map-set token-count 'SP31SYCQVVS1TE6CHYDTFE89XQ6SVBSM3V6VGBTF5 (+ (get-balance 'SP31SYCQVVS1TE6CHYDTFE89XQ6SVBSM3V6VGBTF5) u1))
      (try! (nft-mint? women-power (+ last-nft-id u14) 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69))
      (map-set token-count 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69 (+ (get-balance 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69) u1))
      (try! (nft-mint? women-power (+ last-nft-id u15) 'SP3XDE7YPKZ3GJGBEJRFZCAHFX960ZXX4WMW9A9MZ))
      (map-set token-count 'SP3XDE7YPKZ3GJGBEJRFZCAHFX960ZXX4WMW9A9MZ (+ (get-balance 'SP3XDE7YPKZ3GJGBEJRFZCAHFX960ZXX4WMW9A9MZ) u1))
      (try! (nft-mint? women-power (+ last-nft-id u16) 'SP3H94JS77EWB2QY8148CP5BWXSFWJCSYZBSZSHVT))
      (map-set token-count 'SP3H94JS77EWB2QY8148CP5BWXSFWJCSYZBSZSHVT (+ (get-balance 'SP3H94JS77EWB2QY8148CP5BWXSFWJCSYZBSZSHVT) u1))
      (try! (nft-mint? women-power (+ last-nft-id u17) 'SP2AZ41V8YW95KWZPP8AXN4M3PYGX4TNYV97PKK6H))
      (map-set token-count 'SP2AZ41V8YW95KWZPP8AXN4M3PYGX4TNYV97PKK6H (+ (get-balance 'SP2AZ41V8YW95KWZPP8AXN4M3PYGX4TNYV97PKK6H) u1))
      (try! (nft-mint? women-power (+ last-nft-id u18) 'SPSN6K776CXQBFSVM74W4SAR8W7HCQD6844FA4XC))
      (map-set token-count 'SPSN6K776CXQBFSVM74W4SAR8W7HCQD6844FA4XC (+ (get-balance 'SPSN6K776CXQBFSVM74W4SAR8W7HCQD6844FA4XC) u1))
      (try! (nft-mint? women-power (+ last-nft-id u19) 'SP3Y69N0P0KA89P2ERDFTPSMX6G7KG8W294FKFJKB))
      (map-set token-count 'SP3Y69N0P0KA89P2ERDFTPSMX6G7KG8W294FKFJKB (+ (get-balance 'SP3Y69N0P0KA89P2ERDFTPSMX6G7KG8W294FKFJKB) u1))
      (try! (nft-mint? women-power (+ last-nft-id u20) 'SP3JE4MY4Z91VRE9DWPH98Y6BRRA1YS5RDK9BA6Y7))
      (map-set token-count 'SP3JE4MY4Z91VRE9DWPH98Y6BRRA1YS5RDK9BA6Y7 (+ (get-balance 'SP3JE4MY4Z91VRE9DWPH98Y6BRRA1YS5RDK9BA6Y7) u1))
      (try! (nft-mint? women-power (+ last-nft-id u21) 'SP1F787Q2Z5S4MN0CS1TNTVWB5C8HA0E73EBVBRCN))
      (map-set token-count 'SP1F787Q2Z5S4MN0CS1TNTVWB5C8HA0E73EBVBRCN (+ (get-balance 'SP1F787Q2Z5S4MN0CS1TNTVWB5C8HA0E73EBVBRCN) u1))
      (try! (nft-mint? women-power (+ last-nft-id u22) 'SPGYN0JFKZVEKB6KE4X5YTZATPG0M42A0Y1F8DMG))
      (map-set token-count 'SPGYN0JFKZVEKB6KE4X5YTZATPG0M42A0Y1F8DMG (+ (get-balance 'SPGYN0JFKZVEKB6KE4X5YTZATPG0M42A0Y1F8DMG) u1))
      (try! (nft-mint? women-power (+ last-nft-id u23) 'SP3QEHWDWT8NM3CJDV6SQBH3A5HMQJH7V2JMTS4AR))
      (map-set token-count 'SP3QEHWDWT8NM3CJDV6SQBH3A5HMQJH7V2JMTS4AR (+ (get-balance 'SP3QEHWDWT8NM3CJDV6SQBH3A5HMQJH7V2JMTS4AR) u1))
      (try! (nft-mint? women-power (+ last-nft-id u24) 'SP2KSG8S69M0P5H421662QF1ETXSBA5ENQR2N9C0C))
      (map-set token-count 'SP2KSG8S69M0P5H421662QF1ETXSBA5ENQR2N9C0C (+ (get-balance 'SP2KSG8S69M0P5H421662QF1ETXSBA5ENQR2N9C0C) u1))
      (try! (nft-mint? women-power (+ last-nft-id u25) 'SP14E544B2FY8BSKTV5V7W8NCRYX2B7NXRQ7B7NJ9))
      (map-set token-count 'SP14E544B2FY8BSKTV5V7W8NCRYX2B7NXRQ7B7NJ9 (+ (get-balance 'SP14E544B2FY8BSKTV5V7W8NCRYX2B7NXRQ7B7NJ9) u1))
      (try! (nft-mint? women-power (+ last-nft-id u26) 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM))
      (map-set token-count 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM (+ (get-balance 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM) u1))
      (try! (nft-mint? women-power (+ last-nft-id u27) 'SP27A09VG1SH1J8Z76NXHBGKB0ZWSBZ99DRGAC8NB))
      (map-set token-count 'SP27A09VG1SH1J8Z76NXHBGKB0ZWSBZ99DRGAC8NB (+ (get-balance 'SP27A09VG1SH1J8Z76NXHBGKB0ZWSBZ99DRGAC8NB) u1))
      (try! (nft-mint? women-power (+ last-nft-id u28) 'SP1FBDV7183BMRESDSKYAA712WVGZA9M95H06VG1W))
      (map-set token-count 'SP1FBDV7183BMRESDSKYAA712WVGZA9M95H06VG1W (+ (get-balance 'SP1FBDV7183BMRESDSKYAA712WVGZA9M95H06VG1W) u1))
      (try! (nft-mint? women-power (+ last-nft-id u29) 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE))
      (map-set token-count 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE (+ (get-balance 'SP31WTJ415SNJM9H6202S3WK9AFQXQZMT48PESBQE) u1))
      (try! (nft-mint? women-power (+ last-nft-id u30) 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV))
      (map-set token-count 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV (+ (get-balance 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV) u1))
      (try! (nft-mint? women-power (+ last-nft-id u31) 'SP3GXRSVBWTVS7DNK466APX88XZKAB8FT52ZQ8WG4))
      (map-set token-count 'SP3GXRSVBWTVS7DNK466APX88XZKAB8FT52ZQ8WG4 (+ (get-balance 'SP3GXRSVBWTVS7DNK466APX88XZKAB8FT52ZQ8WG4) u1))
      (try! (nft-mint? women-power (+ last-nft-id u32) 'SP34MV4DJHYHRDNCRZFH0E6BGKDXG40KKDWQEMMRH))
      (map-set token-count 'SP34MV4DJHYHRDNCRZFH0E6BGKDXG40KKDWQEMMRH (+ (get-balance 'SP34MV4DJHYHRDNCRZFH0E6BGKDXG40KKDWQEMMRH) u1))
      (try! (nft-mint? women-power (+ last-nft-id u33) 'SP1K6W1QST3KKJHM4KGG2BN2WZQTD86PC8H9STN1B))
      (map-set token-count 'SP1K6W1QST3KKJHM4KGG2BN2WZQTD86PC8H9STN1B (+ (get-balance 'SP1K6W1QST3KKJHM4KGG2BN2WZQTD86PC8H9STN1B) u1))
      (try! (nft-mint? women-power (+ last-nft-id u34) 'SP1H69NEPZYFKKA74Q0HXTFC3DYNYZKZZA8ZP8MFS))
      (map-set token-count 'SP1H69NEPZYFKKA74Q0HXTFC3DYNYZKZZA8ZP8MFS (+ (get-balance 'SP1H69NEPZYFKKA74Q0HXTFC3DYNYZKZZA8ZP8MFS) u1))
      (try! (nft-mint? women-power (+ last-nft-id u35) 'SPACYCZ2Q9EMAZ4PKD90SRXPWHKNEHK1MXPA7TAK))
      (map-set token-count 'SPACYCZ2Q9EMAZ4PKD90SRXPWHKNEHK1MXPA7TAK (+ (get-balance 'SPACYCZ2Q9EMAZ4PKD90SRXPWHKNEHK1MXPA7TAK) u1))
      (try! (nft-mint? women-power (+ last-nft-id u36) 'SP1GYWMYK320ASBBAERSC40TA3PA99ZHV3GF256T8))
      (map-set token-count 'SP1GYWMYK320ASBBAERSC40TA3PA99ZHV3GF256T8 (+ (get-balance 'SP1GYWMYK320ASBBAERSC40TA3PA99ZHV3GF256T8) u1))
      (try! (nft-mint? women-power (+ last-nft-id u37) 'SP1SJ9BB3D1WTX84GMJ4BTS85NCP9P6ESA8TBWC9G))
      (map-set token-count 'SP1SJ9BB3D1WTX84GMJ4BTS85NCP9P6ESA8TBWC9G (+ (get-balance 'SP1SJ9BB3D1WTX84GMJ4BTS85NCP9P6ESA8TBWC9G) u1))
      (try! (nft-mint? women-power (+ last-nft-id u38) 'SP12WR6FPXDNP9Y1C10TM0GJD91A6ZETMG66MASYY))
      (map-set token-count 'SP12WR6FPXDNP9Y1C10TM0GJD91A6ZETMG66MASYY (+ (get-balance 'SP12WR6FPXDNP9Y1C10TM0GJD91A6ZETMG66MASYY) u1))
      (try! (nft-mint? women-power (+ last-nft-id u39) 'SP1D7H14YMARPB4G7R6SCEGGVGS78G4B3HQCZ43PM))
      (map-set token-count 'SP1D7H14YMARPB4G7R6SCEGGVGS78G4B3HQCZ43PM (+ (get-balance 'SP1D7H14YMARPB4G7R6SCEGGVGS78G4B3HQCZ43PM) u1))
      (try! (nft-mint? women-power (+ last-nft-id u40) 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4))
      (map-set token-count 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4 (+ (get-balance 'SP33QYJHG988R7XD10B5MPKG7NCWQJ77ETKMA2HK4) u1))
      (try! (nft-mint? women-power (+ last-nft-id u41) 'SPPKDYQQ5QP3REJ2G98Y5NAYJYQ2WKVJ2MBBBCBH))
      (map-set token-count 'SPPKDYQQ5QP3REJ2G98Y5NAYJYQ2WKVJ2MBBBCBH (+ (get-balance 'SPPKDYQQ5QP3REJ2G98Y5NAYJYQ2WKVJ2MBBBCBH) u1))
      (try! (nft-mint? women-power (+ last-nft-id u42) 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR))
      (map-set token-count 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR (+ (get-balance 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR) u1))
      (try! (nft-mint? women-power (+ last-nft-id u43) 'SPAX2SZCDFTVV76SR4JY4RYEPC5PBH2QAHEJXHTF))
      (map-set token-count 'SPAX2SZCDFTVV76SR4JY4RYEPC5PBH2QAHEJXHTF (+ (get-balance 'SPAX2SZCDFTVV76SR4JY4RYEPC5PBH2QAHEJXHTF) u1))
      (try! (nft-mint? women-power (+ last-nft-id u44) 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69))
      (map-set token-count 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69 (+ (get-balance 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69) u1))
      (try! (nft-mint? women-power (+ last-nft-id u45) 'SP3ZF6T34TT2CCKBD46Y1C5FW5FKKNQFJW5DY2VX2))
      (map-set token-count 'SP3ZF6T34TT2CCKBD46Y1C5FW5FKKNQFJW5DY2VX2 (+ (get-balance 'SP3ZF6T34TT2CCKBD46Y1C5FW5FKKNQFJW5DY2VX2) u1))
      (try! (nft-mint? women-power (+ last-nft-id u46) 'SP1SWEP0BRXGYRKDSS83XTZVHH883JH1TZ7TQS8XZ))
      (map-set token-count 'SP1SWEP0BRXGYRKDSS83XTZVHH883JH1TZ7TQS8XZ (+ (get-balance 'SP1SWEP0BRXGYRKDSS83XTZVHH883JH1TZ7TQS8XZ) u1))
      (try! (nft-mint? women-power (+ last-nft-id u47) 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR))
      (map-set token-count 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR (+ (get-balance 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR) u1))
      (try! (nft-mint? women-power (+ last-nft-id u48) 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D))
      (map-set token-count 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D (+ (get-balance 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D) u1))
      (try! (nft-mint? women-power (+ last-nft-id u49) 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8))
      (map-set token-count 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8 (+ (get-balance 'SPPMGZTRGMBVCFW3RMEVQJEF26MW9G6EKT51EMD8) u1))

      (var-set last-id (+ last-nft-id u50))
      (var-set airdrop-called true)
      (ok true))))