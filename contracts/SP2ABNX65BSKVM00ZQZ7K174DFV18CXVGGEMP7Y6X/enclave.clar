;; enclave
;; contractType: editions

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token enclave uint)

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
(define-data-var mint-limit uint u420)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmWYVeKL1Jas8Fe7nn53FwoG5CyxCK1WvsGBEG6DDhp31T/")
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

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

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
      (unwrap! (nft-mint? enclave next-id tx-sender) next-id)
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
    (nft-burn? enclave token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? enclave token-id) false)))

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
  (ok (nft-get-owner? enclave token-id)))

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

(define-data-var license-uri (string-ascii 80) "https://arweave.net/zmc1WTspIhFyVY82bwfAIcIExLFH5lUcHHUN0wXg4W8/4")
(define-data-var license-name (string-ascii 40) "PERSONAL")

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
  (match (nft-transfer? enclave id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? enclave id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? enclave id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP14V9BXQR5A6M32REYYFDBQQE7FA0Q2R41GD90NK u5)
(map-set mint-passes 'SP15PKJS4ZPNQV7TZJSSNQYAS2RYDETAM7AJBRK24 u26)
(map-set mint-passes 'SP162D87CY84QVVCMJKNKGHC7GGXFGA0TAR9D0XJW u1)
(map-set mint-passes 'SP1742Q3QT5W250RT3RDX9B6DTC6Y61771DX8TEF5 u1)
(map-set mint-passes 'SP19MNWTQ06X709ZA0T1KXXWWSG629MGB0QS0D16X u2)
(map-set mint-passes 'SP1A32MBZDN1B28ZT5DH6MA739VJ0BFH05CJHCM8W u1)
(map-set mint-passes 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV u2)
(map-set mint-passes 'SP1EGWE0FKXBZF0QFM966MS9KYWT9Z3VNGQ75N7N4 u3)
(map-set mint-passes 'SP1G9PZMQSFRQ7Q98XP7JMNE2C22RXK1W61RXTNKP u1)
(map-set mint-passes 'SP1KBVBP3AZP7YA968Y3G14A17P9XXFPBPEVF5EG9 u1)
(map-set mint-passes 'SP1QS3X6DF6GR55T4PBGPGWB5JZ5RJT6FCPWB13DX u5)
(map-set mint-passes 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 u4)
(map-set mint-passes 'SP1R3EWZM6M102P5A9AJGJMA5YZTR6PXANK9Z13G3 u1)
(map-set mint-passes 'SP1TRJR66FTZZGJWDG3ZK6VCS4SNQ10CHWTTMHMHZ u2)
(map-set mint-passes 'SP1VFMMXJXH7AYA9TKYFVE28MGFTZ0E5N79H6WMCB u3)
(map-set mint-passes 'SP1WXMX9PYKSH86XW29Y30PKKSEAS4MKX9XJQ4GTG u1)
(map-set mint-passes 'SP1WYHPJJVN3P0PS32BMF33P6WVVK1SNRRS28ZF0G u1)
(map-set mint-passes 'SP1Y60B0GCM1P040N7Y0QD9R93Y5EZRJ8YH2BV5NW u3)
(map-set mint-passes 'SP1ZQSWQ9QNNW388VFG45HYX1H592147V2FZZJY8V u1)
(map-set mint-passes 'SP21665394YPPDZ40SMC8F6NX9R5KZKF0YSRFGX8C u1)
(map-set mint-passes 'SP21C94648068TV7RSTNWQ1FSECGAZ7PYTT2GAD63 u1)
(map-set mint-passes 'SP22NY3PR97YA5AG3NMSPCHGFZXXJNJXGTW2A2WJ0 u1)
(map-set mint-passes 'SP22PRWZR37T6KZT9J4HTYTY6H5FJYAXSJSYSMJVB u2)
(map-set mint-passes 'SP23B3GJ1AZ95NAGZ38P6RJ6P78MFPGQE3BP8EEW4 u1)
(map-set mint-passes 'SP23F3QZEWF0J4QBPQJZE6AVWD3JS7P6ADD9H7VZA u1)
(map-set mint-passes 'SP23MDNANPJDANJ5ZBN8YJW9V6DRCGSENM9NHKDQK u1)
(map-set mint-passes 'SP24AGF98C1WYWSDDCA021JGSTTZ90V4BAD4R4SSS u1)
(map-set mint-passes 'SP24GYRG3M7T0S6FZE9RVVP9PNNZQJQ614650G590 u3)
(map-set mint-passes 'SP25QY5WZ8Z4DFC5HGDTEGDNJEAM0DDT433A8QSK2 u2)
(map-set mint-passes 'SP271CPRFRDSX26GZND9YDD3FSE0JK2B61SBJRAG2 u1)
(map-set mint-passes 'SP2791RKSYJJ39MVHC09J8NARWBMK5G9C79EJB0RV u13)
(map-set mint-passes 'SP2ABNX65BSKVM00ZQZ7K174DFV18CXVGGEMP7Y6X u11)
(map-set mint-passes 'SP2BQ3TSCZ78389366WDDDGC1C92Q6WD9ZSGK0WT9 u1)
(map-set mint-passes 'SP2C20XGZBAYFZ1NYNHT1J6MGMM0EW9X7PFBWK7QG u1)
(map-set mint-passes 'SP2CDY5S7VD4Z4RT93Z1RTXAS1ZXGTVMPHKNKZ27S u1)
(map-set mint-passes 'SP2E03GHWY145XMFDTHX4Z913EADP4RMZ0P0DCTE9 u1)
(map-set mint-passes 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH u1)
(map-set mint-passes 'SP2JKPKJCCRTEC1K81W8S3HCFXCP0H7PDKTN0CEGS u1)
(map-set mint-passes 'SP2MXBQSYS8HJ6ZHNFDJNDYVFQG551Y21X9B0YRD7 u1)
(map-set mint-passes 'SP2P336EM6HGAX7NQJGR0A4W7KP11BNY25YDSTA6W u3)
(map-set mint-passes 'SP2QE60HPRY41A767SFT0189KV8JT1MZNFK0BQ3QX u1)
(map-set mint-passes 'SP2R3J2ZJ7A8BKCG2A2SBP8E2708V27KYTHYPERFF u72)
(map-set mint-passes 'SP2SWMAHV98BN57FSHHK6HR2TYGWDSW5XZY19RMBD u3)
(map-set mint-passes 'SP2TGN9DJWTV02B9HRGX6Z43Y7052DTZW6FZVZH0S u3)
(map-set mint-passes 'SP2TW1D8YF5CE0NDP5VCR5NMTPHQ4PQR1KBB4NQ5Q u4)
(map-set mint-passes 'SP2WB2K6T6V9E1JXPM2CCDQK6K137DGGE68R7GC0G u2)
(map-set mint-passes 'SP2WJZCH7S7XN31W63H76CQDYH1SBK08ZM7M06G3F u1)
(map-set mint-passes 'SP3079W6DMRE2TV7B79T0B7B3Q0YZAS2TH42GAAK4 u2)
(map-set mint-passes 'SP30E7R3ZQVT7XE4GGQ4XVFR90V161263VG2F5YHC u1)
(map-set mint-passes 'SP30MX9SS3S6DAY1BRXSQT5SQGQ0PX391MY1YPBF8 u1)
(map-set mint-passes 'SP31QFBF2M32B94JQQMDE5JGRT4T9R0E0HHJ48QKV u2)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u1)
(map-set mint-passes 'SP32V5EAKRWZ66VVA67XGDK18VYMZM5NT7NP98M9 u1)
(map-set mint-passes 'SP35E73RP0EV411FP3Y34GX89P171VHWSF7QKC8JT u3)
(map-set mint-passes 'SP363ECSA62Y3HTHD6NB70RY5WTVA113WJPGN7G6N u1)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u1)
(map-set mint-passes 'SP36MCQHXPP0DZ2KPC1KEY6ERC8GKB6QVCAK0PQYG u1)
(map-set mint-passes 'SP38WZ44X5X4ZYJQ4V9A9R756AY0BAH3S524M81XE u1)
(map-set mint-passes 'SP39HKSZVWV2PJQWGYGX6RZPAAJYXJZ2SRSQ7RM7Z u2)
(map-set mint-passes 'SP3A09H1JEB4F85FZ6XEXRSZA210SC6RB7Q7V7DAF u1)
(map-set mint-passes 'SP3B84QWAXRAKB67Z4TB33SY5G0BGGVQC36526QN6 u1)
(map-set mint-passes 'SP3EQ7FQ8TFXB792P7VAGRXER0YNFMGM1Y8RS69RC u1)
(map-set mint-passes 'SP3FRR202NGRSN2XYMRJG3RSTN5PHP9TYHC2JSDGV u1)
(map-set mint-passes 'SP3FRT6WTV0NGX5NX8EHJZDA7R79CKGGNQJEC0WQ9 u3)
(map-set mint-passes 'SP3JMPP4S5CZBC68XEV2DPWEFTXHDFFHQYJXHM119 u2)
(map-set mint-passes 'SP3KXV3J6MRHAH4H89MDS390X1KS0GQN4DWQ5RFVB u1)
(map-set mint-passes 'SP3M72S3S5085CHCMH6KWQG6NGFT9MYFJRZX036P2 u1)
(map-set mint-passes 'SP3P4E5DQBJXMQ6MY5CR67G8RT9C5E8D3JK80MMKH u1)
(map-set mint-passes 'SP3P53KJAMZMJEQACWZQ4T7NP2P52T7RZ843JJ0HA u1)
(map-set mint-passes 'SP3P8PMKMYJQ9V16A6EZW2XHH1P29JN58R31VQ4VJ u3)
(map-set mint-passes 'SP3Q1ZEEG5K9K4DEWG475B2CTH93237RTZ3NERYD8 u17)
(map-set mint-passes 'SP3QDNXG15V93J3BNTHEY3A7YTED9SZS43AFWCFBF u1)
(map-set mint-passes 'SP3RRA0RQDNGRQYM0K64EVX8E0MBH0DEPPPN4KQG8 u2)
(map-set mint-passes 'SP3SBX7TC4GW4SRS0JD6F0ZQHVVATGRSCW52GBZES u1)
(map-set mint-passes 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 u4)
(map-set mint-passes 'SP3VGV6K1NC5BTK82S06FD9YK3FPZ4KD6YNRJCV2R u1)
(map-set mint-passes 'SP3VYCKS11684SPB5M73AVS692B1GR35XBQPSYS2Z u4)
(map-set mint-passes 'SP3W6K52WCJR6VDJSHAJ9VNMXRFAXAQZS64JA8KY2 u60)
(map-set mint-passes 'SP3WBYAEWN0JER1VPBW8TRT1329BGP9RGC5S2519W u1)
(map-set mint-passes 'SP3WZACEBVVEB4F3SPWQ4N6CWT9Z74VCBA9P16CY5 u2)
(map-set mint-passes 'SP3XVFQ1AB7DD5N19GS0412CG4JG7XWSBYAG98PVW u1)
(map-set mint-passes 'SP4ZZRRZHD344VCABQNZ9MDQ09TBKWXVCY4T0760 u1)
(map-set mint-passes 'SP5G3VY7MZT8BNB6FHXZE9JD4PPF8WRT3H6JSBWW u2)
(map-set mint-passes 'SP661DNB6KZH6YBT1Y32NCDHNJE042ZY7B8JA9WW u4)
(map-set mint-passes 'SP6HYDNWHSSTZFS0HAR4FDRPXK3EK603S0BYJHFJ u1)
(map-set mint-passes 'SP779SC9CDWQVMTRXT0HZCEHSDBXCHNGG7BC1H9B u1)
(map-set mint-passes 'SP8N846PR1492HB2A08R5G96RYNKWRHDJDTBM227 u1)
(map-set mint-passes 'SPA99HZ7KCPMNBHAHWREE95P0M1FNT9FR4AA6HZG u1)
(map-set mint-passes 'SPAFPBD7M89973WDEN68FKYW761RQVYNHSEFQZB9 u1)
(map-set mint-passes 'SPC3270HXDARJHK319ZXPXDZ6KGZATJ8YMEPB5EZ u1)
(map-set mint-passes 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44 u2)
(map-set mint-passes 'SPEJ2JKG5SVZD793CEWFZQ0VDPEGZ6QVP39QFAHM u1)
(map-set mint-passes 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S u1)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u3)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u1)
(map-set mint-passes 'SPKFMMZ410F5KVX5G8JCYH46TB3D175YAQF2AGX u1)
(map-set mint-passes 'SPMR3Z3W08TXBYRBCM95Q9BZ4CKMSFTRD7KJGEZJ u1)
(map-set mint-passes 'SPN4Y5QPGQA8882ZXW90ADC2DHYXMSTN8VAR8C3X u1)
(map-set mint-passes 'SPNDNPQ98RPC4N3PQX4CZJ9SF0K6D0Y9WAVP80S5 u4)
(map-set mint-passes 'SPP28QCMZ51GVN9933VFH9TXKQ3XCT4WE5A07533 u4)
(map-set mint-passes 'SPP33RRR5CJ7C7X5Y8M0G1MH01B34HJ82D2T4PRF u23)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u1)
(map-set mint-passes 'SPQ52NQC3QY4TMZ716MHZGHZSGNQQ9G365MC0EE8 u18)
(map-set mint-passes 'SPQE3J7XMMK0DN0BWJZHGE6B05VDYQRXRMDV734D u3)
(map-set mint-passes 'SPQKQNJHK9EASVBQY0A21B4DSAGHJ9F10WHYQMWJ u1)
(map-set mint-passes 'SPRQKYT0HQK2BMC4B6GZJD12R85RVAAP55WD6V08 u1)
(map-set mint-passes 'SPSS7WAYA17Y8Z5Q6GJTMH4FH4MRJ7HZZ6JPGAGR u2)
(map-set mint-passes 'SPSYE0KJ6QC8MMBG8417Y11460X3X94A640CVH8W u1)
(map-set mint-passes 'SPT5W2M6KVGZN4PRP85HP1ASTZV84ZN9YAJB9Z4D u2)
(map-set mint-passes 'SPTBXT6YRNYZE85F9AZ0W5RMBQQGY0ACBNH7YJR7 u2)
(map-set mint-passes 'SPXEAQN4H2MW9YVSJ48B6PA4362MYPW2SAW0GAHZ u3)
(map-set mint-passes 'SPY294PE2BBZSXDN5WP9ZNBQQJ2JWVGVFNCBZHAM u1)
(map-set mint-passes 'SPZWZQS7QZVPQ7FAKPSDW9BJ6P7JD1S62KPGV5WJ u3)
