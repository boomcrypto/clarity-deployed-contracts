---
title: "Trait sata-vault"
draft: true
---
```
(impl-trait .trait-ownable.ownable-trait)
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(use-trait sft-trait .trait-semi-fungible.semi-fungible-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-BALANCE (err u1001))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-INVALID-TOKEN (err u2026))

(define-data-var contract-owner principal tx-sender)

(define-map approved-contracts principal bool)
(define-map approved-tokens principal bool)

;; @desc get-contract-owner
;; @returns (response principal)
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

;; @desc set-contract-owner
;; @restricted Contract-Owner
;; @returns (response boolean)
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner))
    (ok (var-set contract-owner owner))
  )
)

;; @desc check-is-approved
;; @restricted Approved-Contracts
;; @params sender
;; @returns (response boolean)
(define-private (check-is-approved)
  (ok (asserts! (default-to false (map-get? approved-contracts tx-sender)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-is-approved-token (flash-loan-token principal))
  (ok (asserts! (default-to false (map-get? approved-tokens flash-loan-token)) ERR-NOT-AUTHORIZED))
)

(define-public (add-approved-contract (new-approved-contract principal))
  (begin
    (try! (check-is-owner))
    (ok (map-set approved-contracts new-approved-contract true))
  )
)

(define-public (add-approved-token (new-approved-token principal))
  (begin
    (try! (check-is-owner))
    (ok (map-set approved-tokens new-approved-token true))
  )
)


;; return token balance held by vault
;; @desc get-balance
;; @params token; ft-trait
;; @returns (response uint)
(define-public (get-balance (token <ft-trait>))
  (begin
    (try! (check-is-approved-token (contract-of token)))
    (contract-call? token get-balance-fixed (as-contract tx-sender))
  )
)

;; if sender is an approved contract, then transfer requested amount :qfrom vault to recipient
;; @desc transfer-ft
;; @params token; ft-trait
;; @params amount
;; @params recipient
;; @restricted Contrac-Owner
;; @returns (response boolean)
(define-public (transfer-ft (token <ft-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (and (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) (is-ok (check-is-approved-token (contract-of token)))) ERR-NOT-AUTHORIZED)
    (as-contract (contract-call? token transfer-fixed amount tx-sender recipient none))
  )
)

;; @desc transfer-sft
;; @restricted Contract-Owner
;; @params token ; sft-trait
;; @params token-id
;; @params amount
;; @params recipient
;; @returns (response boolean)
(define-public (transfer-sft (token <sft-trait>) (token-id uint) (amount uint) (recipient principal))
  (begin
    (asserts! (and (or (is-ok (check-is-approved)) (is-ok (check-is-owner))) (is-ok (check-is-approved-token (contract-of token)))) ERR-NOT-AUTHORIZED)
    (as-contract (contract-call? token transfer-fixed token-id amount tx-sender recipient))
  )
)

(define-public (transfer-ft-two (token-x-trait <ft-trait>) (dx uint) (token-y-trait <ft-trait>) (dy uint) (recipient principal))
  (begin
    (try! (transfer-ft token-x-trait dx recipient))
    (transfer-ft token-y-trait dy recipient)
  )
)

;; @desc mul-down
;; @params a
;; @params b
;; @returns uint
(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8)
)

;; @desc mul-up
;; @params a
;; @params b
;; @returns uint
(define-private (mul-up (a uint) (b uint))
    (let
        (
            (product (* a b))
       )
        (if (is-eq product u0)
            u0
            (+ u1 (/ (- product u1) ONE_8))
       )
   )
)

;; contract initialisation
(map-set approved-contracts .stake true)

;; testing only
(map-set approved-contracts .collateral-rebalancing-pool-v1 true)
(map-set approved-contracts .liquidity-bootstrapping-pool true)
(map-set approved-contracts .yield-token-pool true)
(map-set approved-contracts .yield-collateral-rebalancing-pool-v1 true)
```
