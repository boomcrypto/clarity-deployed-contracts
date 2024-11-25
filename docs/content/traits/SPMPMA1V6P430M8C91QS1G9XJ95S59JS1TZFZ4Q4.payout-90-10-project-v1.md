---
title: "Trait payout-90-10-project-v1"
draft: true
---
```
;; send-many with 90:10 to recipient and project
(define-data-var admin principal tx-sender)
(define-data-var project principal tx-sender)
(define-public (set-project (new-project principal))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) (err u401))
    (ok (var-set project new-project))))
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq contract-caller (var-get admin)) (err u401))
    (ok (var-set admin new-admin))))
(define-private (send-stx (recipient {to: principal, ustx: uint, memo: (buff 34)}))
  (let ((amount (get ustx recipient))
        (amount-1 (/ (* amount u900) u1000))
        (amount-2 (- amount amount-1)))
  (try! (stx-transfer-memo? amount-1 tx-sender (get to recipient) (get memo recipient)))
  (stx-transfer? amount-2 tx-sender (var-get project))))

(define-private (check-err (result (response bool uint))
                           (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)))
(define-public (send-many (recipients (list 200 {to: principal, ustx: uint, memo: (buff 34)})))
  (fold check-err
    (map send-stx recipients)
    (ok true)))
```
