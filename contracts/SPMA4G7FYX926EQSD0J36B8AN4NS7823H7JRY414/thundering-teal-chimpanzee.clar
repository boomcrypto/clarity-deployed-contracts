(define-read-only (get-amount-stx-stacked-at-block-height (address principal) (stx-block-height uint))
  (at-block
    (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height)) 
    (get locked (stx-account address)))
)
