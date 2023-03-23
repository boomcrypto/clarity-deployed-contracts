(define-read-only (g (user principal))
  { bh: block-height, stx: (stx-get-balance user) })
