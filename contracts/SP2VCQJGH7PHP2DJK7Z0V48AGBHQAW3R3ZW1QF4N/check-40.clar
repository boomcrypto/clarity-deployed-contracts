;; Used to simulate mainnet migration from v1 to v2 in the test suite
;; Must be called after deploying migrate-v0-v1.clar

(define-constant deployer tx-sender)

(define-data-var executed bool false)
(define-data-var executed-burn-mint bool false)
(define-data-var executed-reserve-data-update bool false)
(define-data-var executed-borrower-block-height bool false)
(define-data-var enabled bool true)

;; TODO: to fetch off-chain
(define-constant holders (list
'SP3X6G145Z6DV5H49MN0P0RK9SXY83ZN4ACM3RPMA
;; 'SP2BY7JAXFAXT0QZQNS8SBJJ09E20JHB0FRM48SVH
;; 'SP3V2DGJ3EVPY680F4N7ZF69152W05X4JH3X0P6RV
))

(define-public (burn-mint)
  (begin
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-burn-mint)) (err u12))
    ;; enable zsusdt access
    (try! (contract-call? .zsusdt-token set-approved-contract .zsusdt-v2-0 true))

    (try! (contract-call? .zsusdt-v1-2 set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zsusdt-v2-0 set-approved-contract (as-contract tx-sender) true))

    ;; burn/mint v2 to v3
    (try! (fold check-err (map consolidate-susdt-lambda holders) (ok true)))

    ;; disable access
    (try! (contract-call? .zsusdt-v1-2 set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zsusdt-v2-0 set-approved-contract (as-contract tx-sender) false))

    (asserts! false (err u1337))
    (var-set executed-burn-mint true)
    (ok true)
  )
)


(define-private (consolidate-ststx-lambda (account principal))
  (consolidate-ststx-balance-to-v3 account)
)

(define-private (consolidate-aeusdc-lambda (account principal))
  (consolidate-aeusdc-balance-to-v3 account)
)

(define-private (consolidate-wstx-lambda (account principal))
  (consolidate-wstx-balance-to-v3 account)
)

(define-private (consolidate-diko-lambda (account principal))
  (consolidate-diko-balance-to-v3 account)
)

(define-private (consolidate-usdh-lambda (account principal))
  (consolidate-usdh-balance-to-v3 account)
)

(define-private (consolidate-susdt-lambda (account principal))
  (consolidate-susdt-balance-to-v3 account)
)

(define-private (consolidate-usda-lambda (account principal))
  (consolidate-usda-balance-to-v3 account)
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (consolidate-ststx-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v0-balance (unwrap-panic (contract-call? .zststx get-principal-balance account)))
    (v1-balance (unwrap-panic (contract-call? .zststx-v1-0 get-principal-balance account)))
    (v2-balance (unwrap-panic (contract-call? .zststx-v1-2 get-principal-balance account)))
    )
    (if (> v0-balance u0)
      (begin
        (try! (contract-call? .zststx burn v0-balance account))
        (try! (contract-call? .zststx-v2-0 mint v0-balance account))
        true
      )
      ;; if doesn't have v0 balance, then check if has v1 balance
      (if (> v1-balance u0)
        (begin
          (try! (contract-call? .zststx-v1-0 burn v1-balance account))
          (try! (contract-call? .zststx-v2-0 mint v1-balance account))
          true
        )
        ;; if doesn't have v1 balance, then check if has v2 balance
        (if (> v2-balance u0)
          (begin
            (try! (contract-call? .zststx-v1-2 burn v2-balance account))
            (try! (contract-call? .zststx-v2-0 mint v2-balance account))
            true
          )
          false
        )
      )
    )
    (ok true)
  )
)

(define-private (consolidate-aeusdc-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v0-balance (unwrap-panic (contract-call? .zaeusdc get-principal-balance account)))
    (v1-balance (unwrap-panic (contract-call? .zaeusdc-v1-0 get-principal-balance account)))
    (v2-balance (unwrap-panic (contract-call? .zaeusdc-v1-2 get-principal-balance account)))
    )
    (if (> v0-balance u0)
      (begin
        (try! (contract-call? .zaeusdc burn v0-balance account))
        (try! (contract-call? .zaeusdc-v2-0 mint v0-balance account))
        true
      )
      ;; if doesn't have v0 balance, then check if has v1 balance
      (if (> v1-balance u0)
        (begin
          (try! (contract-call? .zaeusdc-v1-0 burn v1-balance account))
          (try! (contract-call? .zaeusdc-v2-0 mint v1-balance account))
          true
        )
        ;; if doesn't have v1 balance, then check if has v2 balance
        (if (> v2-balance u0)
          (begin
            (try! (contract-call? .zaeusdc-v1-2 burn v2-balance account))
            (try! (contract-call? .zaeusdc-v2-0 mint v2-balance account))
            true
          )
          false
        )
      )
    )
    (ok true)
  )
)

(define-private (consolidate-wstx-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v0-balance (unwrap-panic (contract-call? .zwstx get-principal-balance account)))
    (v1-balance (unwrap-panic (contract-call? .zwstx-v1 get-principal-balance account)))
    (v2-balance (unwrap-panic (contract-call? .zwstx-v1-2-1 get-principal-balance account)))
    )
    (if (> v0-balance u0)
      (begin
        (try! (contract-call? .zwstx burn v0-balance account))
        (try! (contract-call? .zwstx-v2-0 mint v0-balance account))
        true
      )
      ;; if doesn't have v0 balance, then check if has v1 balance
      (if (> v1-balance u0)
        (begin
          (try! (contract-call? .zwstx-v1 burn v1-balance account))
          (try! (contract-call? .zwstx-v2-0 mint v1-balance account))
          true
        )
        ;; if doesn't have v1 balance, then check if has v2 balance
        (if (> v2-balance u0)
          (begin
            (try! (contract-call? .zwstx-v1-2-1 burn v2-balance account))
            (try! (contract-call? .zwstx-v2-0 mint v2-balance account))
            true
          )
          false
        )
      )
    )
    (ok true)
  )
)

(define-private (consolidate-diko-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v2-balance (unwrap-panic (contract-call? .zdiko-v1-2 get-principal-balance account)))
    )
    ;; if doesn't have v1 balance, then check if has v2 balance
    (if (> v2-balance u0)
      (begin
        (try! (contract-call? .zdiko-v1-2 burn v2-balance account))
        (try! (contract-call? .zdiko-v2-0 mint v2-balance account))
        true
      )
      false
    )
    (ok true)
  )
)

(define-private (consolidate-usdh-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v2-balance (unwrap-panic (contract-call? .zusdh-v1-2 get-principal-balance account)))
    )
    ;; if doesn't have v1 balance, then check if has v2 balance
    (if (> v2-balance u0)
      (begin
        (try! (contract-call? .zusdh-v1-2 burn v2-balance account))
        (try! (contract-call? .zusdh-v2-0 mint v2-balance account))
        true
      )
      false
    )
    (ok true)
  )
)

(define-private (consolidate-susdt-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v2-balance (unwrap-panic (contract-call? .zsusdt-v1-2 get-principal-balance account)))
    )
    ;; if doesn't have v1 balance, then check if has v2 balance
    (if (> v2-balance u0)
      (begin
        (try! (contract-call? .zsusdt-v1-2 burn v2-balance account))
        (try! (contract-call? .zsusdt-v2-0 mint v2-balance account))
        true
      )
      false
    )
    (ok true)
  )
)

(define-private (consolidate-usda-balance-to-v3 (account principal))
  (let (
    ;; burns old balances and mints to the latest version
    (v2-balance (unwrap-panic (contract-call? .zusda-v1-2 get-principal-balance account)))
    )
    ;; if doesn't have v1 balance, then check if has v2 balance
    (if (> v2-balance u0)
      (begin
        (try! (contract-call? .zusda-v1-2 burn v2-balance account))
        (try! (contract-call? .zusda-v2-0 mint v2-balance account))
        true
      )
      false
    )
    (ok true)
  )
)

(define-read-only (can-execute)
  (begin
    (asserts! (not (var-get enabled)) (err u10))
    (ok (not (var-get enabled)))
  )
)


(define-public (disable)
  (begin
    (asserts! (is-eq deployer tx-sender) (err u11))
    (ok (var-set enabled false))
  )
)

