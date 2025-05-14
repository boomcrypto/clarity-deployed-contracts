---
title: "Trait asset-deployment-160"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant ststx-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant aeusdc-address 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant wstx-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)
(define-constant arkadiko-address 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
(define-constant usdh-address 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
(define-constant susdt-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(define-constant usda-address 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)
(define-constant sbtc-address 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant ststxbtc-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)

(define-constant liquidation-params
  {
    liquidation-close-factor-percent: u50000000,
  }
)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent ststx-address (get liquidation-close-factor-percent liquidation-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent aeusdc-address (get liquidation-close-factor-percent liquidation-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent wstx-address (get liquidation-close-factor-percent liquidation-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent arkadiko-address (get liquidation-close-factor-percent liquidation-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent usdh-address (get liquidation-close-factor-percent liquidation-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent susdt-address (get liquidation-close-factor-percent liquidation-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent usda-address (get liquidation-close-factor-percent liquidation-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent sbtc-address (get liquidation-close-factor-percent liquidation-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent ststxbtc-address (get liquidation-close-factor-percent liquidation-params)))

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
```
