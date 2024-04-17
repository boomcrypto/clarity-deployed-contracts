(define-constant supply-cap u2500000000000)
(define-constant borrow-cap u2500000000000)

(define-constant asset-to-update .wstx)
(define-data-var executed bool false)

(define-public (run-update)
  (let (
    (reserve-data (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read asset-to-update)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (print reserve-data)
    (try!
      (contract-call? .pool-borrow
        set-reserve
        asset-to-update
        (merge reserve-data { supply-cap: supply-cap, borrow-cap: borrow-cap })
      )
    )
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

(run-update)