---
title: "Trait water"
draft: true
---
```
(define-data-var fee-receiver principal tx-sender)
(define-constant charging-cash .cha-dmg)

;; For information only.
(define-public (get-fees (ustx uint))
  (ok (jing-cash ustx)))

(define-private (jing-cash (ustx uint))
  (if (> ustx u10000000000) 
    (/ ustx u400)           ;; ustx> 10,000 then 0.25% 
    (if (> ustx u5000000000) 
      (/ ustx u200)            ;; ustx > 5,000  then 0.50% 
      (/ ustx u133))))         ;; 0.75%

;; Hold fees for the given amount in escrow.
(define-public (hold-fees (ustx uint))
  (let ((fee (jing-cash ustx)))
    (asserts! (is-eq contract-caller charging-cash) ERR_NOT_AUTH)
    (and (> fee u0)
      (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer fee tx-sender (as-contract tx-sender) none)))
    (ok true)))

;; Release fees for the given amount if swap was canceled by its creator
(define-public (release-fees (ustx uint))
  (let ((user tx-sender)
        (fee (jing-cash ustx)))
    (asserts! (is-eq contract-caller charging-cash) ERR_NOT_AUTH)
    (and (> fee u0)
      (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer (jing-cash ustx) tx-sender user none))))
    (ok true))) 

;; Pay fee for the given amount if swap was executed.
(define-public (pay-fees (ustx uint))
  (let ((fee (jing-cash ustx)))
    (asserts! (is-eq contract-caller charging-cash) ERR_NOT_AUTH)
    (and (> fee u0)
      (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token transfer fee tx-sender (var-get fee-receiver) none))))
      (ok true)))

;; Fee receiver Functions
(define-public (set-fee-receiver (new-fee-receiver principal))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-receiver)) ERR_NOT_FEE_RECEIVER)
    (ok (var-set fee-receiver new-fee-receiver))))

(define-read-only (get-fee-receiver)
  (ok (var-get fee-receiver)))
  
(define-constant ERR_NOT_AUTH (err u404))
(define-constant ERR_NOT_FEE_RECEIVER (err u405))
;; "The man who views the world at 50 the same as he did at 20 has wasted 30 years of his life."
```
