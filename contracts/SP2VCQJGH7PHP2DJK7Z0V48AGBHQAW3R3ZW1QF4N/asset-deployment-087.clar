(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant wstx-address .wstx)

(define-constant curve-params { liquidation-close-factor-percent: u50000000 })

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent
      wstx-address
      (get liquidation-close-factor-percent curve-params))
    )

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (begin
    {
      new-curve-params: curve-params,
      old-params:
        {
          liquidation-close-factor-percent: (contract-call? .pool-reserve-data get-liquidation-close-factor-percent-read wstx-address)
        }
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
