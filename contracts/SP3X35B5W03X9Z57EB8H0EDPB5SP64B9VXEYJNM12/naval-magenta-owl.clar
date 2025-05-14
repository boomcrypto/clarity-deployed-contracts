(define-read-only (get-holders-at
  (owner principal)
  (balance uint)
  (at-block-height uint))
    (at-block
      (unwrap-panic (get-stacks-block-info? id-header-hash at-block-height))
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-read-2
        get-sbtc-rewards
        owner
        balance
      )
    )
)


(define-read-only (get-block-height)
  stacks-block-height
)