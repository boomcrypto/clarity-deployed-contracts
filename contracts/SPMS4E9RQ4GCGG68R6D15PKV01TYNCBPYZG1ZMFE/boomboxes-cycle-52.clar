;; Boombox 52

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(impl-trait .boombox-trait.boombox-trait)

(define-non-fungible-token b-52 uint)

;; constants
;;
(define-constant deployer tx-sender)
(define-data-var royalty-percent uint u250)
(define-data-var artist-address principal 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW)
(define-map token-count principal uint)
(define-map market uint {price: uint, commission: principal})

;; err constants
(define-constant err-not-authorized (err u403))
(define-constant err-not-found (err u404))
(define-constant err-invalid-stacks-tip (err u608))
(define-constant err-airdrop-called (err u701))

;; Stackerspool added errors constants
(define-constant error (err u1000))
(define-constant err-listing (err u103))
(define-constant err-wrong-commission (err u104))

;; data maps and vars
;;
(define-data-var last-id uint u0)
(define-data-var boombox-admin principal 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boombox-admin-v3)
(define-data-var airdrop-called bool false)

;; boombox-admin contract : boombox id
(define-map boombox-id principal uint)
;; approval maps
(define-map approvals {owner: principal, operator: principal, id: uint} bool)
(define-map approvals-all {owner: principal, operator: principal} bool)

;; private functions
(define-private (is-approved-with-owner (id uint) (operator principal) (owner principal))
  (or
    (is-eq owner operator)
    (default-to (default-to
      false
        (map-get? approvals-all {owner: owner, operator: operator}))
          (map-get? approvals {owner: owner, operator: operator, id: id}))))

(use-trait commission-trait 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-trait.commission)

;; public functions
;;
(define-read-only (get-balance (account principal))
  (default-to u0
    (map-get? token-count account)))

(define-private (trnsfr (id uint) (sender principal) (recipient principal))
    (let
      ((sender-balance (get-balance sender))
      (recipient-balance (get-balance recipient)))
        (try! (nft-transfer? b-52 id sender recipient))
        (map-set token-count
          sender
          (- sender-balance u1))
        (map-set token-count
          recipient
          (+ recipient-balance u1))
        (ok true)))

(define-private (is-sender-owner (id uint))
  (let ((owner (unwrap! (nft-get-owner? b-52 id) false)))
    (or (is-eq tx-sender owner) (is-eq contract-caller owner))))

(define-read-only (get-listing-in-ustx (id uint))
  (map-get? market id))

(define-public (list-in-ustx (id uint) (price uint) (comm-trait <commission-trait>))
  (let ((listing  {price: price, commission: (contract-of comm-trait)}))
    (asserts! (is-sender-owner id) err-not-authorized)
    (map-set market id listing)
    (print {  notification: "nft-listing",
              payload: (merge listing {
                id: id,
                action: "list-in-ustx" })})
    (ok true)))

(define-public (unlist-in-ustx (id uint))
  (begin
    (asserts! (is-sender-owner id) err-not-authorized)
    (map-delete market id)
    (print {  notification: "nft-listing",
              payload: {
                id: id,
                action: "unlist-in-ustx" }})
    (ok true)))

(define-public (buy-in-ustx (id uint) (comm-trait <commission-trait>))
  (let ((owner (unwrap! (nft-get-owner? b-52 id) err-not-found))
      (listing (unwrap! (map-get? market id) err-listing))
      (price (get price listing)))
    (asserts! (is-eq (contract-of comm-trait) (get commission listing)) err-wrong-commission)
    (try! (stx-transfer? price tx-sender owner))
    (try! (pay-royalties price))
    (try! (contract-call? comm-trait pay id price))
    (try! (trnsfr id owner tx-sender))
    (map-delete market id)
    (print {  notification: "nft-listing",
              payload: {
                id: id,
                action: "buy-in-ustx" }})
    (ok true)))

(define-read-only (get-royalty-percent)
  (ok (var-get royalty-percent)))

(define-private (pay-royalties (price uint))
  (let (
    (royalty (/ (* price (var-get royalty-percent)) u10000))
  )
  (if (> (var-get royalty-percent) u0)
    (try! (stx-transfer? royalty tx-sender (var-get artist-address)))
    (print false)
  )
  (ok true)))

;; transfer functions
(define-public (transfer (id uint) (sender principal) (recipient principal))
  (let ((owner (unwrap! (nft-get-owner? b-52 id) err-not-found)))
    (asserts! (is-none (map-get? market id)) err-listing)
    (asserts! (is-approved-with-owner id contract-caller owner) err-not-authorized)
    (nft-transfer? b-52 id sender recipient)))

(define-public (transfer-memo (id uint) (sender principal) (recipient principal) (memo (buff 34)))
  (begin
    (try! (transfer id sender recipient))
    (print memo)
    (ok true)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? b-52 id)))

(define-read-only (get-owner-at-block (id uint) (stacks-tip uint))
  (match (get-block-info? id-header-hash stacks-tip)
    ihh (ok (at-block ihh (nft-get-owner? b-52 id)))
    err-invalid-stacks-tip))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (id uint))
  (ok (some "ipfs://bafkreiguwyw5dcz7uhir6ptkpdtkaxomob4is4jb2udy3szkrelyuyc6te")))

;; can only be called by boombox admin
(define-public (mint (bb-id uint) (stacker principal) (amount-ustx uint) (pox-addr {version: (buff 1), hashbytes: (buff 20)}) (locking-period uint))
  (let ((next-id (+ u1 (var-get last-id))))
    (asserts! (is-eq bb-id (unwrap! (map-get? boombox-id contract-caller) err-not-authorized)) err-not-authorized)
    (var-set last-id next-id)
    (try! (nft-mint? b-52 next-id stacker))
    (map-set token-count stacker (+ u1 (get-balance stacker)))
    (ok next-id)))

;; can only be called by boombox admin
(define-public (set-boombox-id (bb-id uint))
  (begin
    (asserts! (is-eq contract-caller (var-get boombox-admin)) err-not-authorized)
    (map-set boombox-id contract-caller bb-id)
    (ok true)))

;; can only be called by deployer
(define-public (set-boombox-admin (admin principal))
  (begin
    (asserts! (is-eq contract-caller deployer) err-not-authorized)
    (var-set boombox-admin admin)
    (ok true)))

;; can only be called by deployer
;; Airdrop
(define-public (admin-airdrop)
  (let
    (
      (last-nft-id (var-get last-id))
    )
    (begin
      (asserts! (is-eq contract-caller deployer) err-not-authorized)
      (asserts! (is-eq false (var-get airdrop-called)) err-airdrop-called)
      (try! (nft-mint? b-52 u1 'SP25QZMBZ43ZWMCW9FB102XT4EFD602KZ6V0TBY7W))
      (map-set token-count 'SP25QZMBZ43ZWMCW9FB102XT4EFD602KZ6V0TBY7W (+ (get-balance 'SP25QZMBZ43ZWMCW9FB102XT4EFD602KZ6V0TBY7W) u1))
      (try! (nft-mint? b-52 u2 'SP123TY61PFFAEZBX3PNH7KG3663B3GBW440NMYX0))
      (map-set token-count 'SP123TY61PFFAEZBX3PNH7KG3663B3GBW440NMYX0 (+ (get-balance 'SP123TY61PFFAEZBX3PNH7KG3663B3GBW440NMYX0) u1))
      (try! (nft-mint? b-52 u3 'SP2009N95GZJWQ7W6QFN4CXKVVCM3HKCY050ZM97Y))
      (map-set token-count 'SP2009N95GZJWQ7W6QFN4CXKVVCM3HKCY050ZM97Y (+ (get-balance 'SP2009N95GZJWQ7W6QFN4CXKVVCM3HKCY050ZM97Y) u1))
      (try! (nft-mint? b-52 u4 'SP18EDVDZRXYWG6Z0CB4J3Q7R37164ACY6TBSVB9K))
      (map-set token-count 'SP18EDVDZRXYWG6Z0CB4J3Q7R37164ACY6TBSVB9K (+ (get-balance 'SP18EDVDZRXYWG6Z0CB4J3Q7R37164ACY6TBSVB9K) u1))
      (try! (nft-mint? b-52 u5 'SPKFNC4GMXFXM1X4WH82MSEFSZC09MQ673R9CXCD))
      (map-set token-count 'SPKFNC4GMXFXM1X4WH82MSEFSZC09MQ673R9CXCD (+ (get-balance 'SPKFNC4GMXFXM1X4WH82MSEFSZC09MQ673R9CXCD) u1))
      (try! (nft-mint? b-52 u6 'SPWG2646NEV92ZXH2D261WFKRHC25ZGMXA0KHVQA))
      (map-set token-count 'SPWG2646NEV92ZXH2D261WFKRHC25ZGMXA0KHVQA (+ (get-balance 'SPWG2646NEV92ZXH2D261WFKRHC25ZGMXA0KHVQA) u1))
      (try! (nft-mint? b-52 u7 'SP3YF5XZN4CNKRANEHVFWS18DAG5M2CHQTSBZQX35))
      (map-set token-count 'SP3YF5XZN4CNKRANEHVFWS18DAG5M2CHQTSBZQX35 (+ (get-balance 'SP3YF5XZN4CNKRANEHVFWS18DAG5M2CHQTSBZQX35) u1))
      (try! (nft-mint? b-52 u8 'SP3ZAZ6K5X8QHTKYN22E3EFEBMNT7FTS42681WMZ4))
      (map-set token-count 'SP3ZAZ6K5X8QHTKYN22E3EFEBMNT7FTS42681WMZ4 (+ (get-balance 'SP3ZAZ6K5X8QHTKYN22E3EFEBMNT7FTS42681WMZ4) u1))
      (try! (nft-mint? b-52 u9 'SP3FD0JFJ56AYTGA88W2HEKFNWKHMXS4VEA627KXV))
      (map-set token-count 'SP3FD0JFJ56AYTGA88W2HEKFNWKHMXS4VEA627KXV (+ (get-balance 'SP3FD0JFJ56AYTGA88W2HEKFNWKHMXS4VEA627KXV) u1))
      (try! (nft-mint? b-52 u10 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG))
      (map-set token-count 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG (+ (get-balance 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG) u1))
      (try! (nft-mint? b-52 u11 'SP3JJ3SH2841FYVN6AR7EGP5KZBAN5Z3ZX52KT1XF))
      (map-set token-count 'SP3JJ3SH2841FYVN6AR7EGP5KZBAN5Z3ZX52KT1XF (+ (get-balance 'SP3JJ3SH2841FYVN6AR7EGP5KZBAN5Z3ZX52KT1XF) u1))
      (try! (nft-mint? b-52 u12 'SP1GV16H3B3JA72X496VEPX5FFHD0F97RMX8DCX2J))
      (map-set token-count 'SP1GV16H3B3JA72X496VEPX5FFHD0F97RMX8DCX2J (+ (get-balance 'SP1GV16H3B3JA72X496VEPX5FFHD0F97RMX8DCX2J) u1))
      (try! (nft-mint? b-52 u13 'SP1ZNSXW7FTVC96DJB9J6QF14ZY7B582XDR46VG5M))
      (map-set token-count 'SP1ZNSXW7FTVC96DJB9J6QF14ZY7B582XDR46VG5M (+ (get-balance 'SP1ZNSXW7FTVC96DJB9J6QF14ZY7B582XDR46VG5M) u1))
      (try! (nft-mint? b-52 u14 'SP1386044X5N01AJAGN50NGKE87K4Q72P7DHVXF3F))
      (map-set token-count 'SP1386044X5N01AJAGN50NGKE87K4Q72P7DHVXF3F (+ (get-balance 'SP1386044X5N01AJAGN50NGKE87K4Q72P7DHVXF3F) u1))
      (try! (nft-mint? b-52 u15 'SPNDM273MY6ZNGGN1DH4JA0F03BPVGX8T7M80FK6))
      (map-set token-count 'SPNDM273MY6ZNGGN1DH4JA0F03BPVGX8T7M80FK6 (+ (get-balance 'SPNDM273MY6ZNGGN1DH4JA0F03BPVGX8T7M80FK6) u1))
      (try! (nft-mint? b-52 u16 'SP2XFT963GCVW6FKYSTW4B0EFSNZ2GV2Y5MTZEPCP))
      (map-set token-count 'SP2XFT963GCVW6FKYSTW4B0EFSNZ2GV2Y5MTZEPCP (+ (get-balance 'SP2XFT963GCVW6FKYSTW4B0EFSNZ2GV2Y5MTZEPCP) u1))
      (try! (nft-mint? b-52 u17 'SPHZYWBWK910G2B1V1N23WVG8VN0JRWDNG0SZGC4))
      (map-set token-count 'SPHZYWBWK910G2B1V1N23WVG8VN0JRWDNG0SZGC4 (+ (get-balance 'SPHZYWBWK910G2B1V1N23WVG8VN0JRWDNG0SZGC4) u1))
      (try! (nft-mint? b-52 u18 'SP26QBNK5GQT6XKK9VHXGERE8MX7880QHHTA5F26R))
      (map-set token-count 'SP26QBNK5GQT6XKK9VHXGERE8MX7880QHHTA5F26R (+ (get-balance 'SP26QBNK5GQT6XKK9VHXGERE8MX7880QHHTA5F26R) u1))
      (try! (nft-mint? b-52 u19 'SP1DNQQGEBADXNMFKFTVHJBER4XZNH9XJ3DF7KE6X))
      (map-set token-count 'SP1DNQQGEBADXNMFKFTVHJBER4XZNH9XJ3DF7KE6X (+ (get-balance 'SP1DNQQGEBADXNMFKFTVHJBER4XZNH9XJ3DF7KE6X) u1))
      (try! (nft-mint? b-52 u20 'SP5SSDMPF51Q2B9VS4F8HH52249AKAEDDBWYZ678))
      (map-set token-count 'SP5SSDMPF51Q2B9VS4F8HH52249AKAEDDBWYZ678 (+ (get-balance 'SP5SSDMPF51Q2B9VS4F8HH52249AKAEDDBWYZ678) u1))
      (try! (nft-mint? b-52 u21 'SP18XHCP5ZKE1ZXABA3NPJAT4BRBBXRK5F9F75DD3))
      (map-set token-count 'SP18XHCP5ZKE1ZXABA3NPJAT4BRBBXRK5F9F75DD3 (+ (get-balance 'SP18XHCP5ZKE1ZXABA3NPJAT4BRBBXRK5F9F75DD3) u1))
      (try! (nft-mint? b-52 u22 'SP3FQWCHEE92TCD1AVJEHP4W9KEW7QCFMT89YYWJP))
      (map-set token-count 'SP3FQWCHEE92TCD1AVJEHP4W9KEW7QCFMT89YYWJP (+ (get-balance 'SP3FQWCHEE92TCD1AVJEHP4W9KEW7QCFMT89YYWJP) u1))
      (try! (nft-mint? b-52 u23 'SP3S25JE324ZY8G3JS7T983V0KQV14RBRZZNEGPPR))
      (map-set token-count 'SP3S25JE324ZY8G3JS7T983V0KQV14RBRZZNEGPPR (+ (get-balance 'SP3S25JE324ZY8G3JS7T983V0KQV14RBRZZNEGPPR) u1))
      (try! (nft-mint? b-52 u24 'SP66GN64A2BKD4Y1TJBJ21SJP90WE21ZRGZH4ZR6))
      (map-set token-count 'SP66GN64A2BKD4Y1TJBJ21SJP90WE21ZRGZH4ZR6 (+ (get-balance 'SP66GN64A2BKD4Y1TJBJ21SJP90WE21ZRGZH4ZR6) u1))
      (try! (nft-mint? b-52 u25 'SP24SEFZTNWQBC205YC1W44RW03W0SRN418NZ80CF))
      (map-set token-count 'SP24SEFZTNWQBC205YC1W44RW03W0SRN418NZ80CF (+ (get-balance 'SP24SEFZTNWQBC205YC1W44RW03W0SRN418NZ80CF) u1))
      (try! (nft-mint? b-52 u26 'SP25EV6W08DK6TGMC7ENRYWQC2DP61XV6BBMVA02E))
      (map-set token-count 'SP25EV6W08DK6TGMC7ENRYWQC2DP61XV6BBMVA02E (+ (get-balance 'SP25EV6W08DK6TGMC7ENRYWQC2DP61XV6BBMVA02E) u1))
      (try! (nft-mint? b-52 u27 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9))
      (map-set token-count 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9 (+ (get-balance 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9) u1))
      (try! (nft-mint? b-52 u28 'SP3JXAXGZA5JJJ4YHTEW6Q46PKX3VMT0Q0F7JDYF7))
      (map-set token-count 'SP3JXAXGZA5JJJ4YHTEW6Q46PKX3VMT0Q0F7JDYF7 (+ (get-balance 'SP3JXAXGZA5JJJ4YHTEW6Q46PKX3VMT0Q0F7JDYF7) u1))
      (try! (nft-mint? b-52 u29 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F))
      (map-set token-count 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F (+ (get-balance 'SP13QC2G49PXXA84H083Y1PMFS2PGXM583HQ8TQ9F) u1))
      (try! (nft-mint? b-52 u30 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X))
      (map-set token-count 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X (+ (get-balance 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X) u1))
      (try! (nft-mint? b-52 u31 'SP2J56JG0SMAVW0DXXJ7W18W2CQHD1FE83FZCFV26))
      (map-set token-count 'SP2J56JG0SMAVW0DXXJ7W18W2CQHD1FE83FZCFV26 (+ (get-balance 'SP2J56JG0SMAVW0DXXJ7W18W2CQHD1FE83FZCFV26) u1))
      (try! (nft-mint? b-52 u32 'SP13J4QQAWZCB64ZFQH8Y1BY9VD49VEJ30TJMRK1D))
      (map-set token-count 'SP13J4QQAWZCB64ZFQH8Y1BY9VD49VEJ30TJMRK1D (+ (get-balance 'SP13J4QQAWZCB64ZFQH8Y1BY9VD49VEJ30TJMRK1D) u1))
      (try! (nft-mint? b-52 u33 'SPA6DVSF7S0DEXE4NWG6JQBX3BEA5AS5PEE2NQXP))
      (map-set token-count 'SPA6DVSF7S0DEXE4NWG6JQBX3BEA5AS5PEE2NQXP (+ (get-balance 'SPA6DVSF7S0DEXE4NWG6JQBX3BEA5AS5PEE2NQXP) u1))
      (try! (nft-mint? b-52 u34 'SP3AY50XK1ACGTWR3W4N64SAEFHBRR7WZC38Z8AX3))
      (map-set token-count 'SP3AY50XK1ACGTWR3W4N64SAEFHBRR7WZC38Z8AX3 (+ (get-balance 'SP3AY50XK1ACGTWR3W4N64SAEFHBRR7WZC38Z8AX3) u1))
      (try! (nft-mint? b-52 u35 'SP3Y1R9KPDB0SQK8T1BXP9FAMAYV4FR7WTYX42GQZ))
      (map-set token-count 'SP3Y1R9KPDB0SQK8T1BXP9FAMAYV4FR7WTYX42GQZ (+ (get-balance 'SP3Y1R9KPDB0SQK8T1BXP9FAMAYV4FR7WTYX42GQZ) u1))
      (try! (nft-mint? b-52 u36 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9))
      (map-set token-count 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9 (+ (get-balance 'SP3YBQRESRPX4B90BZHE77J2YK5DG8BBBXWJHZ0M9) u1))
      (try! (nft-mint? b-52 u37 'SP3EB2J4GYMGM9W2JP337XCZ8H945D9T11BM8AQR))
      (map-set token-count 'SP3EB2J4GYMGM9W2JP337XCZ8H945D9T11BM8AQR (+ (get-balance 'SP3EB2J4GYMGM9W2JP337XCZ8H945D9T11BM8AQR) u1))
      (try! (nft-mint? b-52 u38 'SPYQ829C0KWNEVETW09C93CCBHV3AGM60AKS66AJ))
      (map-set token-count 'SPYQ829C0KWNEVETW09C93CCBHV3AGM60AKS66AJ (+ (get-balance 'SPYQ829C0KWNEVETW09C93CCBHV3AGM60AKS66AJ) u1))
      (try! (nft-mint? b-52 u39 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16))
      (map-set token-count 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 (+ (get-balance 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16) u1))
      (try! (nft-mint? b-52 u40 'SP16661ZGFH2Y9NGSQXTBH6TYTJ9YZV3B2TARW92J))
      (map-set token-count 'SP16661ZGFH2Y9NGSQXTBH6TYTJ9YZV3B2TARW92J (+ (get-balance 'SP16661ZGFH2Y9NGSQXTBH6TYTJ9YZV3B2TARW92J) u1))
      (try! (nft-mint? b-52 u41 'SP3ZX7K64FF6NDEFY0TFGPFCKNDTY8EVFD860PXXS))
      (map-set token-count 'SP3ZX7K64FF6NDEFY0TFGPFCKNDTY8EVFD860PXXS (+ (get-balance 'SP3ZX7K64FF6NDEFY0TFGPFCKNDTY8EVFD860PXXS) u1))
      (try! (nft-mint? b-52 u42 'SP35TP5W1CMNJA97HSH85VG669NSD9XJFXRES0VQH))
      (map-set token-count 'SP35TP5W1CMNJA97HSH85VG669NSD9XJFXRES0VQH (+ (get-balance 'SP35TP5W1CMNJA97HSH85VG669NSD9XJFXRES0VQH) u1))
      (try! (nft-mint? b-52 u43 'SP27H8AQR7KGNXDEQYV1N7P90PFJAPHE431G23DV7))
      (map-set token-count 'SP27H8AQR7KGNXDEQYV1N7P90PFJAPHE431G23DV7 (+ (get-balance 'SP27H8AQR7KGNXDEQYV1N7P90PFJAPHE431G23DV7) u1))
      (try! (nft-mint? b-52 u44 'SP1MVN4WTAEA9AMNJT7QCAFXMQ1A9EBN58Y5FE2NE))
      (map-set token-count 'SP1MVN4WTAEA9AMNJT7QCAFXMQ1A9EBN58Y5FE2NE (+ (get-balance 'SP1MVN4WTAEA9AMNJT7QCAFXMQ1A9EBN58Y5FE2NE) u1))
      (try! (nft-mint? b-52 u45 'SP192QE0B7TQB9H0F7PMHP6M8NJ7HNS0H3GXZTQ8P))
      (map-set token-count 'SP192QE0B7TQB9H0F7PMHP6M8NJ7HNS0H3GXZTQ8P (+ (get-balance 'SP192QE0B7TQB9H0F7PMHP6M8NJ7HNS0H3GXZTQ8P) u1))
      (try! (nft-mint? b-52 u46 'SP2S5WG0T4H2B4QX4X03HQZ0JP5JB19A3XX9Z3PD0))
      (map-set token-count 'SP2S5WG0T4H2B4QX4X03HQZ0JP5JB19A3XX9Z3PD0 (+ (get-balance 'SP2S5WG0T4H2B4QX4X03HQZ0JP5JB19A3XX9Z3PD0) u1))
      (try! (nft-mint? b-52 u47 'SPQ3STDA3G4Q6QD716425BE7A2G378QFQ10RJK3V))
      (map-set token-count 'SPQ3STDA3G4Q6QD716425BE7A2G378QFQ10RJK3V (+ (get-balance 'SPQ3STDA3G4Q6QD716425BE7A2G378QFQ10RJK3V) u1))
      (try! (nft-mint? b-52 u48 'SP3ET3TVWN5K9MH6CSAP3JK1B3BYS9GB16KKWSAMJ))
      (map-set token-count 'SP3ET3TVWN5K9MH6CSAP3JK1B3BYS9GB16KKWSAMJ (+ (get-balance 'SP3ET3TVWN5K9MH6CSAP3JK1B3BYS9GB16KKWSAMJ) u1))
      (try! (nft-mint? b-52 u49 'SP3KKBF6BSVPJ8KH55W5R3RWZ6HA7FC5BVV8205A5))
      (map-set token-count 'SP3KKBF6BSVPJ8KH55W5R3RWZ6HA7FC5BVV8205A5 (+ (get-balance 'SP3KKBF6BSVPJ8KH55W5R3RWZ6HA7FC5BVV8205A5) u1))
      (try! (nft-mint? b-52 u50 'SP2B4SYS3A7Z2ZZ2EP4RH9M477A59V6DFT4WG2KEM))
      (map-set token-count 'SP2B4SYS3A7Z2ZZ2EP4RH9M477A59V6DFT4WG2KEM (+ (get-balance 'SP2B4SYS3A7Z2ZZ2EP4RH9M477A59V6DFT4WG2KEM) u1))
      (try! (nft-mint? b-52 u51 'SP3N0TH3N7BDG4WBSYV6FE2ASSAPEGWK47EEWD9TV))
      (map-set token-count 'SP3N0TH3N7BDG4WBSYV6FE2ASSAPEGWK47EEWD9TV (+ (get-balance 'SP3N0TH3N7BDG4WBSYV6FE2ASSAPEGWK47EEWD9TV) u1))
      (try! (nft-mint? b-52 u52 'SP379GBZ6DS4XJVEJY4R8FDGT1DK2BREHSBTFM7BP))
      (map-set token-count 'SP379GBZ6DS4XJVEJY4R8FDGT1DK2BREHSBTFM7BP (+ (get-balance 'SP379GBZ6DS4XJVEJY4R8FDGT1DK2BREHSBTFM7BP) u1))
      (try! (nft-mint? b-52 u53 'SP1S73MMPD15AAW6QCD5VVZ34JM56ZWHGYCCMBBCD))
      (map-set token-count 'SP1S73MMPD15AAW6QCD5VVZ34JM56ZWHGYCCMBBCD (+ (get-balance 'SP1S73MMPD15AAW6QCD5VVZ34JM56ZWHGYCCMBBCD) u1))
      (try! (nft-mint? b-52 u54 'SPD75C55PRTMSV60GMMDZEEBPZS37ZD01Q7VYD0Z))
      (map-set token-count 'SPD75C55PRTMSV60GMMDZEEBPZS37ZD01Q7VYD0Z (+ (get-balance 'SPD75C55PRTMSV60GMMDZEEBPZS37ZD01Q7VYD0Z) u1))
      (try! (nft-mint? b-52 u55 'SP0ANQ6E06A81T0WKT0G4NRN04XNBR7PM25F4Y01))
      (map-set token-count 'SP0ANQ6E06A81T0WKT0G4NRN04XNBR7PM25F4Y01 (+ (get-balance 'SP0ANQ6E06A81T0WKT0G4NRN04XNBR7PM25F4Y01) u1))
      (try! (nft-mint? b-52 u56 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE))
      (map-set token-count 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE (+ (get-balance 'SP12BEEDG31J0AH68DFDJJYZ36D002PKDZCP1DZQE) u1))
      (try! (nft-mint? b-52 u57 'SP3CNS7ZAEFRXGGD3TGVB1GW6GQDGTH0TPSB2XN48))
      (map-set token-count 'SP3CNS7ZAEFRXGGD3TGVB1GW6GQDGTH0TPSB2XN48 (+ (get-balance 'SP3CNS7ZAEFRXGGD3TGVB1GW6GQDGTH0TPSB2XN48) u1))
      (try! (nft-mint? b-52 u58 'SP1WP4F6ZP8QYP61MBXBSNWPT3901BS2CC246XFTX))
      (map-set token-count 'SP1WP4F6ZP8QYP61MBXBSNWPT3901BS2CC246XFTX (+ (get-balance 'SP1WP4F6ZP8QYP61MBXBSNWPT3901BS2CC246XFTX) u1))
      (try! (nft-mint? b-52 u59 'SP39RBC1PYD2FAGSP589F7ZZSYBWVSWZQTNCH3FM1))
      (map-set token-count 'SP39RBC1PYD2FAGSP589F7ZZSYBWVSWZQTNCH3FM1 (+ (get-balance 'SP39RBC1PYD2FAGSP589F7ZZSYBWVSWZQTNCH3FM1) u1))
      (try! (nft-mint? b-52 u60 'SPZCFP3486BF968TPQ3H6DBRK70YKKSAW3FBD2E0))
      (map-set token-count 'SPZCFP3486BF968TPQ3H6DBRK70YKKSAW3FBD2E0 (+ (get-balance 'SPZCFP3486BF968TPQ3H6DBRK70YKKSAW3FBD2E0) u1))
      (try! (nft-mint? b-52 u61 'SP2VA1Y2XQZYCBV3FB3MCSY2B7VVWGVFVXYVFRGS5))
      (map-set token-count 'SP2VA1Y2XQZYCBV3FB3MCSY2B7VVWGVFVXYVFRGS5 (+ (get-balance 'SP2VA1Y2XQZYCBV3FB3MCSY2B7VVWGVFVXYVFRGS5) u1))
      (try! (nft-mint? b-52 u62 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV))
      (map-set token-count 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV (+ (get-balance 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV) u1))
      (try! (nft-mint? b-52 u63 'SP3RRA0RQDNGRQYM0K64EVX8E0MBH0DEPPPN4KQG8))
      (map-set token-count 'SP3RRA0RQDNGRQYM0K64EVX8E0MBH0DEPPPN4KQG8 (+ (get-balance 'SP3RRA0RQDNGRQYM0K64EVX8E0MBH0DEPPPN4KQG8) u1))
      (try! (nft-mint? b-52 u64 'SP39WR7DRCPK9AHRFC0YF96S43QMZ0S8XWQKTJP0X))
      (map-set token-count 'SP39WR7DRCPK9AHRFC0YF96S43QMZ0S8XWQKTJP0X (+ (get-balance 'SP39WR7DRCPK9AHRFC0YF96S43QMZ0S8XWQKTJP0X) u1))
      (try! (nft-mint? b-52 u65 'SP24WGQVM1PTWJKP1W5CQ7H8CXHXTXV3NQ12QSQQD))
      (map-set token-count 'SP24WGQVM1PTWJKP1W5CQ7H8CXHXTXV3NQ12QSQQD (+ (get-balance 'SP24WGQVM1PTWJKP1W5CQ7H8CXHXTXV3NQ12QSQQD) u1))
      (try! (nft-mint? b-52 u66 'SP1XCTGM847WJQSVPBDM8SD6H7XHFV7E3809ND3NY))
      (map-set token-count 'SP1XCTGM847WJQSVPBDM8SD6H7XHFV7E3809ND3NY (+ (get-balance 'SP1XCTGM847WJQSVPBDM8SD6H7XHFV7E3809ND3NY) u1))
      (try! (nft-mint? b-52 u67 'SPM06DTBFP2E6056NGR0Q3TEE5SW9ZYRA98XZ23S))
      (map-set token-count 'SPM06DTBFP2E6056NGR0Q3TEE5SW9ZYRA98XZ23S (+ (get-balance 'SPM06DTBFP2E6056NGR0Q3TEE5SW9ZYRA98XZ23S) u1))
      (try! (nft-mint? b-52 u68 'SP1PW84909K241NK7F7Y85KW63H3VMRKMTEKS72DJ))
      (map-set token-count 'SP1PW84909K241NK7F7Y85KW63H3VMRKMTEKS72DJ (+ (get-balance 'SP1PW84909K241NK7F7Y85KW63H3VMRKMTEKS72DJ) u1))
      (try! (nft-mint? b-52 u69 'SP8X90BJRDS47FMER8MJ78SG0ZSYBPXFQWG1H0PS))
      (map-set token-count 'SP8X90BJRDS47FMER8MJ78SG0ZSYBPXFQWG1H0PS (+ (get-balance 'SP8X90BJRDS47FMER8MJ78SG0ZSYBPXFQWG1H0PS) u1))
      (try! (nft-mint? b-52 u70 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH))
      (map-set token-count 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH (+ (get-balance 'SP1FR2M102H4DE4DH96R4D29RC8AGQZG5D5Y4S7CH) u1))
      (try! (nft-mint? b-52 u71 'SP1Q21V7Q88J0463T9EA1ZH3DJ6XYPFQZ4B62Y9GF))
      (map-set token-count 'SP1Q21V7Q88J0463T9EA1ZH3DJ6XYPFQZ4B62Y9GF (+ (get-balance 'SP1Q21V7Q88J0463T9EA1ZH3DJ6XYPFQZ4B62Y9GF) u1))
      (try! (nft-mint? b-52 u72 'SP3E9J3D6YJYX5H3XHR00TXG1MD3D42XP4194XNNZ))
      (map-set token-count 'SP3E9J3D6YJYX5H3XHR00TXG1MD3D42XP4194XNNZ (+ (get-balance 'SP3E9J3D6YJYX5H3XHR00TXG1MD3D42XP4194XNNZ) u1))
      (try! (nft-mint? b-52 u73 'SP3C4YYS3N3NFQQVM04J4FFED70SYSXKK7CYA5WNT))
      (map-set token-count 'SP3C4YYS3N3NFQQVM04J4FFED70SYSXKK7CYA5WNT (+ (get-balance 'SP3C4YYS3N3NFQQVM04J4FFED70SYSXKK7CYA5WNT) u1))
      (try! (nft-mint? b-52 u74 'SP2XFZR7CTWPM686ZFPBHR5YJ927A5R82EZNRT5V0))
      (map-set token-count 'SP2XFZR7CTWPM686ZFPBHR5YJ927A5R82EZNRT5V0 (+ (get-balance 'SP2XFZR7CTWPM686ZFPBHR5YJ927A5R82EZNRT5V0) u1))
      (try! (nft-mint? b-52 u75 'SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE))
      (map-set token-count 'SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE (+ (get-balance 'SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE) u1))
      (try! (nft-mint? b-52 u76 'SP1JY766Q0PM5R5MC3J603NTK27SW7Y7GKXM2T946))
      (map-set token-count 'SP1JY766Q0PM5R5MC3J603NTK27SW7Y7GKXM2T946 (+ (get-balance 'SP1JY766Q0PM5R5MC3J603NTK27SW7Y7GKXM2T946) u1))

      (var-set last-id u76)
      (var-set airdrop-called true)
      (ok true))))