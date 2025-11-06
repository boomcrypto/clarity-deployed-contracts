(define-read-only (block-height-to-bitcoin-block-height (stx-block-height uint)) 
  (at-block (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height)) burn-block-height)
)
