(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant ststx-debt-ceiling u500000000000000)
(define-constant ststxbtc-debt-ceiling u250000000000000)

(define-constant ststx-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant ststxbtc-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-token)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststxbtc-token)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (print reserve-data-1)
    (print reserve-data-2)

    (try!
      (contract-call? .pool-borrow-v2-1 set-reserve ststx-token
        (merge reserve-data-1 { debt-ceiling: ststx-debt-ceiling })
      )
    )

    (try!
      (contract-call? .pool-borrow-v2-1 set-reserve ststxbtc-token
        (merge reserve-data-2 { debt-ceiling: ststxbtc-debt-ceiling })
      )
    )

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
