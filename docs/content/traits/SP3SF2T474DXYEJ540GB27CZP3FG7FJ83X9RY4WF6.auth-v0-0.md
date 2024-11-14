---
title: "Trait auth-v0-0"
draft: true
---
```
(define-constant ERR-NOT-AUTHORIZED (err u12000))
(define-data-var contract-owner principal tx-sender)
(define-map approved-contracts principal bool)
(map-set approved-contracts (as-contract tx-sender) true)
(define-map approved-dca-network principal bool)
(map-set approved-dca-network (as-contract tx-sender) true)
(define-read-only (is-owner) (is-eq contract-caller (var-get contract-owner)) )
(define-read-only (is-approved (address principal)) (default-to false (map-get? approved-contracts address)) )
(define-read-only (is-approved-dca-network (address principal)) (default-to false (map-get? approved-dca-network address)) )
(define-public (change-owner (new-owner principal)) (begin (asserts! (is-owner) ERR-NOT-AUTHORIZED) (ok (var-set contract-owner new-owner)) ))
(define-public (add-approved-contract (new-approved-contract principal)) (begin (asserts! (is-owner) ERR-NOT-AUTHORIZED) (ok (map-set approved-contracts new-approved-contract true)) ))
(define-public (add-approved-dca-network (new-approved-network principal)) (begin (asserts! (is-owner) ERR-NOT-AUTHORIZED) (ok (map-set approved-dca-network new-approved-network true)) ))
(define-public (remove-approved-contract (approved-contract principal)) (begin (asserts! (is-owner) ERR-NOT-AUTHORIZED) (ok (map-set approved-contracts approved-contract false)) ))
```
