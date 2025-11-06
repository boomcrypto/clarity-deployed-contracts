(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant wstx-address .wstx)

(define-constant curve-params { variable-rate-slope-1: u7500000 })

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 wstx-address (get variable-rate-slope-1 curve-params)))

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
