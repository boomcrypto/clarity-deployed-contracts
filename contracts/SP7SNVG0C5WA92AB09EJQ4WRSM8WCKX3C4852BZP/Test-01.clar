
(define-data-var counter uint u0)

(define-read-only (show-counter)
    (var-get counter)
)

(define-public (increase)
    (ok (var-set counter (+ (var-get counter) u1)))
)

(define-public (decrease)
    (ok (var-set counter (- (var-get counter) u1)))
)