(define-public (check)
    (ok (read-only-check)))

(define-read-only (read-only-check)
    (>= 10000000000000000000000000000000 9999999999999999999999999999990))