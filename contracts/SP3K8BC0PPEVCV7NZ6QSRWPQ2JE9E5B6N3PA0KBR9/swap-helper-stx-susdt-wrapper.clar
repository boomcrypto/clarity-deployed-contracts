(define-public (swap-helper-stx-susdt (dx uint) (min-dy (optional uint)))
  (contract-call? .swap-helper-stx-susdt-trait call-impl .swap-helper-stx-susdt dx min-dy)
)