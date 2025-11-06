(define-read-only (get-current-block-height)
  (ok {stacks: stacks-block-height, bitcoin: burn-block-height})
)