---
title: "Trait dca-vault-v2"
draft: true
---
```
(use-trait ft 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(define-constant ERR-NOT-AUTHORIZED (err u10000))
(define-constant ERR-PAUSED (err u10001))
(define-data-var paused bool false)
(define-read-only (is-approved) (contract-call? .auth-v2 is-approved contract-caller) )
(define-read-only (is-paused) (var-get paused) )
(define-public (pause (new-paused bool)) (begin (asserts! (is-approved) ERR-NOT-AUTHORIZED) (ok (var-set paused new-paused)) ))
(define-public (transfer-ft (token-trait <ft>) (amount uint) (recipient principal)) (begin (asserts! (is-approved) ERR-NOT-AUTHORIZED) (asserts! (not (is-paused)) ERR-PAUSED) (as-contract (contract-call? token-trait transfer amount tx-sender recipient none )) ))
```
