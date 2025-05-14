---
title: "Trait oracle-vpv-5"
draft: true
---
```
;; Oracle Trait 
(impl-trait .oracle-trait-vpv-5.oracle-trait)

(use-trait registry-trait .registry-trait-vpv-5.registry-trait)

(define-constant ERR_NO_ORACLE_PRICE (err u700))
(define-constant ERR_STALE_ORACLE_PRICE (err u701))
(define-constant ERR_INVALID_SOURCE (err u702))

(define-constant SOURCE_ARKADIKO u1)
(define-constant SOURCE_DIA u2)

(define-constant SBTC_TOKEN_KEY_ARKADIKO "BTC")
(define-constant SBTC_TOKEN_KEY_DIA "BTC/USD")

(define-data-var current-source uint SOURCE_DIA)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; oracle-trait BEGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (set-source (source uint))
    (begin 
        (try! (contract-call? .controller-vpv-5 is-admin tx-sender))
        (asserts! (or (is-eq source SOURCE_ARKADIKO) (is-eq source SOURCE_DIA)) ERR_INVALID_SOURCE)
        (var-set current-source source)
        (ok true)
    )
)

(define-public (get-price (registry <registry-trait>))
    (let 
        (
            (valid-registry (try! (contract-call? .controller-vpv-5 check-approved-contract "registry" (contract-of registry))))
            (source (var-get current-source))
            (oracle-token-key (if (is-eq source SOURCE_ARKADIKO) SBTC_TOKEN_KEY_ARKADIKO SBTC_TOKEN_KEY_DIA))
            (current-burn-block-height burn-block-height)
            (current-stacks-block-timestamp (get-stacks-block-info? time (- stacks-block-height u1)))
        )
        ;; verify source is correct
         (asserts! (or (is-eq source SOURCE_ARKADIKO) (is-eq source SOURCE_DIA)) ERR_INVALID_SOURCE)

       (if (is-eq source SOURCE_ARKADIKO)
            (get-arkadiko-price oracle-token-key current-burn-block-height registry)
            (get-dia-price oracle-token-key (unwrap-panic current-stacks-block-timestamp) registry)
       )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; oracle-trait END
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-source)
    (ok (var-get current-source))
)

(define-private (get-arkadiko-price (token-key (string-ascii 12)) (current-burn-block uint) (registry <registry-trait>))
    (let 
        (
            (token (unwrap! (contract-call? .oracle-arkadiko-mock fetch-price token-key) ERR_NO_ORACLE_PRICE))
            (token-price (get last-price token))
            (token-block (get last-block token))
            (oracle-stale-threshold (try! (contract-call? registry get-oracle-stale-threshold)))
        ) 
        (asserts! (>= (+ token-block oracle-stale-threshold) current-burn-block) ERR_STALE_ORACLE_PRICE)
        (ok token-price)
    )
)

(define-private (get-dia-price (token-key (string-ascii 12)) (current-timestamp uint) (registry <registry-trait>))
    (let 
        (
            ;; Testnet
            (token (unwrap-panic (contract-call? 'SP1G48FZ4Y7JY8G2Z0N51QTCYGBQ6F4J43J77BQC0.dia-oracle get-value token-key)))
            ;; (token (unwrap-panic (contract-call? .oracle-dia-mock get-value token-key)))
            (token-price (get value token))
            (token-timestamp (get timestamp token))
            (oracle-stale-threshold (try! (contract-call? registry get-oracle-stale-threshold)))
            (oracle-stale-threshold-seconds (* oracle-stale-threshold u10 u60)) ;; blocks * 10 min/block * 60 sec
        ) 
        (asserts! (>= (+ token-timestamp oracle-stale-threshold-seconds) current-timestamp) ERR_STALE_ORACLE_PRICE)
        (ok token-price)
    )
)
```
