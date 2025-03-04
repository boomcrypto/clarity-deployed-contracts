;; Used to simulate mainnet migration from v1 to v2 in the test suite
;; Must be called after deploying migrate-v0-v1.clar

(define-data-var executed bool false)
(define-data-var executed-burn-mint bool false)
(define-data-var executed-reserve-data-update bool false)
(define-data-var executed-borrower-block-height bool false)

(define-data-var enabled bool true)
(define-constant deployer tx-sender)

(define-constant reserve-stacks-block-height-susdt u343387)

(define-public (set-reserve-block-height)
  (begin
    ;; TODO: remove 
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-reserve-data-update)) (err u10))

    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) true))

    (try! (set-reserve-burn-block-height-to-stacks-block-height
      'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
      reserve-stacks-block-height-susdt))

    ;; disable access
    (try! (contract-call? .pool-reserve-data set-approved-contract (as-contract tx-sender) false))

    (var-set executed-reserve-data-update true)
    (ok true)
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (set-reserve-burn-block-height-to-stacks-block-height
  (asset principal)
  (new-stacks-block-height uint))
  (begin
    (try!
      (contract-call? .pool-reserve-data set-reserve-state
        asset
        (merge
          (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read asset))
          { last-updated-block: new-stacks-block-height })))
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