(define-data-var executed bool false)
(define-constant updated-reserve-asset 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)

(define-constant supply-cap u300000000000)
(define-constant borrow-cap u300000000000)

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

(define-read-only (get-update-values)
  (let (
    (reserve-data (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset)))
  )
    (merge reserve-data { is-frozen: false })
  )
)

(run-update)