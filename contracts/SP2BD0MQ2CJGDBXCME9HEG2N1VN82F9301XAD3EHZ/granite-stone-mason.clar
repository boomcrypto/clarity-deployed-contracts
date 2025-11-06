;; granite-stone-mason
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token granite-stone-mason uint)

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
(define-data-var mint-limit uint u55)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP2BD0MQ2CJGDBXCME9HEG2N1VN82F9301XAD3EHZ)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmRT12Qg7prJgSKM8qpQiSBWrktQeGVXGDkfkVjsgidRaY/")
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
      (unwrap! (nft-mint? granite-stone-mason next-id tx-sender) next-id)
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
    (nft-burn? granite-stone-mason token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? granite-stone-mason token-id) false)))

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
  (ok (nft-get-owner? granite-stone-mason token-id)))

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
  (match (nft-transfer? granite-stone-mason id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? granite-stone-mason id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? granite-stone-mason id) (err ERR-NOT-FOUND)))
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
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u0) 'SP2ER8W5ZQSPPHJ4PYA9R9PWE9940TB5W0X03WRKQ))
      (map-set token-count 'SP2ER8W5ZQSPPHJ4PYA9R9PWE9940TB5W0X03WRKQ (+ (get-balance 'SP2ER8W5ZQSPPHJ4PYA9R9PWE9940TB5W0X03WRKQ) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u1) 'SPN3AV2KQ8HYFHGKC34SGVSS9TNMJXG56GXRSR70))
      (map-set token-count 'SPN3AV2KQ8HYFHGKC34SGVSS9TNMJXG56GXRSR70 (+ (get-balance 'SPN3AV2KQ8HYFHGKC34SGVSS9TNMJXG56GXRSR70) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u2) 'SP34GPEJ832HG5BTJE1FKHY8AB3VY9VWPDSKWFVX3))
      (map-set token-count 'SP34GPEJ832HG5BTJE1FKHY8AB3VY9VWPDSKWFVX3 (+ (get-balance 'SP34GPEJ832HG5BTJE1FKHY8AB3VY9VWPDSKWFVX3) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u3) 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4))
      (map-set token-count 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4 (+ (get-balance 'SP14W78Q821B3HQ3ED30624Z1F13X4JMFZY3N5SK4) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u4) 'SP2BKBZDH2E5GMGSERKP51WMZPZRCN34H9F50AVBN))
      (map-set token-count 'SP2BKBZDH2E5GMGSERKP51WMZPZRCN34H9F50AVBN (+ (get-balance 'SP2BKBZDH2E5GMGSERKP51WMZPZRCN34H9F50AVBN) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u5) 'SP2A0VW071VE5QXZ9699FK29F0XXQ0B8AQ5BSC431))
      (map-set token-count 'SP2A0VW071VE5QXZ9699FK29F0XXQ0B8AQ5BSC431 (+ (get-balance 'SP2A0VW071VE5QXZ9699FK29F0XXQ0B8AQ5BSC431) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u6) 'SP2H6M5G37EDRD62J68YC4857JA14KZ5YDE6WG31W))
      (map-set token-count 'SP2H6M5G37EDRD62J68YC4857JA14KZ5YDE6WG31W (+ (get-balance 'SP2H6M5G37EDRD62J68YC4857JA14KZ5YDE6WG31W) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u7) 'SP1GENSBAR9F4VP51ZHJH44NN8EFJPCKQKAZJ0Z3P))
      (map-set token-count 'SP1GENSBAR9F4VP51ZHJH44NN8EFJPCKQKAZJ0Z3P (+ (get-balance 'SP1GENSBAR9F4VP51ZHJH44NN8EFJPCKQKAZJ0Z3P) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u8) 'SP2W6K3AWTNQZCEQZ6XBK3RR9PZ3557W9EE2E2A1F))
      (map-set token-count 'SP2W6K3AWTNQZCEQZ6XBK3RR9PZ3557W9EE2E2A1F (+ (get-balance 'SP2W6K3AWTNQZCEQZ6XBK3RR9PZ3557W9EE2E2A1F) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u9) 'SP3JDZX69PD5Y4W2PY7XE2E9PW2R5GGKQ2Z7X39ZS))
      (map-set token-count 'SP3JDZX69PD5Y4W2PY7XE2E9PW2R5GGKQ2Z7X39ZS (+ (get-balance 'SP3JDZX69PD5Y4W2PY7XE2E9PW2R5GGKQ2Z7X39ZS) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u10) 'SP20QS4PBRFWRQFHVKQHBR3C8TETC6H89QMXBQB8M))
      (map-set token-count 'SP20QS4PBRFWRQFHVKQHBR3C8TETC6H89QMXBQB8M (+ (get-balance 'SP20QS4PBRFWRQFHVKQHBR3C8TETC6H89QMXBQB8M) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u11) 'SP2Y8WK2WPW6HP49RJEQ61H39SE8FQ9N0H6M9X6JY))
      (map-set token-count 'SP2Y8WK2WPW6HP49RJEQ61H39SE8FQ9N0H6M9X6JY (+ (get-balance 'SP2Y8WK2WPW6HP49RJEQ61H39SE8FQ9N0H6M9X6JY) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u12) 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ))
      (map-set token-count 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ (+ (get-balance 'SP2PZYA27E8MRBQHQXE0JQH5CHM9JJNM00YEMC4QJ) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u13) 'SP19FW5TRXVHE700F0QDF8Q5GT2XMKTCAXDF6YSJB))
      (map-set token-count 'SP19FW5TRXVHE700F0QDF8Q5GT2XMKTCAXDF6YSJB (+ (get-balance 'SP19FW5TRXVHE700F0QDF8Q5GT2XMKTCAXDF6YSJB) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u14) 'SP1N6QYMS4771B58J5WDQMX917F2ZQJVD48RJH047))
      (map-set token-count 'SP1N6QYMS4771B58J5WDQMX917F2ZQJVD48RJH047 (+ (get-balance 'SP1N6QYMS4771B58J5WDQMX917F2ZQJVD48RJH047) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u15) 'SP260ZF58NPJZCJGB2K51327RW299BHES24W4ARKE))
      (map-set token-count 'SP260ZF58NPJZCJGB2K51327RW299BHES24W4ARKE (+ (get-balance 'SP260ZF58NPJZCJGB2K51327RW299BHES24W4ARKE) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u16) 'SP1P2XGDSVYHXZ6GQAM4N7CX89GTZKBRP2BQF0G15))
      (map-set token-count 'SP1P2XGDSVYHXZ6GQAM4N7CX89GTZKBRP2BQF0G15 (+ (get-balance 'SP1P2XGDSVYHXZ6GQAM4N7CX89GTZKBRP2BQF0G15) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u17) 'SP1GKYRP9M1CX75CGWTMQ1734HHY3J2X32H4X9SQD))
      (map-set token-count 'SP1GKYRP9M1CX75CGWTMQ1734HHY3J2X32H4X9SQD (+ (get-balance 'SP1GKYRP9M1CX75CGWTMQ1734HHY3J2X32H4X9SQD) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u18) 'SPXRJFXTHFCAK12HTMJ83SQRY5BE82FYXDK0QTWX))
      (map-set token-count 'SPXRJFXTHFCAK12HTMJ83SQRY5BE82FYXDK0QTWX (+ (get-balance 'SPXRJFXTHFCAK12HTMJ83SQRY5BE82FYXDK0QTWX) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u19) 'SPTQBW7NXNMW6Z2YRV8KJS2ZHCPTKZ9J61NH3SP0))
      (map-set token-count 'SPTQBW7NXNMW6Z2YRV8KJS2ZHCPTKZ9J61NH3SP0 (+ (get-balance 'SPTQBW7NXNMW6Z2YRV8KJS2ZHCPTKZ9J61NH3SP0) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u20) 'SP1ARC8PTHHY7C9P076ZHH5MM6WDWA0XP2EXKVZJE))
      (map-set token-count 'SP1ARC8PTHHY7C9P076ZHH5MM6WDWA0XP2EXKVZJE (+ (get-balance 'SP1ARC8PTHHY7C9P076ZHH5MM6WDWA0XP2EXKVZJE) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u21) 'SP385BWVP75KE37D9V0V40QFKZBVD3VXSK83ENRVB))
      (map-set token-count 'SP385BWVP75KE37D9V0V40QFKZBVD3VXSK83ENRVB (+ (get-balance 'SP385BWVP75KE37D9V0V40QFKZBVD3VXSK83ENRVB) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u22) 'SP1EGSTD67HEJ9BWH3QF0V19CQRBMAB2PV5SHTAZT))
      (map-set token-count 'SP1EGSTD67HEJ9BWH3QF0V19CQRBMAB2PV5SHTAZT (+ (get-balance 'SP1EGSTD67HEJ9BWH3QF0V19CQRBMAB2PV5SHTAZT) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u23) 'SP53KS6RZF15YAFZ4E4GDAZ36KKH0SRPXQ0Y57E4))
      (map-set token-count 'SP53KS6RZF15YAFZ4E4GDAZ36KKH0SRPXQ0Y57E4 (+ (get-balance 'SP53KS6RZF15YAFZ4E4GDAZ36KKH0SRPXQ0Y57E4) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u24) 'SP1HFXD9SCN1DNSA17CSZ5559X0AETD91BY7M03YY))
      (map-set token-count 'SP1HFXD9SCN1DNSA17CSZ5559X0AETD91BY7M03YY (+ (get-balance 'SP1HFXD9SCN1DNSA17CSZ5559X0AETD91BY7M03YY) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u25) 'SP5P4SE4BQ2HGHQP3THY6D69W1EM4KKTAHHM2760))
      (map-set token-count 'SP5P4SE4BQ2HGHQP3THY6D69W1EM4KKTAHHM2760 (+ (get-balance 'SP5P4SE4BQ2HGHQP3THY6D69W1EM4KKTAHHM2760) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u26) 'SPK9J5DD22NTTMK6FMF07CANX81FQW8WE63SAM2Q))
      (map-set token-count 'SPK9J5DD22NTTMK6FMF07CANX81FQW8WE63SAM2Q (+ (get-balance 'SPK9J5DD22NTTMK6FMF07CANX81FQW8WE63SAM2Q) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u27) 'SP2VCTYBK1M4KNVJGDNTXV9F6Z6BE40A9CV6A4VB0))
      (map-set token-count 'SP2VCTYBK1M4KNVJGDNTXV9F6Z6BE40A9CV6A4VB0 (+ (get-balance 'SP2VCTYBK1M4KNVJGDNTXV9F6Z6BE40A9CV6A4VB0) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u28) 'SP26F2KNTSNVTGDG6DBGHT04KREVH2T11DWJMZ2BZ))
      (map-set token-count 'SP26F2KNTSNVTGDG6DBGHT04KREVH2T11DWJMZ2BZ (+ (get-balance 'SP26F2KNTSNVTGDG6DBGHT04KREVH2T11DWJMZ2BZ) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u29) 'SP2KY7F21EWVRKJ2BQSMJTP68DDFCQ7BGKXJ50RGW))
      (map-set token-count 'SP2KY7F21EWVRKJ2BQSMJTP68DDFCQ7BGKXJ50RGW (+ (get-balance 'SP2KY7F21EWVRKJ2BQSMJTP68DDFCQ7BGKXJ50RGW) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u30) 'SPAPKNKRRP9PAEJ08W2H8WPB0NX816HW0JM102RE))
      (map-set token-count 'SPAPKNKRRP9PAEJ08W2H8WPB0NX816HW0JM102RE (+ (get-balance 'SPAPKNKRRP9PAEJ08W2H8WPB0NX816HW0JM102RE) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u31) 'SP3EMZ5XM95XZRVFWB5M8JH3VRMMPJ8661WTT1M3T))
      (map-set token-count 'SP3EMZ5XM95XZRVFWB5M8JH3VRMMPJ8661WTT1M3T (+ (get-balance 'SP3EMZ5XM95XZRVFWB5M8JH3VRMMPJ8661WTT1M3T) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u32) 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75))
      (map-set token-count 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75 (+ (get-balance 'SPPB155Z73HHGF2EDE1FPZDEM0NY65PTMQK17W75) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u33) 'SP3N8Y7RYHPBHGX0E6EWS7634N4Q2XF665AWQ7ZJ4))
      (map-set token-count 'SP3N8Y7RYHPBHGX0E6EWS7634N4Q2XF665AWQ7ZJ4 (+ (get-balance 'SP3N8Y7RYHPBHGX0E6EWS7634N4Q2XF665AWQ7ZJ4) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u34) 'SPSK86Q3EP02Q5618EBPH9H4KSWDD1HDBB9SDSK8))
      (map-set token-count 'SPSK86Q3EP02Q5618EBPH9H4KSWDD1HDBB9SDSK8 (+ (get-balance 'SPSK86Q3EP02Q5618EBPH9H4KSWDD1HDBB9SDSK8) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u35) 'SP2MJYMCZE87ZEFNBR6J8891RR9BZQ19ZY3GPBD2X))
      (map-set token-count 'SP2MJYMCZE87ZEFNBR6J8891RR9BZQ19ZY3GPBD2X (+ (get-balance 'SP2MJYMCZE87ZEFNBR6J8891RR9BZQ19ZY3GPBD2X) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u36) 'SPVZECXHCVS8PG0TZTZGPZDWP28TT1AHHN0R97ED))
      (map-set token-count 'SPVZECXHCVS8PG0TZTZGPZDWP28TT1AHHN0R97ED (+ (get-balance 'SPVZECXHCVS8PG0TZTZGPZDWP28TT1AHHN0R97ED) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u37) 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ))
      (map-set token-count 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ (+ (get-balance 'SP18QG8A8943KY9S15M08AMAWWF58W9X1M90BRCSJ) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u38) 'SP22YFNH4BYXM6QK3XN55JTJSRBHE99K5VPH8S4BR))
      (map-set token-count 'SP22YFNH4BYXM6QK3XN55JTJSRBHE99K5VPH8S4BR (+ (get-balance 'SP22YFNH4BYXM6QK3XN55JTJSRBHE99K5VPH8S4BR) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u39) 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9))
      (map-set token-count 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9 (+ (get-balance 'SP25RK61425QBXW105M85SY22WJ46T6T6G5D1XJ9) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u40) 'SPAFRYT831WS7ZRHGZBPMNCBJRBC0ZT884HFXERA))
      (map-set token-count 'SPAFRYT831WS7ZRHGZBPMNCBJRBC0ZT884HFXERA (+ (get-balance 'SPAFRYT831WS7ZRHGZBPMNCBJRBC0ZT884HFXERA) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u41) 'SPRPR5TNY0CQAMBQEYCH59W710Z9S3C3QZ1S285C))
      (map-set token-count 'SPRPR5TNY0CQAMBQEYCH59W710Z9S3C3QZ1S285C (+ (get-balance 'SPRPR5TNY0CQAMBQEYCH59W710Z9S3C3QZ1S285C) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u42) 'SP11R906JZPRRC663NRE0DN0Y6NYFM7DQSS4YED1E))
      (map-set token-count 'SP11R906JZPRRC663NRE0DN0Y6NYFM7DQSS4YED1E (+ (get-balance 'SP11R906JZPRRC663NRE0DN0Y6NYFM7DQSS4YED1E) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u43) 'SP3DGVP1YKV8GMBPWGNJW5AWY2W21N1CSEPH5C8R5))
      (map-set token-count 'SP3DGVP1YKV8GMBPWGNJW5AWY2W21N1CSEPH5C8R5 (+ (get-balance 'SP3DGVP1YKV8GMBPWGNJW5AWY2W21N1CSEPH5C8R5) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u44) 'SP1KD2BS98HCAEZQB3A4AXNS2KNAFTXF2CTJBQWF6))
      (map-set token-count 'SP1KD2BS98HCAEZQB3A4AXNS2KNAFTXF2CTJBQWF6 (+ (get-balance 'SP1KD2BS98HCAEZQB3A4AXNS2KNAFTXF2CTJBQWF6) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u45) 'SP3QAJTSTDDY1B3BDCX44YJSQ5RXTV734T0YFNRCP))
      (map-set token-count 'SP3QAJTSTDDY1B3BDCX44YJSQ5RXTV734T0YFNRCP (+ (get-balance 'SP3QAJTSTDDY1B3BDCX44YJSQ5RXTV734T0YFNRCP) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u46) 'SP2W69C81XYZCNBRSDKMVQC7NDQ5WTJX50E472NEV))
      (map-set token-count 'SP2W69C81XYZCNBRSDKMVQC7NDQ5WTJX50E472NEV (+ (get-balance 'SP2W69C81XYZCNBRSDKMVQC7NDQ5WTJX50E472NEV) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u47) 'SPTH64XEH3W5S0W088QF89166A8YKYB5FEKX42XQ))
      (map-set token-count 'SPTH64XEH3W5S0W088QF89166A8YKYB5FEKX42XQ (+ (get-balance 'SPTH64XEH3W5S0W088QF89166A8YKYB5FEKX42XQ) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u48) 'SP3GZP0JPBXSZYN0A7FX9TKSYM4SZS4H1YFYKWPGE))
      (map-set token-count 'SP3GZP0JPBXSZYN0A7FX9TKSYM4SZS4H1YFYKWPGE (+ (get-balance 'SP3GZP0JPBXSZYN0A7FX9TKSYM4SZS4H1YFYKWPGE) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u49) 'SP25SBK9JEAYGEJX950AXF69X44WRF9S6TXWW2YPM))
      (map-set token-count 'SP25SBK9JEAYGEJX950AXF69X44WRF9S6TXWW2YPM (+ (get-balance 'SP25SBK9JEAYGEJX950AXF69X44WRF9S6TXWW2YPM) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u50) 'SP3JFEKTFHVC3B9RRQ46FNC8MFRZPHVYYTFWYRX6W))
      (map-set token-count 'SP3JFEKTFHVC3B9RRQ46FNC8MFRZPHVYYTFWYRX6W (+ (get-balance 'SP3JFEKTFHVC3B9RRQ46FNC8MFRZPHVYYTFWYRX6W) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u51) 'SP3KW1DBZQCJ7QMAPVVZX72VB5CYMEB9VK5DWDPXG))
      (map-set token-count 'SP3KW1DBZQCJ7QMAPVVZX72VB5CYMEB9VK5DWDPXG (+ (get-balance 'SP3KW1DBZQCJ7QMAPVVZX72VB5CYMEB9VK5DWDPXG) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u52) 'SP2BWMDQ6FFHCRGRP1VCAXHSMYTDY8J0T0J5AZV4Q))
      (map-set token-count 'SP2BWMDQ6FFHCRGRP1VCAXHSMYTDY8J0T0J5AZV4Q (+ (get-balance 'SP2BWMDQ6FFHCRGRP1VCAXHSMYTDY8J0T0J5AZV4Q) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u53) 'SPNERQGR1M2D1ZW9Q73E8VG85WGSJH4WP9VJY8D8))
      (map-set token-count 'SPNERQGR1M2D1ZW9Q73E8VG85WGSJH4WP9VJY8D8 (+ (get-balance 'SPNERQGR1M2D1ZW9Q73E8VG85WGSJH4WP9VJY8D8) u1))
      (try! (nft-mint? granite-stone-mason (+ last-nft-id u54) 'SP1BQCZZG8VRTFJ1E75YRHB45HRXT2AHDNK2R1QT6))
      (map-set token-count 'SP1BQCZZG8VRTFJ1E75YRHB45HRXT2AHDNK2R1QT6 (+ (get-balance 'SP1BQCZZG8VRTFJ1E75YRHB45HRXT2AHDNK2R1QT6) u1))

      (var-set last-id (+ last-nft-id u55))
      (var-set airdrop-called true)
      (ok true))))