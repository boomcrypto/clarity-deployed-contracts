
(define-read-only (get-holders-at (owner principal) (at-block-height uint))
    (at-block
      (unwrap-panic
        (get-block-info?
          id-header-hash
          at-block-height
        )
      )
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsbtc-v2-0 get-balance owner)
    )
)