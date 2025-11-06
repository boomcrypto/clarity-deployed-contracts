(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant prev-pool-borrow 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-2)
(define-constant new-pool-borrow 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-3)

(define-constant prev-liquidation-manager 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-2)
(define-constant new-liquidation-manager 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-3)

(define-constant prev-borrow-helper 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-1-4)
(define-constant new-borrow-helper 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.borrow-helper-v2-1-5)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    ;; pool-0-reserve permissions
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 set-liquidator new-liquidation-manager))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 set-lending-pool new-pool-borrow))

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-0-reserve-v2-0 set-approved-contract prev-pool-borrow false))
    ;; END pool-0-reserve permissions

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-2 set-lending-pool tx-sender))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.liquidation-manager-v2-3 set-lending-pool new-pool-borrow))

    ;; update helper caller
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-3 set-approved-contract new-borrow-helper true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-borrow-v2-2 set-approved-contract prev-borrow-helper false))

    ;; update incentives caller
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-v2-2 set-approved-contract new-borrow-helper true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-v2-2 set-approved-contract prev-borrow-helper false))

    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-v2-2 set-price 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token u10700000000000))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-v2-2 set-price .wstx u70000000))

    ;; pool-reserve-data permissions
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-1 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-1 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-2 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-2 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-3 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data-3 set-approved-contract prev-pool-borrow false))

    ;; STSTX UPGRADE
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0 set-approved-contract prev-liquidation-manager false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v2-0 set-approved-contract new-liquidation-manager true))
    ;; ===

    ;; aeUSDC UPGRADE
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0 set-approved-contract prev-liquidation-manager false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zaeusdc-v2-0 set-approved-contract new-liquidation-manager true))
    ;; ===

    ;; wstx UPGRADE
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0 set-approved-contract prev-liquidation-manager false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zwstx-v2-0 set-approved-contract new-liquidation-manager true))
    ;; ===

    ;; diko UPGRADE
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0 set-approved-contract prev-liquidation-manager false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zdiko-v2-0 set-approved-contract new-liquidation-manager true))
    ;; ===

    ;; usdh UPGRADE
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0 set-approved-contract prev-liquidation-manager false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusdh-v2-0 set-approved-contract new-liquidation-manager true))
    ;; ===

    ;; susdt UPGRADE
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0 set-approved-contract prev-liquidation-manager false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0 set-approved-contract new-liquidation-manager true))
    ;; ===

    ;; usda UPGRADE
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0 set-approved-contract prev-liquidation-manager false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zusda-v2-0 set-approved-contract new-liquidation-manager true))
    ;; ===

    ;; sbtc UPGRADE
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract prev-liquidation-manager false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 set-approved-contract new-liquidation-manager true))
    ;; ===

    ;; ststxbtc UPGRADE
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0 set-approved-contract prev-liquidation-manager false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-0 set-approved-contract new-liquidation-manager true))
    ;; ===

    ;; alex UPGRADE
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zalex-v2-0 set-approved-contract new-pool-borrow true))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zalex-v2-0 set-approved-contract prev-pool-borrow false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zalex-v2-0 set-approved-contract prev-liquidation-manager false))
    (try! (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zalex-v2-0 set-approved-contract new-liquidation-manager true))
    ;; ===

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