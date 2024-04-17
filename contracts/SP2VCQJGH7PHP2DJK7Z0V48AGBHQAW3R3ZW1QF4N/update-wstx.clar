(define-constant stx-supply-cap u100000000000)
(define-constant stx-borrow-cap u100000000000)

(define-data-var executed bool false)

(define-public (run-update)
  (let (
    (reserve-data (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read .wstx)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (print reserve-data)
    (try!
      (contract-call? .pool-borrow
        set-reserve
        .wstx
        (merge reserve-data { supply-cap: stx-supply-cap, borrow-cap: stx-borrow-cap })
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

(define-read-only (get-update-values)
  (let (
    (reserve-data (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read .wstx)))
  )
    (merge reserve-data { supply-cap: stx-supply-cap, borrow-cap: stx-borrow-cap })
  )
)

(run-update)