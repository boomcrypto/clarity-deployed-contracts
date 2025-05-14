---
title: "Trait usda-part-1"
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
 { borrower: 'SP3WPN9AJFS3NJA0K5BGBCZGE6ABHMFNS4WWP8K1F, new-height: u341655 }
 { borrower: 'SP2YADQRAJ4468KEX4CYD4MQPF0S6QYFT5BRA22J0, new-height: u299348 }
 { borrower: 'SP7CD8EB3GT9N5PFW8TPY9CMF84208V7KB0EPAPR, new-height: u314978 }
 { borrower: 'SP3ZW40EN0XN0JVEKJ20656MSDV1JB4Z80DG6FEK3, new-height: u312970 }
 { borrower: 'SP3X6G145Z6DV5H49MN0P0RK9SXY83ZN4ACM3RPMA, new-height: u294105 }
 { borrower: 'SP1BQZ7QBWMRCYYFB51F5SGH2NJJ33R3BJQA71AQ0, new-height: u300358 }
 { borrower: 'SPG22Y5SKSQMYE3Q54962NZNTJ1ANEYJC9Y2TYB0, new-height: u317036 }
 { borrower: 'SP3W1EY9XBBCP2RG1J6A42WJNP4FAK4D8SVT4AB5V, new-height: u306500 }
 { borrower: 'SP2P336EM6HGAX7NQJGR0A4W7KP11BNY25YDSTA6W, new-height: u341555 }
 { borrower: 'SP2TT71CXBRDDYP2P8XMVKRFYKRGSMBWCZ6W6FDGT, new-height: u340214 }
 { borrower: 'SPZGQQDNG2SC5ZY8E9ZQXB3PYQJRRWQJ39B43C1R, new-height: u328351 }
 { borrower: 'SP3DNVSQBYVJDSZXMCFTWZP3DHAC01PGG8RWNRQ3E, new-height: u299068 }
 { borrower: 'SP1A4S4WTWKPYWZQ946BG4893J6JP0N2GX7NT1QCY, new-height: u297383 }
 { borrower: 'SP1M0YRYGQDD433YFWMD1EBFQH4067B5WDSVZGZDG, new-height: u307445 }
 { borrower: 'SP2NMG5CCPNE8T4CTSNE6NAGBNNSKQMZ71BY58FKN, new-height: u314626 }
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
    (try! (fold check-err (map set-usda-user-burn-block-height-lambda borrowers) (ok true)))

    ;; disable access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

    (var-set executed-borrower-block-height true)
    (ok true)
  )
)

(define-private (set-usda-user-burn-block-height-lambda (usda-borrower (tuple (borrower principal) (new-height uint))))
  (set-user-burn-block-height-to-stacks-block-height
    (get borrower usda-borrower)
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
    (get new-height usda-borrower))
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
