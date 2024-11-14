
;; title: test-ok-print
;; version:
;; summary:
;; description:

(define-data-var value-d uint u0)

(define-public (change-value (new-value uint))
    (begin
        (var-set value-d u1)
        (ok (print {boolean: true, old-value: (var-get value-d), new-value: new-value}))
    )
)

