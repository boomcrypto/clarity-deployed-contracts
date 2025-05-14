---
title: "Trait pool-reserve-data-4"
draft: true
---
```
(define-constant ERR_UNAUTHORIZED (err u7003))

;; asset -> liquidation-bonus-e-mode
(define-map liquidation-bonus-e-mode principal uint)
(define-public (set-liquidation-bonus-e-mode (asset principal) (new-liquidation-bonus-e-mode uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-liquidation-bonus-e-mode", payload: { key: asset, data: new-liquidation-bonus-e-mode } })
    (ok (map-set liquidation-bonus-e-mode asset new-liquidation-bonus-e-mode))))
(define-public (get-liquidation-bonus-e-mode (asset principal))
  (ok (map-get? liquidation-bonus-e-mode asset)))
(define-read-only (get-liquidation-bonus-e-mode-read (asset principal))
  (map-get? liquidation-bonus-e-mode asset))

;; -- ownable-trait --
(define-data-var contract-owner principal tx-sender)
(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (print { type: "set-contract-owner-pool-reserve-data-4", payload: owner })
    (ok (var-set contract-owner owner))))

(define-public (get-contract-owner)
  (ok (var-get contract-owner)))
(define-read-only (get-contract-owner-read)
  (var-get contract-owner))

(define-read-only (is-contract-owner (caller principal))
  (is-eq caller (var-get contract-owner)))

;; -- permissions
(define-map approved-contracts principal bool)

(define-public (set-approved-contract (contract principal) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-set approved-contracts contract enabled))))

(define-public (delete-approved-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-delete approved-contracts contract))))

(define-read-only (is-approved-contract (contract principal))
  (if (default-to false (map-get? approved-contracts contract))
    (ok true)
    ERR_UNAUTHORIZED))

```
