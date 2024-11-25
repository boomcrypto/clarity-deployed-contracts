---
title: "Trait swap-3"
draft: true
---
```
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant CONTRACT_OWNER 'SP1M8YVQ3KZZJQGGZ3KJ0B8MM9PJ0GHE9HDTBNNXS)
(define-private (assert-contract-owner) (ok (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR-NOT-AUTHORIZED)))
(define-private (withdrawal-one-a (token-and-amount { token: <ft-trait>, amount: uint, recipient: principal }))
    (let (
        (amount (get amount token-and-amount))
        (token (get token token-and-amount))
        (recipient (get recipient token-and-amount))
    )
        (as-contract (contract-call? token transfer-fixed amount .swap-1 recipient none))
    )
)
(define-private (withdrawal-one-b (token-and-amount { token: <ft-trait>, amount: uint, recipient: principal }))
    (let (
        (amount (get amount token-and-amount))
        (token (get token token-and-amount))
        (recipient (get recipient token-and-amount))
    )
        (as-contract (contract-call? token transfer-fixed amount contract-caller recipient none))
    )
)
(define-private (check-err (result (response bool uint)) (prior (response bool uint))) (match prior ok-value result err-value (err err-value)))
(define-public (withdraw-fees-many-a (tokens-and-amounts (list 200 {token: <ft-trait>, amount: uint, recipient: principal})))
    (begin
        (try! (assert-contract-owner))
        (fold check-err (map withdrawal-one-a tokens-and-amounts) (ok true))
    )
)
(define-public (withdraw-fees-many-b (tokens-and-amounts (list 200 {token: <ft-trait>, amount: uint, recipient: principal})))
    (begin
        (try! (assert-contract-owner))
        (fold check-err (map withdrawal-one-b tokens-and-amounts) (ok true))
    )
)
```
