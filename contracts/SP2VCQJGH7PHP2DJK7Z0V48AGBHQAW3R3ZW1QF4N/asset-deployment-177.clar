(define-data-var executed bool false)
(define-constant deployer tx-sender)


(define-constant stx-emode-type 0x01)
(define-constant stx-emode-type-config { ltv: u80000000 , liquidation-threshold: u90000000 })

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try!
      (contract-call? .pool-borrow-v2-1 set-e-mode-type-config
        stx-emode-type
        (get ltv stx-emode-type-config)
        (get liquidation-threshold stx-emode-type-config)
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
