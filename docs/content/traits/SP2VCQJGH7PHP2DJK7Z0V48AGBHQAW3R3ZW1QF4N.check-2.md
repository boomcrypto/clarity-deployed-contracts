---
title: "Trait check-2"
draft: true
---
```
;; Used to simulate mainnet migration from v1 to v2 in the test suite
;; Must be called after deploying migrate-v0-v1.clar

(define-data-var executed bool false)
(define-data-var executed-burn-mint bool false)
(define-data-var executed-reserve-data-update bool false)
(define-data-var executed-borrower-block-height bool false)

(define-data-var enabled bool true)
(define-constant deployer tx-sender)

(define-constant ststx-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant aeusdc-address 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
(define-constant wstx-address 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)
(define-constant diko-address 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
(define-constant usdh-address 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
(define-constant susdt-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
(define-constant usda-address 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)

(define-constant v0-version-ststx 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx)
(define-constant v1-version-ststx 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-0)
(define-constant v1-2-version-ststx 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-2)
(define-constant v2-0-version-ststx 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0)

(define-constant zststx-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-token)

(define-constant v0-version-aeusdc 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc)
(define-constant v1-version-aeusdc 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v1-0)
(define-constant v1-2-version-aeusdc 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v1-2)
(define-constant v2-0-version-aeusdc 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0)

(define-constant zaeusdc-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-token)

;; non-standard name on v1, v1-2-1
(define-constant v0-version-wstx 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx)
(define-constant v1-version-wstx 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v1)
(define-constant v1-2-version-wstx 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v1-2-1)
(define-constant v2-0-version-wstx 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0)

(define-constant zwstx-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-token)

;; only has 1-2 version
(define-constant v1-2-version-diko 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v1-2)
(define-constant v2-0-version-diko 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0)

(define-constant zdiko-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-token)

;; only has 1-2 version
(define-constant v1-2-version-usdh 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v1-2)
(define-constant v2-0-version-usdh 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0)

(define-constant zusdh-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-token)

;; only has 1-2 version
(define-constant v1-2-version-susdt 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v1-2)
(define-constant v2-0-version-susdt 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0)

(define-constant zsusdt-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-token)

;; only has 1-2 version
(define-constant v1-2-version-usda 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v1-2)
(define-constant v2-0-version-usda 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0)

(define-constant zusda-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-token)

(define-constant pool-0-reserve-v0 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve)
(define-constant pool-0-reserve-v1-2 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v1-2)
(define-constant pool-0-reserve-v2-0 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read aeusdc-address)))
    (reserve-data-3 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read wstx-address)))
    (reserve-data-4 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read diko-address)))
    (reserve-data-5 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read usdh-address)))
    (reserve-data-6 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read susdt-address)))
    (reserve-data-7 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read usda-address)))
  )
    ;; TODO: remove 
    (asserts! false (err u1))
    (asserts! (var-get enabled) (err u10))
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (try!
      (contract-call? .pool-borrow set-reserve ststx-address
        (merge reserve-data-1 { a-token-address: v2-0-version-ststx })
      )
    )
    (try!
      (contract-call? .pool-borrow set-reserve aeusdc-address
        (merge reserve-data-2 { a-token-address: v2-0-version-aeusdc })
      )
    )
    (try!
      (contract-call? .pool-borrow set-reserve wstx-address
        (merge reserve-data-3 { a-token-address: v2-0-version-wstx })
      )
    )
    (try!
      (contract-call? .pool-borrow set-reserve diko-address
        (merge reserve-data-4 { a-token-address: v2-0-version-diko })
      )
    )
    (try!
      (contract-call? .pool-borrow set-reserve usdh-address
        (merge reserve-data-5 { a-token-address: v2-0-version-usdh })
      )
    )
    (try!
      (contract-call? .pool-borrow set-reserve susdt-address
        (merge reserve-data-6 { a-token-address: v2-0-version-susdt })
      ) 
    )
    (try!
      (contract-call? .pool-borrow set-reserve usda-address
        (merge reserve-data-7 { a-token-address: v2-0-version-usda })
      )
    )

    ;; (try! (contract-call? .liquidation-manager-v2-0 set-lending-pool .pool-borrow-v2-0))
    
    ;; ;; pass permission to new pool-0-reserve. pool-0-reserve is used for transferring from pool-vault
    ;; (try! (contract-call? .pool-0-reserve set-lending-pool .pool-0-reserve-v2-0))
    ;; (try! (contract-call? .pool-0-reserve set-liquidator .pool-0-reserve-v2-0))
    ;; (try! (contract-call? .pool-0-reserve set-approved-contract .pool-borrow false))
    ;; (try! (contract-call? .pool-0-reserve set-approved-contract .pool-borrow-v1-2 false))

    ;; ;; disable previous permissions
    ;; (try! (contract-call? .pool-0-reserve-v1-2 set-approved-contract .pool-borrow-v1-2 false))

    ;; (try! (contract-call? .pool-0-reserve-v2-0 set-liquidator .liquidation-manager-v2-0))
    ;; (try! (contract-call? .pool-0-reserve-v2-0 set-lending-pool .pool-borrow-v2-0))
    ;; (try! (contract-call? .pool-0-reserve-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    ;; ;; END pool-0-reserve permissions

    ;; ;; update helper caller
    ;; (try! (contract-call? .pool-borrow-v2-0 set-approved-contract .borrow-helper-v2-0 true))
    ;; (try! (contract-call? .pool-borrow-v1-2 set-approved-contract .borrow-helper-v1-2 false))

    ;; ;; update pool-reserve-data controller
    ;; (try! (contract-call? .pool-reserve-data set-approved-contract .pool-0-reserve-v1-2 false))
    ;; (try! (contract-call? .pool-reserve-data set-approved-contract .pool-0-reserve-v2-0 true))
    ;; (try! (contract-call? .pool-reserve-data-1 set-approved-contract .pool-borrow-v2-0 true))
    ;; (try! (contract-call? .pool-reserve-data-2 set-approved-contract .pool-borrow-v2-0 true))

    ;; ;; STSTX UPGRADE
    ;; ;; give permission for burn/mint of previous versions to new version
    ;; ;; permission to ztoken contract
    ;; (try! (contract-call? .zststx-token set-approved-contract v2-0-version-ststx true))
    ;; ;; permission to logic lp token
    ;; ;; revoke pool-borrow permissions to v1-2 version
    ;; (try! (contract-call? .zststx-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    ;; (try! (contract-call? .zststx-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    ;; (try! (contract-call? .zststx-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; ;; disable access to v0, v1 from v1-2
    ;; (try! (contract-call? .zststx set-approved-contract v1-2-version-ststx false))
    ;; (try! (contract-call? .zststx-v1-0 set-approved-contract v1-2-version-ststx false))
    ;; ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    ;; (try! (contract-call? .zststx-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    ;; (try! (contract-call? .zststx-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    ;; (try! (contract-call? .zststx-v2-0 set-approved-contract pool-0-reserve-v2-0 true))
    ;; ;; ===

    ;; ;; aeUSDC UPGRADE
    ;; ;; give permission for burn/mint of previous versions to new version
    ;; ;; permission to ztoken contract
    ;; (try! (contract-call? .zaeusdc-token set-approved-contract v2-0-version-aeusdc true))
    ;; ;; permission to logic lp token
    ;; ;; revoke pool-borrow permissions to v1-2 version
    ;; (try! (contract-call? .zaeusdc-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    ;; (try! (contract-call? .zaeusdc-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    ;; (try! (contract-call? .zaeusdc-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; ;; disable access to v0, v1-0 from v1-2
    ;; (try! (contract-call? .zaeusdc set-approved-contract v1-2-version-aeusdc false))
    ;; (try! (contract-call? .zaeusdc-v1-0 set-approved-contract v1-2-version-aeusdc false))
    ;; ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    ;; (try! (contract-call? .zaeusdc-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    ;; (try! (contract-call? .zaeusdc-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    ;; (try! (contract-call? .zaeusdc-v2-0 set-approved-contract pool-0-reserve-v2-0 true))
    ;; ;; ===

    ;; ;; wstx UPGRADE
    ;; ;; give permission for burn/mint of previous versions to new version
    ;; ;; permission to ztoken contract
    ;; (try! (contract-call? .zwstx-token set-approved-contract v2-0-version-wstx true))
    ;; ;; permission to logic lp token
    ;; ;; revoke pool-borrow permissions to v1-2 version
    ;; (try! (contract-call? .zwstx-v1-2-1 set-approved-contract .pool-borrow-v1-2 false))
    ;; (try! (contract-call? .zwstx-v1-2-1 set-approved-contract .liquidation-manager-v1-2 false))
    ;; (try! (contract-call? .zwstx-v1-2-1 set-approved-contract pool-0-reserve-v0 false))
    ;; ;; disable access from v0, v1 to v1-2
    ;; (try! (contract-call? .zwstx set-approved-contract v1-2-version-wstx false))
    ;; (try! (contract-call? .zwstx-v1 set-approved-contract v1-2-version-wstx false))
    ;; ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    ;; (try! (contract-call? .zwstx-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    ;; (try! (contract-call? .zwstx-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    ;; (try! (contract-call? .zwstx-v2-0 set-approved-contract pool-0-reserve-v2-0 true))
    ;; ;; ===

    ;; ;; diko UPGRADE
    ;; ;; give permission for burn/mint of previous versions to new version
    ;; ;; permission to ztoken contract
    ;; (try! (contract-call? .zdiko-token set-approved-contract v2-0-version-diko true))
    ;; ;; permission to logic lp token
    ;; ;; revoke pool-borrow permissions to v1-2 version
    ;; (try! (contract-call? .zdiko-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    ;; (try! (contract-call? .zdiko-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    ;; (try! (contract-call? .zdiko-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; ;; no v1-2 version in diko
    ;; ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    ;; (try! (contract-call? .zdiko-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    ;; (try! (contract-call? .zdiko-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    ;; (try! (contract-call? .zdiko-v2-0 set-approved-contract pool-0-reserve-v2-0 true))
    ;; ;; ===

    ;; ;; usdh UPGRADE
    ;; ;; give permission for burn/mint of previous versions to new version
    ;; ;; permission to ztoken contract
    ;; (try! (contract-call? .zusdh-token set-approved-contract v2-0-version-usdh true))
    ;; ;; permission to logic lp token
    ;; ;; revoke pool-borrow permissions to v1-2 version
    ;; (try! (contract-call? .zusdh-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    ;; (try! (contract-call? .zusdh-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    ;; (try! (contract-call? .zusdh-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; ;; no v1-2 version in usdh
    ;; ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    ;; (try! (contract-call? .zusdh-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    ;; (try! (contract-call? .zusdh-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    ;; (try! (contract-call? .zusdh-v2-0 set-approved-contract pool-0-reserve-v2-0 true))
    ;; ;; ===

    ;; ;; susdt UPGRADE
    ;; ;; give permission for burn/mint of previous versions to new version
    ;; ;; permission to ztoken contract
    ;; (try! (contract-call? .zsusdt-token set-approved-contract v2-0-version-susdt true))
    ;; ;; permission to logic lp token
    ;; ;; revoke pool-borrow permissions to v1-2 version
    ;; (try! (contract-call? .zsusdt-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    ;; (try! (contract-call? .zsusdt-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    ;; (try! (contract-call? .zsusdt-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; ;; no v1-2 version in susdt
    ;; ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    ;; (try! (contract-call? .zsusdt-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    ;; (try! (contract-call? .zsusdt-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    ;; (try! (contract-call? .zsusdt-v2-0 set-approved-contract pool-0-reserve-v2-0 true))
    ;; ;; ===

    ;; ;; usda UPGRADE
    ;; ;; give permission for burn/mint of previous versions to new version
    ;; ;; permission to ztoken contract
    ;; (try! (contract-call? .zusda-token set-approved-contract v2-0-version-usda true))
    ;; ;; permission to logic lp token
    ;; ;; revoke pool-borrow permissions to v1-2 version
    ;; (try! (contract-call? .zusda-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    ;; (try! (contract-call? .zusda-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    ;; (try! (contract-call? .zusda-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; ;; no v1-2 version in usda
    ;; ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    ;; (try! (contract-call? .zusda-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    ;; (try! (contract-call? .zusda-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    ;; (try! (contract-call? .zusda-v2-0 set-approved-contract pool-0-reserve-v2-0 true))
    ;; ;; ===

    (var-set executed true)
    (ok true)
  )
)

;; TODO: to fetch off-chain
(define-constant ststx-borrowers (list
{ borrower: 'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND, new-height: u117 }
))
;; TODO: to fetch off-chain
(define-constant ststx-holders (list
'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND
))

;; TODO: to fetch off-chain
(define-constant reserve-stacks-block-height-ststx u118)
(define-constant reserve-stacks-block-height-aeusdc u118)
(define-constant reserve-stacks-block-height-wstx u118)
(define-constant reserve-stacks-block-height-diko u118)
(define-constant reserve-stacks-block-height-usdh u118)
(define-constant reserve-stacks-block-height-susdt u118)
(define-constant reserve-stacks-block-height-usda u118)

;; (define-public (set-reserve-block-height)
;;   (begin
;;     ;; TODO: remove 
;;     (asserts! false (err u1))
;;     (asserts! (var-get enabled) (err u10))
;;     (asserts! (is-eq deployer tx-sender) (err u11))
;;     (asserts! (not (var-get executed-reserve-data-update)) (err u10))

;;     ;; set to last updated block height of the v2 version for the reserve
;;     (try! (set-reserve-burn-block-height-to-stacks-block-height
;;       'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
;;       reserve-stacks-block-height-ststx))
;;     (try! (set-reserve-burn-block-height-to-stacks-block-height
;;       'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
;;       reserve-stacks-block-height-aeusdc))
;;     (try! (set-reserve-burn-block-height-to-stacks-block-height
;;       .wstx
;;       reserve-stacks-block-height-wstx))
;;     (try! (set-reserve-burn-block-height-to-stacks-block-height
;;       'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
;;       reserve-stacks-block-height-diko))
;;     (try! (set-reserve-burn-block-height-to-stacks-block-height
;;       'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
;;       reserve-stacks-block-height-usdh))
;;     (try! (set-reserve-burn-block-height-to-stacks-block-height
;;       'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
;;       reserve-stacks-block-height-susdt))
;;     (try! (set-reserve-burn-block-height-to-stacks-block-height
;;       'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
;;       reserve-stacks-block-height-usda))

;;     (var-set executed-reserve-data-update true)
;;     (ok true)
;;   )
;; )

;; (define-public (set-ststx-borrower-block-height)
;;   (begin
;;     ;; TODO: remove 
;;     (asserts! false (err u1))
;;     (asserts! (var-get enabled) (err u10))
;;     (asserts! (is-eq deployer tx-sender) (err u11))
;;     (asserts! (not (var-get executed-borrower-block-height)) (err u10))
;;     ;; enabled access
;;     (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

;;     ;; set to last updated block height of the v2 version for borrowers
;;     ;; only addr-2 is a borrower in this case
;;     (try! (fold check-err (map set-ststx-user-burn-block-height-lambda ststx-borrowers) (ok true)))

;;     ;; disable access
;;     (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

;;     (var-set executed-borrower-block-height true)
;;     (ok true)
;;   )
;; )

;; (define-public (burn-mint-zststx)
;;   (begin
;;     ;; TODO: remove 
;;     (asserts! false (err u1))
;;     (asserts! (var-get enabled) (err u10))
;;     (asserts! (is-eq deployer tx-sender) (err u11))
;;     (asserts! (not (var-get executed-burn-mint)) (err u10))
;;     ;; enable zststx access
;;     (try! (contract-call? .zststx set-approved-contract (as-contract tx-sender) true))
;;     (try! (contract-call? .zststx-v1 set-approved-contract (as-contract tx-sender) true))
;;     (try! (contract-call? .zststx-v1-2 set-approved-contract (as-contract tx-sender) true))
;;     (try! (contract-call? .zststx-v2-0 set-approved-contract (as-contract tx-sender) true))
;;     (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

;;     ;; burn/mint v2 to v3
;;     (try! (fold check-err (map consolidate-ststx-lambda ststx-holders) (ok true)))

;;     ;; disable access
;;     (try! (contract-call? .zststx set-approved-contract (as-contract tx-sender) false))
;;     (try! (contract-call? .zststx-v1 set-approved-contract (as-contract tx-sender) false))
;;     (try! (contract-call? .zststx-v2 set-approved-contract (as-contract tx-sender) false))
;;     (try! (contract-call? .zststx-v3 set-approved-contract (as-contract tx-sender) false))
;;     (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

;;     (var-set executed-burn-mint true)
;;     (ok true)
;;   )
;; )

;; (define-private (set-ststx-user-burn-block-height-lambda (ststx-borrower (tuple (borrower principal) (new-height uint))))
;;   (set-user-burn-block-height-to-stacks-block-height
;;     (get borrower ststx-borrower)
;;     'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
;;     (get new-height ststx-borrower))
;; )

;; (define-private (set-aeusdc-user-burn-block-height-lambda (aeusdc-borrower (tuple (borrower principal) (new-height uint))))
;;   (set-user-burn-block-height-to-stacks-block-height
;;     (get borrower aeusdc-borrower)
;;     'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
;;     (get new-height aeusdc-borrower))
;; )

;; (define-private (set-wstx-user-burn-block-height-lambda (wstx-borrower (tuple (borrower principal) (new-height uint))))
;;   (set-user-burn-block-height-to-stacks-block-height
;;     (get borrower wstx-borrower)
;;     .wstx
;;     (get new-height wstx-borrower))
;; )

;; (define-private (set-diko-user-burn-block-height-lambda (diko-borrower (tuple (borrower principal) (new-height uint))))
;;   (set-user-burn-block-height-to-stacks-block-height
;;     (get borrower diko-borrower)
;;     'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
;;     (get new-height diko-borrower))
;; )

;; (define-private (set-usdh-user-burn-block-height-lambda (usdh-borrower (tuple (borrower principal) (new-height uint))))
;;   (set-user-burn-block-height-to-stacks-block-height
;;     (get borrower usdh-borrower)
;;     'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
;;     (get new-height usdh-borrower))
;; )

;; (define-private (set-susdt-user-burn-block-height-lambda (susdt-borrower (tuple (borrower principal) (new-height uint))))
;;   (set-user-burn-block-height-to-stacks-block-height
;;     (get borrower susdt-borrower)
;;     'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
;;     (get new-height susdt-borrower))
;; )

;; (define-private (set-usda-user-burn-block-height-lambda (usda-borrower (tuple (borrower principal) (new-height uint))))
;;   (set-user-burn-block-height-to-stacks-block-height
;;     (get borrower usda-borrower)
;;     'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
;;     (get new-height usda-borrower))
;; )


;; (define-private (consolidate-ststx-lambda (account principal))
;;   (consolidate-ststx-balance-to-v3 account)
;; )

;; (define-private (consolidate-aeusdc-lambda (account principal))
;;   (consolidate-aeusdc-balance-to-v3 account)
;; )

;; (define-private (consolidate-wstx-lambda (account principal))
;;   (consolidate-wstx-balance-to-v3 account)
;; )

;; (define-private (consolidate-diko-lambda (account principal))
;;   (consolidate-diko-balance-to-v3 account)
;; )

;; (define-private (consolidate-usdh-lambda (account principal))
;;   (consolidate-usdh-balance-to-v3 account)
;; )

;; (define-private (consolidate-susdt-lambda (account principal))
;;   (consolidate-susdt-balance-to-v3 account)
;; )

;; (define-private (consolidate-usda-lambda (account principal))
;;   (consolidate-usda-balance-to-v3 account)
;; )

;; (define-private (check-err (result (response bool uint)) (prior (response bool uint)) (err-value uint))
;;   (match prior ok-value result err-value (err err-value))
;; )

;; (define-private (set-user-burn-block-height-to-stacks-block-height
;;   (account principal)
;;   (asset principal)
;;   (new-stacks-block-height uint))
;;   (begin
;;     (try!
;;       (contract-call? .pool-reserve-data set-user-reserve-data
;;         account
;;         asset
;;           (merge
;;             (unwrap-panic (contract-call? .pool-reserve-data get-user-reserve-data-read account asset))
;;             { last-updated-block: new-stacks-block-height })))
;;     (ok true)
;;   )
;; )

;; (define-private (set-reserve-burn-block-height-to-stacks-block-height
;;   (asset principal)
;;   (new-stacks-block-height uint))
;;   (begin
;;     (try!
;;       (contract-call? .pool-reserve-data set-reserve-state
;;         asset
;;         (merge
;;           (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read asset))
;;           { last-updated-block: new-stacks-block-height })))
;;     (ok true)
;;   )
;; )

;; (define-private (consolidate-ststx-balance-to-v3 (account principal))
;;   (let (
;;     ;; burns old balances and mints to the latest version
;;     (v0-balance (unwrap-panic (contract-call? .zststx get-principal-balance account)))
;;     (v1-balance (unwrap-panic (contract-call? .zststx-v1-0 get-principal-balance account)))
;;     (v2-balance (unwrap-panic (contract-call? .zststx-v1-2 get-principal-balance account)))
;;     )
;;     (if (> v0-balance u0)
;;       (begin
;;         (try! (contract-call? .zststx burn v0-balance account))
;;         (try! (contract-call? .zststx-v2-0 mint v0-balance account))
;;         true
;;       )
;;       ;; if doesn't have v0 balance, then check if has v1 balance
;;       (if (> v1-balance u0)
;;         (begin
;;           (try! (contract-call? .zststx-v1-0 burn v1-balance account))
;;           (try! (contract-call? .zststx-v2-0 mint v1-balance account))
;;           true
;;         )
;;         ;; if doesn't have v1 balance, then check if has v2 balance
;;         (if (> v2-balance u0)
;;           (begin
;;             (try! (contract-call? .zststx-v1-2 burn v2-balance account))
;;             (try! (contract-call? .zststx-v2-0 mint v2-balance account))
;;             true
;;           )
;;           false
;;         )
;;       )
;;     )
;;     (ok true)
;;   )
;; )

;; (define-private (consolidate-aeusdc-balance-to-v3 (account principal))
;;   (let (
;;     ;; burns old balances and mints to the latest version
;;     (v0-balance (unwrap-panic (contract-call? .zaeusdc get-principal-balance account)))
;;     (v1-balance (unwrap-panic (contract-call? .zaeusdc-v1-0 get-principal-balance account)))
;;     (v2-balance (unwrap-panic (contract-call? .zaeusdc-v1-2 get-principal-balance account)))
;;     )
;;     (if (> v0-balance u0)
;;       (begin
;;         (try! (contract-call? .zaeusdc burn v0-balance account))
;;         (try! (contract-call? .zaeusdc-v2-0 mint v0-balance account))
;;         true
;;       )
;;       ;; if doesn't have v0 balance, then check if has v1 balance
;;       (if (> v1-balance u0)
;;         (begin
;;           (try! (contract-call? .zaeusdc-v1-0 burn v1-balance account))
;;           (try! (contract-call? .zaeusdc-v2-0 mint v1-balance account))
;;           true
;;         )
;;         ;; if doesn't have v1 balance, then check if has v2 balance
;;         (if (> v2-balance u0)
;;           (begin
;;             (try! (contract-call? .zaeusdc-v1-2 burn v2-balance account))
;;             (try! (contract-call? .zaeusdc-v2-0 mint v2-balance account))
;;             true
;;           )
;;           false
;;         )
;;       )
;;     )
;;     (ok true)
;;   )
;; )

;; (define-private (consolidate-wstx-balance-to-v3 (account principal))
;;   (let (
;;     ;; burns old balances and mints to the latest version
;;     (v0-balance (unwrap-panic (contract-call? .zwstx get-principal-balance account)))
;;     (v1-balance (unwrap-panic (contract-call? .zwstx-v1 get-principal-balance account)))
;;     (v2-balance (unwrap-panic (contract-call? .zwstx-v1-2-1 get-principal-balance account)))
;;     )
;;     (if (> v0-balance u0)
;;       (begin
;;         (try! (contract-call? .zwstx burn v0-balance account))
;;         (try! (contract-call? .zwstx-v2-0 mint v0-balance account))
;;         true
;;       )
;;       ;; if doesn't have v0 balance, then check if has v1 balance
;;       (if (> v1-balance u0)
;;         (begin
;;           (try! (contract-call? .zwstx-v1 burn v1-balance account))
;;           (try! (contract-call? .zwstx-v2-0 mint v1-balance account))
;;           true
;;         )
;;         ;; if doesn't have v1 balance, then check if has v2 balance
;;         (if (> v2-balance u0)
;;           (begin
;;             (try! (contract-call? .zwstx-v1-2-1 burn v2-balance account))
;;             (try! (contract-call? .zwstx-v2-0 mint v2-balance account))
;;             true
;;           )
;;           false
;;         )
;;       )
;;     )
;;     (ok true)
;;   )
;; )

;; (define-private (consolidate-diko-balance-to-v3 (account principal))
;;   (let (
;;     ;; burns old balances and mints to the latest version
;;     (v2-balance (unwrap-panic (contract-call? .zdiko-v1-2 get-principal-balance account)))
;;     )
;;     ;; if doesn't have v1 balance, then check if has v2 balance
;;     (if (> v2-balance u0)
;;       (begin
;;         (try! (contract-call? .zdiko-v1-2 burn v2-balance account))
;;         (try! (contract-call? .zdiko-v2-0 mint v2-balance account))
;;         true
;;       )
;;       false
;;     )
;;     (ok true)
;;   )
;; )

;; (define-private (consolidate-usdh-balance-to-v3 (account principal))
;;   (let (
;;     ;; burns old balances and mints to the latest version
;;     (v2-balance (unwrap-panic (contract-call? .zusdh-v1-2 get-principal-balance account)))
;;     )
;;     ;; if doesn't have v1 balance, then check if has v2 balance
;;     (if (> v2-balance u0)
;;       (begin
;;         (try! (contract-call? .zusdh-v1-2 burn v2-balance account))
;;         (try! (contract-call? .zusdh-v2-0 mint v2-balance account))
;;         true
;;       )
;;       false
;;     )
;;     (ok true)
;;   )
;; )

;; (define-private (consolidate-susdt-balance-to-v3 (account principal))
;;   (let (
;;     ;; burns old balances and mints to the latest version
;;     (v2-balance (unwrap-panic (contract-call? .zsusdt-v1-2 get-principal-balance account)))
;;     )
;;     ;; if doesn't have v1 balance, then check if has v2 balance
;;     (if (> v2-balance u0)
;;       (begin
;;         (try! (contract-call? .zsusdt-v1-2 burn v2-balance account))
;;         (try! (contract-call? .zsusdt-v2-0 mint v2-balance account))
;;         true
;;       )
;;       false
;;     )
;;     (ok true)
;;   )
;; )

(define-private (consolidate-usda-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v2-balance (unwrap-panic (contract-call? .zusda-v1-2 get-principal-balance account)))
    )
    ;; if doesn't have v1 balance, then check if has v2 balance
    (if (> v2-balance u0)
      (begin
        (try! (contract-call? .zusda-v1-2 burn v2-balance account))
        (try! (contract-call? .zusda-v2-0 mint v2-balance account))
        true
      )
      false
    )
    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)

(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set enabled false))
  )
)

;; (run-update)
;; (burn-mint-zststx)
```
