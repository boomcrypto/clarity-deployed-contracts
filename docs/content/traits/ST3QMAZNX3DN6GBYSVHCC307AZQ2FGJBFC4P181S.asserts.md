---
title: "Trait asserts"
draft: true
---
```
(define-constant ERR-NOT-AUTHORIZED u1000)

(define-constant owner 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6)

;; +----------------------+----------+------------+
;; |                      | Consumed | Limit      |
;; +----------------------+----------+------------+
;; | Runtime              | 2176     | 5000000000 |
;; +----------------------+----------+------------+
(define-public (only-assert)
  (begin
    (asserts! (is-eq tx-sender owner) (err ERR-NOT-AUTHORIZED))
    (ok true)))

;; +----------------------+----------+------------+
;; |                      | Consumed | Limit      |
;; +----------------------+----------+------------+
;; | Runtime              | 15748    | 5000000000 |
;; +----------------------+----------+------------+
(define-public (expensive-call)
  (let ((ls (list 1 2 3 4 5 6 7 8 9 10)))
    (fold + ls 1)
    (fold + ls 2)
    (fold + ls 3)
    (fold + ls 4)
    (ok true)))

;; +----------------------+----------+------------+
;; |                      | Consumed | Limit      |
;; +----------------------+----------+------------+
;; | Runtime              | 2176     | 5000000000 |
;; +----------------------+----------+------------+
(define-public (assert-first)
  (begin
    (asserts! (is-eq tx-sender owner) (err ERR-NOT-AUTHORIZED))
    (let ((ls (list 1 2 3 4 5 6 7 8 9 10)))
      (fold + ls 1)
      (fold + ls 2)
      (fold + ls 3)
      (fold + ls 4)
      (ok true))))

;; +----------------------+----------+------------+
;; |                      | Consumed | Limit      |
;; +----------------------+----------+------------+
;; | Runtime              | 16498    | 5000000000 |
;; +----------------------+----------+------------+
(define-public (assert-last)
  (let ((ls (list 1 2 3 4 5 6 7 8 9 10)))
    (fold + ls 1)
    (fold + ls 2)
    (fold + ls 3)
    (fold + ls 4)
    (asserts! (is-eq tx-sender owner) (err ERR-NOT-AUTHORIZED))
    (ok true)))

;; eof

```
