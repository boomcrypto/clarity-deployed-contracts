(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant stx-token .wstx)


(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-borrow-v2-1 set-grace-period-enabled stx-token false))
    (try! (contract-call? .pool-borrow-v2-1 set-freeze-end-block stx-token burn-block-height))

    (try! (contract-call? .pool-borrow-v2-1 add-isolated-asset stx-token u1000000000000000))

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
