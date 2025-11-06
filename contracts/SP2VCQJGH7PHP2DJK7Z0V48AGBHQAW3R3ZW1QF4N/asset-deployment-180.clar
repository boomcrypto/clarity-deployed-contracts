(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant flashloan-fee-total u500)
(define-constant flashloan-fee-protocol u500)

(define-constant ststx-token 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
(define-constant stx-token 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx)

(define-public (run-update)
  (let (
    (reserve-data-1 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read ststx-token)))
    (reserve-data-2 (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read stx-token)))
  )
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (print reserve-data-1)
    (print reserve-data-2)

    (try!
      (contract-call? .pool-borrow-v2-2
        set-reserve
        ststx-token
        (merge reserve-data-1 { flashloan-enabled: true })
      )
    )
    (try!
      (contract-call? .pool-borrow-v2-2
        set-reserve
        stx-token
        (merge reserve-data-2 { flashloan-enabled: true })
      )
    )

    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

    (try! (contract-call? .pool-reserve-data set-flashloan-fee-total ststx-token flashloan-fee-total))
    (try! (contract-call? .pool-reserve-data set-flashloan-fee-protocol ststx-token flashloan-fee-protocol))

    (try! (contract-call? .pool-reserve-data set-flashloan-fee-total stx-token flashloan-fee-total))
    (try! (contract-call? .pool-reserve-data set-flashloan-fee-protocol stx-token flashloan-fee-protocol))

    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

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
