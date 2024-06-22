(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant diko-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
(define-constant diko-z-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v1-2)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! 
      (contract-call? .pool-borrow-v1-2 set-usage-as-collateral-enabled
        diko-token
        true
        u30000000
        u60000000
        u10000000
      )
    )

    (try!
      (contract-call? .pool-borrow-v1-2 add-isolated-asset
        diko-token
        u20000000000000
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
