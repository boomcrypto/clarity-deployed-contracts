(define-trait points
  (
    (collect (uint uint) (response bool uint))
    (send (uint uint uint) (response bool uint))
    (spend (uint uint) (response bool uint))
    (get-balance (uint) (response uint uint))
    (get-total-supply () (response uint uint))
  )
)