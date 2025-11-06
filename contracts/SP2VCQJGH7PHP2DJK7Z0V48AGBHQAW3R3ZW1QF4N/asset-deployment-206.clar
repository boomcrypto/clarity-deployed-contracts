(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-constant ststxbtc-address 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token-v2)

(define-constant liquidation-bonus u5000000)

(define-constant stx-emode-type 0x01)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .pool-reserve-data-4 set-approved-contract (as-contract tx-sender) true))

    (try! (contract-call? .pool-reserve-data-4 set-liquidation-bonus-e-mode ststxbtc-address liquidation-bonus))

    (try! (contract-call? .pool-reserve-data-4 set-approved-contract (as-contract tx-sender) false))

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
