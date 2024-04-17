(define-data-var executed bool false)
(define-constant updated-reserve-asset 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)

(define-public (run-update)
  (let (
    (reserve-data (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (print reserve-data)
    (try!
      (contract-call? .pool-borrow
        set-reserve
        updated-reserve-asset
        (merge reserve-data { is-frozen: false })
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
    (reserve-data (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset)))
  )
    (merge reserve-data { is-frozen: false })
  )
)

(run-update)