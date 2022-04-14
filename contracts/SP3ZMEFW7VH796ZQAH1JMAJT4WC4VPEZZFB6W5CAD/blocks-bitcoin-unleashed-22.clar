;; blocks-bitcoin-unleashed-22

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token blocks-bitcoin-unleashed-22 uint)

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
(define-data-var mint-limit uint u25)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0000000)
(define-data-var artist-address principal 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmZpGmMs3TFEUWvwymS6DBjyWzEDgQBhEWy5sJW3a2nHDh/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u1)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

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
      (unwrap! (nft-mint? blocks-bitcoin-unleashed-22 next-id tx-sender) next-id)
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
    (nft-burn? blocks-bitcoin-unleashed-22 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? blocks-bitcoin-unleashed-22 token-id) false)))

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
  (ok (nft-get-owner? blocks-bitcoin-unleashed-22 token-id)))

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
  (match (nft-transfer? blocks-bitcoin-unleashed-22 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? blocks-bitcoin-unleashed-22 id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? blocks-bitcoin-unleashed-22 id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u0) 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV))
      (map-set token-count 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV (+ (get-balance 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u1) 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D))
      (map-set token-count 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D (+ (get-balance 'SP2FHRXHTZBFGPFKSNWFGYPNBQXKSXC2JFJZ7BY7D) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u2) 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW))
      (map-set token-count 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW (+ (get-balance 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u3) 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N))
      (map-set token-count 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N (+ (get-balance 'SP27E3TDKYNH3C11RBDFPD5WGR6FV0VN08RKX4D2N) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u4) 'SP1ZCYG0D3HCK2F7SY8VH9ZREB0JWCBSAPFNS8V5Z))
      (map-set token-count 'SP1ZCYG0D3HCK2F7SY8VH9ZREB0JWCBSAPFNS8V5Z (+ (get-balance 'SP1ZCYG0D3HCK2F7SY8VH9ZREB0JWCBSAPFNS8V5Z) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u5) 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9))
      (map-set token-count 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 (+ (get-balance 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u6) 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6))
      (map-set token-count 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6 (+ (get-balance 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u7) 'SP1BBA92W9S1MD4AAK1JM2Z4G03W2H6PS1EK82YXR))
      (map-set token-count 'SP1BBA92W9S1MD4AAK1JM2Z4G03W2H6PS1EK82YXR (+ (get-balance 'SP1BBA92W9S1MD4AAK1JM2Z4G03W2H6PS1EK82YXR) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u8) 'SP3J1W2FS54ZEB5W64S0DFFPS86AGYGFB4VM0CFC2))
      (map-set token-count 'SP3J1W2FS54ZEB5W64S0DFFPS86AGYGFB4VM0CFC2 (+ (get-balance 'SP3J1W2FS54ZEB5W64S0DFFPS86AGYGFB4VM0CFC2) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u9) 'SP2MJC01HV090N8NKC4J5E1W9A19V7HE9VEKD2ZQT))
      (map-set token-count 'SP2MJC01HV090N8NKC4J5E1W9A19V7HE9VEKD2ZQT (+ (get-balance 'SP2MJC01HV090N8NKC4J5E1W9A19V7HE9VEKD2ZQT) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u10) 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9))
      (map-set token-count 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9 (+ (get-balance 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u11) 'SP2V6HR6CTCKYSBC47F1V6D1FMCSHJ0SXM0MJZYVY))
      (map-set token-count 'SP2V6HR6CTCKYSBC47F1V6D1FMCSHJ0SXM0MJZYVY (+ (get-balance 'SP2V6HR6CTCKYSBC47F1V6D1FMCSHJ0SXM0MJZYVY) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u12) 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ))
      (map-set token-count 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ (+ (get-balance 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u13) 'SP15MYY6R4A44A4TGVEZZ2GNWVNGG9G4FNE097FK7))
      (map-set token-count 'SP15MYY6R4A44A4TGVEZZ2GNWVNGG9G4FNE097FK7 (+ (get-balance 'SP15MYY6R4A44A4TGVEZZ2GNWVNGG9G4FNE097FK7) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u14) 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ))
      (map-set token-count 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ (+ (get-balance 'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u15) 'SP69MS8W17WWT6MNH8AB4A7BMY5AX6MAMWD89CCR))
      (map-set token-count 'SP69MS8W17WWT6MNH8AB4A7BMY5AX6MAMWD89CCR (+ (get-balance 'SP69MS8W17WWT6MNH8AB4A7BMY5AX6MAMWD89CCR) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u16) 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G))
      (map-set token-count 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G (+ (get-balance 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u17) 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51))
      (map-set token-count 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51 (+ (get-balance 'SP25VWGTPR19E344S4ENTHQT8651216EPNABRYE51) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u18) 'SP8JVD8G9RRXPWF13STYZSJDDP25WSM8GWB46MAX))
      (map-set token-count 'SP8JVD8G9RRXPWF13STYZSJDDP25WSM8GWB46MAX (+ (get-balance 'SP8JVD8G9RRXPWF13STYZSJDDP25WSM8GWB46MAX) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u19) 'SP3SXZEV9KGEF5VM9N1CVHY9482XJ50MNS4KPSSCD))
      (map-set token-count 'SP3SXZEV9KGEF5VM9N1CVHY9482XJ50MNS4KPSSCD (+ (get-balance 'SP3SXZEV9KGEF5VM9N1CVHY9482XJ50MNS4KPSSCD) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u20) 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W))
      (map-set token-count 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W (+ (get-balance 'SP2R3CHRAP1HE4M64X1NZXHZT41JG3XGNHJW4HX2W) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u21) 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD))
      (map-set token-count 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD (+ (get-balance 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u22) 'SP2DCZAFH72S458MNV9SEE3Q983V9CJG49X2J3P7G))
      (map-set token-count 'SP2DCZAFH72S458MNV9SEE3Q983V9CJG49X2J3P7G (+ (get-balance 'SP2DCZAFH72S458MNV9SEE3Q983V9CJG49X2J3P7G) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u23) 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A))
      (map-set token-count 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A (+ (get-balance 'SP2F40S465JTD7AMZ2X9SMN229617HZ9YB0HHY98A) u1))
      (try! (nft-mint? blocks-bitcoin-unleashed-22 (+ last-nft-id u24) 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA))
      (map-set token-count 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA (+ (get-balance 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA) u1))

      (var-set last-id (+ last-nft-id u25))
      (var-set airdrop-called true)
      (ok true))))