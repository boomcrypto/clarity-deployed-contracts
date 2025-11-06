(define-constant err-no-profit (err u1111))

(define-private (buy-leo-on-alex (amount uint))
  (/
    (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01
      swap-helper-a 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo u100000000
      u100000000 (* u100 amount) none
    ))
    u100
  )
)

(define-private (buy-stx-on-alex (amount uint))
  (/
    (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01
      swap-helper-a 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wleo
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 u100000000
      u100000000 (* u100 amount) none
    ))
    u100
  )
)

(define-private (buy-stx-on-bitflow (amount uint))
  (unwrap-panic (contract-call?
    'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-3
    swap-helper-a amount u1 none {
    a: 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token,
    b: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2,
  } { a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-leo-stx-v-1-1 }
  ))
)

(define-private (buy-leo-on-bitflow (amount uint))
  (unwrap-panic (contract-call?
    'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-3
    swap-helper-a amount u1 none {
    a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2,
    b: 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token,
  } { a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-leo-stx-v-1-1 }
  ))
)

(define-private (buy-stx-on-velar (amount uint))
  (get amt-out
    (get swap1
      (unwrap-panic (contract-call?
        'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging apply
        (list {
          a: "u",
          b: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-leo,
          c: u28,
          d: 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token,
          e: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx,
          f: false,
        })
        amount (some 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token)
        (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx) none none none
        (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)
        none none none none none none none none none none none none none none
        none none none none none none none none none none
      ))
    ))
)

(define-private (buy-leo-on-velar (amount uint))
  (get amt-out
    (get swap1
      (unwrap-panic (contract-call?
        'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.path-apply_staging apply
        (list {
          a: "u",
          b: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-leo,
          c: u28,
          d: 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.wstx,
          e: 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token,
          f: true,
        })
        amount (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx)
        (some 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token) none none
        none
        (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to)
        none none none none none none none none none none none none none none
        none none none none none none none none none none
      ))
    ))
)

(define-public (a-b (amount uint))
  (let (
      ;; Alex always uses 8 decimals, so although Leo and STX use 6 decimals, we convert them to 8 and back.
      (leo (buy-leo-on-alex amount))
      (stx (buy-stx-on-bitflow leo))
    )
    (begin
      (if (> stx amount)
        (ok stx)
        err-no-profit
      )
    )
  )
)

(define-public (a-v (amount uint))
  (let (
      (leo (buy-leo-on-alex amount))
      (stx (buy-stx-on-velar leo))
    )
    (begin
      (if (> stx amount)
        (ok stx)
        err-no-profit
      )
    )
  )
)

(define-public (b-a (amount uint))
  (let (
      (leo (buy-leo-on-bitflow amount))
      (stx (buy-stx-on-alex leo))
    )
    (begin
      (if (> stx amount)
        (ok stx)
        err-no-profit
      )
    )
  )
)

(define-public (b-v (amount uint))
  (let (
      (leo (buy-leo-on-bitflow amount))
      (stx (buy-stx-on-velar leo))
    )
    (begin
      (if (> stx amount)
        (ok stx)
        err-no-profit
      )
    )
  )
)

(define-public (v-a (amount uint))
  (let (
      (leo (buy-leo-on-velar amount))
      (stx (buy-stx-on-alex leo))
    )
    (begin
      (if (> stx amount)
        (ok stx)
        err-no-profit
      )
    )
  )
)

(define-public (v-b (amount uint))
  (let (
      (leo (buy-leo-on-velar amount))
      (stx (buy-stx-on-bitflow leo))
    )
    (begin
      (if (> stx amount)
        (ok stx)
        err-no-profit
      )
    )
  )
)
