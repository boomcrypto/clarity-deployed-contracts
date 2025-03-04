(define-constant deployer tx-sender)

(define-data-var rate uint u100000000)

(define-read-only (get-base-apy)
  (* (var-get rate) u365)
)

(define-read-only (get-rate)
  (var-get rate)
)

(define-public (set-rate (new-rate uint))
  (begin
    (asserts! (is-eq deployer tx-sender) (err u10))
    (var-set rate new-rate)
    (ok true)
  )
)
