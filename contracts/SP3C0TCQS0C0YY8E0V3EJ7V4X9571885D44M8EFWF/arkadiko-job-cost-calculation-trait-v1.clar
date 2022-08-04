(define-trait cost-calculation-trait
  (
    ;; read-only function to calculate cost
    (calculate-cost (principal) (response uint uint))
  )
)
