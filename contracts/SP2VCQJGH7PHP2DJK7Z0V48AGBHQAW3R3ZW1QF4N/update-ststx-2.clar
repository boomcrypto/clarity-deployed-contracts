(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant new-borrow-cap u500000000000)
(define-constant is-borrowing-enabled true)

(define-constant updated-reserve-asset-1 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)

(define-constant curve-params
  {
    base-variable-borrow-rate: u0,
    variable-rate-slope-1: u7000000,
    variable-rate-slope-2: u300000000,
    optimal-utilization-rate: u45000000,
    liquidation-close-factor-percent: u5000000,
    origination-fee-prc: u0,
    reserve-factor: u10000000,
  }
)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (print reserve-data-1)

    (try!
      (contract-call? .pool-borrow-v1-2 set-reserve updated-reserve-asset-1
        (merge reserve-data-1 { borrow-cap: new-borrow-cap, borrowing-enabled: is-borrowing-enabled })
      )
    )

    ;; Interest Curve parameters
    (try! (contract-call? .pool-reserve-data set-base-variable-borrow-rate updated-reserve-asset-1 (get base-variable-borrow-rate curve-params)))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-1 updated-reserve-asset-1 (get variable-rate-slope-1 curve-params)))
    (try! (contract-call? .pool-reserve-data set-variable-rate-slope-2 updated-reserve-asset-1 (get variable-rate-slope-2 curve-params)))
    (try! (contract-call? .pool-reserve-data set-optimal-utilization-rate updated-reserve-asset-1 (get optimal-utilization-rate curve-params)))
    (try! (contract-call? .pool-reserve-data set-liquidation-close-factor-percent updated-reserve-asset-1 (get liquidation-close-factor-percent curve-params)))
    (try! (contract-call? .pool-reserve-data set-origination-fee-prc updated-reserve-asset-1 (get origination-fee-prc curve-params)))
    (try! (contract-call? .pool-reserve-data set-reserve-factor updated-reserve-asset-1 (get reserve-factor curve-params)))

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read updated-reserve-asset-1)))
  )
    {
      before: reserve-data-1,
      reserve-after: (merge reserve-data-1 { borrow-cap: new-borrow-cap, borrowing-enabled: is-borrowing-enabled}),
      curve-params: curve-params,
    }
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
