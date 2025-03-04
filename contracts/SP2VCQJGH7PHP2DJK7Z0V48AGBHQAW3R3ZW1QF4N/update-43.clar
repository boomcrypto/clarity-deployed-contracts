;; Used to simulate mainnet migration from v1 to v2 in the test suite
;; Must be called after deploying migrate-v0-v1.clar

(define-data-var executed bool false)
(define-data-var executed-burn-mint bool false)
(define-data-var executed-reserve-data-update bool false)
(define-data-var executed-borrower-block-height bool false)

(define-data-var enabled bool true)
(define-constant deployer tx-sender)

(define-public (run-update)
  (begin
    (asserts! (var-get enabled) (err u10))
    (asserts! (not (var-get executed)) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))

    ;; update helper caller
    ;; (try! (contract-call? .pool-borrow-v2-0 set-approved-contract .borrow-helper-v2-0 false))

    (try! (contract-call? .zsbtc-token set-approved-contract .zsbtc-v2-0 true))

    (var-set executed true)
    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get executed)) (err u10))
    (ok (not (var-get executed)))
  )
)

(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set enabled false))
  )
)

;; (run-update)
;; (burn-mint-zststx)