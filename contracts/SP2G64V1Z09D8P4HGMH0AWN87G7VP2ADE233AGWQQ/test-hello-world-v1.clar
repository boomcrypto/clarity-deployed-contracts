
(define-data-var counter int 0)
(define-data-var counter2 int 0)

(define-public (say-hi)
  (ok "hello world")
)

(define-read-only (echo-number (val int))
  (ok val)
)

(define-read-only (get-counter)
  (ok (var-get counter))
)

(define-public (increment)
  (begin
    (var-set counter (+ (var-get counter) 1))
    (ok (var-get counter))
  )
)

(define-public (decrement)
  (begin
    (var-set counter (- (var-get counter) 1))
    (ok (var-get counter))
  )
)

(define-read-only (get-counter-2)
  (ok (var-get counter2))
)

(define-public (increment-2)
  (begin
    (var-set counter2 (+ (var-get counter) 1))
    (ok (var-get counter2))
  )
)

(define-public (decrement-2)
  (begin
    (var-set counter2 (- (var-get counter) 1))
    (ok (var-get counter2))
  )
)

(define-constant ERR-TEST u40401)

(define-data-var contract-owner principal tx-sender)

