(impl-trait 'SP39EMTZG4P7D55FMEQXEB8ZEQEK0ECBHB1GD8GMT.nft-trait.nft-trait)
(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)


(define-non-fungible-token Name-God-3A uint)


(define-constant contract-owner tx-sender)
(define-constant COMM u1000)
(define-constant COMM-ADDR 'SP1KMJR4X9BHS7830AA64316SGKZGQY354JRP2TQ7)
(define-constant COMM-ADDR-TWO 'SP28KZ784B7AA6FGANSCPHV9V5CW4J43XT79DFKHG)

(define-constant err-no-more-nfts u0)
(define-constant err-not-enough-passes u1)
(define-constant err-public-sale-disabled u2)
(define-constant err-no-more-mints u3)
(define-constant err-not-authorized u4)
(define-constant err-invalid-user u5)
(define-constant err-listing u6)
(define-constant err-wrong-commission u7)
(define-constant err-not-found u8)
(define-constant err-minting-restricted-temporarily u9)
(define-constant err-max-supply u10)
(define-constant err-metadata-frozen u11)
(define-constant err-no-such-section u12)
(define-constant err-already-carried-out-airdrop u13)

(define-map mints-per-user principal uint)
(define-map mint-passes principal uint)
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

(define-data-var max-supply uint u111)
(define-data-var total-price uint u0)
(define-data-var artiste-address principal 'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7)
(define-data-var nonce uint u1)
(define-data-var ipfs (string-ascii 80) "ipfs://bafyreich35mdmxo4dq2ccxw47eoyzgp2zpt53loflry2gjzixgpa6psk5e/metadata.json")
(define-data-var can-mint bool false)
(define-data-var metadata-frozen bool false)
(define-data-var mint-cap uint u0)
(define-data-var can-airdrop bool true)





(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? Name-God-3A token-id)))


(define-read-only (get-last-token-id)
  (ok (- (var-get nonce) u1)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get ipfs))))

(define-read-only (get-price)
  (ok (var-get total-price)))

(define-read-only (get-mints (caller principal))
  (default-to u0 (map-get? mints-per-user caller)))

(define-read-only (get-max-supply)
  (ok (var-get max-supply)))

(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-read-only (get-mint-status)
  (ok (var-get can-mint)))


(define-public (set-artiste-address (address principal))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-invalid-user))
    (ok (var-set artiste-address address))))

(define-public (set-price (price uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-invalid-user))
    (ok (var-set total-price price))))

(define-public (restrict-minting)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-invalid-user))
    (ok (var-set can-mint (not (var-get can-mint))))))

(define-public (set-max-supply (limit uint))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-invalid-user))
    (asserts! (< limit (var-get max-supply)) (err err-max-supply))
    (ok (var-set max-supply limit))))

(define-public (burn (token-id uint))
  (begin 
    (asserts! (is-owner token-id tx-sender) (err err-not-authorized))
    (nft-burn? Name-God-3A token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? Name-God-3A token-id) false)))

(define-public (set-base-uri (new-base-uri (string-ascii 80)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-not-authorized))
    (asserts! (not (var-get metadata-frozen)) (err err-metadata-frozen))
    (var-set ipfs new-base-uri)
    (ok true)))

(define-public (freeze-metadata)
  (begin
    (asserts! (or (is-eq tx-sender (var-get artiste-address)) (is-eq tx-sender contract-owner)) (err err-not-authorized))
    (var-set metadata-frozen true)
    (ok true)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err err-not-authorized))
    (asserts! (is-none (map-get? market id)) (err err-listing))
    (trnsfr id sender recipient)))


(define-private (iterate-minting (not-to-be-used bool) (next-id uint))
  (if (<= next-id (var-get max-supply))
    (begin
      (unwrap! (nft-mint? Name-God-3A next-id tx-sender) next-id)
      (+ next-id u1)    
    )
    next-id))


(define-public (claim-one)
  (mint (list true))
)
(define-public (claim-two)
  (mint (list true true))
)
(define-public (claim-three)
  (mint (list true true true))
)



(define-private (mint (orders (list 25 bool )))  
  (let 
    (
      (last-nft-id (var-get nonce))
      (enabled (asserts! (<= last-nft-id (var-get max-supply)) (err err-no-more-nfts)))
      (art-addr (var-get artiste-address))
      (id-reached (fold iterate-minting orders last-nft-id))
      (price (* (var-get total-price) (- id-reached last-nft-id)))
      (total-commission (/ (* price COMM) u10000))
      (current-balance (get-balance tx-sender))
      (total-artist (- price total-commission))
      (capped (> (var-get mint-cap) u0))
      (user-mints (get-mints tx-sender))
    )

    (asserts! (or (is-eq false (var-get can-mint)) (is-eq tx-sender contract-owner)) (err err-minting-restricted-temporarily))
    (asserts! (or (not capped) (is-eq tx-sender contract-owner) (is-eq tx-sender art-addr) (>= (var-get mint-cap) (+ (len orders) user-mints))) (err err-no-more-mints))
    (map-set mints-per-user tx-sender (+ (len orders) user-mints))
    (if (or (is-eq tx-sender art-addr) (is-eq tx-sender contract-owner) (is-eq (var-get total-price) u0000000))
      (begin
        (var-set nonce id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
      )
      (begin
        (var-set nonce id-reached)
        (map-set token-count tx-sender (+ current-balance (- id-reached last-nft-id)))
        (try! (stx-transfer? total-artist tx-sender (var-get artiste-address)))
        (try! (stx-transfer? total-commission tx-sender COMM-ADDR))
      )    
    )
    (ok id-reached)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
  (match (nft-transfer? Name-God-3A id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? Name-God-3A id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
    (asserts! (is-sender-owner id) (err err-not-authorized))
    (map-set market id listing)
    (print (merge listing {a: "list-in-ustx", id: id}))
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) (err err-not-authorized))
    (map-delete market id)
    (print {a: "unlist-in-ustx", id: id})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? Name-God-3A id) (err err-not-found)))
      (listing (unwrap! (map-get? market id) (err err-listing)))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) (err err-wrong-commission))
    (try! (stx-transfer? price tx-sender owner))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {a: "buy-in-ustx", id: id})
    (ok true)))



(define-private (airdrop-iter (collector principal) (next-id uint)) 
  (if (<= next-id (var-get max-supply))
    (let (
      (user-mints (get-mints collector))
      (current-balance (get-balance collector))
    )
      (unwrap! (nft-mint? Name-God-3A next-id collector) next-id)
      (map-set mints-per-user collector (+ u1 user-mints))
      (map-set token-count collector (+ current-balance (- (+ next-id u1) next-id)))
      (+ next-id u1)    
    )
    next-id)
)

(define-public (airdrop (collectors (list 111 principal))) 
  (let (
    (last-nft-id (var-get nonce))
    (new-nonce (fold airdrop-iter collectors last-nft-id))
  ) 
    (asserts! (is-eq tx-sender contract-owner) (err err-not-authorized))
    (asserts! (is-eq true (var-get can-airdrop)) (err err-already-carried-out-airdrop))
    (var-set can-mint false)
    (var-set nonce new-nonce)
    (ok new-nonce)
  )
)


(unwrap! (airdrop (list 
'SP1HRK5ZWS3DC0KVSKK7GF32KYJ0TGDE90KXDFC3H
'SP3KHQ1P6HQXTKKN50Y30TZKC6N1EQ0F1RDDGR9AT
'SPMR3PQK63ME9T99M2X4DVP1XD4WY6NFSJ4QTBWT
'SP3JPR7XNR60AMBBEZAGF1YHRSFY1JCKE14HBKGTY
'SP356ASPHXK1EMKDZF5JBA36Z33DKSZD7R4PMCWZB
'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE
'SP3MYM8YGM8MVT10WKQ3A19E3MAG2H6PHCW8PMZWT
'SP2J9X4QT67FAJPEFK35M7EE87MCNAJ04VHZC7DRB
'SP1G4Z5J9AYVKZCHZ8RVPH593FPWJX5P6QM6JEV27
'SP3KHQ1P6HQXTKKN50Y30TZKC6N1EQ0F1RDDGR9AT
'SP3B9R6SPYP6E693ZTYVB1AS81HTJPQ081EZBB3S2
'SP3A09H1JEB4F85FZ6XEXRSZA210SC6RB7Q7V7DAF
'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6
'SP3A09H1JEB4F85FZ6XEXRSZA210SC6RB7Q7V7DAF
'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE
'SP3KW1JVCDNEVKN3JR4TGSCS9FW1T403WAH8BFNWN
'SP356ASPHXK1EMKDZF5JBA36Z33DKSZD7R4PMCWZB
'SPN9JGFGXFJZD7AM5VF2S7BRATNCQYVHVWG3087B
'SP3TBSZ85T6G8V91FGYQ3QG8HNR7GTVVHRCW62B6X
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SPYF9PC72BSWS0DGA33FR24GCG81MG1Z96463H68
'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW
'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH
'SP1Q3W9ZK6VEJBJYJTS1W295Z5HQXA1FEHGBF1JGR
'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6
'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE
'SP247RS63PWW7ZQZ9EYYA9CXKKPWEP71M14W8N294
'SPRX8W53YWFKB61CAMRH4WPT3N1SD7H2KCZTH9Z3
'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP9XKY1WP621NESM1RZV75E6K3WVVKKQ1Z7YFCFZ
'SP3NH26Q1KYANP3CYBV5ZWRJVXBPBE8GK33S8M20F
'SPV00QHST52GD7D0SEWV3R5N04RD4Q1PMA3TE2MP
'SP5TQYPJSBVHV757PJZ0KMXGT8SHCNSDTB2PNY0Z
'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6
'SP1E4798MP7RNHPVSBM954MSS5EJNM1AC3R53DC31
'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B
'SPWRS7QKQ3D41MY7MDAY2ZB1XRP7BQ8RFJPCK755
'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD
'SP328RRCE6B3DK3NJR01C2QHVVHXAF9WY9CVV36QD
'SPMR3PQK63ME9T99M2X4DVP1XD4WY6NFSJ4QTBWT
'SPAT6CDQN977Y6RC5M294GX63QQBSD8BMMX3DJZF
'SPFPBQ30DZ2G4CX8XZGZXD013N2NPHH7K7SB7GEZ
'SPWRS7QKQ3D41MY7MDAY2ZB1XRP7BQ8RFJPCK755
'SP16QZ3J5WVWVF7MZEK3J1TXWNJM7ED60JEHRQB97
'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9
'SPRX8W53YWFKB61CAMRH4WPT3N1SD7H2KCZTH9Z3
'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX
'SP1NEYZ0E1G4MXXA2GTPT2DRSQS2XCMEAE1YKKXMB
'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX
'SP9QP5ZJGAD1TTQV0VMQ6SQHW6ZZQ2111BCK9J3R
'SPWRS7QKQ3D41MY7MDAY2ZB1XRP7BQ8RFJPCK755
'SP3N6EZPTSX8ZV2RGPY9NR9A8CA0QET39CY978H5E
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP1MKM54044H7323201NP14ZKX0AKJ1X8MQ1VM11Z
'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP1G4Z5J9AYVKZCHZ8RVPH593FPWJX5P6QM6JEV27
'SP2QV18K6HB5NBE2RWHKH1HY2A3HKJ4NVW7KYN2SY
'SP8JVD8G9RRXPWF13STYZSJDDP25WSM8GWB46MAX
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP3SF0PSD7KYVJQPKKRBYJFF7NENGFHZSBVHM3B27
'SP3HYFVG35TW1RF47N6RKYYDNPX6T47J6ZJB3B4PE
'SP1G4Z5J9AYVKZCHZ8RVPH593FPWJX5P6QM6JEV27
'SP1E4798MP7RNHPVSBM954MSS5EJNM1AC3R53DC31
'SP1ZQBAJAB9S0QFJCJSK6J0NR80334T7GBVMW7ABS
'SP3KHQ1P6HQXTKKN50Y30TZKC6N1EQ0F1RDDGR9AT
'SP2XV2G7H7DC97ESZGFKWADTYZWNQH1QHZWGDDVS1
'SP1JF9VSNJBP4YZVC7AJ9CE6CXBD2ZV0W67T0E4T0
'SPGMAXJHXV7RKPEWW1Z9XZHDKBWFWYEZZZ1MYPG4
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9
'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH
'SP3190JW2TXA2YZ3QWCV9WXB2XG7GS970SY4A4A7X
'SP24ZBZ8ZE6F48JE9G3F3HRTG9FK7E2H6K2QZ3Q1K
'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0
'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0
'SP3ZMEFW7VH796ZQAH1JMAJT4WC4VPEZZFB6W5CAD
'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV
'SP1CE3NQXDKCJ2KEFFGCVFA5C196S9F0RRX93HY87
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP2F18PH7FP22EHS0J0X3A6EFZ9PAW0EZJRET0GXZ
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SP3D5EHK8SMJ3MMJWYCAKWJ2H4F1JQX85E33ZJDB9
'SP3HYFVG35TW1RF47N6RKYYDNPX6T47J6ZJB3B4PE
'SP2NDK60R7JKQ3SJ98CEHV2CMNDVTFBR541C4KV5Y
'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX
'SP38NPAYZY9335MG2EZ4CSYJ6TN49EY0FEZF0PDF7
'SPXQS1T1T2BKGSHH8H75PVFEY0R1X39F0B3MQWTJ
'SP17YP1HGWK7DP5Q69GRG14W34E078S4D78YM1FA5
'SPFXQK7QMGCYWJ5DTATS96N7FAEXNRNZM3FMB1AJ
'SP30AG244B32NQ90AQT99P82PRKM4GWD0JYBMCCP0
'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B
'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG
'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM
'SP25KJH4N4YNKTVXSWSHDPVCWDFAN2BA4H2VQVN0G
'SP2F2KH0RVX6GF1Y9FWMMSR9RHG0TW3NN72D724NX
'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3
'SP32DFA3HXYZ2BV3P8H6XQM8EN94D2212QM71BRYG
'SP2CZMH9A6FH5QPAJAR8ZG091Z15JKAGY1X0F3EJ0
'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH
'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ
 )) (err u500))