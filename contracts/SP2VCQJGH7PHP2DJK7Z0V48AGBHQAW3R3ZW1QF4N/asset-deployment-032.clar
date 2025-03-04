(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant base-rate u7500000)

(define-constant asset-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-borrow-v2-0 set-base-supply-rate asset-address base-rate))

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (begin
    {
      before: (contract-call? .pool-reserve-data-2 get-base-supply-rate-read asset-address),
      after: base-rate
    }
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