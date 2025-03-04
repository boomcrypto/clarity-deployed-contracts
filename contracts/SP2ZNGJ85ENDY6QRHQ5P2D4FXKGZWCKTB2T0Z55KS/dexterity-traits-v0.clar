(define-trait liquidity-pool-trait
  (
    (execute 
      (uint (optional (buff 16))) 
      (response (tuple (dx uint) (dy uint) (dk uint)) uint))
    (quote 
      (uint (optional (buff 16)))
      (response (tuple (dx uint) (dy uint) (dk uint)) uint))
  )
)