(define-data-var counter uint u0)

(define-public (increment-counter)
  (begin
    (var-set counter (+ (var-get counter) u1))
    (print {
        counter: (var-get counter),
        user: tx-sender,
        action: "increment-counter"
    })
    (ok u0)
  )
)

(define-public (increment-counter-by-amount (amount uint))
  (begin
    (var-set counter (+ (var-get counter) amount))
    (print {
        counter: (var-get counter),
        amount: amount,
        user: tx-sender,
        action: "increment-counter-by-amount"
    })
    (ok u0)
  )
)

(define-read-only (get-counter)
  (var-get counter)
)

(define-read-only (get-counter-response)
  (ok (var-get counter))
)
