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
 'SP3K33J6GFG0R10VZNZBA7PCKNZXQNTMBAQVE1YK2
 'SP1SY043Y1S8Y2D88JGY7C4191CJ6BYAT14D9ZXGB
 'SP113VAC9F2VNRWWC4SBS3X9MBKYR0VRBPJAWZ2SX
 'SP12NT59RP062GR9DFZXEV61YTJD5N1G2PC1YKE83
 'SP2GEHNS7HCJSNQP59S6XNWYN21YHWFZE1CXN0BFY
 'SP2HTV55CQJJ3HSFDXS7S5RBRJT8YW9SG5TFT0A7S
 'SP3A5Z8D47MQSSSR4M4H4S1EJKN3HHYTAATZPGXX1
 'SPA4Q216PTXBE9YGG34JN7X7AEHZHTJZQP1YV7A3
 'SP51P5Y5731EZHAJH6WHTCB9QQVSP3JFX9JB4M7Z
 'SP3VRAGBPHKRCNN47AG8QNB5144DB0BK2CQRRMAWB
 'SP29DX2PV40QY2J6Y66MDTVW5KANSGD8VA1FXC6RA
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

