---
title: "Trait takeoff"
draft: true
---
```
(define-constant fee-receiver tx-sender)
(define-constant charging-ctr .creatures-neon)

;; For information only.
(define-public (get-fees (ustx uint))
  (ok (calc-fees ustx)))

(define-private (calc-fees (ustx uint))
  (/ ustx u10) ;; 10% of ustx
)

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (ustx uint))
  (begin
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (stx-transfer? (calc-fees ustx) tx-sender (as-contract tx-sender))))

;; Release fees for the given amount if swap was canceled by its creator
(define-public (release-fees (ustx uint))
  (let ((user tx-sender))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (as-contract (stx-transfer? (calc-fees ustx) tx-sender user)))) 

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (ustx uint))
  (let ((fee (calc-fees ustx)))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (if (> fee u0)
      (as-contract (stx-transfer? fee tx-sender fee-receiver))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))
```
