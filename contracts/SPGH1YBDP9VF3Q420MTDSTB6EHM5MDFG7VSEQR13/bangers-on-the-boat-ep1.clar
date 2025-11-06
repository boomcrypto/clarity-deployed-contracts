;; bangers-on-the-boat-ep1
;; contractType: public

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token bangers-on-the-boat-ep1 uint)

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
(define-data-var mint-limit uint u280)
(define-data-var last-id uint u1)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SPGH1YBDP9VF3Q420MTDSTB6EHM5MDFG7VSEQR13)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmRnC9nkGY44dMsDPqWD1qzAcVTnrA5CQExg61YwznuBf9/json/")
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

(define-public (claim-two) (mint (list true true)))

(define-public (claim-three) (mint (list true true true)))

(define-public (claim-four) (mint (list true true true true)))

(define-public (claim-five) (mint (list true true true true true)))

(define-public (claim-six) (mint (list true true true true true true)))

(define-public (claim-seven) (mint (list true true true true true true true)))

(define-public (claim-eight) (mint (list true true true true true true true true)))

(define-public (claim-nine) (mint (list true true true true true true true true true)))

(define-public (claim-ten) (mint (list true true true true true true true true true true)))

(define-public (claim-fifteen) (mint (list true true true true true true true true true true true true true true true)))

(define-public (claim-twenty) (mint (list true true true true true true true true true true true true true true true true true true true true)))

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
      (unwrap! (nft-mint? bangers-on-the-boat-ep1 next-id tx-sender) next-id)
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
    (nft-burn? bangers-on-the-boat-ep1 token-id tx-sender)))

(define-private (is-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? bangers-on-the-boat-ep1 token-id) false)))

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
  (ok (nft-get-owner? bangers-on-the-boat-ep1 token-id)))

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
  (match (nft-transfer? bangers-on-the-boat-ep1 id sender recipient)
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
  (let ((owner (unwrap! (nft-get-owner? bangers-on-the-boat-ep1 id) false)))
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
  (let ((owner (unwrap! (nft-get-owner? bangers-on-the-boat-ep1 id) (err ERR-NOT-FOUND)))
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

(map-set mint-passes 'SP37T58KZ5M8WD7A94M8EREJ3V92KDXTCGC16B8JX u3)
(map-set mint-passes 'SP3P8M5J25457Q73MKS8EGD5Z19Z57RKYSPNEAK85 u7)
(map-set mint-passes 'SP3EN2WMVAP7SNVV1QJA0ZZ6TC3R0044FZXE8PQTX u1)
(map-set mint-passes 'SPEXRA92V0H67ETCVGCX89D3Q4YRCV40T3DB001S u1)
(map-set mint-passes 'SP3Y59KK9W7YQV1E9GEN2QXS8ND4E08QNS7AWMK9 u1)
(map-set mint-passes 'SP3Z7511VWR5WG9J3MAKER3NRZYKWT83K2XTP36EV u2)
(map-set mint-passes 'SP1XKR4A44BBRW9ZCXA6QEZ958K2WWQ67V67N004G u6)
(map-set mint-passes 'SPBNAM3RV2ZTXAYRV70PETHWSJ65NA319JXCQX08 u1)
(map-set mint-passes 'SP2Z2CBMGWB9MQZAF5Z8X56KS69XRV3SJF4WKJ7J9 u1)
(map-set mint-passes 'SP3S4WPQRPRH8T94EA1HQ2WZHEQRRKPDAFVFZH0DM u1)
(map-set mint-passes 'SPC2XQHNDWAKVSEGTR56HZJFSGTSSFD54EJBB9S6 u5)
(map-set mint-passes 'SP320MG4BDVAZM5K9MRW9GA0R6SZXNRK6WP0QWK9Y u6)
(map-set mint-passes 'SP37DWSRH9Y1C6R90VK6VF29S7SRQGDM8ANWA3NX5 u2)
(map-set mint-passes 'SPWC45P8JQP1VG9NDNPJ6ZXPVZ4XXGK06GXR5XN3 u1)
(map-set mint-passes 'SP3G9BMCJ0858Y68MM35R6HA0WAZDNYXWZBN4RYK1 u1)
(map-set mint-passes 'SP1QZT85MFT8HBAG3XEK7K6QY4GGP3MSG5C3H9PQ1 u1)
(map-set mint-passes 'SPHK8A7P61C6ASWKYDX1PCDX9YA54DKVJN49EXGJ u1)
(map-set mint-passes 'SPJFHQVQNGRWNX90FA49QQ5RGPR31YVVFB3EJ71D u4)
(map-set mint-passes 'SP1REM0ZMCFWY70CXAQMGYDMYCEC1SZKHVQ6ZR8JR u1)
(map-set mint-passes 'SP3R4NKXMGW6YXA44X2ESZPKJNV25X4ZN7DPW0RXR u1)
(map-set mint-passes 'SP3Z5H5KFMGBTYB37DYTGEA14VZG8AT32EPDEAKQH u1)
(map-set mint-passes 'SP3FH59N9EX7MMR7VNSE25WS49SGSB0AHF2X43K33 u1)
(map-set mint-passes 'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD u2)
(map-set mint-passes 'SP3VTWA4VHJXCC82898M21QSRQCYC730K49M5NMKF u1)
(map-set mint-passes 'SP26NGDM9HX4DXN0CHNM2FBMAY0NFE7F9D705YTE4 u1)
(map-set mint-passes 'SP22MNQZVGS9QSC54F6NZ9N3WZ9S6CTB3NBASBFSX u1)
(map-set mint-passes 'SP3ANCGBJ7E8MB64YHDSGARNPQC29P0FHQDZE1M0Q u5)
(map-set mint-passes 'SP2JTA1CCNPN66R24H20S67R48NKHMXAV4D80WGJT u1)
(map-set mint-passes 'SP7D5PN1QZ32CDZESPAZE9TA3Y6PV7HQEETSFVNT u1)
(map-set mint-passes 'SPS46Q8P75FGWDX11JNVER71R90VD5MV45XA5X1B u1)
(map-set mint-passes 'SP2KYP13520BR3CN0JAGRJGHEF0EATAVT4580WF3G u2)
(map-set mint-passes 'SP3JTDMCVTT7SNXM8F0M20SXMD83MC7TAH0E44C14 u3)
(map-set mint-passes 'SP2P7X0H5FAFBN5WDRQNKX4AS2ZCNQTFJ47BEDMNS u3)
(map-set mint-passes 'SP2TZK8ZY8Q77YQJF21WH42AQ6HTGTVK33AMNPEMP u1)
(map-set mint-passes 'SP37QD7QXANGPN7VPDZ4F8D6YVS681Z1XVYG1R1V8 u3)
(map-set mint-passes 'SP30K6XRJ99HF5WSF2QDTXS25V7ZGT6CNYMP63ZQP u5)
(map-set mint-passes 'SP2NHZDAMMEEASE4DKHYYCVAG8RF8PA7YHPPW40BX u1)
(map-set mint-passes 'SP3MMG05H6T48W5NJEEST0RR3FTPGKPM7C19X5M16 u1)
(map-set mint-passes 'SP3TZF64TY080GVMZRT4Z87E383Q8EAKZ5W67FCNY u2)
(map-set mint-passes 'SP27D2H2WEQS7AQS3C7CY9T4TK8JQEH9WD11PN6VZ u1)
(map-set mint-passes 'SP3RBMGTRD92F0S8DTDJ4FVP3D76SM4A27EV93106 u5)
(map-set mint-passes 'SPQ2HN9TYF8ZYY9D3G45NGYA9GHA6QZHQ8AXF5QM u5)
(map-set mint-passes 'SP09MMMCJDCD6WQ7VW0N4ZPV3SR0FTHN59H97DFP u1)
(map-set mint-passes 'SP3Q53T8T1PAYZH25MAWRJEH5YBAPK4PMJHRM2S9A u1)
(map-set mint-passes 'SP18WRH4SF7F1M5QZZ2BQDZZYBCJWT9VWQMDSTFY5 u1)
(map-set mint-passes 'SP3BSDRJMXBY7C73NF83T2RPBK3NBRGQMG7PBTJRA u1)
(map-set mint-passes 'SP27K1498HEGJSSVMFH64NTRJXSWEQN5H22S9TZ8M u5)
(map-set mint-passes 'SPAFJKGDVS11C9P9DY0ZTNFQ9774R568W9XYZDJV u5)
(map-set mint-passes 'SP2WJXBW24EFSHAJJGXNX4T7QQW9RK88W15GR7DKN u3)
(map-set mint-passes 'SP33M5BGDQD9WVV0MPDT8WCSM03J0WX3ABK5DEXZA u3)
(map-set mint-passes 'SPCBX0GCHMK9GP717F23ZP7V2NM2A0EJ8D634N44 u5)
(map-set mint-passes 'SP14VDDN583TB43F06NFV36YRAS0QWQC75QBDFBFR u1)
(map-set mint-passes 'SP2JQKHDV4N3FH86S52G4DH8HRG93DE1X39YHNSN u1)
(map-set mint-passes 'SP4QA0NHP03T3T9GJKR5KEA7VQ2KNSXRK5JC74NG u1)
(map-set mint-passes 'SP2H3TTG3MQK9CEF59S7VQ86H4FX9CH596ZXSE2EK u1)
(map-set mint-passes 'SP3BPYC4HJM0PJ8ZG9TDY053KE9K0KDARRN8WXAJ3 u2)
(map-set mint-passes 'SP3Y5WK0G9GMXS4YRNW9SSVEET0WFJM37X2SBEW99 u1)
(map-set mint-passes 'SP1TS6MC7DTJ538F6F4F6ZB2K376DT1GTTY552FCW u1)
(map-set mint-passes 'SP2HV9HYWZRAPTCC10VXCK72P3W4F9NDB8E1HBEZH u3)
(map-set mint-passes 'SP7MAP8XJCMRZ9901ETFA3EKVVPJ4X51AWQ2VG4F u1)
(map-set mint-passes 'SP1FPD5TJ6CPWMS0D1Q93S5ACBB6SQNF7DS4SGBHM u2)
(map-set mint-passes 'SPM2BGGS3EZVPSKFGWHGNE3QDJQNKMAKJSC1TFQF u4)
(map-set mint-passes 'SP2V16FKN22BJK1SG49S7AM51SNAQH9DXR2Z4BSQH u1)
(map-set mint-passes 'SP364J7EDJXRE1FPDZDABP9M58HPY4G88BFCP2HD0 u2)
(map-set mint-passes 'SP3SS41B35D60T0SNCR0NJCZX23MV50GF16F6T6NG u1)
(map-set mint-passes 'SP1XNJH1NZX90QV2VJE5QAPB7YAE3WHFY2NAH3JCC u1)
(map-set mint-passes 'SP3356JJ54Q0YB2Q7EN3ZPV7DAY8E2NAS9P8E2WZ0 u2)
(map-set mint-passes 'SPV48Q8E5WP4TCQ63E9TV6KF9R4HP01Z8WS3FBTG u1)
(map-set mint-passes 'SP1DAG3N4JSKF8NK10R7G3NBJQ7D7H3QG80TE0ZFP u1)
(map-set mint-passes 'SPE9CQ6VBE2DER8MG4DJVZ9123CZM0QSVGWXSKWD u1)
(map-set mint-passes 'SPHYYF20CF09CNMY1JN4Q6GPDRT5CECEFVX3JG7G u1)
(map-set mint-passes 'SP35MER4PHM6XGB99YDRQAK0M0JQ8F9CVF04VZ1VX u1)
(map-set mint-passes 'SPY1612ZD54TBX84CY78MHJFZ7H8MR4HZTW9HNP0 u4)
(map-set mint-passes 'SP377K719ABJWDFJZNTN2ZB2ZZ2G9MG8NZDQ83NG2 u2)
(map-set mint-passes 'SP1KC3BEGRFE9CNV1Q6G3H3TBAA36Q4TZGRS6J322 u1)
(map-set mint-passes 'SP6DAZJ3X7NCZC0B1JZ7W37PMWHPREVCSMQH995Y u5)
(map-set mint-passes 'SPQY88E87FNMP1NTY2YQ7X5DPTVY810PS8T6D2Y3 u2)
(map-set mint-passes 'SP1ATAR793F62BQDB427EDATEYBGGFQA8ABZ2FA4Y u1)
(map-set mint-passes 'SP3E6RFGYFMKJDKXT0RFW27C0WN2CEK0T0DWZYVA9 u5)
(map-set mint-passes 'SP3JNV4TE3Z14YBY4BFS7ZNNAEEP9ZRQTRZ8699A u5)
(map-set mint-passes 'SP1MKK6B8HMVYZCAD6KEV4BBNM3ER628ATA9ZPKZ4 u3)
(map-set mint-passes 'SP3ZY51K23M753B7S2CG823Y47EE80RC3ZMYJ78X u2)
(map-set mint-passes 'SP1ASRP257FF220G7ZMJ8A7V0E41DVPHKKXA74142 u1)
(map-set mint-passes 'SP36CAP9WSZMG642SP34ZMEJ8ZHD106ZWAF1ZX5M9 u1)
(map-set mint-passes 'SP3AQSW210PFW6K3FB1JW62ZHTH11FSVR0SH5AZ6P u1)
(map-set mint-passes 'SP329G766AV8Z01X9EEAHPDQ4WDJXT2A0XB383MGP u6)
(map-set mint-passes 'SPBB2EX5DA1NYAP4M2A2XS2BAQ5Y4VCZ89XDCPY7 u9)
(map-set mint-passes 'SPM1Q7YG18378H6W254YN8PABEVRPT38ZCY01SJD u20)
(map-set mint-passes 'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB u6)
(map-set mint-passes 'SP3TZ3BCB16A0W0PPFYMGTTWTT3DVWTQEP8DFRAG1 u6)
(map-set mint-passes 'SPFERFF3QKF0Q6WBC4Y2Y6RQWEGN3DTDD5Y7S0NY u5)
(map-set mint-passes 'SP1DPNP3RRD6JG1557SP6JMX68W5BV6R2Z74BQEXV u3)
(map-set mint-passes 'SP25RYXK6XNRTKNE8T7J4XRMB2D5DYAFY1546FBH6 u2)
(map-set mint-passes 'SP2NYMCHYXB8AMG1Z3SB12KHTSMDSQV3MBDPDNKNC u1)
