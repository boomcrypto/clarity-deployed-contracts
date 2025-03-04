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
 'SP30HNAPMTA5C3ACV7H0GNW9EHECMFJZAKGPJ27NB
 'SPV8DH2P859X4BQVKF6SYBPVCJ5E8XM7H9WGH74J
 'SP2HMAV5ZHEMA6J0P0DQ00DPJKD1VNF40M9CHM8VA
 'SP20N37V1XABW8C35PPMEGKM62Y8BK1DNXNC2NHHG
 'SP1B80E0X3R1KQFA5GFQ7RTKHTR038M513AG3143S
 'SP15M57F3EB9EJB58CH7KMQWKY7CJBZW8JX9VMRTG
 'SPEDWWG6KC7PK1TFG6E5X942C65133C1Y19CKKDZ
 'SPBDZRNYQAPPE32WY3XNY2AZ9A1ZYMA19NM3SP7Y
 'SP5XXPN7C9JMJ61AM28MGB5HM8W1Z7E4KD7YXB2V
 'SP3E2ER2Q7FYTAZ43J13M3343NQZ0SGM4HBE43C37
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

