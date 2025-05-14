---
title: "Trait usdh-part-1"
draft: true
---
```
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
 { borrower: 'SP3PVW0VNNFPBTT76MPJHC4AM175EZ0XBFAAPBQ1Y, new-height: u328841 }
 { borrower: 'SP1M2KTKG2HK0ZAKVYTEN9DF7Q00KC5YMDWK263CK, new-height: u281506 }
 { borrower: 'SPF8BVSF0C786B5EGZP94NF6Z3DC22X446FWTHGS, new-height: u269945 }
 { borrower: 'SP31RM6SWEJ787WADZPHGWNP7XMH463HCX4CYX96A, new-height: u320492 }
 { borrower: 'SP2HY3ZNRF1ZA202KQKW7C59M24QR0NZ2NXWSBBP3, new-height: u287529 }
 { borrower: 'SP14AATYGAPMK2Z5R5R1FAMT87HWQFHNMFFM5D1ZF, new-height: u255193 }
 { borrower: 'SP34T0DS0ECN32J0JK891YP6JQ8VZDHJ98MPR74GX, new-height: u300352 }
 { borrower: 'SP1S538TKS1HVKKA111X54FCR9DV7YGD069EDTF1F, new-height: u247826 }
 { borrower: 'SP31YB1E2VCAGW2DKGGNH82ZEYCF7V3P7CZ61N89P, new-height: u241104 }
 { borrower: 'SP2SNQHT55ZM0TBF7DD0TA39XM652QZ97E3CXN2SJ, new-height: u262859 }
 { borrower: 'SP3EEY64DVR8HWWNQJHBK37DT1HSC6X4P6ENG4HDE, new-height: u336629 }
 { borrower: 'SP281DHYZ11K3B0BQHPWBBH5SRB457270073RVVES, new-height: u287598 }
 { borrower: 'SP218TBV9HWW8QQRARHQ6XK7G10271SQTTCCTHW20, new-height: u278350 }
 { borrower: 'SP265MKD6DWYXTMZZ41DEFQ5M2HWJSQ52V26WFWRF, new-height: u274301 }
 { borrower: 'SP3KBQKWQXAH2S86EZZ48TDQM1WTSK7PNV5JMZDA, new-height: u274410 }
 { borrower: 'SP284MQ5HZJ22NQRWVMT2MB9YXCF7S1DDZRDPXB7Z, new-height: u328224 }
 { borrower: 'SP3DGSR08ZWWPKKXXFJ91SC2JQ0HZZ1JC927DM58Q, new-height: u263824 }
 { borrower: 'SP37E46M4GR5X7A1KGE3B3V7TCVWBJCZCGQH0PS40, new-height: u282012 }
 { borrower: 'SP1D49J1N5ZRR1HHKY0TZ7GPAYWTHTMS9HKDBESQ7, new-height: u305148 }
 { borrower: 'SPXYZ93BG3ACW8MMF85JXJY9WNRWHKY9ZAJ3EY2K, new-height: u336127 }
 { borrower: 'SP49PX512DWJ0JG3D3WJ016Y4R6WJA17QANBQ4BW, new-height: u263015 }
 { borrower: 'SP1M71JK52GZSZSTXT9FSGB2FHY8630WD756VV97D, new-height: u276314 }
 { borrower: 'SP94YN79D00S42WDQT6WG0DH4JVYCSR060ERAQZ2, new-height: u346211 }
 { borrower: 'SP30Z4TB1Z40VQV6XCN20KXCM4SQNNBHGHDC8QYTK, new-height: u310256 }
 { borrower: 'SP1ZFYA52KJP45K8PEW75RC47D26ZRFNSZQRV7A4W, new-height: u325985 }
 { borrower: 'SP3GJG93GXXS7ACMANB4N0QDVE5FB5PCW6J8ZZGZS, new-height: u269961 }
 { borrower: 'SP32ZYEZGWHHFQ5RX2WMFVDXR77C5WWQP4EK7E6HC, new-height: u239349 }
 { borrower: 'SP1JBBGYFQ7M19C2C8N08HGP3M57NZYE3QZKKT79K, new-height: u289681 }
 { borrower: 'SP29JDBZVBA1NVN40R4RZJ2H4CXZJ75B51FJ7DXAP, new-height: u300992 }
 { borrower: 'SPV9TZ0MPMHQM4QYY484E1ACF88N8FG3D5M8PC64, new-height: u263208 }
 { borrower: 'SP15P56F24FAY09RVRM98J0NDCW2P3JTDWWK8RQ1J, new-height: u242825 }
 { borrower: 'SP27K5VXGG9512F3Z1JCE5NS4NDC72KAAZD929ABS, new-height: u326069 }
 { borrower: 'SP1843KM1SPSMM8MHE4YFDFKFNKC8FFK8BTM47W1X, new-height: u278338 }
 { borrower: 'SP1YMCJTJA48FT8NK21QYMAT3E9QW1BQECXRJ9H4E, new-height: u266461 }
 { borrower: 'SP1RP1T219NCCH0MPHMXX24JCCEMHARA4HVTH30Q9, new-height: u249605 }
 { borrower: 'SP2FND3FF6W7J2115GXVS4M71H5JR8469E4DJYRHK, new-height: u300482 }
 { borrower: 'SP17951KHZ2D8Z8QYFD3YKRHNZTPVPHQ4061EX42J, new-height: u250460 }
 { borrower: 'SP1MKKX1CDRYNRGSA1E1BE4C2Q63FK27K5ZWMATYE, new-height: u239187 }
 { borrower: 'SP12ZRK139NWG5AWXXRXT7A1MHAANDDGDZ4H37RYG, new-height: u325544 }
 { borrower: 'SP3502BW2YK4AJ8RQAJXS386VREVQR9ZM69X80PJV, new-height: u270018 }
 { borrower: 'SPW8JW1GERWDCY8XXEKW1TC939547DCMW1M2XENK, new-height: u251598 }
 { borrower: 'SP1A4S4WTWKPYWZQ946BG4893J6JP0N2GX7NT1QCY, new-height: u277552 }
 { borrower: 'SP376Y7METTJAT372GYDGD225YE20A01GAV7KJFKN, new-height: u346357 }
 { borrower: 'SP3WJQK5J161R89ZQ3XVC3FRGTNFADGXTDZEPTPSH, new-height: u270037 }
 { borrower: 'SPDH4MRBTPA7TY969XX57HB0EZJSGTTHP5ZBTAPH, new-height: u255392 }
 { borrower: 'SP320J503KBVP6J4QSSC4Y83VTWX1K7KKY04QBHVB, new-height: u263831 }
 { borrower: 'SP3PKRBPR9JVA3C4DB1X6AB8BPWWMZFK158GC7RA1, new-height: u248913 }
 { borrower: 'SP3XTYYV9133Z7RNWEDEP04Z6FZ0E9WVKV9D65XQM, new-height: u327400 }
 { borrower: 'SP2KP0K1AYV2T39Q2FKJFVQG9ZMG90DPQ7JRMH3BG, new-height: u263824 }
 { borrower: 'SP11Q6XVWW91NQG0G1KZGFRVATZPZK2N78VNV52ZQ, new-height: u311560 }
 { borrower: 'SP2DRR2KC0NYS16BCSKQ41YD9P02ZVDKPHCN3RY0E, new-height: u266461 }
 { borrower: 'SP1KWR3XZFQCMGXYDHNSTPPXFHRK6N0QPTQMEXEM8, new-height: u327347 }
 { borrower: 'SP1XSM7TXGZ5JGY1DF4R6NPWSH1XKQCVZ1XARH0KA, new-height: u311514 }
 { borrower: 'SPDVSGNH3DPYFWCKEB9E2RYGC3ZSNY3YYV0MNBSP, new-height: u327347 }
 { borrower: 'SP3G9YA8J5WRE4H402C9DWS970V2H8801P7SGSXGJ, new-height: u266351 }
 { borrower: 'SP25DP4A9QDM42KC40EXTYQPMQCT1P0R5243GWEGS, new-height: u290140 }
 { borrower: 'SP19ECAYACEGGD56T9CFNGRQJC32F8P1H50EATCHX, new-height: u336629 }
 { borrower: 'SP38F139KNGWV4GNPJYGRFHM0MG4NKEJ97T7ZTT41, new-height: u345728 }
 { borrower: 'SP1HXT635AVD4MWFGNYEC79YG4TXS5QJE9NTB3T2A, new-height: u294822 }
 { borrower: 'SP29JJVSD8BEVGZWH5TS0RYHZH4Q2DSAZNXPEGGFZ, new-height: u239159 }
 { borrower: 'SP385CENFX0R0E7D5S6QSJ90PDBN50HANR6K9K4X7, new-height: u310305 }
 { borrower: 'SP1BQZ7QBWMRCYYFB51F5SGH2NJJ33R3BJQA71AQ0, new-height: u243567 }
 { borrower: 'SP2WMYDF3S39FWDSJ72CAJ9PZRYTW1PKTC0WN5QAP, new-height: u301016 }
 { borrower: 'SP375EMBBESRAHKNP9FEWMSS6DYCGB2QZVSG8VZ3J, new-height: u287187 }
 { borrower: 'SP1ZCA2YV8TGX1NCJ8K04P5WJSGJVM1XD44APZD9Q, new-height: u289681 }
 { borrower: 'SP2Y89Z3WBCDCXS1VR0NY9W5BX4AQVAB9S4BFEB02, new-height: u314063 }
 { borrower: 'SP3X6G145Z6DV5H49MN0P0RK9SXY83ZN4ACM3RPMA, new-height: u238243 }
 { borrower: 'SP2V2B7EMRA7VYF6NJHGZFK406B6R3WDC9FRAWBXV, new-height: u263765 }
 { borrower: 'SP1CW0XDACDGQQWTT751T6JFJ01JNMZJQEPRN92Y2, new-height: u301016 }
 { borrower: 'SP142CABNW8MASXP6MXTSVJJ0Y7QGD07A76XBTV84, new-height: u271354 }
 { borrower: 'SP3RRGMNH6NVP2NNKTN9QQBVXWZJ2H9XDP6Y38GMG, new-height: u276029 }
 { borrower: 'SP1MDNST2SFPEN3E6JK0FV4A10ADFXPJ3RHBX5GNR, new-height: u326345 }
 { borrower: 'SP17BR51JTVDXM97TTWA8AESRSASBWSASN7T47NA, new-height: u301059 }
 { borrower: 'SP3RNM0MHCE5HG54CKBBWT8RSK778PB315GZJV9CF, new-height: u266351 }
 { borrower: 'SP3DW2YR31HWKR70630ZPFM88F1Y5M490AX13QC19, new-height: u292924 }
 { borrower: 'SP2RKXEZ7DV9N9V4FW4X0REXKRH0N6AZV2E7ARSGH, new-height: u315303 }
 { borrower: 'SP247C4SSWAP2BCV7A6W25J29K9FKHSBZKPHKZ68D, new-height: u315303 }
 { borrower: 'SP2Z0FJD75VCER4FGSEJP2TK6FX44A9RK43X4GF4N, new-height: u266444 }
 { borrower: 'SP3REXZ9NQQ84R2SJ0D26CJ6RDBQ383W8QM5MC2R4, new-height: u304370 }
 { borrower: 'SP28AC8VQ45F8V3NQK2RWT9ACQ7Q8Q4FFNYQDQB4B, new-height: u317213 }
 { borrower: 'SP3TZEC9PYDZ3Y2F5RMNGFS24D1CDPW6EW8QK6616, new-height: u317562 }
 { borrower: 'SP1AF7TH2DDN2XCFFEVXKF15VVYW2X68CDQW3G4MK, new-height: u274301 }
 { borrower: 'SP1T07GK9H4M0WP4N1DSSA7NJ7GNTQZ0GBZM0GAR2, new-height: u293535 }
 { borrower: 'SP3T8XVBX10T72WB2E41ZTS5NCY85WC6YMWR2QA6K, new-height: u296700 }
 { borrower: 'SP2GGHY9C697PSVBNX1TSFDJCH003DZBTCFTCF9ZY, new-height: u294548 }
 { borrower: 'SP3SSTB4J0FTBJ4VP9QV47NKDRVYBYT0TZT4G16ZH, new-height: u269961 }
 { borrower: 'SPT6A1ZY975ZD0TW5SP128WQWTQNVM4ZC856KZQ2, new-height: u298011 }
 { borrower: 'SPVA7N3ZZ2NC57QY9QTKXRBG44H6FFJ6XRXNHBPN, new-height: u270018 }
 { borrower: 'SP2D21TSA9RB2TXT67E2A0K76JVG1NBEWC93FZE8Q, new-height: u345295 }
))

(define-public (set-borrowers-block-height)
  (begin
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-borrower-block-height)) (err u10))
    ;; enabled access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

    ;; set to last updated block height of the v2 version for borrowers
    ;; only addr-2 is a borrower in this case
    (try! (fold check-err (map set-usdh-user-burn-block-height-lambda borrowers) (ok true)))

    ;; disable access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

    (var-set executed-borrower-block-height true)
    (ok true)
  )
)

(define-private (set-usdh-user-burn-block-height-lambda (usdh-borrower (tuple (borrower principal) (new-height uint))))
  (set-user-burn-block-height-to-stacks-block-height
    (get borrower usdh-borrower)
    'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
    (get new-height usdh-borrower))
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
```
