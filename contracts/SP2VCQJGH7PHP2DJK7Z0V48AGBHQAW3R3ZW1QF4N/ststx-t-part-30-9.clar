;; Used to simulate mainnet migration from v1 to v2 in the test suite
;; Must be called after deploying migrate-v0-v1.clar

(define-constant deployer tx-sender)

(define-data-var executed bool false)
(define-data-var executed-burn-mint bool false)
(define-data-var executed-reserve-data-update bool false)
(define-data-var executed-borrower-block-height bool false)
(define-data-var enabled bool true)

;; TODO: to fetch off-chain
(define-constant ststx-holders (list
 'SP15ASP2D38SY65RGYQJEYF382VAH5Y4E9KX5MQ5B
 'SP1C31SGCE3KYEHK05Z6ZA619XWEQPNZV4BNS0YT3
 'SP1FSRR30V73X1J5EVZZPRVDQWWG9405HZ4A7ESR6
 'SP1HFHENGR50MD480HPRFMYA045GXN5GHTWWZ95TM
 'SP1KF3XJHPE2JP1ARJJWYAXYKS149VJY6YRMB7NT1
 'SP1MR35C1WXZ0H428KAY4055RNG1V9472ARCXS1JZ
 'SP1NEJGY34M6B4GT2J7KQ7SKM46R4RV9F0H3V6RNQ
 'SP1SCWYG15CXNRHF53CXQ3PVPJTB3BQ7VY3YTD6B7
 'SP1WQRZ61CQ68BMQP0KM185Q3N7ZCPTMEP5QDQ5DN
 'SP209GK9ES3X6EZSASTJW1S8PD5DKZJCWA9FR0ECZ
))

(define-public (burn-mint-zststx)
  (begin
    (asserts! (var-get enabled) (err u10))
    (asserts! (is-eq deployer tx-sender) (err u11))
    (asserts! (not (var-get executed-burn-mint)) (err u12))
    ;; enable zststx access
    (try! (contract-call? .zststx set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zststx-v1-0 set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zststx-v1-2 set-approved-contract (as-contract tx-sender) true))
    (try! (contract-call? .zststx-v2-0 set-approved-contract (as-contract tx-sender) true))

    ;; burn/mint v2 to v3
    (try! (fold check-err (map consolidate-ststx-lambda ststx-holders) (ok true)))

    ;; disable access
    (try! (contract-call? .zststx set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zststx-v1-0 set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zststx-v1-2 set-approved-contract (as-contract tx-sender) false))
    (try! (contract-call? .zststx-v2-0 set-approved-contract (as-contract tx-sender) false))

    
    (var-set executed-burn-mint true)
    (ok true)
  )
)


(define-private (consolidate-ststx-lambda (account principal))
  (consolidate-ststx-balance-to-v3 account)
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

