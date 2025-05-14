(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant ststxbtc-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)
(define-constant new-settings {
  grace-period-enabled: false,
  grace-period-time: u1,
  freeze-end-block: burn-block-height,
})

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-enabled ststxbtc-token (get grace-period-enabled new-settings)))
    (try! (contract-call? .pool-borrow-v2-0 set-grace-period-time ststxbtc-token (get grace-period-time new-settings)))
    (try! (contract-call? .pool-borrow-v2-0 set-freeze-end-block ststxbtc-token (get freeze-end-block new-settings)))

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (preview-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststxbtc-token)))
  )
    (print {
      before: {
        grace-period-enabled: (contract-call? .pool-reserve-data-1 get-grace-period-enabled-read ststxbtc-token),
        grace-period-time: (contract-call? .pool-reserve-data-1 get-grace-period-time-read ststxbtc-token),
        freeze-end-block: (contract-call? .pool-reserve-data-1 get-freeze-end-block-read ststxbtc-token),
      },
      after: {
        grace-period-enabled: (get grace-period-enabled new-settings),
        grace-period-time: (get grace-period-time new-settings),
        freeze-end-block: (get freeze-end-block new-settings),
      },
    })
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
