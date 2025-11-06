
(define-read-only (get-ststxbtc-total-supply (block uint))
  (let (
    (block-hash (unwrap! (get-stacks-block-info? id-header-hash block) (err u666)))
  )
    (ok (at-block block-hash (get-total-supply block)))
  )
)

(define-read-only (get-total-supply (block uint))
  (let (
    (supply-v1 (if (<= block u489222)
      u0
      (unwrap! (contract-call? .ststxbtc-token get-total-supply) u0))
    )
    (supply-v2 (if (<= block u1491293)
      u0
      (unwrap! (contract-call? .ststxbtc-token-v2 get-total-supply) u0))
    )
  )
    (+ supply-v1 supply-v2)
  )
)

(define-read-only (get-current-total-supply)
  (let (
    (supply-v1 (unwrap! (contract-call? .ststxbtc-token get-total-supply) (ok u0)))
    (supply-v2 (unwrap! (contract-call? .ststxbtc-token-v2 get-total-supply) (ok u0)))
  )
    (ok (+ supply-v1 supply-v2))
  )
)