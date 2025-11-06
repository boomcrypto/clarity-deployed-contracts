
(define-read-only (get-stacked-amount-at-stx-block-height (stx-block-height uint) (stacked-address principal)) 
  (at-block
    (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height)) 
    (get locked (stx-account stacked-address)))
)

(define-read-only (get-stx-amounts-at-stx-block-height (stx-block-height uint) (stacked-address principal)) 
  (at-block
    (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height)) 
    (stx-account stacked-address))
)
