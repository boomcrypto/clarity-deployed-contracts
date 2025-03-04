(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    ;; permissions
    (try! (contract-call? .pool-borrow-v2-0 set-approved-contract .borrow-helper-v2-0-0 false))
    (try! (contract-call? .pool-borrow-v2-0 set-approved-contract .borrow-helper-v2-0-1 true))

    ;; rewards-data permissions
    (try! (contract-call? .rewards-data set-approved-contract .incentives true))
    ;; already set by default, but should set this explicitly
    ;; (try! (contract-call? .rewards-data set-rewards-contract .incentives))

    ;; intializing sbtc -> wstx rewards
    (try! (contract-call? .incentives set-approved-contract .borrow-helper-v2-0-1 true))

    (try! (contract-call? .incentives initialize-reward-program-data 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token .wstx))
    (try! (contract-call? .incentives set-liquidity-rate 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token .wstx u0))

    (try! (contract-call? .incentives set-price 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token u8500000000000))
    (try! (contract-call? .incentives set-price .wstx u72000000))

    (try! (contract-call? .incentives set-precision 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token u8))
    (try! (contract-call? .incentives set-precision .wstx u6))

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
