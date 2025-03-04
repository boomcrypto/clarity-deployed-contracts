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
 'SP1ESCTF9029MH550RKNE8R4D62G5HBY8PBBAF2N8
 'SP1VDCM9FZH5DCDA21M06PV216S0DDECV0G62AEZM
 'SP2N7VSJ2DT9NY438G3VDWYFP3WWBKYN46GQPHH6T
 'SPTT1ZEFQ88QQHV8PQ5ASR3RWPBY34PX7MM1D314
 'SP3BJB60HT48Y0T9R93H2AWN62GWP8XTYFTETYRA5
 'SPXMZGWZS4XPGWFX1WC0M4WH8B7HMXP5E5VZFRYX
 'SP1222YJD8VC4TQB26MCYSM25SAE44ZBYRZYDBSDB
 'SP3X6G145Z6DV5H49MN0P0RK9SXY83ZN4ACM3RPMA
))

(define-public (burn-mint)
  (begin
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-burn-mint)) (err u12))
    ;; enable zsusdt access
    (try! (contract-call? .zsusdt-token set-approved-contract .zsusdt-v2-0 true))

    (try! (contract-call? .zsusdt-v1-2 set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zsusdt-v2-0 set-approved-contract (as-contract tx-sender) true))

    ;; burn/mint v2 to v3
    (try! (fold check-err (map consolidate-susdt-lambda holders) (ok true)))

    ;; disable access
    (try! (contract-call? .zsusdt-v1-2 set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zsusdt-v2-0 set-approved-contract (as-contract tx-sender) false))

    (var-set executed-burn-mint true)
    (ok true)
  )
)

(define-private (consolidate-susdt-lambda (account principal))
  (consolidate-susdt-balance-to-v3 account)
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (consolidate-susdt-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v2-balance (unwrap-panic (contract-call? .zsusdt-v1-2 get-principal-balance account)))
    )
    ;; if doesn't have v1 balance, then check if has v2 balance
    (if (> v2-balance u0)
      (begin
        (try! (contract-call? .zsusdt-v1-2 burn v2-balance account))
        (try! (contract-call? .zsusdt-v2-0 mint v2-balance account))
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

