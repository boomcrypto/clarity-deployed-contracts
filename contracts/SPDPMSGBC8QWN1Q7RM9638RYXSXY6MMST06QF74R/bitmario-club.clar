;; bitmario-club
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token bitmario-club uint)

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
(define-data-var mint-limit uint u9999)
(define-data-var last-id uint u1)
(define-data-var total-price uint u9900000)
(define-data-var artist-address principal 'SPDPMSGBC8QWN1Q7RM9638RYXSXY6MMST06QF74R)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmfB9EF4XZrQYzC7vdMxFeRmkmsQkstvJ4cqSzqbRCtEXJ/json/")
(define-data-var mint-paused bool true)
(define-data-var premint-enabled bool false)
(define-data-var sale-enabled bool false)
(define-data-var metadata-frozen bool false)
(define-data-var airdrop-called bool false)
(define-data-var mint-cap uint u5)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)

(define-public (claim) 
  (mint (list true)))

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

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
      (unwrap! (nft-mint? bitmario-club next-id tx-sender) next-id)
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
    (nft-burn? bitmario-club token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? bitmario-club token-id) false)))

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
  (ok (nft-get-owner? bitmario-club token-id)))

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

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/5")
(define-data-var license-name (string-ascii 40) "PERSONAL-NO-HATE")

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
  (match (nft-transfer? bitmario-club id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? bitmario-club id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? bitmario-club id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? bitmario-club (+ last-nft-id u0) 'SP1WN6GXQ4B991ZC9B5G7QXXZ9BVRAASD1A4TZ7C5))
      (map-set token-count 'SP1WN6GXQ4B991ZC9B5G7QXXZ9BVRAASD1A4TZ7C5 (+ (get-balance 'SP1WN6GXQ4B991ZC9B5G7QXXZ9BVRAASD1A4TZ7C5) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u1) 'SP1TT41KBJR7ZVQ1BGXP257HZR046ZRZ60ZHDF5TT))
      (map-set token-count 'SP1TT41KBJR7ZVQ1BGXP257HZR046ZRZ60ZHDF5TT (+ (get-balance 'SP1TT41KBJR7ZVQ1BGXP257HZR046ZRZ60ZHDF5TT) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u2) 'SP1AGA2TFPMQRWB637Z7ZVZQW97WE30RKHSHTNN06))
      (map-set token-count 'SP1AGA2TFPMQRWB637Z7ZVZQW97WE30RKHSHTNN06 (+ (get-balance 'SP1AGA2TFPMQRWB637Z7ZVZQW97WE30RKHSHTNN06) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u3) 'SP1DZSGBYY0DA46JE8VTXV36VAP6DSFEMJTEVYMQQ))
      (map-set token-count 'SP1DZSGBYY0DA46JE8VTXV36VAP6DSFEMJTEVYMQQ (+ (get-balance 'SP1DZSGBYY0DA46JE8VTXV36VAP6DSFEMJTEVYMQQ) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u4) 'SP1FXSJFWVF4MAHSX3QHYB65KZ4H86HK0CEN24DHD))
      (map-set token-count 'SP1FXSJFWVF4MAHSX3QHYB65KZ4H86HK0CEN24DHD (+ (get-balance 'SP1FXSJFWVF4MAHSX3QHYB65KZ4H86HK0CEN24DHD) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u5) 'SP1WK6ZHBY51RZXT14FR1GK0B0NQ97R6KGMHC2YV))
      (map-set token-count 'SP1WK6ZHBY51RZXT14FR1GK0B0NQ97R6KGMHC2YV (+ (get-balance 'SP1WK6ZHBY51RZXT14FR1GK0B0NQ97R6KGMHC2YV) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u6) 'SPDW6DRYBDF6B0C20HP6KPCMXJAC1P6HC6V2N91P))
      (map-set token-count 'SPDW6DRYBDF6B0C20HP6KPCMXJAC1P6HC6V2N91P (+ (get-balance 'SPDW6DRYBDF6B0C20HP6KPCMXJAC1P6HC6V2N91P) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u7) 'SP3GV5STEV4S2HN7YZDFRTE653Q786A9RFEMNGDYV))
      (map-set token-count 'SP3GV5STEV4S2HN7YZDFRTE653Q786A9RFEMNGDYV (+ (get-balance 'SP3GV5STEV4S2HN7YZDFRTE653Q786A9RFEMNGDYV) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u8) 'SP33J3DGAA6WQ8ZNNCQBXG184EDA53BSNNRCXR8PP))
      (map-set token-count 'SP33J3DGAA6WQ8ZNNCQBXG184EDA53BSNNRCXR8PP (+ (get-balance 'SP33J3DGAA6WQ8ZNNCQBXG184EDA53BSNNRCXR8PP) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u9) 'SP63P4DJJ0F5Y50F1ZT6W27S4NJF5P93YJJS8QE7))
      (map-set token-count 'SP63P4DJJ0F5Y50F1ZT6W27S4NJF5P93YJJS8QE7 (+ (get-balance 'SP63P4DJJ0F5Y50F1ZT6W27S4NJF5P93YJJS8QE7) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u10) 'SPB2WDYZCQZ0EX9Y2GZ70178SFW4X20ZYJ7021HG))
      (map-set token-count 'SPB2WDYZCQZ0EX9Y2GZ70178SFW4X20ZYJ7021HG (+ (get-balance 'SPB2WDYZCQZ0EX9Y2GZ70178SFW4X20ZYJ7021HG) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u11) 'SP4BXCSVE78PMTJ3GA9TPMJRE62QMJR5Y3KNGH1X))
      (map-set token-count 'SP4BXCSVE78PMTJ3GA9TPMJRE62QMJR5Y3KNGH1X (+ (get-balance 'SP4BXCSVE78PMTJ3GA9TPMJRE62QMJR5Y3KNGH1X) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u12) 'SP3F62R521JGK0BDYNV1SQ3102J5ZZ7Z2CFZJEPYW))
      (map-set token-count 'SP3F62R521JGK0BDYNV1SQ3102J5ZZ7Z2CFZJEPYW (+ (get-balance 'SP3F62R521JGK0BDYNV1SQ3102J5ZZ7Z2CFZJEPYW) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u13) 'SP3JWFG22F480XN7MZ4PN04HRHM1FXPT2VQF9W732))
      (map-set token-count 'SP3JWFG22F480XN7MZ4PN04HRHM1FXPT2VQF9W732 (+ (get-balance 'SP3JWFG22F480XN7MZ4PN04HRHM1FXPT2VQF9W732) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u14) 'SP3KVKQB9KJ3G7JD1HJ3YDM9SCEK0CNCP7SWAK6C7))
      (map-set token-count 'SP3KVKQB9KJ3G7JD1HJ3YDM9SCEK0CNCP7SWAK6C7 (+ (get-balance 'SP3KVKQB9KJ3G7JD1HJ3YDM9SCEK0CNCP7SWAK6C7) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u15) 'SP2YTQ125P9H4H86ST456TZWPFG7W8G48GAB2E6SY))
      (map-set token-count 'SP2YTQ125P9H4H86ST456TZWPFG7W8G48GAB2E6SY (+ (get-balance 'SP2YTQ125P9H4H86ST456TZWPFG7W8G48GAB2E6SY) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u16) 'SP35QQSW0B4NKBZPSCYCXN2MX2V3RY77J9T3J1605))
      (map-set token-count 'SP35QQSW0B4NKBZPSCYCXN2MX2V3RY77J9T3J1605 (+ (get-balance 'SP35QQSW0B4NKBZPSCYCXN2MX2V3RY77J9T3J1605) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u17) 'SP28WJCF3A4PMM7BJ8XYS4XJ107S0935MBHNK1PNT))
      (map-set token-count 'SP28WJCF3A4PMM7BJ8XYS4XJ107S0935MBHNK1PNT (+ (get-balance 'SP28WJCF3A4PMM7BJ8XYS4XJ107S0935MBHNK1PNT) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u18) 'SP2WK1J6E68FTSE0RMSJZSRFQJXR4PHKRJNVCGCB3))
      (map-set token-count 'SP2WK1J6E68FTSE0RMSJZSRFQJXR4PHKRJNVCGCB3 (+ (get-balance 'SP2WK1J6E68FTSE0RMSJZSRFQJXR4PHKRJNVCGCB3) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u19) 'SP1WJWT53TX3XZE8VS411P5W5CE41QE54EED7Q8FJ))
      (map-set token-count 'SP1WJWT53TX3XZE8VS411P5W5CE41QE54EED7Q8FJ (+ (get-balance 'SP1WJWT53TX3XZE8VS411P5W5CE41QE54EED7Q8FJ) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u20) 'SP2B1M2HVZ5N8YQ7R37R4XAHY73BGW01K58WHCAAX))
      (map-set token-count 'SP2B1M2HVZ5N8YQ7R37R4XAHY73BGW01K58WHCAAX (+ (get-balance 'SP2B1M2HVZ5N8YQ7R37R4XAHY73BGW01K58WHCAAX) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u21) 'SP1EVBP5WWRRV51R7ZCDSQZAGZBR8T9AJ9BJ3N1M5))
      (map-set token-count 'SP1EVBP5WWRRV51R7ZCDSQZAGZBR8T9AJ9BJ3N1M5 (+ (get-balance 'SP1EVBP5WWRRV51R7ZCDSQZAGZBR8T9AJ9BJ3N1M5) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u22) 'SP153N3JVJ3Z9DAF7FV62H31PG8P39WVS9T3NTQWM))
      (map-set token-count 'SP153N3JVJ3Z9DAF7FV62H31PG8P39WVS9T3NTQWM (+ (get-balance 'SP153N3JVJ3Z9DAF7FV62H31PG8P39WVS9T3NTQWM) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u23) 'SP2DW92EHBGGR4JN0R23XYSW0JVS8J4NQ4B6DNX6W))
      (map-set token-count 'SP2DW92EHBGGR4JN0R23XYSW0JVS8J4NQ4B6DNX6W (+ (get-balance 'SP2DW92EHBGGR4JN0R23XYSW0JVS8J4NQ4B6DNX6W) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u24) 'SP38TWKBBFPAPG2145CZ9VQ554T1B34N6P3295W8F))
      (map-set token-count 'SP38TWKBBFPAPG2145CZ9VQ554T1B34N6P3295W8F (+ (get-balance 'SP38TWKBBFPAPG2145CZ9VQ554T1B34N6P3295W8F) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u25) 'SP1G5DF648A71RW1BY0JSGQHWGNAXNJ853TBSCT9R))
      (map-set token-count 'SP1G5DF648A71RW1BY0JSGQHWGNAXNJ853TBSCT9R (+ (get-balance 'SP1G5DF648A71RW1BY0JSGQHWGNAXNJ853TBSCT9R) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u26) 'SP3KMN1JQWNJD0T9T44CB4PF3GNF76FN7Z30H97HZ))
      (map-set token-count 'SP3KMN1JQWNJD0T9T44CB4PF3GNF76FN7Z30H97HZ (+ (get-balance 'SP3KMN1JQWNJD0T9T44CB4PF3GNF76FN7Z30H97HZ) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u27) 'SP1FAZWQQCPFG75RMRJGTPKWSZ9MF5EGNXCAYJNJZ))
      (map-set token-count 'SP1FAZWQQCPFG75RMRJGTPKWSZ9MF5EGNXCAYJNJZ (+ (get-balance 'SP1FAZWQQCPFG75RMRJGTPKWSZ9MF5EGNXCAYJNJZ) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u28) 'SP1Y319ZFAGJKEDYWA0BXPKC7N4KBMQB27ZSNJ971))
      (map-set token-count 'SP1Y319ZFAGJKEDYWA0BXPKC7N4KBMQB27ZSNJ971 (+ (get-balance 'SP1Y319ZFAGJKEDYWA0BXPKC7N4KBMQB27ZSNJ971) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u29) 'SP32GMK4FAM3D06YCV05H3NRZBQ252GBY95GYKR4D))
      (map-set token-count 'SP32GMK4FAM3D06YCV05H3NRZBQ252GBY95GYKR4D (+ (get-balance 'SP32GMK4FAM3D06YCV05H3NRZBQ252GBY95GYKR4D) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u30) 'SP3PHHWVS6CHJ3FJ33QYQBQFYXEKZ2G0CYWTGE4B4))
      (map-set token-count 'SP3PHHWVS6CHJ3FJ33QYQBQFYXEKZ2G0CYWTGE4B4 (+ (get-balance 'SP3PHHWVS6CHJ3FJ33QYQBQFYXEKZ2G0CYWTGE4B4) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u31) 'SP3Y2TS2FEW40YCET5SQ87JBQMYKKGEWJ9ZERCEBG))
      (map-set token-count 'SP3Y2TS2FEW40YCET5SQ87JBQMYKKGEWJ9ZERCEBG (+ (get-balance 'SP3Y2TS2FEW40YCET5SQ87JBQMYKKGEWJ9ZERCEBG) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u32) 'SP1T2HRHTHY5BDTX1C93QGTEMZMRJP4VXDSM6MS2R))
      (map-set token-count 'SP1T2HRHTHY5BDTX1C93QGTEMZMRJP4VXDSM6MS2R (+ (get-balance 'SP1T2HRHTHY5BDTX1C93QGTEMZMRJP4VXDSM6MS2R) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u33) 'SPMPB5QJXT4HRY2TTSNCQ56149ZR3TKZJPG7KYRP))
      (map-set token-count 'SPMPB5QJXT4HRY2TTSNCQ56149ZR3TKZJPG7KYRP (+ (get-balance 'SPMPB5QJXT4HRY2TTSNCQ56149ZR3TKZJPG7KYRP) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u34) 'SP170V8HFZEN0N5TVKEZT7CKFTWQEPTPWF6QAJQH))
      (map-set token-count 'SP170V8HFZEN0N5TVKEZT7CKFTWQEPTPWF6QAJQH (+ (get-balance 'SP170V8HFZEN0N5TVKEZT7CKFTWQEPTPWF6QAJQH) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u35) 'SP1S1RGDEQVKZMNMS7FC310D6JM4Y7Y2XYMNEZC52))
      (map-set token-count 'SP1S1RGDEQVKZMNMS7FC310D6JM4Y7Y2XYMNEZC52 (+ (get-balance 'SP1S1RGDEQVKZMNMS7FC310D6JM4Y7Y2XYMNEZC52) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u36) 'SPM7GM9EQ2N60H372AZ7ZCPM0E7PPHR423GT9XY0))
      (map-set token-count 'SPM7GM9EQ2N60H372AZ7ZCPM0E7PPHR423GT9XY0 (+ (get-balance 'SPM7GM9EQ2N60H372AZ7ZCPM0E7PPHR423GT9XY0) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u37) 'SPZ3K1JMFMDPXNPTD174ZPCX805FM7HFH5ES8PQC))
      (map-set token-count 'SPZ3K1JMFMDPXNPTD174ZPCX805FM7HFH5ES8PQC (+ (get-balance 'SPZ3K1JMFMDPXNPTD174ZPCX805FM7HFH5ES8PQC) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u38) 'SP2MAEAS221AZEKJRJ7K675VVD5ZDQGVM3AH50YF8))
      (map-set token-count 'SP2MAEAS221AZEKJRJ7K675VVD5ZDQGVM3AH50YF8 (+ (get-balance 'SP2MAEAS221AZEKJRJ7K675VVD5ZDQGVM3AH50YF8) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u39) 'SPN5FSVWSBX34YSKJG8C1HBTWC30BEPHC789QX1P))
      (map-set token-count 'SPN5FSVWSBX34YSKJG8C1HBTWC30BEPHC789QX1P (+ (get-balance 'SPN5FSVWSBX34YSKJG8C1HBTWC30BEPHC789QX1P) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u40) 'SP1SQ5J56H12BAP1KDHJRCZCW4AGTB4MXH5NE55PV))
      (map-set token-count 'SP1SQ5J56H12BAP1KDHJRCZCW4AGTB4MXH5NE55PV (+ (get-balance 'SP1SQ5J56H12BAP1KDHJRCZCW4AGTB4MXH5NE55PV) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u41) 'SP22TVBB79XDPVAHH9B03S9FEDXJRJWNANGRFBA0R))
      (map-set token-count 'SP22TVBB79XDPVAHH9B03S9FEDXJRJWNANGRFBA0R (+ (get-balance 'SP22TVBB79XDPVAHH9B03S9FEDXJRJWNANGRFBA0R) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u42) 'SP2YJHEPRXMQBD7T3PA0VJCNBQH6PDMM4QZVBKRYK))
      (map-set token-count 'SP2YJHEPRXMQBD7T3PA0VJCNBQH6PDMM4QZVBKRYK (+ (get-balance 'SP2YJHEPRXMQBD7T3PA0VJCNBQH6PDMM4QZVBKRYK) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u43) 'SP2NE51ZJ27TTNQ63S8HXYWE2BBK54B1SSGV8CTAB))
      (map-set token-count 'SP2NE51ZJ27TTNQ63S8HXYWE2BBK54B1SSGV8CTAB (+ (get-balance 'SP2NE51ZJ27TTNQ63S8HXYWE2BBK54B1SSGV8CTAB) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u44) 'SP2JZSM9RK4SGWBQEX55DABNMN284XN3SDMBES7F5))
      (map-set token-count 'SP2JZSM9RK4SGWBQEX55DABNMN284XN3SDMBES7F5 (+ (get-balance 'SP2JZSM9RK4SGWBQEX55DABNMN284XN3SDMBES7F5) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u45) 'SP2M8BSZSTJRMG8K70PTHZGZGTNNVNG2JPN1GY34T))
      (map-set token-count 'SP2M8BSZSTJRMG8K70PTHZGZGTNNVNG2JPN1GY34T (+ (get-balance 'SP2M8BSZSTJRMG8K70PTHZGZGTNNVNG2JPN1GY34T) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u46) 'SP3AWV56BQGFHEFXKHB8KABMRBK5E1QSD1ED5J6SS))
      (map-set token-count 'SP3AWV56BQGFHEFXKHB8KABMRBK5E1QSD1ED5J6SS (+ (get-balance 'SP3AWV56BQGFHEFXKHB8KABMRBK5E1QSD1ED5J6SS) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u47) 'SPHM2TEZ2JJ7GZW1DFF9C2SSJDRRCHG4JHX4HYXP))
      (map-set token-count 'SPHM2TEZ2JJ7GZW1DFF9C2SSJDRRCHG4JHX4HYXP (+ (get-balance 'SPHM2TEZ2JJ7GZW1DFF9C2SSJDRRCHG4JHX4HYXP) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u48) 'SP130E9ZA8NYXH475D9HY72685F2VJZVG844W1SAA))
      (map-set token-count 'SP130E9ZA8NYXH475D9HY72685F2VJZVG844W1SAA (+ (get-balance 'SP130E9ZA8NYXH475D9HY72685F2VJZVG844W1SAA) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u49) 'SP8C0WXDRV5YZDVPBKEVXFGZ8DCQBGS86VGKJMG6))
      (map-set token-count 'SP8C0WXDRV5YZDVPBKEVXFGZ8DCQBGS86VGKJMG6 (+ (get-balance 'SP8C0WXDRV5YZDVPBKEVXFGZ8DCQBGS86VGKJMG6) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u50) 'SP1FW1H44GZH8B45KZR2Z7D0YNDCD2QGRN3W0B8WC))
      (map-set token-count 'SP1FW1H44GZH8B45KZR2Z7D0YNDCD2QGRN3W0B8WC (+ (get-balance 'SP1FW1H44GZH8B45KZR2Z7D0YNDCD2QGRN3W0B8WC) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u51) 'SP2PZBD89MEN24P5MWKMG4T3JZPS3GY5TFTJ1DKSY))
      (map-set token-count 'SP2PZBD89MEN24P5MWKMG4T3JZPS3GY5TFTJ1DKSY (+ (get-balance 'SP2PZBD89MEN24P5MWKMG4T3JZPS3GY5TFTJ1DKSY) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u52) 'SP16M6TMP4E34TSFW5PHG8KHQSQBJQ8J1WVWH32RG))
      (map-set token-count 'SP16M6TMP4E34TSFW5PHG8KHQSQBJQ8J1WVWH32RG (+ (get-balance 'SP16M6TMP4E34TSFW5PHG8KHQSQBJQ8J1WVWH32RG) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u53) 'SPS2YCGE41822FDRCKEYBVRESMVYP30GDF3GJXK4))
      (map-set token-count 'SPS2YCGE41822FDRCKEYBVRESMVYP30GDF3GJXK4 (+ (get-balance 'SPS2YCGE41822FDRCKEYBVRESMVYP30GDF3GJXK4) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u54) 'SP186MA9FSSECXB07RP3WAFWXF7HM8YB5RMMDPZ05))
      (map-set token-count 'SP186MA9FSSECXB07RP3WAFWXF7HM8YB5RMMDPZ05 (+ (get-balance 'SP186MA9FSSECXB07RP3WAFWXF7HM8YB5RMMDPZ05) u1))
      (try! (nft-mint? bitmario-club (+ last-nft-id u55) 'SP1HQ972KS060YH8KRSQJE28AS13T0T9V94KD3P93))
      (map-set token-count 'SP1HQ972KS060YH8KRSQJE28AS13T0T9V94KD3P93 (+ (get-balance 'SP1HQ972KS060YH8KRSQJE28AS13T0T9V94KD3P93) u1))

      (var-set last-id (+ last-nft-id u56))
      (var-set airdrop-called true)
      (ok true))))