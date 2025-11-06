(define-constant PRECISION_HELPER u100000000)

(define-read-only (get-amount-wallet-stx-stacked (address principal))
  (get locked (stx-account address))
)

(define-read-only (get-user-wallet-ststx-balance (address principal))
  (unwrap!
    (contract-call?
      'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
      get-balance address
    )
    u0
  )
)

(define-read-only (get-user-wallet-ststxbtc-balance (address principal))
  (unwrap!
    (contract-call?
      'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token-v2
      get-balance address
    )
    u0
  )
)

(define-read-only (get-zest-ststx-balance (address principal))
  (contract-call?
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-token
    get-balance address
  )
)

(define-read-only (get-zest-ststxbtc-balance (address principal))
  (contract-call?
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-token
    get-balance address
  )
)

(define-read-only (get-amount-liquid-ststx-user (address principal))
  (+ (get-zest-ststx-balance address)
    (get-user-wallet-ststx-balance address)
  )
)

(define-read-only (get-amount-liquid-ststxbtc-user (address principal))
  (+ (get-zest-ststxbtc-balance address)
    (get-user-wallet-ststxbtc-balance address)
  )
)

(define-read-only (get-ratio-stx-ststx)
  (unwrap-panic (contract-call?
    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.block-info-nakamoto-ststx-ratio-v2
    get-ststx-ratio
  ))
)

(define-read-only (get-stx-stacked-user-total (address principal))
  (+ (get-amount-wallet-stx-stacked address)
    (get-amount-liquid-ststxbtc-user address)
    (/ (* (get-amount-liquid-ststx-user address) (get-ratio-stx-ststx))
      u1000000
    ))
)

(define-read-only (get-stx-stacked-user-total-at-block-height
    (address principal)
    (stx-block-height uint)
  )
  (at-block
    (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height))
    (get-stx-stacked-user-total address)
  )
)
