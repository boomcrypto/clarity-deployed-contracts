---
title: "Trait fee"
draft: true
---
```
(define-constant fee-receiver tx-sender)
(define-constant charging-ctr .stx-swap) 

;; For information only.
(define-public (get-fees (ustx uint))
  (ok (neon-fee ustx)))

(define-private (neon-fee (ustx uint))
  (if (> ustx u37500000000) 
    (/ ustx u133)           ;; 0.75% 
    (if (> ustx u12500000000) 
      (/ ustx u80)            ;; 1.25% 
      (/ ustx u40))))         ;; 2.5%

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (ustx uint))
  (begin
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (stx-transfer? (neon-fee ustx) tx-sender (as-contract tx-sender))))

;; Release fees for the given amount if swap was canceled by its creator
(define-public (release-fees (ustx uint))
  (let ((user tx-sender))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (as-contract (stx-transfer? (neon-fee ustx) tx-sender user)))) 

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (ustx uint))
  (let ((fee (neon-fee ustx)))
    (asserts! (is-eq contract-caller charging-ctr) ERR_NOT_AUTH)
    (if (> fee u0)
      (as-contract (stx-transfer? fee tx-sender fee-receiver))
      (ok true))))

(define-constant ERR_NOT_AUTH (err u404))
;; "The man who views the world at 50 the same as he did at 20 has wasted 30 years of his life."
```
