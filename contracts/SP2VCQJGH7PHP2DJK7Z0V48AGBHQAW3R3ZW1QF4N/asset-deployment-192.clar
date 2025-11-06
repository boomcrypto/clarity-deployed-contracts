(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant new-supply-cap u285000000000000)

(define-constant alex-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read alex-token)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (print reserve-data-1)

    (try!
      (contract-call? .pool-borrow-v2-2 set-reserve alex-token
        (merge reserve-data-1 { supply-cap: new-supply-cap })
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
