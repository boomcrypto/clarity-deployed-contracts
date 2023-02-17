(define-trait ccd007-citycoin-stacking-trait
  (
    (stack ((string-ascii 10) uint uint)
      (response bool uint)
    )
    (claim-stacking-reward ((string-ascii 10) uint)
      (response bool uint)
    )
  )
)
