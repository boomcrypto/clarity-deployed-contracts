;; sentient-beings

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token sentient-beings uint)

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
(define-data-var mint-limit uint u300)
(define-data-var last-id uint u1)
(define-data-var total-price uint u80000000)
(define-data-var artist-address principal 'SP3PCWPPMHA136X4BDTKSMMB2SYPG3CXE8KZTBJ8Z)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmekKwhPt4AfGib967oMNbfhvWAMmia54j3QQXmnCDpgPZ/json/")
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

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

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
      (unwrap! (nft-mint? sentient-beings next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id))

(define-public (set-artist-address (address principal))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set artist-address address))))

(define-public (set-price (price uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set total-price price))))

(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (ok (var-set mint-paused (not (var-get mint-paused))))))

(define-public (set-mint-limit (limit uint))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-INVALID-USER))
    (asserts! (< limit (var-get mint-limit)) (err ERR-MINT-LIMIT))
    (ok (var-set mint-limit limit))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err ERR-NOT-AUTHORIZED))
    (nft-burn? sentient-beings token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? sentient-beings token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (var-get metadata-frozen)) (err ERR-METADATA-FROZEN))
    (var-set ipfs-root new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
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
  (ok (nft-get-owner? sentient-beings token-id)))

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
  (match (nft-transfer? sentient-beings id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? sentient-beings id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? sentient-beings id) (err ERR-NOT-FOUND)))
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
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (var-set premint-enabled false)
    (var-set sale-enabled sale)
    (print { sale: sale })
    (ok true)))

(define-public (enable-premint)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled true))))

(define-public (disable-premint)
  (begin
    (asserts! (is-eq tx-sender DEPLOYER) (err ERR-NOT-AUTHORIZED))
    (ok (var-set premint-enabled false))))

(define-read-only (get-passes (caller principal))
  (default-to u0 (map-get? mint-passes caller)))

(define-read-only (get-premint-enabled)
  (ok (var-get premint-enabled)))

(define-read-only (get-sale-enabled)
  (ok (var-get sale-enabled)))  

(map-set mint-passes 'SP88THFXG9JJD7458F7N1KJ8516N2X75RAM6X7SZ u1)
(map-set mint-passes 'SPEXAF3YRNCR01Z4DFZ567Z0FB4RKPHM88DMKJSQ u1)
(map-set mint-passes 'SPKN9G4XHTR3QKGE13YT8M9WFVR91GFS6D81R7J2 u1)
(map-set mint-passes 'SP1J4SFHSMMT5Z0PG3WDD1TNGZVCWMB5QBYHNFECG u1)
(map-set mint-passes 'SPW05PZKP6CXKF0YAKBAMHV5XY2VXFVSCVKJCDVE u1)
(map-set mint-passes 'SP3KPC43PAJA0ZFEYNGZDWTHKPWKSHF8ARP2CQ6ED u1)
(map-set mint-passes 'SP11ES3N5CNYF4CPAE391SJACQYMQ9GQW0TXWJVGE u1)
(map-set mint-passes 'SP368YRZ81XA52ZX2WGXBCZVFZVZSYX203RD2J4CY u1)
(map-set mint-passes 'SP235VD14JSA9EZJT2SPWAYS70BV5QFGF9JFS754A u1)
(map-set mint-passes 'SP3EJ6T75R7S1AYXE5ZPBWB8M1P14M99D66DG2PN7 u1)
(map-set mint-passes 'SP1K98DG5F7PCKVX3PBS8QYPXPRH25C0K5NZGF6QB u1)
(map-set mint-passes 'SP2KDEQS7Q3BAJT4BPP94FGT963ESXPKS7S8A995S u1)
(map-set mint-passes 'SP398XE371G08T84A99TCBD8XKWY3S7VVX6JKJWKY u1)
(map-set mint-passes 'SPQVG91FWDN2KZ6V8DTSKYCXC5FEZFDZSQC8ZNM1 u1)
(map-set mint-passes 'SP39CCPB32JPTB5G2SCSJ8FNFZ2Q435435KAJP1AY u1)
(map-set mint-passes 'SP1G7FAB5SVNAM59VAEBP5WDRGB3Y4P0FMCX4B6CN u1)
(map-set mint-passes 'SP12FXX43RDKMHD2BNQTT6XYQX4AMEEG52XT36N9S u1)
(map-set mint-passes 'SP3P2WGFWSX0W4ANW105BZ8QHZVA9EM9H4YWG3MSH u1)
(map-set mint-passes 'SP2RS0YJZ2QH5VYXQ91X06B9QYR90BNGJETWP0V69 u1)
(map-set mint-passes 'SP3P8PMKMYJQ9V16A6EZW2XHH1P29JN58R31VQ4VJ u1)
(map-set mint-passes 'SP2RGWKHHD9126YKCVJ1NW5QSPVYFJ7EEQ81RC9AM u2)
(map-set mint-passes 'SP2FZ154ESZ8NB34RZ3RS147GD6DSEYNE8DQD0XDM u1)
(map-set mint-passes 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2 u1)
(map-set mint-passes 'SP2QK20FRJ6N1XZ0T6RGF180RVQ62HPR1NAFMYTVB u1)
(map-set mint-passes 'SP3ESAZF6WRRB1X0C5Y0ERAV2B2H9QRMK005AHDZC u1)
(map-set mint-passes 'SP35K3WCA9GCJV2XC7X021MR2D9D2PKF855CVCKB0 u1)
(map-set mint-passes 'SP12WR6FPXDNP9Y1C10TM0GJD91A6ZETMG66MASYY u1)
(map-set mint-passes 'SP2X1GD24FA3TGGV6T4TRPKT8MVZ8F02RZESYWEH5 u1)
(map-set mint-passes 'SPC4KZE8PZ82XG79TYGFXMWMNFY0TPFEFESYWFS7 u1)
(map-set mint-passes 'SP267TMY9MTMP98AW05X8RFQ43JRMTPGDWFKFCPTH u1)
(map-set mint-passes 'SP1GYWMYK320ASBBAERSC40TA3PA99ZHV3GF256T8 u1)
(map-set mint-passes 'SP2ZCER0Z8VVMCDA3817SDFVES833XD9ACYDAFH1T u1)
(map-set mint-passes 'SPJ25PPMNNVYSHRP9ZG6D6KXN4R7B4JFKQPRSFK3 u1)
(map-set mint-passes 'SP152CGECH11CBS16N55WKKDRAWFMYK1XN3MNBZFP u1)
(map-set mint-passes 'SP1392G8MX3CSDZJPVM6R0JHH06NF8P8H0QBY3T5H u1)
(map-set mint-passes 'SP1G7FAB5SVNAM59VAEBP5WDRGB3Y4P0FMCX4B6CN u1)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u1)
(map-set mint-passes 'SP11ZZZN1ASC9QE01HJAAA2KX89RKEJF88BH53Y88 u1)
(map-set mint-passes 'SP20E0RC1NWFVD6A2QC8Z4CTWK7X5FKFCB6M6P6W4 u1)
(map-set mint-passes 'SP3MZ0HS03DMDHX8GYE967W5C9KMXSSMED7BEBG1E u1)
(map-set mint-passes 'SP1CJCC6CZDX12V1SHTPW10ME1H0QZ7GKYCN202CV u1)
(map-set mint-passes 'SP3VHCK82WS8R61H1VQD529MAF197B8GK5CJ8WYK9 u1)
(map-set mint-passes 'SPPHQ18BSEZVB52Z4XZD5H4JFEZ7ARD5QS2PTCG u1)
(map-set mint-passes 'SP28EEFXFETGTVTDHFYFW0MRXZKGRPV4Y9DQ2WE94 u1)
