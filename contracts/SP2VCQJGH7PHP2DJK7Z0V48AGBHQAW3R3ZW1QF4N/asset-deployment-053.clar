(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant aeusdc-address 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant usdh-address 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
(define-constant susdt-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(define-constant usda-address 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)

(define-constant aeusdc-curve-params
  {
    variable-rate-slope-1: u12500000,
  }
)

(define-constant usdh-curve-params
  {
    variable-rate-slope-1: u12500000,
    liquidation-close-factor-percent: u50000000,
  }
)

(define-constant susdt-curve-params
  {
    variable-rate-slope-1: u12500000,
    liquidation-close-factor-percent: u50000000,
  }
)

(define-constant usda-curve-params
  {
    variable-rate-slope-1: u12500000,
    liquidation-close-factor-percent: u50000000,
  }
)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 aeusdc-address (get variable-rate-slope-1 aeusdc-curve-params)))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 usdh-address (get variable-rate-slope-1 usdh-curve-params)))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 susdt-address (get variable-rate-slope-1 susdt-curve-params)))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 usda-address (get variable-rate-slope-1 usda-curve-params)))

    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent usdh-address (get liquidation-close-factor-percent usdh-curve-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent susdt-address (get liquidation-close-factor-percent susdt-curve-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent usda-address (get liquidation-close-factor-percent usda-curve-params)))

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (begin
    (print 
      {
        aeusdc-curve-params: aeusdc-curve-params,
        usdh-curve-params: usdh-curve-params,
        susdt-curve-params: susdt-curve-params,
        usda-curve-params: usda-curve-params,
      }
    )
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