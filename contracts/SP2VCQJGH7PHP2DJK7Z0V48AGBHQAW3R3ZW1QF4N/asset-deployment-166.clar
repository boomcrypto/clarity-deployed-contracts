(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    ;; permissions
    (try! (contract-call? .pool-borrow-v2-1 set-approved-contract .borrow-helper-v2-1-1 false))
    (try! (contract-call? .pool-borrow-v2-1 set-approved-contract .borrow-helper-v2-1-2 true))

    (try! (contract-call? .incentives-v2-2 set-approved-contract .borrow-helper-v2-1-1 false))
    (try! (contract-call? .incentives-v2-2 set-approved-contract .borrow-helper-v2-1-2 true))

    (try! (contract-call? .incentives-v2-2 set-price 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token u9400000000000))
    (try! (contract-call? .incentives-v2-2 set-price .wstx u79000000))

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
