(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    ;; pool-0-reserve permissions
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 set-liquidator 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 set-lending-pool 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1))

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    ;; END pool-0-reserve permissions

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1 set-lending-pool 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1))

    ;; update helper caller
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-0-3 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-0-2 false))

    ;; update incentives caller
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-0-3 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-0-2 false))

    ;; pool-reserve-data permissions
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-1 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-1 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-2 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-2 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))

    ;; ;; STSTX UPGRADE
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1 true))
    ;; ;; ===

    ;; ;; aeUSDC UPGRADE
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1 true))
    ;; ;; ===

    ;; ;; wstx UPGRADE
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1 true))
    ;; ;; ===

    ;; ;; diko UPGRADE
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1 true))
    ;; ;; ===

    ;; ;; usdh UPGRADE
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1 true))
    ;; ;; ===

    ;; ;; susdt UPGRADE
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1 true))
    ;; ;; ===

    ;; ;; usda UPGRADE
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1 true))
    ;; ;; ===

    ;; ;; sbtc UPGRADE
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1 true))
    ;; ;; ===

    ;; ;; ststxbtc UPGRADE
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0-1 true))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0 false))
    ;; (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0 set-approved-contract 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-0-1 true))
    ;; ;; ===

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
