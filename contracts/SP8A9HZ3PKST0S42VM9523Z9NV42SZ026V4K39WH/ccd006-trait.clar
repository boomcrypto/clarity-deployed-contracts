(define-trait ccd006-citycoin-mining-trait
  (
    (mine ((string-ascii 10) (list 200 uint))
      (response bool uint)
    )
    (claim-mining-reward ((string-ascii 10) uint)
      (response bool uint)
    )
  )
)
