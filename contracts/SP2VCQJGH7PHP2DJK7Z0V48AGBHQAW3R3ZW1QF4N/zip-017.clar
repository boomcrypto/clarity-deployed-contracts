(define-data-var executed bool false)

(define-constant new-supply-cap u50000000000000)

(define-constant wstx-address .wstx)

(define-public (execute (sender principal))
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read wstx-address)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (print reserve-data-1)

    (try!
      (contract-call? .pool-borrow-v2-4 set-reserve wstx-address
        (merge reserve-data-1 { supply-cap: new-supply-cap })
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
