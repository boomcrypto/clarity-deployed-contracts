(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant flashloan-fee-total u500)
(define-constant flashloan-fee-protocol u500)

(define-constant aeusdc-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant usdh-token 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
(define-constant susdt-token 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(define-constant usda-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read aeusdc-token)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read usdh-token)))
    (reserve-data-3 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read susdt-token)))
    (reserve-data-4 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read usda-token)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (print reserve-data-1)
    (print reserve-data-2)
    (print reserve-data-3)
    (print reserve-data-4)

    (try!
      (contract-call? .pool-borrow-v2-1
        set-reserve
        aeusdc-token
        (merge reserve-data-1 { flashloan-enabled: true })
      )
    )
    (try!
      (contract-call? .pool-borrow-v2-1
        set-reserve
        usdh-token
        (merge reserve-data-2 { flashloan-enabled: true })
      )
    )
    (try!
      (contract-call? .pool-borrow-v2-1
        set-reserve
        susdt-token
        (merge reserve-data-3 { flashloan-enabled: true })
      )
    )
    (try!
      (contract-call? .pool-borrow-v2-1
        set-reserve
        usda-token
        (merge reserve-data-4 { flashloan-enabled: true })
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
