---
title: "Trait upgrade-v1-2_step_2"
draft: true
---
```
(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant updated-reserve-asset-1 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant updated-reserve-asset-2 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant updated-reserve-asset-3 .wstx)

(define-constant asset-1_v0 .zststx)
(define-constant asset-1_v1-0 .zststx-v1-0)
(define-constant asset-1_v1-2 .zststx-v1-2)

(define-constant ststx-oracle .ststx-oracle-v1-4)

(define-constant asset-2_v0 .zaeusdc)
(define-constant asset-2_v1-0 .zaeusdc-v1-0)
(define-constant asset-2_v1-2 .zaeusdc-v1-2)

(define-constant asset-3_v0 .zwstx)
(define-constant asset-3_v1-0 .zwstx-v1)
(define-constant asset-3_v1-2 .zwstx-v1-2)

;; (u144 u3)
(define-constant grace-period-time u432)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-2)))
    (reserve-data-3 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-3)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (print reserve-data-1)
    (print reserve-data-2)
    (print reserve-data-3)
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve updated-reserve-asset-1
        (merge reserve-data-1
          {
            a-token-address: asset-1_v1-2,
            oracle: ststx-oracle,
          })
      )
    )
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve updated-reserve-asset-2
        (merge reserve-data-2 { a-token-address: asset-2_v1-2 })
      )
    )
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve updated-reserve-asset-3
        (merge reserve-data-3 {
          a-token-address: asset-3_v1-2,
          total-borrows-variable: (- (get total-borrows-variable reserve-data-3) u322000000000)
         })
      )
    )

    ;; set lending-pool in liquidation-manager
    (try! (contract-call? .liquidation-manager-v1-2 set-lending-pool .pool-borrow-v1-2))
    
    ;; set to pool-0-reserve-v1-2 for transfer-to-user
    (try! (contract-call? .pool-0-reserve set-lending-pool .pool-0-reserve-v1-2))
    (try! (contract-call? .pool-0-reserve set-liquidator .pool-0-reserve-v1-2))
    ;; drop old pool-0-reserve permissions
    (try! (contract-call? .pool-0-reserve set-approved-contract .pool-borrow false))
    (try! (contract-call? .pool-0-reserve set-approved-contract .pool-borrow-v1-1 false))

    ;; update liquidator and lending-pool in logic calls
    (try! (contract-call? .pool-0-reserve-v1-2 set-lending-pool .pool-borrow-v1-2))
    (try! (contract-call? .pool-0-reserve-v1-2 set-liquidator .liquidation-manager-v1-2))
    (try! (contract-call? .pool-0-reserve-v1-2 set-approved-contract .pool-borrow-v1-2 true))

    ;; update for helper caller
    (try! (contract-call? .pool-borrow-v1-2 set-approved-contract .borrow-helper-v1-2 true))

    ;; disable previous helper caller
    (try! (contract-call? .pool-borrow-v1-1 set-approved-contract .borrow-helper-v2-1 false))

    ;; update pool-reserve-data controller
    (try! (contract-call? .pool-reserve-data delete-approved-contract .pool-0-reserve))
    (try! (contract-call? .pool-reserve-data set-approved-contract .pool-0-reserve-v1-2 true))

    ;; STSTX UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    (try! (contract-call? .zststx-v1-0 set-approved-contract asset-1_v1-2 true))
    (try! (contract-call? .zststx set-approved-contract asset-1_v1-2 true))
    ;; revoke permissions to v1 version
    (try! (contract-call? .zststx-v1-0 set-approved-contract .borrow-helper-v2-2 false))
    (try! (contract-call? .zststx-v1-0 set-approved-contract .pool-borrow-v1-1 false))
    (try! (contract-call? .zststx-v1-0 set-approved-contract .liquidation-manager-v1-1 false))
    (try! (contract-call? .zststx-v1-0 set-approved-contract .pool-0-reserve false))
    ;; revoke permissions to v0 version
    (try! (contract-call? .zststx set-approved-contract asset-1_v1-0 false))
    (try! (contract-call? .zststx set-approved-contract .pool-borrow-v1-1 false))
    (try! (contract-call? .zststx set-approved-contract .liquidation-manager-v1-1 false))
    (try! (contract-call? .zststx set-approved-contract .pool-0-reserve false))
    ;; give permissions to new set to v1-2
    (try! (contract-call? .zststx-v1-2 set-approved-contract .pool-borrow-v1-2 true))
    (try! (contract-call? .zststx-v1-2 set-approved-contract .liquidation-manager-v1-2 true))
    (try! (contract-call? .zststx-v1-2 set-approved-contract .pool-0-reserve-v1-2 true))

    ;; AEUSDC UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    (try! (contract-call? .zaeusdc-v1-0 set-approved-contract asset-2_v1-2 true))
    (try! (contract-call? .zaeusdc set-approved-contract asset-2_v1-2 true))
    ;; revoke permissions to v1 version
    (try! (contract-call? .zaeusdc-v1-0 set-approved-contract .borrow-helper-v2-2 false))
    (try! (contract-call? .zaeusdc-v1-0 set-approved-contract .pool-borrow-v1-1 false))
    (try! (contract-call? .zaeusdc-v1-0 set-approved-contract .liquidation-manager-v1-1 false))
    (try! (contract-call? .zaeusdc-v1-0 set-approved-contract .pool-0-reserve false))
    ;; remove permissions to v0 version
    (try! (contract-call? .zaeusdc set-approved-contract asset-2_v1-0 false))
    (try! (contract-call? .zaeusdc set-approved-contract .pool-borrow-v1-1 false))
    (try! (contract-call? .zaeusdc set-approved-contract .liquidation-manager-v1-1 false))
    (try! (contract-call? .zaeusdc set-approved-contract .pool-0-reserve false))
    ;; give permissions to new set to v1-2
    (try! (contract-call? .zaeusdc-v1-2 set-approved-contract .pool-borrow-v1-2 true))
    (try! (contract-call? .zaeusdc-v1-2 set-approved-contract .liquidation-manager-v1-2 true))
    (try! (contract-call? .zaeusdc-v1-2 set-approved-contract .pool-0-reserve-v1-2 true))

    ;; STX UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    (try! (contract-call? .zwstx-v1 set-approved-contract asset-3_v1-2 true))
    (try! (contract-call? .zwstx set-approved-contract asset-3_v1-2 true))
    ;; revoke permissions to v1 version
    (try! (contract-call? .zwstx-v1 set-approved-contract .borrow-helper-v2-2 false))
    (try! (contract-call? .zwstx-v1 set-approved-contract .pool-borrow-v1-1 false))
    (try! (contract-call? .zwstx-v1 set-approved-contract .liquidation-manager-v1-1 false))
    (try! (contract-call? .zwstx-v1 set-approved-contract .pool-0-reserve false))
    ;; revoke permissions to v0 version
    (try! (contract-call? .zwstx set-approved-contract asset-3_v1-0 false))
    (try! (contract-call? .zwstx set-approved-contract .pool-borrow-v1-1 false))
    (try! (contract-call? .zwstx set-approved-contract .liquidation-manager-v1-1 false))
    (try! (contract-call? .zwstx set-approved-contract .pool-0-reserve false))
    ;; give permissions to new set to v1-2
    (try! (contract-call? .zwstx-v1-2 set-approved-contract .pool-borrow-v1-2 true))
    (try! (contract-call? .zwstx-v1-2 set-approved-contract .liquidation-manager-v1-2 true))
    (try! (contract-call? .zwstx-v1-2 set-approved-contract .pool-0-reserve-v1-2 true))

    (try! (contract-call? .pool-borrow-v1-2 set-grace-period-enabled updated-reserve-asset-1 true))
    (try! (contract-call? .pool-borrow-v1-2 set-grace-period-time updated-reserve-asset-1 grace-period-time))
    (try! (contract-call? .pool-borrow-v1-2 set-freeze-end-block updated-reserve-asset-1 burn-block-height))
    (try! (contract-call? .pool-borrow-v1-2 set-grace-period-enabled updated-reserve-asset-2 true))
    (try! (contract-call? .pool-borrow-v1-2 set-grace-period-time updated-reserve-asset-2 grace-period-time))
    (try! (contract-call? .pool-borrow-v1-2 set-freeze-end-block updated-reserve-asset-2 burn-block-height))
    (try! (contract-call? .pool-borrow-v1-2 set-grace-period-enabled updated-reserve-asset-3 true))
    (try! (contract-call? .pool-borrow-v1-2 set-grace-period-time updated-reserve-asset-3 grace-period-time))
    (try! (contract-call? .pool-borrow-v1-2 set-freeze-end-block updated-reserve-asset-3 burn-block-height))


    ;; clear permission from step_1
    (try! (contract-call? .pool-reserve-data delete-approved-contract .upgrade-v1-2_step_1))
    (try! (contract-call? .zwstx-v1 set-approved-contract .upgrade-v1-2_step_1 false))

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-2)))
    (reserve-data-3 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-3)))
  )
    (print reserve-data-1)
    (print reserve-data-2)
    (print reserve-data-3)

    (print (merge reserve-data-1
      {
        a-token-address: asset-1_v1-2,
        oracle: ststx-oracle,
      }))
    (print (merge reserve-data-2 { a-token-address: asset-2_v1-2 }))
    (print (merge reserve-data-3 { 
      a-token-address: asset-3_v1-2,
      total-borrows-variable: (- (get total-borrows-variable reserve-data-3) u322000000000)
    }))
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
