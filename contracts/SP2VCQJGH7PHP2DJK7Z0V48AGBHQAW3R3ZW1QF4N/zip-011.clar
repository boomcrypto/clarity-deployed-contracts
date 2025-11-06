(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant updated-reserve-asset-1 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-constant collateral-params
  {
    liquidation-threshold: u75000000
  }
)

(define-public (execute (sender principal))
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (print reserve-data-1)

    (try!
      (contract-call? .pool-borrow-v2-4 set-reserve updated-reserve-asset-1
        (merge reserve-data-1
          {
            liquidation-threshold: (get liquidation-threshold collateral-params)
          }
        )
      )
    )

    (var-set executed true)
    (ok true)
  )
)

(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set executed true))
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)
