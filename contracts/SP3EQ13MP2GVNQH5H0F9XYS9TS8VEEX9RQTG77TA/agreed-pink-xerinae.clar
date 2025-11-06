(define-read-only (get-reserve-asset-at (asset principal) (at-block-height uint))
    (at-block
      (unwrap-panic (get-stacks-block-info? id-header-hash at-block-height))
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-reserve-state-read asset)
    )
)