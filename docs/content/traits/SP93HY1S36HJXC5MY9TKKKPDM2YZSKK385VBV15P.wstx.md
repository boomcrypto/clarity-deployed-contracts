---
title: "Trait wstx"
draft: true
---
```
(impl-trait .traits.asset-wrapper-trait)

(define-map balances principal uint)

(define-public (transfer-in (amount uint))
  (begin
  (try! (stx-transfer? amount tx-sender contract-caller))
    (map-set balances contract-caller
                      (+ (default-to u0 (map-get? balances contract-caller)) amount))
    (ok amount)))

(define-public (transfer-out (amount uint) (to principal))
  (begin
    (asserts! (is-eq contract-caller .pool) (err u123))
    (try! (stx-transfer? amount contract-caller to))
    (map-set balances contract-caller
                      (- (default-to u0 (map-get? balances contract-caller)) amount))
    (ok amount)))

(define-public (get-underlying) (ok none))
(define-public (get-decimals) (ok u6))
(define-public (get-name) (ok "Stacks"))
(define-public (get-symbol) (ok "STX"))
(define-public (get-balance (p principal)) (ok (default-to u0 (map-get? balances p))))

(print {
    type: "announce-asset-wrapper-deployment",
    underying: (unwrap-panic (get-underlying)),
    name: (unwrap-panic (get-name)),
    symbol: (unwrap-panic (get-symbol)),
    decimals: (unwrap-panic (get-decimals))
})

```
