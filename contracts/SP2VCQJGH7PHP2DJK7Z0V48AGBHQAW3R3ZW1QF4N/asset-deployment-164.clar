(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant alex-token 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex)
(define-constant alex-z-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zalex-v2-0)

(define-constant alex-supply-cap u230000000000000)
(define-constant alex-borrow-cap u230000000000000)
(define-constant decimals u8)

(define-constant curve-params
  {
    base-variable-borrow-rate: u0,
    variable-rate-slope-1: u7000000,
    variable-rate-slope-2: u300000000,
    optimal-utilization-rate: u45000000,
    liquidation-close-factor-percent: u50000000,
    origination-fee-prc: u0,
    reserve-factor: u10000000,
  }
)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .zalex-v2-0 set-approved-contract .pool-borrow-v2-1 true))
    (try! (contract-call? .zalex-v2-0 set-approved-contract .liquidation-manager-v2-1 true))
    (try! (contract-call? .zalex-v2-0 set-approved-contract .pool-0-reserve-v2-0 true))

    (try! (contract-call? .zalex-token set-approved-contract alex-z-token true))

    (try!
      (contract-call? .pool-borrow-v2-1 init
        alex-z-token
        alex-token
        decimals
        alex-supply-cap
        alex-borrow-cap
        .alex-oracle-v1-0
        alex-z-token
      )
    )
    (try! (contract-call? .pool-borrow-v2-1 add-asset alex-token))

    ;; Curve parameters
    (try! (contract-call? .pool-reserve-data set-base-variable-borrow-rate alex-token (get base-variable-borrow-rate curve-params)))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 alex-token (get variable-rate-slope-1 curve-params)))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-2 alex-token (get variable-rate-slope-2 curve-params)))
    (try! (contract-call? .pool-reserve-data set-optimal-utilization-rate alex-token (get optimal-utilization-rate curve-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent alex-token (get liquidation-close-factor-percent curve-params)))
    (try! (contract-call? .pool-reserve-data set-origination-fee-prc alex-token (get origination-fee-prc curve-params)))
    (try! (contract-call? .pool-reserve-data set-reserve-factor alex-token (get reserve-factor curve-params)))

    (try! (contract-call? .pool-borrow-v2-1 set-grace-period-enabled alex-z-token false))
    (try! (contract-call? .pool-borrow-v2-1 set-freeze-end-block alex-z-token burn-block-height))

    ;; collateral settings
    (try! 
      (contract-call? .pool-borrow-v2-1 set-usage-as-collateral-enabled
        alex-token
        true
        u30000000
        u50000000
        u10000000
      )
    )

    (try! (contract-call? .pool-borrow-v2-1 add-isolated-asset alex-token u50000000000000))


    (try! (contract-call? .pool-borrow-v2-1 set-borrowing-enabled alex-token true))
    (try! (contract-call? .pool-borrow-v2-1 set-borroweable-isolated alex-token))

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
