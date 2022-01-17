(define-constant fee-ratio u997)
(define-constant stackswap-ratio u3)
(define-constant total-ratio u1000)


(define-read-only (get-owner-amount (init-amount uint))
  ( / (* init-amount fee-ratio)  total-ratio)
)

(define-read-only (get-stackswap-amount (init-amount uint))
  ( / (* init-amount stackswap-ratio)  total-ratio)
)
