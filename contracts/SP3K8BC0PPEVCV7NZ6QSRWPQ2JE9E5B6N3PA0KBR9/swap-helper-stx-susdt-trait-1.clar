(define-trait swap-helper-stx-susdt-trait 
  (
    (swap-helper-stx-susdt (uint (optional uint)) (response uint uint))
  )
)
(define-public (call-impl (f <swap-helper-stx-susdt-trait>) (dx uint) (min-dy (optional uint)))
  (contract-call? f swap-helper-stx-susdt dx min-dy)
)