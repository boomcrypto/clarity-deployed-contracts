(define-data-var executed bool false)
(define-constant deployer tx-sender)

(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    ;; permissions
    (try! (contract-call? .pool-borrow-v2-0-2 set-approved-contract .borrow-helper-v2-0-4 false))
    (try! (contract-call? .pool-borrow-v2-0-2 set-approved-contract .borrow-helper-v2-0-5 true))

    ;; rewards-data permissions
    (try! (contract-call? .rewards-data set-approved-contract .incentives false))
    (try! (contract-call? .rewards-data set-approved-contract .incentives-v2-0 true))
    ;; already set by default, but should set this explicitly
    (try! (contract-call? .rewards-data set-rewards-contract .incentives-v2-0))

    ;; intializing sbtc -> wstx rewards
    (try! (contract-call? .incentives set-approved-contract .borrow-helper-v2-0-4 false))
    (try! (contract-call? .incentives-v2-0 set-approved-contract .borrow-helper-v2-0-5 true))


    ;; clear assets
    (let (
      (stx-balance (stx-get-balance .incentives))
      )
      (try! (contract-call? .incentives withdraw-assets .wstx stx-balance tx-sender))
      (try! (stx-transfer? stx-balance tx-sender .incentives-v2-0))
    )

    (try! (contract-call? .incentives-v2-0 set-price 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token u8500000000000))
    (try! (contract-call? .incentives-v2-0 set-price .wstx u60000000))

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
