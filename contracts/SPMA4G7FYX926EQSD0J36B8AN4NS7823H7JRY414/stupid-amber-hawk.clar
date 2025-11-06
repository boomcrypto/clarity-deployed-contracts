(define-constant PRECISION_HELPER u100000000)

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

(define-read-only (get-bitflow-ststx-print (address principal))
  (let (
      (stableswap-token-4-user-lp-balance (unwrap-panic (contract-call?
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4
        get-balance address
      )))
      (stableswap-stacking-4-lp-data (unwrap-panic (contract-call?
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-stx-ststx-v-1-4
        get-user address
      )))
      (stableswap-stacking-4-user-lp-balance (get lp-staked (unwrap-panic stableswap-stacking-4-lp-data)))
      (lp-total-balance (unwrap-panic (contract-call?
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4
        get-total-supply
      )))
      (pool-data (unwrap-panic (contract-call?
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-stx-ststx-v-1-4
        get-pool
      )))
      (y-balance (get y-balance pool-data))
    )
    (ok {
      y-balance: y-balance,
      stableswap-token-4-user-lp-balance: stableswap-token-4-user-lp-balance,
      stableswap-stacking-4-user-lp-balance: stableswap-stacking-4-user-lp-balance,
      lp-total-balance: lp-total-balance,
    })
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

(define-read-only (get-velar-ststx-amount-from-ststx-stx-pools-print (address principal))
  (let (
      (pool-data (unwrap-panic (contract-call?
        'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-v1_0_0_ststx-0001
        get-pool
      )))
      (y-balance (get reserve1 pool-data))
      (lp-user-balance (unwrap-panic (contract-call?
        'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-lp-token-v1_0_0_ststx-0001
        get-balance address
      )))
      (lp-total-balance (unwrap-panic (contract-call?
        'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-lp-token-v1_0_0_ststx-0001
        get-total-supply
      )))
      (lp-farming-balance (get end
        (contract-call?
          'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-farming-core-v1_1_1_ststx-0001
          get-user-staked address
        )))
    )
    (ok {
      lp-total-balance: lp-total-balance,
      y-balance: y-balance,
      lp-user-balance: lp-user-balance,
      lp-farming-balance: lp-farming-balance,
    })
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

(define-read-only (get-velar-ststx-amount-from-ststx-aeusdc-pools-print (address principal))
  (let (
      (pool-data (contract-call?
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core
        get-pool u8
      ))
      (x-balance (unwrap-panic (get reserve0 pool-data)))
      (lp-total-balance (unwrap-panic (contract-call?
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc
        get-total-supply
      )))
      (lp-user-balance (unwrap-panic (contract-call?
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc
        get-balance address
      )))
      (lp-farming-balance (get end
        (contract-call?
          'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.farming-ststx-aeusdc-core
          get-user-staked address
        )))
    )
    (ok {
      lp-total-balance: lp-total-balance,
      x-balance: x-balance,
      lp-user-balance: lp-user-balance,
      lp-farming-balance: lp-farming-balance,
    })
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
