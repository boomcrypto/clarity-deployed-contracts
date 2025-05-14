---
title: "Trait usda-t-part-1"
draft: true
---
```
;; Used to simulate mainnet migration from v1 to v2 in the test suite
;; Must be called after deploying migrate-v0-v1.clar

(define-constant deployer tx-sender)

(define-data-var executed bool false)
(define-data-var executed-burn-mint bool false)
(define-data-var executed-reserve-data-update bool false)
(define-data-var executed-borrower-block-height bool false)
(define-data-var enabled bool true)

;; TODO: to fetch off-chain
(define-constant holders (list
 'SP2E0Y433PC3SN4JPMHWZ1V4CBA8RW3GB7N3T2NJ6
 'SP1AX2ND6NE41YNN9C0SDJV2N11X7684RBKQWB9XD
 'SP3VCX5NFQ8VCHFS9M6N40ZJNVTRT4HZ62WFH5C4Q
 'SPMZ912TEK2P15E8Q9W1W33QN793XR7XVDYY4R8H
 'SP1222YJD8VC4TQB26MCYSM25SAE44ZBYRZYDBSDB
 'SP3X6G145Z6DV5H49MN0P0RK9SXY83ZN4ACM3RPMA
 'SP3W1EY9XBBCP2RG1J6A42WJNP4FAK4D8SVT4AB5V
 'SP17W459944DRA4FSRE1DYTHTVZ6620WS8F24NXR9
))

(define-public (burn-mint)
  (begin
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-burn-mint)) (err u12))
    ;; enable zusda access
    (try! (contract-call? .zusda-v1-2 set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zusda-v2-0 set-approved-contract (as-contract tx-sender) true))

    ;; burn/mint v2 to v3
    (try! (fold check-err (map consolidate-usda-lambda holders) (ok true)))

    ;; disable access
    (try! (contract-call? .zusda-v1-2 set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zusda-v2-0 set-approved-contract (as-contract tx-sender) false))

    (var-set executed-burn-mint true)
    (ok true)
  )
)

(define-private (consolidate-usda-lambda (account principal))
  (consolidate-usda-balance-to-v3 account)
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (consolidate-usda-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v2-balance (unwrap-panic (contract-call? .zusda-v1-2 get-principal-balance account)))
    )
    ;; if doesn't have v1 balance, then check if has v2 balance
    (if (> v2-balance u0)
      (begin
        (try! (contract-call? .zusda-v1-2 burn v2-balance account))
        (try! (contract-call? .zusda-v2-0 mint v2-balance account))
        true
      )
      false
    )
    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get enabled)) (err u10))
    (ok (not (var-get enabled)))
  )
)


(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set enabled false))
  )
)


```
