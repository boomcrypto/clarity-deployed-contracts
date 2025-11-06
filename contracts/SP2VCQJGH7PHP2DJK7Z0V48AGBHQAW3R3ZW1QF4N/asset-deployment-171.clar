(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    ;; permissions
    (try! (contract-call? .pool-borrow-v2-1 set-approved-contract .borrow-helper-v2-1-2 false))
    (try! (contract-call? .pool-borrow-v2-1 set-approved-contract .borrow-helper-v2-1-3 true))

    (try! (contract-call? .incentives-v2-2 set-approved-contract .borrow-helper-v2-1-2 false))
    (try! (contract-call? .incentives-v2-2 set-approved-contract .borrow-helper-v2-1-3 true))

    (try! (contract-call? .incentives-v2-2 set-price 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token u10200000000000))
    (try! (contract-call? .incentives-v2-2 set-price .wstx u87000000))

    (try! (contract-call? .flashloan-data set-approved-sender 'SP2YHB356J5MKXF08WKB7214AWM5RJV1HWB28G9TA true))

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
