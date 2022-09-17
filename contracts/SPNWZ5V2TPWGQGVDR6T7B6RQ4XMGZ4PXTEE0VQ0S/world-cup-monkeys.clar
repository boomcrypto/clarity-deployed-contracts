;; world-cup-monkeys
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token world-cup-monkeys uint)

;; Constants
(define-constant DEPLOYER tx-sender)
(define-constant COMM u500)
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
(define-data-var mint-limit uint u352)
(define-data-var last-id uint u1)
(define-data-var total-price uint u65000000)
(define-data-var artist-address principal 'SP30V40JKNRB350CRAMS8145CR8C9GA59MKA0J1SW)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmbJ1nqwiSdWShQAsbCbhZjnHiXjcsRpBh8oX5xmwj7fNh/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u0)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

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

(define-public (mint-for-many (recipients (list 25 principal)))
  (let
    (
      (next-id (var-get last-id))
      (id-reached (fold mint-for-many-iter recipients next-id))
    )
    (begin
      (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-NOT-AUTHORIZED))
      (var-set last-id id-reached)
      (ok id-reached))))

(define-private (mint-for-many-iter (recipient principal) (next-id uint))
  (if (<= next-id (var-get mint-limit))
    (begin
      (unwrap! (nft-mint? world-cup-monkeys next-id tx-sender) next-id)
      (unwrap! (nft-transfer? world-cup-monkeys next-id tx-sender recipient) next-id)
      (map-set token-count recipient (+ (get-balance recipient) u1))
      (+ next-id u1)
    )
    next-id))

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
      (unwrap! (nft-mint? world-cup-monkeys next-id tx-sender) next-id)
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
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? world-cup-monkeys token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? world-cup-monkeys token-id) false)))

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
  (ok (nft-get-owner? world-cup-monkeys token-id)))

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
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal, royalty: uint})

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? world-cup-monkeys id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? world-cup-monkeys id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? world-cup-monkeys id) (err ERR-NOT-FOUND)))
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
  (if (> royalty-amount u0)
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

;; Alt Minting Mintpass
(define-data-var total-price-banana uint u120000000)

(define-read-only (get-price-banana)
  (ok (var-get total-price-banana)))

(define-public (set-price-banana (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-banana price))))

(define-public (claim-banana)
  (mint-banana (list true)))

(define-public (claim-two-banana) (mint-banana (list true true)))

(define-public (claim-three-banana) (mint-banana (list true true true)))

(define-public (claim-four-banana) (mint-banana (list true true true true)))

(define-public (claim-five-banana) (mint-banana (list true true true true true)))

(define-public (claim-ten-banana) (mint-banana (list true true true true true true true true true true)))

(define-private (mint-banana (orders (list 25 bool)))
  (let
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-banana orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-banana orders)
      )
    )))

(define-private (mint-many-banana (orders (list 25 bool )))
  (let
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-banana) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas burn total-artist))
        (try! (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )
    )
    (ok id-reached)))

;; Alt Minting Mintpass
(define-data-var total-price-slime uint u850000000)

(define-read-only (get-price-slime)
  (ok (var-get total-price-slime)))

(define-public (set-price-slime (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artist-address)) (is-eq tx-sender DEPLOYER)) (err ERR-INVALID-USER))
    (ok (var-set total-price-slime price))))

(define-public (claim-slime)
  (mint-slime (list true)))

(define-public (claim-two-slime) (mint-slime (list true true)))

(define-public (claim-three-slime) (mint-slime (list true true true)))

(define-public (claim-four-slime) (mint-slime (list true true true true)))

(define-public (claim-five-slime) (mint-slime (list true true true true true)))

(define-public (claim-ten-slime) (mint-slime (list true true true true true true true true true true)))

(define-private (mint-slime (orders (list 25 bool)))
  (let
    (
      (passes (get-passes tx-sender))
    )
    (if (var-get premint-enabled)
      (begin
        (asserts! (>= passes (len orders)) (err ERR-NOT-ENOUGH-PASSES))
        (map-set mint-passes tx-sender (- passes (len orders)))
        (mint-many-slime orders)
      )
      (begin
        (asserts! (var-get sale-enabled) (err ERR-PUBLIC-SALE-DISABLED))
        (mint-many-slime orders)
      )
    )))

(define-private (mint-many-slime (orders (list 25 bool )))
  (let
    (
      (last-nft-id (var-get last-id))
      (enabled (asserts! (<= last-nft-id (var-get mint-limit)) (err ERR-NO-MORE-NFTS)))
      (art-addr (var-get artist-address))
      (id-reached (fold mint-many-iter orders last-nft-id))
      (price (* (var-get total-price-slime) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
    )
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender DEPLOYER))
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set last-id id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token burn total-artist))
        (try! (contract-call? 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token transfer total-commission tx-sender COMM-ADDR (some 0x00)))
      )
    )
    (ok id-reached)))

(map-set mint-passes 'SP0EV7XBYZBK5T7WBFV14Y7827WTT8EP8F2M6QVC u3)
(map-set mint-passes 'SP103ZFPKEB5B61ZEV7DW95XTBEWRP2NFE3YX2EFF u1)
(map-set mint-passes 'SP110TAR7RZE8ZTHMTMZYN76KT4440CS1KADFCG2B u2)
(map-set mint-passes 'SP115DK6C1D819T4Y7JVZ8Z8QJ13VCZCZ1PRHJJN u1)
(map-set mint-passes 'SP11MG7BEETBFDYQG0JJ5PG60RKMACM5P27FNPPS6 u1)
(map-set mint-passes 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE u3)
(map-set mint-passes 'SP12FFGQJ5WGR7R7MCFCNRX60ZN7BS2Y855M6CDW7 u1)
(map-set mint-passes 'SP12YGGACNA4R43DB1HAQ3AE03PKPJGXZ1BX96CYB u5)
(map-set mint-passes 'SP13473ZZ772R27F6MK7B8MZ92P3G1PP239RTPA4K u1)
(map-set mint-passes 'SP14BY02Z1FH6ZVA8YT2JAGCW037Y1QQJW17EJ4GA u1)
(map-set mint-passes 'SP14DXPAQB3E841SE031QFTCB31R54A34X47QYTDM u1)
(map-set mint-passes 'SP14K6PZW8B7Z7G07B798H7V2Q8WWCM04H4PZP153 u1)
(map-set mint-passes 'SP156TPWS4JGFVH615K63T22WQAQ0XWY8ZNY9R7Q1 u1)
(map-set mint-passes 'SP158378PVRA077MC9851WTVSF7G3MES99HPJ26DW u1)
(map-set mint-passes 'SP16AZ9829ABNJ8TXV57DCDP6Q67VBSA43RYXC1F0 u1)
(map-set mint-passes 'SP16PRV5FEZRH1KNFWNJTZ9HHZGWMPFB6G1QKE607 u4)
(map-set mint-passes 'SP175WK14PAZ9HRT84BNMWASD9YVGM2GNPXM3BR93 u1)
(map-set mint-passes 'SP17K66V0V1ZRBFEQCNW4FEXXV4RJCVTTCP2RHXTT u1)
(map-set mint-passes 'SP17MF5SZF5MSY8TQXK01SZB3VAJTC61QK78WFPHC u1)
(map-set mint-passes 'SP18K5B9EN9039K6EBH8R2MB6QE0M8MNQVK6T9XTK u3)
(map-set mint-passes 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ u1)
(map-set mint-passes 'SP18SQ92V4C8HG48CPZ32MK3V4PNJGK25EAGH75KT u2)
(map-set mint-passes 'SP197GMEG6WGBRDTCTGGWMRA1G77E65TRXWYKGCT7 u1)
(map-set mint-passes 'SP19KPWZDPBD13N07C7Q1BENQMEPRTNA6J6ACBJB3 u1)
(map-set mint-passes 'SP19P1R0N3AANXX1FWZHT1T100SN6AJDSDVS5PRWW u1)
(map-set mint-passes 'SP19Z0WS3G6CZ8T9ZPAA93K6FH399BZYSTH6VZ1S0 u1)
(map-set mint-passes 'SP1ANNSCKV17N2E4FJQY2MN1SNJDRK45QKDV4NTDD u1)
(map-set mint-passes 'SP1AV1T403Y7ZB5V7XCZK460G8515PVK6NGJFR7KD u2)
(map-set mint-passes 'SP1B66VYMGMDPCW5JENBKZW49MXDPJY9NSKHX4VAJ u1)
(map-set mint-passes 'SP1BQHRVPQKN8KBXX2T02KQ3SEVJ9GJ58R3QKTGCG u1)
(map-set mint-passes 'SP1BZYH5Q0R279MKJHMDF3G4WGYZS40RKGSEWF9N u1)
(map-set mint-passes 'SP1CA9W3C35F6WH2MH1D5Z1XQG9595Q1C3P7Z2NYY u1)
(map-set mint-passes 'SP1DJWJNKREHT3YGRB09DRCYD1QKGK5DKF8V868VX u1)
(map-set mint-passes 'SP1DRW8GY74R0SAZ82HGFJJMT4CX0ZX6P309AR8ND u1)
(map-set mint-passes 'SP1DXRA36MATCTFXSQDRW9G0Q8HY2ZT0HMM9ZQKWR u1)
(map-set mint-passes 'SP1EF64D5ZWF4HEBHSPJPX68M9DA5XYH6V97RBXCH u2)
(map-set mint-passes 'SP1FTE6BCZ14AHW7025F8B7AS6GQT4ZRNG4V209WH u3)
(map-set mint-passes 'SP1GJK5XZ0RP9WBHN18CNTBAXMB7WEV3H0C2NN1N3 u3)
(map-set mint-passes 'SP1KQ1NNKJB7N65T10VN1410SM88NF8CBSDA1NPNT u1)
(map-set mint-passes 'SP1KYADNQFZBR5FNPN0PQV85TN54577MZX84B971W u1)
(map-set mint-passes 'SP1MFKQM507CF8JT5SHYX992BHXC4Y5XY4WK3ZCMC u1)
(map-set mint-passes 'SP1PCEAP62X5BZSMH257ZHAPGAPSX3BDT3TDVCN4M u1)
(map-set mint-passes 'SP1PTT5GSWJSD4PZR4WR4NHJZQ3NJEWJK41HV1G7H u1)
(map-set mint-passes 'SP1QY7NXWJJAH5R8WQ50A8WAKCTSFH7HQPPQNV7D6 u1)
(map-set mint-passes 'SP1ST9NA85RZQX2D3P5VEXDKE9WXDZRGKHB88A5CF u2)
(map-set mint-passes 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 u1)
(map-set mint-passes 'SP1VWZ87JH5QVYB1FZ9274Q597XR1ZAQ99KGCTEFS u1)
(map-set mint-passes 'SP1W12YAJ4E3G31PX863QF1SZDEZCB687XSGZQX5P u1)
(map-set mint-passes 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G u2)
(map-set mint-passes 'SP1XA04SDW26E4CDVJGF17SHKF1TJQPB1J62JDWC u1)
(map-set mint-passes 'SP1YBP35K01SG2G8NG7NHSDXFSVEAKWKFEHF09PMG u1)
(map-set mint-passes 'SP1YMHHM5HZEA7W4NQF2WK5SK79RAWNJEBRVYTRVF u1)
(map-set mint-passes 'SP1YRFYPSPTPQJFDE07CNHQQ998QMAHG4K39HG71A u1)
(map-set mint-passes 'SP1ZC3EFEVB8CY8CTTGS7G0YV4YJR79CF6AD2PDXR u1)
(map-set mint-passes 'SP21A89VNFKAHRFGN0KBXWC97T0EFKXWBH4MJP6MQ u1)
(map-set mint-passes 'SP21QFR1A49TGX8Z8X0ZVPPM5A1CN2CPMCE71NQ3A u1)
(map-set mint-passes 'SP22ZMWMT7NGSQ9B2B0QTXJ9FFDWA6NXFHV9XJ294 u2)
(map-set mint-passes 'SP23H2CGE75B251C6BR28FS5K5Z57HR0EPRKHBTXV u1)
(map-set mint-passes 'SP23Z0N0PBBH6GB0P2HD0Y2TMN3VNRWS3EGWM7C4H u1)
(map-set mint-passes 'SP24GRMRYV61X68KZWP2EVEH5X632GSF6WV9MSR1E u1)
(map-set mint-passes 'SP24RE2HVY7R0P7KDRX623EZ89Q2KV8JKJQ5MJ9JX u1)
(map-set mint-passes 'SP24TD9G7JBNMGT3S3AJWBF1YS3E6A03D2ZT154J5 u3)
(map-set mint-passes 'SP25A4G4V7W3XQVCAQW2SJG1END8F1AS6CNTR25Q1 u1)
(map-set mint-passes 'SP25V55KKHXEX0YRJKSC9DBDP7GSAGBMGXRCM5RRW u4)
(map-set mint-passes 'SP267TMY9MTMP98AW05X8RFQ43JRMTPGDWFKFCPTH u2)
(map-set mint-passes 'SP26ZXHQ28WTZG3GKR5AZN2PHTR7S9G1YD555BE4P u3)
(map-set mint-passes 'SP271CPRFRDSX26GZND9YDD3FSE0JK2B61SBJRAG2 u2)
(map-set mint-passes 'SP2778AQXRYX13JAYFXVXZ2DB8TM993SF2DR3ZMBS u1)
(map-set mint-passes 'SP28RZ1QXMXJXVKRRCR3D7GR5D48XY0NNA9MZWHJB u1)
(map-set mint-passes 'SP29BSG7A2R7M9KA6FCHBCWPSX9WXVDY4FATDCRY2 u1)
(map-set mint-passes 'SP2A4R43TCNHZ19AKK44WEBP4R16X7DV4093GQ0X4 u1)
(map-set mint-passes 'SP2AEY9QJD5MGDEEYYTNYBVVS7S97W2S0302HQ7S1 u1)
(map-set mint-passes 'SP2C3QTBK8HBZ886RWN2EW27B2X9JP9WCM4MB86YB u2)
(map-set mint-passes 'SP2D7VMJ193TJKY3ECZ9KQ0EPMHPVF3047CXH2N6Z u1)
(map-set mint-passes 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM u1)
(map-set mint-passes 'SP2JCF3ME5QC779DQ2X1CM9S62VNJF44GC23MKQXK u1)
(map-set mint-passes 'SP2MC6PBPNPSEHA6G87DDMN6WX3HGMTANXZBYKCNF u1)
(map-set mint-passes 'SP2MCPE4ACC1W9FY1JC3BK2FMYSNWYDEADFEJH2MY u2)
(map-set mint-passes 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX u1)
(map-set mint-passes 'SP2PBW5WPNJ88BZVNDVP4KCTN9HJGNNR1BQA6G1W6 u6)
(map-set mint-passes 'SP2Q1SZSETS27AZ9FE0BH6C6B7MVC25E4N6C2VE7D u1)
(map-set mint-passes 'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ u1)
(map-set mint-passes 'SP2RH3J2MJ4E5RQ4MNQSBCEQMGVS9XCTNCCP2DN2W u2)
(map-set mint-passes 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69 u1)
(map-set mint-passes 'SP2RSAVZ21HNNY3S95HJG58VCZTB837A2728EYXX u29)
(map-set mint-passes 'SP2SSHDSGHHEQN1A7Z0RP0YJ6QECE8TGQTYN594PM u1)
(map-set mint-passes 'SP2T7BZRB3ACRATVVNGCHFXZRXA513Q2SZ0N34786 u1)
(map-set mint-passes 'SP2T8C3XJBX207QTHJJC0GW66JNJ8HFTMRE1Z8FP1 u1)
(map-set mint-passes 'SP2TGN9DJWTV02B9HRGX6Z43Y7052DTZW6FZVZH0S u2)
(map-set mint-passes 'SP2V1FAZ3ZX1N3MMR7W4TJQSGV0SV7MX5J7FPYJXY u1)
(map-set mint-passes 'SP2VS41C9A89KXKS23J7B3SZ46H8SY1595KJHS6W3 u2)
(map-set mint-passes 'SP2XJCFE0MZB33AAP91ZY8TXJ03HMXCJPJD71AJCM u1)
(map-set mint-passes 'SP2XXYVX4VKKZAE6DZFAGQJF2760GE99N68GAXFPM u1)
(map-set mint-passes 'SP2YT64CG2Y0JERQ4YSJV4DHFQEBF4Y0K35G4D51V u1)
(map-set mint-passes 'SP30GWW7TZQHB0C6WYXH36MB6GTYWNTAXPWW96NW7 u2)
(map-set mint-passes 'SP30HDQ1WGZRD1YTBRPPPYZHKQJ7E8CVYZCTHXKVX u1)
(map-set mint-passes 'SP30WDR90F6CYE8826JQ9STMNAAFVWZ7N1SXAZRXP u1)
(map-set mint-passes 'SP30Z954NBY6E3BGMMCM87VAFHJVZQE29HT3VZ6PJ u2)
(map-set mint-passes 'SP32728WFVK74FQXC0BD48QD6BNW5A3MJ8HB5YADR u4)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u4)
(map-set mint-passes 'SP334WZ0PF1XYZEBK6GTXW3J80GJJ1D92M4JNN0H u2)
(map-set mint-passes 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 u4)
(map-set mint-passes 'SP337WP7AQSX8Q9H0TGY8K3RVQBBF82MTZMRE7JDB u3)
(map-set mint-passes 'SP33BS1408BBKEHY0RF4KQ0J7SCBARY7HT86C6062 u1)
(map-set mint-passes 'SP33NGNPHCB6WSRHFDQ5TPTKDNQRAQ5SZ7J3CJK65 u1)
(map-set mint-passes 'SP34GCRXM8W4H9SS4CR783JTDJ2YM46GJZ7HEG1GM u1)
(map-set mint-passes 'SP356400A5XM1ZKNXCQ7BJRE8PXXG1EJHV3954Z27 u2)
(map-set mint-passes 'SP36KY6SG05FK21AZGTNNY7HD5CPH5MQT8Q85HPD8 u1)
(map-set mint-passes 'SP36NC0KX6RZGPQXR73AMW8R0CXXHS06DRM487A5G u2)
(map-set mint-passes 'SP38AJ28GP1Q3E40QD8K3WA7JR315794Y29YWKAP1 u5)
(map-set mint-passes 'SP38F13RDY25HD5MV9ZEF1FG5N7CM5RYDAZ9F3BWC u1)
(map-set mint-passes 'SP38MA900CFX8J4NQJCCFJGDQGJD2KR8H2CQSB5P0 u2)
(map-set mint-passes 'SP3950ZX51YWKXBHW5SJGYE9CJ0WTY9FW4VYYJC5R u1)
(map-set mint-passes 'SP3A11ABJTF6PXA5BDKES4KHCVJ9X3WG82ARXAFJJ u1)
(map-set mint-passes 'SP3A5VJWA3CH4BM7W08APVJKJ8MQ7PXXFACWAYA2J u2)
(map-set mint-passes 'SP3AARS5TBY5X7ZS7JJHBKNND3EJME7AD2BRX1V4A u1)
(map-set mint-passes 'SP3AEDNY49C70TWRV6G01PJBGYTW4AJ38Y2N5F1YH u2)
(map-set mint-passes 'SP3AFTJ38PSZQBXZGNCDGM05GR0SFY7HBPZD2ACR2 u5)
(map-set mint-passes 'SP3BCKC9STZKCVBJRB3EFK86JEWVEJWYH7JRXG9Q u13)
(map-set mint-passes 'SP3C5W9RSSYG3SVP192DCQY4Z2WQWPJ9YEERKTPSY u6)
(map-set mint-passes 'SP3C9JPPGYZV04QF3J0N3ME7KN5NDVF79AZ96HR1 u1)
(map-set mint-passes 'SP3DJV4P28PGPCKPE6KAHBRGHRV3ETGANRBJ33TJF u2)
(map-set mint-passes 'SP3E39MKXYNNHN557YXT5JXGBTFPHYYBFJCSFF481 u3)
(map-set mint-passes 'SP3E545ADCKY56EVCXZPA87525VM0ZA8DQQAEP77Z u10)
(map-set mint-passes 'SP3EPS563XJNK170J902C78ZPDPNXVZFWWCN7DGWH u2)
(map-set mint-passes 'SP3ERB3CKV60Z4SW5R2RZGF6Z0A93AJTN1ATJ3T7P u2)
(map-set mint-passes 'SP3EV7DWHMVJJNF9Q64YVXVQH69SKHVED89R3SR5Z u1)
(map-set mint-passes 'SP3FVPWJ1ZZYRWCQYCSBFMSHSFA7NCP9P1QNQZ7BS u1)
(map-set mint-passes 'SP3GARS14D25RNGWRS85V5VZWJ6TKNFY8Y2TPZV3K u1)
(map-set mint-passes 'SP3GD9W8CX9V7CVY01WNTHT94H6K07EDFHRC89QP u3)
(map-set mint-passes 'SP3J7Y4C6XGJ5DAWMAKVDT4YTSH5FJP1THCZ2NYY4 u1)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u2)
(map-set mint-passes 'SP3KY9D092ZVXYSQ2Z43XH8DGK319PWBX848XWM4P u1)
(map-set mint-passes 'SP3M1X036A4KCD49JZC4M941S4ZDH140ZDVZEHVBA u1)
(map-set mint-passes 'SP3M6D6M2BS7FNEFV111ZF6WQYATNJZ89Q7MXSPAE u1)
(map-set mint-passes 'SP3N30Z0KGHTXCFQ2HD4MW6S00YH1MAN46WQCTSKN u1)
(map-set mint-passes 'SP3QBRHQF4BN8HNNGFHCJMQZDB8V20BMGF2VS3MJ2 u1)
(map-set mint-passes 'SP3QC4R6M7M0DAZBXSZCW4FWGDCNDD05FV8Y0AY8C u1)
(map-set mint-passes 'SP3QD9EVZB3E7E7Z3FWH7KBDH5RZWA4PYHSQ0FGTQ u1)
(map-set mint-passes 'SP3QEHWDWT8NM3CJDV6SQBH3A5HMQJH7V2JMTS4AR u1)
(map-set mint-passes 'SP3QJ41PARX6F6B4H56JZ272ANK0TRJ9J2VFBVY1D u1)
(map-set mint-passes 'SP3QQMF5JEQTNW2HFAQ52JGH7BHDKKP25PSHXJBG9 u2)
(map-set mint-passes 'SP3QVXMZWR9T5RZVFGJ838BDH4S96BZKDWHBX52EK u1)
(map-set mint-passes 'SP3SKH6YB515J76KVDHDHBTE2GQ4CV6QJHC5GJKRF u7)
(map-set mint-passes 'SP3SXJ8HP6JB7ZFA44T39NAFD1105KR8G6XFRZD7Z u1)
(map-set mint-passes 'SP3T7WAB5DMJ3JSRMCQF6SC7CG50DYYJVS4C303CN u3)
(map-set mint-passes 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 u1)
(map-set mint-passes 'SP3VJCMXAGTVF4BJ81JGTYVEBCXWZARFN60D8VSKG u5)
(map-set mint-passes 'SP3X6QG6ZHB7HNP3RMQFXYRMF2TWBHN0CWG3GYZ5N u1)
(map-set mint-passes 'SP3XS4S929NXPK5HW5R9HZ1DHDTQSZ591BPVX9TEP u4)
(map-set mint-passes 'SP3YWXEJY6Y7S54DWA2FKQW3DBGETBVGA44YTQGWR u1)
(map-set mint-passes 'SP3Z0BHS0SVP5733GDZ2RWJV1G2EW04PFN2NSX3PK u2)
(map-set mint-passes 'SP3Z5H5KFMGBTYB37DYTGEA14VZG8AT32EPDEAKQH u1)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u7)
(map-set mint-passes 'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD u1)
(map-set mint-passes 'SP3ZQ324JA8CPZ5X38S7Q7ZCC0MM9F3PKRDJA0PC3 u10)
(map-set mint-passes 'SP3ZTYBN9PYVVFKBEFVSZ2BEGK3HXRNVP6FDG79WV u1)
(map-set mint-passes 'SP57MVR1EEEC5AR9C2VCCBYTXP3603G99N6D7YJD u1)
(map-set mint-passes 'SP69W4H8QQ3FRV7H8H1SXRQY3D47NKD0TP4MKD9S u1)
(map-set mint-passes 'SP6G65ZRFNX2RJ019PB11C8KA5FZ6GPXAYDPRA2Q u1)
(map-set mint-passes 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ u5)
(map-set mint-passes 'SP6SSMC628J3GD0RVGJFVNRNFAPZD37GMBJ6TYMD u1)
(map-set mint-passes 'SP6T887NVJ3EA15JRGY038B4NCVX7EP07H7C37X1 u1)
(map-set mint-passes 'SP7VCY0S1WZF3XDGSMPQ67SDQQ4DCW1DWBR29G19 u2)
(map-set mint-passes 'SP8SWEY2AAP77JWEGJB8WBBXYV7CD6P9HNVD05AB u1)
(map-set mint-passes 'SP9MANP57C4QHVMNHR9HEAX6D5BAA4JN9KC8N4J8 u3)
(map-set mint-passes 'SP9R1DTP15B10S5WFPZVM8W2FDS6VXP27VA96CEZ u9)
(map-set mint-passes 'SPA0SZQ6KCCYMJV5XVKSNM7Y1DGDXH39A11ZX2Y8 u3)
(map-set mint-passes 'SPAD6SHQNFD8JV1X9SZ3B8D1S9E09T0TB2CMAE8W u1)
(map-set mint-passes 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV u1)
(map-set mint-passes 'SPAFPBD7M89973WDEN68FKYW761RQVYNHSEFQZB9 u18)
(map-set mint-passes 'SPAX2SZCDFTVV76SR4JY4RYEPC5PBH2QAHEJXHTF u2)
(map-set mint-passes 'SPBK7YEVECRN3G4J3P49773MN5ZJQ9VR8PF9G2Y4 u1)
(map-set mint-passes 'SPBN3J1JST1K4MEZXZMV95ZXNBGMMKFZGJKY7VVC u2)
(map-set mint-passes 'SPBQNXCXEFFQDDQSXD0RD93AHSVCQ76QJ3QFRFZ7 u2)
(map-set mint-passes 'SPC0W5SWQV4QRPARBX1514HWZDB7RXSV5E6G9S9D u1)
(map-set mint-passes 'SPDAV1G8FQ0TMEWKVE0A9WS8RNDJ7K808X2MY22E u1)
(map-set mint-passes 'SPDBS5QFW2QHZ06FYG7CP30SC6BYAPCS6XHPZFW9 u1)
(map-set mint-passes 'SPEAXKHJME2RR5M09XSQGGHNKYJB8FG2YZWKCF8B u1)
(map-set mint-passes 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY u4)
(map-set mint-passes 'SPH2FHVTD5ZTF0EB4FM9K5S2V54JKNX735WKQYYN u1)
(map-set mint-passes 'SPHD4XDKT644J5ZQ9C96A4741752GTQ5184MT5HJ u1)
(map-set mint-passes 'SPHF68XP1M0Y0ZZV614SY0PZAJQRCK3V5RS3D7GW u1)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u1)
(map-set mint-passes 'SPJ52DQFJVJACKHY0QX5DRE559MBCXWTSGNBN76V u1)
(map-set mint-passes 'SPJKE9ENFNTW8QPYP8XTGYGW9VB29HM2W5570HCG u1)
(map-set mint-passes 'SPK70AN512VN2VRD52D0928MA05JVJ7DY2H5F3CF u1)
(map-set mint-passes 'SPKE3315Y5ADA1PFW01AAA4B1HBDT7YTDX8QCHSD u1)
(map-set mint-passes 'SPKQ8HJ1ED0Y7YGGH72YJAVX9J73C0D0D6QVCJ8T u1)
(map-set mint-passes 'SPN94HCARG2MKFBVMDF3QVP6ZADR3TYGJBEF3HZG u1)
(map-set mint-passes 'SPNSZNPAKHTM2SYV94GC55H3WZVXVCGSZ0KEPC9K u1)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u3)
(map-set mint-passes 'SPRQM6AQZ5STJRA8HV3HMQV5FSWCKGRW805VXB1H u1)
(map-set mint-passes 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR u3)
(map-set mint-passes 'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP u2)
(map-set mint-passes 'SPVCMKZTGYMKYJEHFN4FABNFBBYMM02HNF66A6N6 u1)
(map-set mint-passes 'SPVM12QZD5GG98SAZQAWJVB0AZRF8QK86WHPTKR2 u1)
(map-set mint-passes 'SPWE6JW213WW1NJZC3YY8ANG42NC81P5EYQ3GF58 u1)
(map-set mint-passes 'SPXE4CC9QNP0VVVMWHQDAQ3DZ8WCFTV5J2RZWRM0 u3)
(map-set mint-passes 'SPYABRXAJRTERW97VT4P5ACESQRNTD2Q16C9YQ2F u1)
(map-set mint-passes 'SPZ0FZ0162H8YH2535YJF6WHYMDENAS0FHXDGGR4 u1)
(map-set mint-passes 'SPZ41N5G5E2BNBHR360170R014X41HMXN1V0BQNY u1)