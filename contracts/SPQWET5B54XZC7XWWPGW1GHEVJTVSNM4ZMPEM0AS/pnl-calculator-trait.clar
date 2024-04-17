(define-trait pnl-calculator-trait
  (
    ;; checks for correct strike order
    (check-strike-order (uint uint (optional uint) (optional uint) (optional uint) (optional uint)) (response bool uint))

    ;; determines the option pnl and returns it
    (calculate-pnl (uint uint uint (optional uint) (optional uint) (optional uint) (optional uint)) (response uint uint))
  )
)