---
title: "Trait assert-test"
draft: true
---
```
(define-constant ERR-NOT-AUTHORIZED u4104)

(define-data-var owner principal tx-sender)

(define-public (assert-first)
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) (err ERR-NOT-AUTHORIZED))
        (fold + (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) 1)
        (fold + (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) 1)
        (fold + (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) 1)
        (fold + (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) 1)
        (fold + (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) 1)
        (ok u1)))



(define-public (assert-last)
    (begin
        (fold + (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) 1)
        (fold + (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) 1)
        (fold + (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) 1)
        (fold + (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) 1)
        (fold + (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) 1)
        (asserts! (is-eq tx-sender (var-get owner)) (err ERR-NOT-AUTHORIZED))
        (ok u1)))
```
