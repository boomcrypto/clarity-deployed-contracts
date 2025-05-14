---
title: "Trait ststx-part-4"
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
 { borrower: 'SP216CCD1CXGSGVXEZ073A6M8MCACT8QQ33XH5QV5, new-height: u157010 }
 { borrower: 'SP2C6BAJFCZAQTE9JVTNHKERP9E85HG65DPTXHH08, new-height: u157008 }
 { borrower: 'SP18T0NVN9ASCGTHJNHP41NG82NE50ACQ8AEV6HX9, new-height: u157008 }
 { borrower: 'SP1S1SEYS6YP2DSH0RT0WXJBC8KR3KN0SWPB2CDFE, new-height: u157013 }
 { borrower: 'SPFEXFX4SAQTG8SAC3C09CR8T00AZB45Q01KG6Y8, new-height: u167225 }
 { borrower: 'SP26RCCH463CWPHP7X839DTM51RZ8T134CYBMMD2P, new-height: u157010 }
 { borrower: 'SP15BWFCTJPKJXQ25MSCDTXHXJSZVK6WKFK1RM8KG, new-height: u157581 }
 { borrower: 'SP5TX47XA0FPHJ3GP3QM1G1PXT2NYYP9R0A8NBF6, new-height: u157013 }
 { borrower: 'SPP7SF3VCAS55KRRSA6X1NGQ76VNAAFKQ0NEK5K, new-height: u158659 }
 { borrower: 'SPD7THD7GS835R02RMZPDWJ3HE6JG1CM95CEJVF3, new-height: u157026 }
 { borrower: 'SP2DH8EWYV1AD95YKNNE4QTY1VWPN9FET8Q6YAR0H, new-height: u157027 }
 { borrower: 'SP15ET57VBMPY2F9K6CBDMCC3V8FJSV58VZMZJ4ZZ, new-height: u157647 }
 { borrower: 'SPSFH3JG92JZRXNEJWBHZM0AS0ER6TJJA22QBXS6, new-height: u157028 }
 { borrower: 'SP3K6VMHJKSYH0JD181DHMR2VH7VAAPGBY7K14J3J, new-height: u157581 }
 { borrower: 'SP9ES981MBE9RJPTFWWYBBYTESCR3K3V9J1742XX, new-height: u157010 }
 { borrower: 'SP1FB3G0V2S78SMQ11M1AWK3JXXAYP2FRG1N54634, new-height: u157027 }
 { borrower: 'SP3766V2QFS9MTZGGKVTPWST3J3NMFZQ9HVTV9N34, new-height: u156984 }
 { borrower: 'SP1K345SABJ2PKYYXC2261QGGQ7W2TJX7BBY1SN7Z, new-height: u157195 }
 { borrower: 'SP2G5BMW0H0YZNNWZDECJREPA19G8K06BW1KRT94K, new-height: u157028 }
 { borrower: 'SP2X4FEGSRJ8PJ09DYGVVMTGQK9H6CSKQZGNXJQE1, new-height: u157010 }
 { borrower: 'SP2E78TGFKW96CMBWQVK118AJYD9SC7DH1E0PVCV0, new-height: u161843 }
 { borrower: 'SP2D4BNFPXSBN2D0R8QS2QRQED9TTZVVS8EBA7RPG, new-height: u157028 }
 { borrower: 'SP12JWWTT9Z26JBXCMBBNW0WT1NB5Y2CE5N6HYGTX, new-height: u158432 }
 { borrower: 'SP1VE2C3RH2NAEM7CSBET6AZB8BMQ6P2JEV7S34V9, new-height: u157010 }
 { borrower: 'SP310VPG5A9YN3PS7NTSAEBEPX3E8H0HE8MACVTKZ, new-height: u166670 }
 { borrower: 'SP1342DAV9ANVMQMF5GWYQYJD6GXPT5EENP29CV1V, new-height: u157577 }
 { borrower: 'SPD1KY2V76R8PKA0HMHHCCDE51KDQXJV0VM98V1R, new-height: u157008 }
 { borrower: 'SP1XC8PH6FK8MJ8S0M24WGWVAPPE4Z7YYZ66FEW7C, new-height: u157010 }
 { borrower: 'SPPMVWYJHZX5ADZSA7GMAAPGE3V07JEE5KZSFP4D, new-height: u156857 }
 { borrower: 'SP224G21ZK17WA7D2VZC17JPWQ1PWEDPB418HM127, new-height: u156547 }
 { borrower: 'SP35C795MDF8ZNNG120AXPR3TZSETBJ84160415M5, new-height: u302881 }
 { borrower: 'SP1A9NJCYPQ8B0B8Q1ETG55T8YYG7X3S5EBEHZXMS, new-height: u158673 }
 { borrower: 'SPA5TQXK1FEEV8SA0S6G2PPZCWKDQQCSRG0N5BM4, new-height: u157185 }
 { borrower: 'SP23FHX061WDTW4K4BN1A07WA041S1M7B6CEAJFJQ, new-height: u156336 }
 { borrower: 'SP331F8SSP31M3AZQSB850XW5AGYRFJYFZTACXA1W, new-height: u156641 }
 { borrower: 'SP3JHZQ54Y1KMHZ1RQRG1B6SW47ZCNEM5NXZTNH9Z, new-height: u157578 }
 { borrower: 'SP3KZYTDJDYSXKRZHX4397FMK6B3BQ9WDJ4HYKTKW, new-height: u156377 }
 { borrower: 'SPHAE39Y1VX5QD2RFGYJG824WCE7MXNF7DPK2B8A, new-height: u156729 }
 { borrower: 'SP6KDDXGXQET3YG38QB264B76V9FT5V77HK2JXGG, new-height: u296132 }
 { borrower: 'SPE9PMY85TREWR33YYN44DX8BJ2CX5ZKF7NDHMM5, new-height: u156628 }
 { borrower: 'SP2PGDWR97DM7ASJSXY1R7NV5Z829A2H7C40Q2MPA, new-height: u156018 }
 { borrower: 'SP2NJS89HWM7E1W4P3MWEMJQEA0WHBA2WNM01H7X, new-height: u156212 }
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
    (try! (fold check-err (map set-ststx-user-burn-block-height-lambda borrowers) (ok true)))

    ;; disable access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

    (var-set executed-borrower-block-height true)
    (ok true)
  )
)

(define-private (set-ststx-user-burn-block-height-lambda (ststx-borrower (tuple (borrower principal) (new-height uint))))
  (set-user-burn-block-height-to-stacks-block-height
    (get borrower ststx-borrower)
    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
    (get new-height ststx-borrower))
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
