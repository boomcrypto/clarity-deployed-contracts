(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant flashloan-fee-total u500)
(define-constant flashloan-fee-protocol u500)

(define-constant aeusdc-token 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant usdh-token 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
(define-constant susdt-token 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(define-constant usda-token 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))


    (try! (contract-call? .pool-reserve-data set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N true))

    (try! (contract-call? .pool-reserve-data set-flashloan-fee-total aeusdc-token flashloan-fee-total))
    (try! (contract-call? .pool-reserve-data set-flashloan-fee-protocol aeusdc-token flashloan-fee-total))

    (try! (contract-call? .pool-reserve-data set-flashloan-fee-total usdh-token flashloan-fee-total))
    (try! (contract-call? .pool-reserve-data set-flashloan-fee-protocol usdh-token flashloan-fee-total))

    (try! (contract-call? .pool-reserve-data set-flashloan-fee-total susdt-token flashloan-fee-total))
    (try! (contract-call? .pool-reserve-data set-flashloan-fee-protocol susdt-token flashloan-fee-total))

    (try! (contract-call? .pool-reserve-data set-flashloan-fee-total usda-token flashloan-fee-total))
    (try! (contract-call? .pool-reserve-data set-flashloan-fee-protocol usda-token flashloan-fee-total))

    (try! (contract-call? .pool-reserve-data set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N false))

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
