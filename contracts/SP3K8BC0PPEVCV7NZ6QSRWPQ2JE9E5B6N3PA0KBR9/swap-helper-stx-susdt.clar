(define-constant ONE_8 u100000000)
(define-public (swap-helper-stx-susdt (dx uint) (min-dy (optional uint)))
  (ok (try! (contract-call? .amm-swap-pool swap-helper .token-wstx .token-wbtc ONE_8 dx min-dy)))
)