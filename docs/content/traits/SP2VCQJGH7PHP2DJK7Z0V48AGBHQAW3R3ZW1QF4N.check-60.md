---
title: "Trait check-60"
draft: true
---
```

(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant updated-reserve-asset-1 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant updated-reserve-asset-2 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant updated-reserve-asset-3 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)
(define-constant updated-reserve-asset-4 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
(define-constant updated-reserve-asset-5 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
(define-constant updated-reserve-asset-6 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)

;; (u144 u3)
(define-constant grace-period-time u100)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-enabled updated-reserve-asset-1 true))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-time updated-reserve-asset-1 grace-period-time))
    (try! (contract-call? .pool-borrow-v2-0 set-freeze-end-block updated-reserve-asset-1 burn-block-height))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-enabled updated-reserve-asset-2 true))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-time updated-reserve-asset-2 grace-period-time))
    (try! (contract-call? .pool-borrow-v2-0 set-freeze-end-block updated-reserve-asset-2 burn-block-height))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-enabled updated-reserve-asset-3 true))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-time updated-reserve-asset-3 grace-period-time))
    (try! (contract-call? .pool-borrow-v2-0 set-freeze-end-block updated-reserve-asset-3 burn-block-height))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-enabled updated-reserve-asset-4 true))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-time updated-reserve-asset-4 grace-period-time))
    (try! (contract-call? .pool-borrow-v2-0 set-freeze-end-block updated-reserve-asset-4 burn-block-height))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-enabled updated-reserve-asset-5 true))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-time updated-reserve-asset-5 grace-period-time))
    (try! (contract-call? .pool-borrow-v2-0 set-freeze-end-block updated-reserve-asset-5 burn-block-height))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-enabled updated-reserve-asset-6 true))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-time updated-reserve-asset-6 grace-period-time))
    (try! (contract-call? .pool-borrow-v2-0 set-freeze-end-block updated-reserve-asset-6 burn-block-height))

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
