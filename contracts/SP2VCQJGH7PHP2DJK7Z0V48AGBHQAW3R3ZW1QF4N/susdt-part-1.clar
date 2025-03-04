;; Used to simulate mainnet migration from v1 to v2 in the test suite
;; Must be called after deploying migrate-v0-v1.clar

(define-data-var executed bool false)
(define-data-var executed-burn-mint bool false)
(define-data-var executed-reserve-data-update bool false)
(define-data-var executed-borrower-block-height bool false)

(define-data-var enabled bool true)
(define-constant deployer tx-sender)

;; TODO: to fetch off-chain
(define-constant borrowers (list
 { borrower: 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B, new-height: u320986 }
 { borrower: 'SP2BYPKKSVF01Z4QBW6XY47FBHKEB8RM78PTX5RHT, new-height: u340696 }
 { borrower: 'SP17WH9WXDENGR4EXFVZNDE9RW2M19H5C8SQAMTG3, new-height: u338898 }
 { borrower: 'SPK40QN3YCT0CHT2DFC17W7NG54FPYCHGN41ACQV, new-height: u301910 }
 { borrower: 'SP301ZT9SW5Z1BQ4D020YWJZSWG7BR8W207917RQF, new-height: u308494 }
 { borrower: 'SP35B8D78SWFDFFRMXB3X015EDEM0YFARXY585N8E, new-height: u293208 }
 { borrower: 'SP37JBHFY0G094PPZKZHBTRG31JDGY3TZK041CACK, new-height: u294214 }
 { borrower: 'SP37JBA3QSWYHR7HJMSKMJYV7ZYRKY0SGWXDT1E0W, new-height: u319768 }
 { borrower: 'SP3X6G145Z6DV5H49MN0P0RK9SXY83ZN4ACM3RPMA, new-height: u263492 }
 { borrower: 'SP12ZRK139NWG5AWXXRXT7A1MHAANDDGDZ4H37RYG, new-height: u325544 }
 { borrower: 'SP25SF2MPZZS8Q20QA3VTYJXTHAHCRNM5MSZYDNB0, new-height: u336081 }
 { borrower: 'SP1M2KTKG2HK0ZAKVYTEN9DF7Q00KC5YMDWK263CK, new-height: u287348 }
 { borrower: 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT, new-height: u340214 }
 { borrower: 'SPYRK8D45R4CDB3K5YWP907NC0P4HC8GQKF6EJ9S, new-height: u337197 }
 { borrower: 'SP2BENRVZR0TJVXGV3X3XMK9V7C0TJFGSN8SYB6DP, new-height: u292562 }
 { borrower: 'SP38F139KNGWV4GNPJYGRFHM0MG4NKEJ97T7ZTT41, new-height: u327523 }
 { borrower: 'SP9XKFETDDVXCACG4501SDWGV3R8AEDRMKZNHP4Y, new-height: u343387 }
 { borrower: 'SP29JDBZVBA1NVN40R4RZJ2H4CXZJ75B51FJ7DXAP, new-height: u297067 }
 { borrower: 'SP1AF7TH2DDN2XCFFEVXKF15VVYW2X68CDQW3G4MK, new-height: u300467 }
 { borrower: 'SP3N0FHDQSHB9NQ37SJJ882BR4WSDQAXBASA3EDYB, new-height: u328286 }
 { borrower: 'SP3A7WGTT3G279RR90S6G9F4FNR0H9EX770VQF0GG, new-height: u301170 }
 { borrower: 'SP35MJ7PS69WE0BX1QFE2QS4VNFS2W32N8AEWHZPP, new-height: u306343 }
 { borrower: 'SP2WHHNS0QFZKE4J2V0PMJ9X4GHKXA6NTCMXX36AF, new-height: u295332 }
 { borrower: 'SPQ7KBBP7MPVBGBDFBW17X4C07JPEZGPSX4XZMKK, new-height: u292616 }
 { borrower: 'SP17TK3BKFPQADD4Q1CTWSR5GC7GVFY7VE76NJTW5, new-height: u311512 }
 { borrower: 'SP3XBCE7R73W9TPWSM3B1NYKHYY9P5K81HE0TWPRP, new-height: u296293 }
 { borrower: 'SP1EW1NDQG9G73R7TZGJXMRK6E7VERVHRG7HPN5VX, new-height: u296973 }
 { borrower: 'SP1ZQYG5H5SPF4Z49RAZDKMFSGKK7ACTYNY3QM70C, new-height: u301956 }
 { borrower: 'SPNY7WD51NKPXJR25G0Y80QN7ZPY4CDR6TAP0VB7, new-height: u291867 }
 { borrower: 'SP1ZN3QYDX9J8F1V8HDBB16WZ9EVG762XRPED0HMD, new-height: u301956 }
 { borrower: 'SP3TTZVGZ4HNTYSDSRGN1GXK7RWSWYJ9FXFWJ2BCZ, new-height: u330097 }
 { borrower: 'SP265MKD6DWYXTMZZ41DEFQ5M2HWJSQ52V26WFWRF, new-height: u300467 }
 { borrower: 'SPWV51E9AJFX130258AN5630F5JGH0SW8664H4HW, new-height: u301956 }
 { borrower: 'SP10ECZKBTMVGV9Z41A9QQP80TQFZK2QRSV5BWNMX, new-height: u310132 }
 { borrower: 'SP2925X9ZAQJ8BCZDJXD591YVR65JCQAM18SHKCPB, new-height: u301956 }
 { borrower: 'SP25DP4A9QDM42KC40EXTYQPMQCT1P0R5243GWEGS, new-height: u321409 }
 { borrower: 'SP1BQZ7QBWMRCYYFB51F5SGH2NJJ33R3BJQA71AQ0, new-height: u263492 }
 { borrower: 'SPGTK5GDQH0BCGZ5A39K34P7WZ5GY4TGNGH1RPPZ, new-height: u292893 }
 { borrower: 'SP2RN4MYP5WKP8WC2262YBXZ0D0Z9XX38B5DA13BK, new-height: u291647 }
 { borrower: 'SP2HXFYD2BHNEVPX01SKK26N45GBKJ5E3X72G1XEG, new-height: u286177 }
 { borrower: 'SPARHENQD3QXG6VTHPNQBXSA72508JZZA4NW7VNG, new-height: u315826 }
 { borrower: 'SP3JNACGEX37WW3GJM4SHZMZ04QMDRVHY63DC58HQ, new-height: u301956 }
 { borrower: 'SPQSZC1X38TTDT6VQ0K3Q0YZ419KWNYM2A76R2PC, new-height: u295627 }
 { borrower: 'SP73813P0X4ER4KTWQX796NC9T500P092KJNDYDN, new-height: u301956 }
 { borrower: 'SP2JF9JVQ6AYYG3VDYYSM7B87DZTK2QAX783H3T5R, new-height: u293348 }
 { borrower: 'SP37E46M4GR5X7A1KGE3B3V7TCVWBJCZCGQH0PS40, new-height: u294822 }
 { borrower: 'SP1JES6BF7VN9840VTXGT5MB36SY0PAE3KP7FQNTZ, new-height: u301971 }
 { borrower: 'SP3SJSJPN28AAZMW27YKY4CMT9J6PVXHTXCMBZ1FZ, new-height: u292766 }
 { borrower: 'SP2M7K3YM8813404G1R7AXV106CPWH0Z5ZA80JVAV, new-height: u294347 }
 { borrower: 'SP1WT0MNXRA8Z0TEE7FS4Y836HQ62WR0ZPXG31T51, new-height: u301910 }
 { borrower: 'SP3CC9SYWR9AWNF5QAW8S9SXNYRKA71M3PM27HFAG, new-height: u287348 }
 { borrower: 'SP2HY3ZNRF1ZA202KQKW7C59M24QR0NZ2NXWSBBP3, new-height: u312605 }
 { borrower: 'SP2WHGX98J57PV22RG15VSYGYQQJCDWCS4NDCRZS4, new-height: u293208 }
 { borrower: 'SP18A6PSVMYTC9REXF5MED259S5Y9TRHHD8Z7Y69N, new-height: u301956 }
 { borrower: 'SPMYZC3EQYQ73RJFZKYBF7D76BNWEVR7TCH7XDBD, new-height: u301971 }
 { borrower: 'SP3JW7CH7K8B03P1G4YKZABRJ5KK1CN6DVMQYW0F7, new-height: u286722 }
 { borrower: 'SP3ZW40EN0XN0JVEKJ20656MSDV1JB4Z80DG6FEK3, new-height: u312226 }
 { borrower: 'SP22AG163Q337WVNQ3KYY3DNKEA7C4Z1WWH22DNQ5, new-height: u332381 }
 { borrower: 'SP2EM5T1YJNVDRKXC4M7J1EJV9NTN84K9PN1ZS8GE, new-height: u312653 }
 { borrower: 'SP7J42390QDA490H886K0WZ9CDE28XGN06MH2CEC, new-height: u301350 }
 { borrower: 'SP1545TQCSD9VVGMCTVMV5RAVKMS8S7PPDJSEV3ST, new-height: u330956 }
 { borrower: 'SP7DMXKBSM8K3CJJJJNPTE3MNACK1WJ2PF1Y7Y29, new-height: u286583 }
 { borrower: 'SP37X5NF39N68F48THEJ8FFB6HQ0KF988ADQFGXH5, new-height: u300327 }
 { borrower: 'SP2N7VSJ2DT9NY438G3VDWYFP3WWBKYN46GQPHH6T, new-height: u308923 }
 { borrower: 'SP6DY71RQE3104DJKRYRD4MPKX62AQ6KG6K5XCCN, new-height: u295999 }
 { borrower: 'SP17TK9D2MWWSE1GWD3Q8SFT5AMT8TTDGQHZ023M6, new-height: u292562 }
 { borrower: 'SP3DCXSAP7P1HAAK36MRJGJGDJHMGVR24P2MGWEHJ, new-height: u296061 }
 { borrower: 'SP3BJB60HT48Y0T9R93H2AWN62GWP8XTYFTETYRA5, new-height: u296408 }
 { borrower: 'SP1M0YRYGQDD433YFWMD1EBFQH4067B5WDSVZGZDG, new-height: u307549 }
 { borrower: 'SPXMZGWZS4XPGWFX1WC0M4WH8B7HMXP5E5VZFRYX, new-height: u296422 }
 { borrower: 'SP1A4S4WTWKPYWZQ946BG4893J6JP0N2GX7NT1QCY, new-height: u295769 }
 { borrower: 'SP143S7QJWE14EYGVTC99HGYEMG70YVG1RT81KA1A, new-height: u302749 }
))

(define-public (set-borrowers-block-height)
  (begin
    ;; TODO: remove 
    (asserts! false (err u1))
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-borrower-block-height)) (err u10))
    ;; enabled access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

    ;; set to last updated block height of the v2 version for borrowers
    ;; only addr-2 is a borrower in this case
    (try! (fold check-err (map set-susdt-user-burn-block-height-lambda borrowers) (ok true)))

    ;; disable access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

    (var-set executed-borrower-block-height true)
    (ok true)
  )
)

(define-private (set-susdt-user-burn-block-height-lambda (susdt-borrower (tuple (borrower principal) (new-height uint))))
  (set-user-burn-block-height-to-stacks-block-height
    (get borrower susdt-borrower)
    'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
    (get new-height susdt-borrower))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (set-user-burn-block-height-to-stacks-block-height
  (account principal)
  (asset principal)
  (new-stacks-block-height uint))
  (begin
    (try!
      (contract-call? .pool-reserve-data set-user-reserve-data
        account
        asset
          (merge
            (unwrap-panic (contract-call? .pool-reserve-data get-user-reserve-data-read account asset))
            { last-updated-block: new-stacks-block-height })))
    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)

(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set enabled false))
  )
)

;; (run-update)
;; (burn-mint-zststx)