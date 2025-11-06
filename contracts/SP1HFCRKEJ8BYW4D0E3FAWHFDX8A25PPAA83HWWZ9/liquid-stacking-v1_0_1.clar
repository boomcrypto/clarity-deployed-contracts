(define-constant PRECISION_HELPER u100000000)

;; Total related

(define-read-only (get-user-liquid-stx-stacked-at-block-height
    (address principal)
    (stx-block-height uint)
  )
  (at-block
    (unwrap-panic (get-stacks-block-info? id-header-hash stx-block-height))
    (get-user-liquid-stx-stacked address)
  )
)

(define-read-only (get-user-liquid-stx-stacked (address principal))
  (+
    (/
      (* (get-ratio-stx-ststx)
        (+ (get-ststx-balance-in-defis address)
          (get-ststx-balance-in-wallet address)
        ))
      u1000000
    )
    (get-ststxbtc-balance-in-defis address)
    (get-ststxbtc-balance-in-wallet address)
  )
)

(define-read-only (get-ratio-stx-ststx)
  (unwrap-panic (contract-call?
    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.block-info-nakamoto-ststx-ratio-v2
    get-ststx-ratio-at-block (- stacks-block-height u1)
  ))
)

;; User related
(define-read-only (get-ststx-balance-in-wallet (address principal))
  (unwrap!
    (contract-call?
      'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
      get-balance address
    )
    u0
  )
)

(define-read-only (get-ststxbtc-balance-in-wallet (address principal))
  (unwrap!
    (contract-call?
      'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token-v2
      get-balance address
    )
    u0
  )
)

;; DeFi related

(define-read-only (get-zest-ststx-balance (address principal))
  (contract-call?
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-token
    get-balance address
  )
)

(define-read-only (get-arkadiko-ststx-balance (address principal))
  (get collateral
    (unwrap!
      (contract-call?
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-data-v1-1
        get-vault address
        'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
      )
      u0
    ))
)

(define-read-only (get-bitflow-ststx-balance (address principal))
  (let (
      (stableswap-token-4-user-lp-balance (unwrap!
        (contract-call?
          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4
          get-balance address
        )
        u0
      ))
      (stableswap-stacking-4-lp-data (unwrap!
        (contract-call?
          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-stx-ststx-v-1-4
          get-user address
        )
        u0
      ))
      (stableswap-stacking-4-user-lp-balance (get lp-staked (unwrap! stableswap-stacking-4-lp-data u0)))
      (lp-total-balance (unwrap!
        (contract-call?
          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4
          get-total-supply
        )
        u0
      ))
      (pool-data (unwrap-panic (contract-call?
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4
        get-pool
      )))
      (y-balance (get y-balance pool-data))
    )
    (if (is-eq lp-total-balance u0)
      u0
      (/
        (* PRECISION_HELPER y-balance
          (+ stableswap-token-4-user-lp-balance
            stableswap-stacking-4-user-lp-balance
          ))
        lp-total-balance PRECISION_HELPER
      )
    )
  )
)

(define-read-only (get-velar-ststx-amount-from-ststx-stx-pools (address principal))
  (let (
      (pool-data (unwrap-panic (contract-call?
        'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-v1_0_0_ststx-0001
        get-pool
      )))
      (y-balance (get reserve1 pool-data))
      (lp-user-balance (unwrap!
        (contract-call?
          'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-lp-token-v1_0_0_ststx-0001
          get-balance address
        )
        u0
      ))
      (lp-total-balance (unwrap!
        (contract-call?
          'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-lp-token-v1_0_0_ststx-0001
          get-total-supply
        )
        u0
      ))
      (lp-farming-balance (get end
        (contract-call?
          'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-farming-core-v1_1_1_ststx-0001
          get-user-staked address
        )))
    )
    (if (is-eq lp-total-balance u0)
      u0
      (/
        (* PRECISION_HELPER y-balance
          (+ lp-user-balance lp-farming-balance)
        )
        lp-total-balance PRECISION_HELPER
      )
    )
  )
)

(define-read-only (get-velar-ststx-amount-from-ststx-aeusdc-pools (address principal))
  (let (
      (pool-data (contract-call?
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core
        get-pool u8
      ))
      (x-balance (unwrap! (get reserve0 pool-data) u0))
      (lp-total-balance (unwrap!
        (contract-call?
          'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc
          get-total-supply
        )
        u0
      ))
      (lp-user-balance (unwrap!
        (contract-call?
          'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc
          get-balance address
        )
        u0
      ))
      (lp-farming-balance (get end
        (contract-call?
          'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.farming-ststx-aeusdc-core
          get-user-staked address
        )))
    )
    (if (is-eq lp-total-balance u0)
      u0
      (/
        (* PRECISION_HELPER x-balance
          (+ lp-user-balance lp-farming-balance)
        )
        lp-total-balance PRECISION_HELPER
      )
    )
  )
)

(define-read-only (get-velar-ststx-balance (address principal))
  (+ (get-velar-ststx-amount-from-ststx-aeusdc-pools address)
    (get-velar-ststx-amount-from-ststx-stx-pools address)
  )
)

(define-read-only (get-ststx-balance-in-defis (address principal))
  (let (
      (arkadiko-amount (get-arkadiko-ststx-balance address))
      (zest-amount (get-zest-ststx-balance address))
      (bitflow-amount (get-bitflow-ststx-balance address))
      (velar-amount (get-velar-ststx-balance address))
    )
    (+ arkadiko-amount zest-amount bitflow-amount velar-amount)
  )
)

(define-read-only (get-zest-ststxbtc-balance (address principal))
  (contract-call?
    'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststxbtc-v2-token
    get-balance address
  )
)

(define-read-only (get-ststxbtc-balance-in-defis (address principal))
  (let ((zest-amount (get-zest-ststxbtc-balance address)))
    zest-amount
  )
)
