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
    (asserts! (var-get enabled) (err u10))
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve ststx-address
        (merge reserve-data-1 {
          a-token-address: v2-0-version-ststx
        })
      )
    )
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve aeusdc-address
        (merge reserve-data-2 {
          a-token-address: v2-0-version-aeusdc
        })
      )
    )
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve wstx-address
        (merge reserve-data-3 {
          a-token-address: v2-0-version-wstx
        })
      )
    )
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve diko-address
        (merge reserve-data-4 {
          a-token-address: v2-0-version-diko
        })
      )
    )
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve usdh-address
        (merge reserve-data-5 {
          a-token-address: v2-0-version-usdh
        })
      )
    )
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve susdt-address
        (merge reserve-data-6 {
          a-token-address: v2-0-version-susdt
        })
      ) 
    )
    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve usda-address
        (merge reserve-data-7 {
          a-token-address: v2-0-version-usda
        })
      )
    )

    (try! (contract-call? .liquidation-manager-v2-0 set-lending-pool .pool-borrow-v2-0))
    
    ;; pass permission to new pool-0-reserve. pool-0-reserve is used for transferring from pool-vault
    (try! (contract-call? .pool-0-reserve set-lending-pool .pool-0-reserve-v2-0))
    (try! (contract-call? .pool-0-reserve set-liquidator .pool-0-reserve-v2-0))
    (try! (contract-call? .pool-0-reserve set-approved-contract .pool-borrow false))
    (try! (contract-call? .pool-0-reserve set-approved-contract .pool-borrow-v1-2 false))

    ;; disable previous permissions
    (try! (contract-call? .pool-0-reserve-v1-2 set-approved-contract .pool-borrow-v1-2 false))

    (try! (contract-call? .pool-0-reserve-v2-0 set-liquidator .liquidation-manager-v2-0))
    (try! (contract-call? .pool-0-reserve-v2-0 set-lending-pool .pool-borrow-v2-0))
    (try! (contract-call? .pool-0-reserve-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    ;; END pool-0-reserve permissions

    ;; update helper caller
    (try! (contract-call? .pool-borrow-v1-2 set-approved-contract .borrow-helper-v1-2 false))
    (try! (contract-call? .pool-borrow-v2-0 set-approved-contract .borrow-helper-v2-0 true))

    ;; update pool-reserve-data controller
    (try! (contract-call? .pool-reserve-data set-approved-contract .pool-0-reserve-v1-2 false))

    (try! (contract-call? .pool-reserve-data set-approved-contract .pool-0-reserve-v2-0 true))
    (try! (contract-call? .pool-reserve-data set-approved-contract .pool-borrow-v2-0 true))

    (try! (contract-call? .pool-reserve-data-1 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? .pool-reserve-data-1 set-approved-contract .pool-0-reserve-v2-0 true))

    (try! (contract-call? .pool-reserve-data-2 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? .pool-reserve-data-2 set-approved-contract .pool-0-reserve-v2-0 true))

    ;; STSTX UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    ;; permission to ztoken contract
    (try! (contract-call? .zststx-token set-approved-contract v2-0-version-ststx true))
    ;; permission to logic lp token
    ;; revoke pool-borrow permissions to v1-2 version
    (try! (contract-call? .zststx-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    (try! (contract-call? .zststx-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    (try! (contract-call? .zststx-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; disable access to v0, v1 from v1-2
    (try! (contract-call? .zststx set-approved-contract v1-2-version-ststx false))
    (try! (contract-call? .zststx-v1-0 set-approved-contract v1-2-version-ststx false))
    ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    (try! (contract-call? .zststx-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? .zststx-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    (try! (contract-call? .zststx-v2-0 set-approved-contract .pool-0-reserve-v2-0 true))
    ;; ===

    ;; aeUSDC UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    ;; permission to ztoken contract
    (try! (contract-call? .zaeusdc-token set-approved-contract v2-0-version-aeusdc true))
    ;; permission to logic lp token
    ;; revoke pool-borrow permissions to v1-2 version
    (try! (contract-call? .zaeusdc-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    (try! (contract-call? .zaeusdc-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    (try! (contract-call? .zaeusdc-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; disable access to v0, v1-0 from v1-2
    (try! (contract-call? .zaeusdc set-approved-contract v1-2-version-aeusdc false))
    (try! (contract-call? .zaeusdc-v1-0 set-approved-contract v1-2-version-aeusdc false))
    ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    (try! (contract-call? .zaeusdc-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? .zaeusdc-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    (try! (contract-call? .zaeusdc-v2-0 set-approved-contract .pool-0-reserve-v2-0 true))
    ;; ===

    ;; wstx UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    ;; permission to ztoken contract
    (try! (contract-call? .zwstx-token set-approved-contract v2-0-version-wstx true))
    ;; permission to logic lp token
    ;; revoke pool-borrow permissions to v1-2 version
    (try! (contract-call? .zwstx-v1-2-1 set-approved-contract .pool-borrow-v1-2 false))
    (try! (contract-call? .zwstx-v1-2-1 set-approved-contract .liquidation-manager-v1-2 false))
    (try! (contract-call? .zwstx-v1-2-1 set-approved-contract pool-0-reserve-v0 false))
    ;; disable access from v0, v1 to v1-2
    (try! (contract-call? .zwstx set-approved-contract v1-2-version-wstx false))
    (try! (contract-call? .zwstx-v1 set-approved-contract v1-2-version-wstx false))
    ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    (try! (contract-call? .zwstx-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? .zwstx-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    (try! (contract-call? .zwstx-v2-0 set-approved-contract .pool-0-reserve-v2-0 true))
    ;; ===

    ;; diko UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    ;; permission to ztoken contract
    (try! (contract-call? .zdiko-token set-approved-contract v2-0-version-diko true))
    ;; permission to logic lp token
    ;; revoke pool-borrow permissions to v1-2 version
    (try! (contract-call? .zdiko-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    (try! (contract-call? .zdiko-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    (try! (contract-call? .zdiko-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; no v1-2 version in diko
    ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    (try! (contract-call? .zdiko-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? .zdiko-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    (try! (contract-call? .zdiko-v2-0 set-approved-contract .pool-0-reserve-v2-0 true))
    ;; ===

    ;; usdh UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    ;; permission to ztoken contract
    (try! (contract-call? .zusdh-token set-approved-contract v2-0-version-usdh true))
    ;; permission to logic lp token
    ;; revoke pool-borrow permissions to v1-2 version
    (try! (contract-call? .zusdh-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    (try! (contract-call? .zusdh-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    (try! (contract-call? .zusdh-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; no v1-2 version in usdh
    ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    (try! (contract-call? .zusdh-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? .zusdh-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    (try! (contract-call? .zusdh-v2-0 set-approved-contract .pool-0-reserve-v2-0 true))
    ;; ===

    ;; susdt UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    ;; permission to ztoken contract
    (try! (contract-call? .zsusdt-token set-approved-contract v2-0-version-susdt true))
    ;; permission to logic lp token
    ;; revoke pool-borrow permissions to v1-2 version
    (try! (contract-call? .zsusdt-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    (try! (contract-call? .zsusdt-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    (try! (contract-call? .zsusdt-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; no v1-2 version in susdt
    ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    (try! (contract-call? .zsusdt-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? .zsusdt-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    (try! (contract-call? .zsusdt-v2-0 set-approved-contract .pool-0-reserve-v2-0 true))
    ;; ===

    ;; usda UPGRADE
    ;; give permission for burn/mint of previous versions to new version
    ;; permission to ztoken contract
    (try! (contract-call? .zusda-token set-approved-contract v2-0-version-usda true))
    ;; permission to logic lp token
    ;; revoke pool-borrow permissions to v1-2 version
    (try! (contract-call? .zusda-v1-2 set-approved-contract .pool-borrow-v1-2 false))
    (try! (contract-call? .zusda-v1-2 set-approved-contract .liquidation-manager-v1-2 false))
    (try! (contract-call? .zusda-v1-2 set-approved-contract pool-0-reserve-v0 false))
    ;; no v1-2 version in usda
    ;; Give permission to new pool-borrow, liquidation-manager and pool-0-reserve
    (try! (contract-call? .zusda-v2-0 set-approved-contract .pool-borrow-v2-0 true))
    (try! (contract-call? .zusda-v2-0 set-approved-contract .liquidation-manager-v2-0 true))
    (try! (contract-call? .zusda-v2-0 set-approved-contract .pool-0-reserve-v2-0 true))
    ;; ===


    ;; running test
    ;; (try!
    ;;   (contract-call? .pool-borrow-v2-0 set-reserve ststx-address
    ;;     (merge
    ;;       (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-address))
    ;;       { is-frozen: false }
    ;;     )
    ;;   )
    ;; )

    ;; (try! (stx-transfer? u1000000 tx-sender (as-contract tx-sender)))
    ;; (try!
    ;;   (as-contract
    ;;     (contract-call?
    ;;       .borrow-helper-v2-0-0
    ;;       supply
    ;;       .zststx-v2-0
    ;;       .pool-0-reserve-v2-0
    ;;       ststx-address
    ;;       u1000000
    ;;       tx-sender
    ;;       none
    ;;     )
    ;;   )
    ;; )
    ;; running test
    ;; revert all the changes
    ;; (asserts! false (err u1337))
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

(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set enabled false))
  )
)

;; (run-update)
;; (burn-mint-zststx)