---
title: "Trait yang"
draft: true
---
```
(define-data-var fee-receiver principal tx-sender)
(define-constant charging-jing .jing)
(define-constant charging-cash .cash)

;; New variables for fee percentages
(define-data-var low uint u400)
(define-data-var med uint u200)
(define-data-var hi uint u133)

;; For information only.
(define-public (get-fees (ustx uint))
  (ok (jing-cash ustx)))

(define-private (jing-cash (ustx uint))
  (if (> ustx u10000000000) 
    (/ ustx (var-get low))           ;; ustx> 10,000 then 0.25% 
    (if (> ustx u5000000000) 
      (/ ustx (var-get med))            ;; ustx > 5,000  then 0.50% 
     (/ ustx (var-get hi)))))       ;; 0.75%

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (ustx uint))
  (let ((fee (jing-cash ustx)))
    (asserts! (or (is-eq contract-caller charging-jing) 
                  (is-eq contract-caller charging-cash))  ERR_NOT_AUTH)
    (and (> fee u0)
      (try! (stx-transfer? fee tx-sender (as-contract tx-sender))))
    (ok true)))

;; Release fees for the given amount if swap was canceled by its creator
(define-public (release-fees (ustx uint))
  (let ((user tx-sender)
        (fee (jing-cash ustx)))
    (asserts! (or (is-eq contract-caller charging-jing) 
                  (is-eq contract-caller charging-cash))  ERR_NOT_AUTH)
    (and (> fee u0)
      (try! (as-contract (stx-transfer? (jing-cash ustx) tx-sender user))))
    (ok true))) 

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (ustx uint))
  (let ((fee (jing-cash ustx)))
    (asserts! (or (is-eq contract-caller charging-jing) 
                  (is-eq contract-caller charging-cash))  ERR_NOT_AUTH)
    (and (> fee u0)
      (try! (as-contract (stx-transfer? fee tx-sender (var-get fee-receiver)))))
      (ok true)))

;; Fee receiver Functions
(define-public (set-fee-receiver (new-fee-receiver principal))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_FEE_RECEIVER)
    (ok (var-set fee-receiver new-fee-receiver))))

(define-read-only (get-fee-receiver)
  (ok (var-get fee-receiver)))

;; Functions to change fee percentages
(define-public (set-hi (new uint))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_FEE_RECEIVER)
    (ok (var-set hi new))))

(define-public (set-med (new uint))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_FEE_RECEIVER)
    (ok (var-set med new))))

(define-public (set-low (new uint))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_FEE_RECEIVER)
    (ok (var-set low new))))
  
(define-constant ERR_NOT_AUTH (err u404))
(define-constant ERR_NOT_FEE_RECEIVER (err u405))
;; "The man who views the world at 50 the same as he did at 20 has wasted 30 years of his life."
```
