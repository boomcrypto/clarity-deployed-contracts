(define-public (swap-helper-stx-susdt (dx uint) (min-dy (optional uint)))
  (contract-call? .swap-helper-stx-susdt-trait-1 call-impl .swap-helper-stx-susdt-1 dx min-dy)
)