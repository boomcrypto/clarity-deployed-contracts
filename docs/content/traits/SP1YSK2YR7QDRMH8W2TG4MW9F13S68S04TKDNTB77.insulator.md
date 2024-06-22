---
title: "Trait insulator"
draft: true
---
```
(impl-trait .traits.asset-wrapper-trait)

(define-map balances principal uint)

(define-public (transfer-in (amount uint))
  (let ((balance-before (get-wrapped-balance)))
    (try! (contract-call? .mockusda transfer amount tx-sender (as-contract tx-sender) none))
    (let ((amount-in (- (get-wrapped-balance) balance-before)))
      (map-set balances contract-caller
                        (+ (default-to u0 (map-get? balances contract-caller)) amount-in))
      (ok amount-in))))

(define-public (transfer-out (amount uint) (to principal))
  (begin
    (asserts! (is-eq contract-caller .pool) (err u123))
    (try! (as-contract (contract-call? .mockusda transfer amount (as-contract tx-sender) to none)))
    (map-set balances contract-caller
                      (- (default-to u0 (map-get? balances contract-caller)) amount))
    (ok amount)))

(define-private (get-wrapped-balance) (unwrap-panic (contract-call? .mockusda get-balance (as-contract tx-sender))))

(define-public (get-underlying) (ok (some .usda)))
(define-public (get-decimals) (contract-call? .mockusda get-decimals))
(define-public (get-name) (contract-call? .mockusda get-name))
(define-public (get-symbol) (contract-call? .mockusda get-symbol))
(define-public (get-balance (p principal)) (ok (default-to u0 (map-get? balances p))))

(print {
    type: "announce-asset-wrapper-deployment",
    underying: (unwrap-panic (get-underlying)),
    name: (unwrap-panic (get-name)),
    symbol: (unwrap-panic (get-symbol)),
    decimals: (unwrap-panic (get-decimals))
})

```
