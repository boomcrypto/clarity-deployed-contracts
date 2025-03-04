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
 { borrower: 'SP3BEF3A0GDS3QGQ3YVQVK9ZCXWK9QWTMM79RTDQW, new-height: u267970 }
 { borrower: 'SP3D0SAFAZB9X2XE3XA74JGHJ8RTRFYQEQPGWEG04, new-height: u304370 }
 { borrower: 'SP3X6G145Z6DV5H49MN0P0RK9SXY83ZN4ACM3RPMA, new-height: u152864 }
 { borrower: 'SP2VG7S0R4Z8PYNYCAQ04HCBX1MH75VT11VXCWQ6G, new-height: u207662 }
 { borrower: 'SP1VM5898Q6M7AD0ASY99NB9VKCXKNDP93PKQ4T64, new-height: u156130 }
 { borrower: 'SPM923TSGVG4VZ8BJJSC6VS4PTWBT2KPG5FRNKHW, new-height: u333880 }
 { borrower: 'SPMZ912TEK2P15E8Q9W1W33QN793XR7XVDYY4R8H, new-height: u200688 }
 { borrower: 'SP1HRWQ1NB3QP80AWCSNFP7HV7MC9T0D85MTFXJRW, new-height: u344351 }
 { borrower: 'SP2KP96PS0P584GVKA1HC5RP385DK53ZYC50B00K0, new-height: u244718 }
 { borrower: 'SPJH144XQV4YAJJTD5FMWN97N46F6PVP6B4R1KPE, new-height: u168759 }
 { borrower: 'SP1BQZ7QBWMRCYYFB51F5SGH2NJJ33R3BJQA71AQ0, new-height: u167436 }
 { borrower: 'SP15GQSH3J0YVXMJFPE633XXC8XY5R0NSYY95CY3H, new-height: u156228 }
 { borrower: 'SPFJBA3PWNM7ED1M3RJSX5DYCAXW94Y0FQ72X096, new-height: u156073 }
 { borrower: 'SPSG8C4JFTZ6YSAJX7WPTCY5N0WPGGPX166PSPZT, new-height: u169003 }
 { borrower: 'SP18NFAVW5MFHM3EWYQ2C5VMJKT2XX7GKN5KQZ0QC, new-height: u221594 }
 { borrower: 'SP30RK02S4MV7B6KEXCNYKXKBF8T3B1S5G20ZSV2K, new-height: u155984 }
 { borrower: 'SPK7H00T21T5E5GP7MWDP3WYXASV3YP48HMEQH2D, new-height: u189701 }
 { borrower: 'SPY9Q896GJ209XKATBPBZWXB90BF369DD2CM7R41, new-height: u155905 }
 { borrower: 'SP1EWKJHKSAHT6HZPJTZRZ1YEJ5W1QH662E926NVB, new-height: u342662 }
 { borrower: 'SP1P3HD8Z6F8EBFP4CGN2MFP0V3JGN5A31NT3GDHQ, new-height: u253469 }
 { borrower: 'SP2Z4N1YCW45176FA0XF5TXHT0KKDQ8EXWWZVBZNB, new-height: u167212 }
 { borrower: 'SP8FJY9QA7478VB123KAZPC8C272HDH2FF3MNMMB, new-height: u251744 }
 { borrower: 'SP1ZJW1V01F36YRTFY4NQA8E497VK1YB89VM5Z7FX, new-height: u205361 }
 { borrower: 'SP6P4SYXEPH76C7PANGTKY4K157E8W4BF3Q5VS38, new-height: u343131 }
 { borrower: 'SP11Z7945VRSJ7D5HE0QGRCR3KXQ8RNE41AZS1WB6, new-height: u166457 }
 { borrower: 'SP3ZS78YTT8N5NJQPX7M50K1R57W764MX5T47S0XY, new-height: u154176 }
 { borrower: 'SP3P1TCXN3FP3V79YWXC49F5X2HYKS39CMCP5FEHN, new-height: u166707 }
 { borrower: 'SP3YHVAR9CP9QD2D2HNJ5RH7NT5GXE2X4GXNX4YPX, new-height: u171726 }
 { borrower: 'SP3KVQ9CP8N80VPFY8CKNKWWHFQQNMMN58BARKFQ6, new-height: u166190 }
 { borrower: 'SP2HMHC2JNXJ9363MDE1G2S4CTJSMDCXG4AG50VQX, new-height: u166518 }
 { borrower: 'SP1B3VEMWMC1BMSCWKZKPPVHQD8TJ8QQD93ZFP0VN, new-height: u153936 }
 { borrower: 'SP7TEF3PAXCQHZF4N5PT68GWQ5PGWR6VDNWQ5CYK, new-height: u261505 }
 { borrower: 'SP2JTTG6NWJ3V4CFVPY0Q62Z0VSMSGVD9RT0VX9AH, new-height: u207493 }
 { borrower: 'SP1S538TKS1HVKKA111X54FCR9DV7YGD069EDTF1F, new-height: u165595 }
 { borrower: 'SP2EZBRH2T5A4TPFFTDK48CHR0WG95YZZA4HC1TJE, new-height: u165651 }
 { borrower: 'SP34D1D5P3TAYDGMD1W78849ATDQHGHKARR5YCHE6, new-height: u157876 }
 { borrower: 'SP2YE97WPR9C184MQ4RVM6AP1J629750Z1N48N82S, new-height: u153788 }
 { borrower: 'SP1Z80QY12ZHKVV59KR72SJ6ZPJA2833VKW53JHD5, new-height: u269945 }
 { borrower: 'SP3ATFW5VSD0W4N0E3K1E4CGFE8MJXQ9XFFMQ0HBY, new-height: u345385 }
 { borrower: 'SP1QF33CQESD5K623HDG9CW19SBDRTW17N13WGXVR, new-height: u161225 }
 { borrower: 'SP2ZGVSV6JDJ6SCGJETE3ZT0PNRSB90FM01P830D4, new-height: u165052 }
 { borrower: 'SP1J5WHWNNEYH5NE9DS4W0RHZBP4XTKHSX79YC18K, new-height: u268099 }
 { borrower: 'SP1TB1TCQE6VRCC4R05EPJN79Y0NMTRDAPAPF4MSN, new-height: u156734 }
))

(define-public (set-borrowers-block-height)
  (begin
    ;; TODO: remove
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-borrower-block-height)) (err u10))
    ;; enabled access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

    ;; set to last updated block height of the v2 version for borrowers
    ;; only addr-2 is a borrower in this case
    (try! (fold check-err (map set-diko-user-burn-block-height-lambda borrowers) (ok true)))

    ;; disable access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

    (var-set executed-borrower-block-height true)
    (ok true)
  )
)

(define-private (set-diko-user-burn-block-height-lambda (diko-borrower (tuple (borrower principal) (new-height uint))))
  (set-user-burn-block-height-to-stacks-block-height
    (get borrower diko-borrower)
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
    (get new-height diko-borrower))
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