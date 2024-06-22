---
title: "Trait pool-reserve-data-1"
draft: true
---
```
(use-trait ft .ft-trait.ft-trait)
(use-trait ft-mint-trait .ft-mint-trait.ft-mint-trait)
(use-trait oracle-trait .oracle-trait.oracle-trait)

(define-constant one-8 (contract-call? .math-v1-2 get-one))
(define-constant max-value (contract-call? .math-v1-2 get-max-value))

(define-constant ERR_UNAUTHORIZED (err u7000))

(define-map freeze-end-block principal uint)
(define-public (set-freeze-end-block (asset principal) (end-block uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-freeze-end-block", payload: { key: asset, data: { end-block: end-block } } })
    (ok (map-set freeze-end-block asset end-block))))

(define-public (get-freeze-end-block (asset principal))
  (ok (map-get? freeze-end-block asset)))
(define-read-only (get-freeze-end-block-read (asset principal))
  (map-get? freeze-end-block asset))

(define-map grace-period-time principal uint)
(define-public (set-grace-period-time (asset principal) (time uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-grace-period-time", payload: { key: asset, data: { grace-period-time: time } } })
    (ok (map-set grace-period-time asset time))))

(define-public (get-grace-period-time (asset principal))
  (ok (map-get? grace-period-time asset)))
(define-read-only (get-grace-period-time-read (asset principal))
  (map-get? grace-period-time asset))

(define-map grace-period-enabled principal bool)
(define-public (set-grace-period-enabled (asset principal) (enabled bool))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-grace-period-enabled", payload: { key: asset, data: { grace-period-enabled: enabled } } })
    (ok (map-set grace-period-enabled asset enabled))))

(define-public (get-grace-period-enabled (asset principal))
  (ok (map-get? grace-period-enabled asset)))
(define-read-only (get-grace-period-enabled-read (asset principal))
  (map-get? grace-period-enabled asset))


;; -- ownable-trait --
(define-data-var contract-owner principal tx-sender)
(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (print { type: "set-contract-owner-pool-reserve-data", payload: owner })
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

(map-set approved-contracts .pool-borrow-v1-2 true)

```
