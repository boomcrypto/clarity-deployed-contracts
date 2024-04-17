
(define-constant aeusdc-supply-cap u200000000000)
(define-constant aeusdc-borrow-cap u200000000000)

(define-data-var executed bool false)

(define-public (run-update)
  (let (
    (reserve-data (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (print reserve-data)
    (try!
      (contract-call? .pool-borrow
        set-reserve
        'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
        (merge reserve-data { supply-cap: aeusdc-supply-cap, borrow-cap: aeusdc-borrow-cap })
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
    (reserve-data (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)))
  )
    (merge reserve-data { supply-cap: aeusdc-supply-cap, borrow-cap: aeusdc-borrow-cap })
  )
)

(run-update)