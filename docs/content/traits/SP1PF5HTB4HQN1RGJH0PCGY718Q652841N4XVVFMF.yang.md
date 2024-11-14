---
title: "Trait yang"
draft: true
---
```
(use-trait fungible-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait) 

(define-data-var fee-receiver principal tx-sender)
(define-constant charging-jing .jing)
(define-constant charging-cash .cash)

;; New variables for fee percentages
(define-data-var low uint u400)

;; For information only.
(define-public (get-fees (amount uint) (ft <fungible-token>))
  (ok (jing-cash amount)))

(define-private (jing-cash (amount uint))
    (/ amount (var-get low)))       ;; 0.25%

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (amount uint) (ft <fungible-token>))
  (let ((fee (jing-cash amount)))
    (asserts! (or (is-eq contract-caller charging-jing) 
                  (is-eq contract-caller charging-cash))  ERR_NOT_AUTH)
    (and (> fee u0)
      (try! (contract-call? ft transfer fee tx-sender (as-contract tx-sender) none)))
    (ok true)))

;; Release fees for the given amount if swap was canceled by its creator
(define-public (release-fees (amount uint) (ft <fungible-token>))
  (let ((user tx-sender)
        (fee (jing-cash amount)))
    (asserts! (or (is-eq contract-caller charging-jing) 
                  (is-eq contract-caller charging-cash))  ERR_NOT_AUTH)
    (and (> fee u0)
      (try! (as-contract (contract-call? ft transfer (jing-cash amount) tx-sender user none))))
    (ok true))) 

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (amount uint) (ft <fungible-token>))
  (let ((fee (jing-cash amount)))
    (asserts! (or (is-eq contract-caller charging-jing) 
                  (is-eq contract-caller charging-cash))  ERR_NOT_AUTH)
    (and (> fee u0)
      (try! (as-contract (contract-call? ft transfer fee tx-sender (var-get fee-receiver) none))))
      (ok true)))

;; Fee receiver Functions
(define-public (set-fee-receiver (new-fee-receiver principal))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_FEE_RECEIVER)
    (ok (var-set fee-receiver new-fee-receiver))))

(define-read-only (get-fee-receiver)
  (ok (var-get fee-receiver)))

;; Functions to change fee percentages
(define-public (set-low (new uint))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_FEE_RECEIVER)
    (ok (var-set low new))))

(define-public (get-low)
  (ok (var-get low)))
  
(define-constant ERR_NOT_AUTH (err u404))
(define-constant ERR_NOT_FEE_RECEIVER (err u405))
;; "The man who views the world at 50 the same as he did at 20 has wasted 30 years of his life."
```
