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

(define-read-only (get-user-sbtc-balance (owner principal) (at-block-height uint))
    (at-block
      (unwrap-panic (get-stacks-block-info? id-header-hash at-block-height))
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-read-2
        get-user-sbtc-balance
        owner
      )
    )
)

(define-read-only (get-vault-rewards (owner principal) (at-block-height uint))
    (at-block
      (unwrap-panic (get-stacks-block-info? id-header-hash at-block-height))
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.incentives-v2-2
        get-vault-rewards
        owner
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.wstx
      )
    )
)

(define-read-only (get-block-height)
  stacks-block-height
)
