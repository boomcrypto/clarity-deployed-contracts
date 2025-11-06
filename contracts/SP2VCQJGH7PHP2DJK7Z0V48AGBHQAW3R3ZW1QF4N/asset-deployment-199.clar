(define-data-var executed bool false)
(define-constant deployer tx-sender)


(define-public (run-update)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    (try! (contract-call? .zststxbtc-v2-0 set-approved-contract .liquidation-manager-v2-1 false))
    (try! (contract-call? .zststxbtc-v2-0 set-approved-contract .liquidation-manager-v2-2 true))

    (try! (contract-call? .zsbtc-v2-0 set-approved-contract .liquidation-manager-v2-1 false))
    (try! (contract-call? .zsbtc-v2-0 set-approved-contract .liquidation-manager-v2-2 true))

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
