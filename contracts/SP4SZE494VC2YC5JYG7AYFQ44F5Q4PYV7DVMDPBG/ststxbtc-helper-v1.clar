(define-read-only (get-ststxbtc-total-supply (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err u666)))
  )
    (if (<= block u489222)
      (ok u0)
      (at-block block-hash (get-total-supply))
    )
  )
)

(define-read-only (get-total-supply)
  (contract-call? .ststxbtc-token get-total-supply)
)
