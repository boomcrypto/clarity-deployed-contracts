(define-data-var executed bool false)

(define-constant sbtc-token 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

(define-public (execute (sender principal))
  (begin
    (asserts! (not (var-get executed)) (err u10))

    (try! (contract-call? .pool-borrow-v2-4 set-grace-period-enabled sbtc-token false))
    (try! (contract-call? .pool-borrow-v2-4 set-freeze-end-block sbtc-token burn-block-height))

    (var-set executed true)

    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)
