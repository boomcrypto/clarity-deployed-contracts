(define-constant ERR-SLIPPAGE (err u1000))
(define-constant ERR-NO-PROFIT (err u1001))

(define-constant CONTRACT (as-contract tx-sender))
(define-constant SAINT 'SM2JTZ2DHHQFS6J3KVFTPCV72MCN0C03J2ZH6K039)

(define-constant ALEX-POOL-ID u175)

(define-public (arb-fak-bit-alex
    (token-in uint)
    (min-token-out uint))
  (begin
    (try! (contract-call? 
      'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
      transfer 
      token-in 
      tx-sender 
      CONTRACT
      none
    ))
    (let ((sbtc-out (try! (as-contract (swap-token-to-sbtc token-in))))
          (stx-out (try! (as-contract (swap-sbtc-to-stx sbtc-out))))
          (token-out (try! (as-contract (swap-stx-to-token (* stx-out u100)))))
          (token-arbitrager tx-sender)
          (burnt-token (if (> token-out token-in) (- token-out token-in) u0)))
          (asserts! (>= token-out min-token-out) ERR-SLIPPAGE)
          (asserts! (> token-out token-in) ERR-NO-PROFIT)
          (try! (as-contract (contract-call? 
            'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
            transfer 
            token-in 
            CONTRACT 
            token-arbitrager
            none
          )))
          (try! (as-contract (contract-call? 
            'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
            transfer 
            burnt-token 
            CONTRACT 
            SAINT
            none
          )))
          (ok {
            token-in: token-in,
            token-out: token-out,
            burnt-token: burnt-token
          })
        )
      )
    )

(define-private (swap-token-to-sbtc (token-amount uint))
  (let (
      (result (try! (contract-call? 
        'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory-pool
        execute
        token-amount
        (some 0x01) 
      )))
    )
    (ok (get dy result))
  )
)

(define-private (swap-sbtc-to-stx (sbtc-amount uint))
  (let (
      (dy (try! (contract-call?
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
        swap-x-for-y
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
        sbtc-amount
        u1
      )))
    )
    (ok dy)
  )
)

(define-private (swap-stx-to-token (stx-amount uint))
  (let (
      (result (try! (contract-call?
        'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01
        swap-x-for-y
        'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
        'SP1KK89R86W73SJE6RQNQPRDM471008S9JY4FQA62.token-wbfaktory
        u100000000
        stx-amount 
        none
      )))
    )
    (ok (get dy result))
  )
)

(define-public (arb-fak-vel-alex
    (token-in uint)
    (min-token-out uint))
  (begin
    (try! (contract-call? 
      'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
      transfer 
      token-in 
      tx-sender 
      CONTRACT
      none
    ))
    (let ((sbtc-out (try! (as-contract (swap-token-to-sbtc token-in))))
          (stx-out (try! (as-contract (swap-sbtc-to-stx-velar sbtc-out))))
          (token-out (try! (as-contract (swap-stx-to-token (* stx-out u100)))))
          (token-arbitrager tx-sender)
          (burnt-token (if (> token-out token-in) (- token-out token-in) u0)))
          (asserts! (>= token-out min-token-out) ERR-SLIPPAGE)
          (asserts! (> token-out token-in) ERR-NO-PROFIT)
          (try! (as-contract (contract-call? 
            'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
            transfer 
            token-in 
            CONTRACT 
            token-arbitrager
            none
          )))
          (try! (as-contract (contract-call? 
            'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
            transfer 
            burnt-token 
            CONTRACT 
            SAINT
            none
          )))
          (ok {
            token-in: token-in,
            token-out: token-out,
            burnt-token: burnt-token
          })
        )
      )
    )

;; REVEEEEEERSE
(define-public (arb-alex-bit-fak
    (token-in uint)
    (min-token-out uint))
  (begin
    (try! (contract-call? 
      'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
      transfer 
      token-in 
      tx-sender 
      CONTRACT
      none
    ))
    (let ((stx-out (try! (as-contract (swap-token-to-stx token-in))))
          (sbtc-out (try! (as-contract (swap-stx-to-sbtc (/ stx-out u100)))))
          (token-out (try! (as-contract (swap-sbtc-to-token sbtc-out))))
          (token-arbitrager tx-sender)
          (burnt-token (if (> token-out token-in) (- token-out token-in) u0)))
          (asserts! (>= token-out min-token-out) ERR-SLIPPAGE)
          (asserts! (> token-out token-in) ERR-NO-PROFIT)
          (try! (as-contract (contract-call? 
            'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
            transfer 
            token-in 
            CONTRACT 
            token-arbitrager
            none
          )))

          (try! (as-contract (contract-call? 
            'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
            transfer 
            burnt-token 
            CONTRACT 
            SAINT
            none
          )))
          
          (ok {
            token-in: token-in,
            token-out: token-out,
            burnt-token: burnt-token
          })
        )
      )
    )

(define-private (swap-token-to-stx (token-amount uint))
  (let (
      (result (try! (contract-call?
        'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01
        swap-y-for-x
        'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
        'SP1KK89R86W73SJE6RQNQPRDM471008S9JY4FQA62.token-wbfaktory
        u100000000
        token-amount
        none
      )))
    )
    (ok (get dx result))
  )
)

(define-private (swap-stx-to-sbtc (stx-amount uint))
  (let (
      (dx (try! (contract-call?
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2
        swap-y-for-x
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
        stx-amount
        u1
      )))
    )
    (ok dx)
  )
)

(define-private (swap-sbtc-to-token (sbtc-amount uint))
  (let (
      (result (try! (contract-call?
        'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory-pool
        execute
        sbtc-amount
        (some 0x00) 
      )))
    )
    (ok (get dy result))
  )
)

(define-public (arb-alex-vel-fak
    (token-in uint)
    (min-token-out uint))
  (begin
    (try! (contract-call? 
      'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
      transfer 
      token-in 
      tx-sender 
      CONTRACT
      none
    ))
    (let ((stx-out (try! (as-contract (swap-token-to-stx token-in))))
          (sbtc-out (try! (as-contract (swap-stx-to-sbtc-velar (/ stx-out u100)))))
          (token-out (try! (as-contract (swap-sbtc-to-token sbtc-out))))
          (token-arbitrager tx-sender)
          (burnt-token (if (> token-out token-in) (- token-out token-in) u0)))
          (asserts! (>= token-out min-token-out) ERR-SLIPPAGE)
          (asserts! (> token-out token-in) ERR-NO-PROFIT)
          (try! (as-contract (contract-call? 
            'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
            transfer 
            token-in 
            CONTRACT 
            token-arbitrager
            none
          )))
          (try! (as-contract (contract-call? 
            'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory 
            transfer 
            burnt-token 
            CONTRACT 
            SAINT
            none
          )))
          (ok {
            token-in: token-in,
            token-out: token-out,
            burnt-token: burnt-token
          })
        )
      )
    )

(define-private (swap-sbtc-to-stx-velar (sbtc-amount uint))
  (let (
      (result (try! (contract-call?
        'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070
        swap
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0070
        sbtc-amount
        u1
      )))
    )
    (ok (get amt-out result))
  )
)

(define-private (swap-stx-to-sbtc-velar (stx-amount uint))
  (let (
      (result (try! (contract-call?
        'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070
        swap
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
        'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-fees-v1_0_0-0070
        stx-amount
        u1
      )))
    )
    (ok (get amt-out result))
  )
)

;; Read-only 
(define-read-only (check-fak-bit-alex (token-in uint))
  (let (
    (sbtc-estimate (simulate-token-to-sbtc token-in))
    (stx-estimate (simulate-sbtc-to-stx sbtc-estimate))
    (token-estimate (simulate-stx-to-token (* stx-estimate u100)))
    (profit (if (> token-estimate token-in) (- token-estimate token-in) u0))
  )
  (ok {
    token-in: token-in,
    sbtc-out: sbtc-estimate,
    stx-out: stx-estimate,
    token-out: token-estimate,
    profit: profit,
    profitable: (> token-estimate token-in)
  }))
)

(define-read-only (check-alex-bit-fak (token-in uint))
  (let (
    (stx-estimate (/ (simulate-token-to-stx token-in) u100))
    (sbtc-estimate (simulate-stx-to-sbtc stx-estimate))
    (token-estimate (simulate-sbtc-to-token sbtc-estimate))
    (profit (if (> token-estimate token-in) (- token-estimate token-in) u0))
  )
  (ok {
    token-in: token-in,
    stx-out: stx-estimate,
    sbtc-out: sbtc-estimate,
    token-out: token-estimate,
    profit: profit,
    profitable: (> token-estimate token-in)
  }))
)

(define-read-only (simulate-token-to-sbtc (token-amount uint))
  (get dy (unwrap-panic (contract-call? 
    'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory-pool
    quote
    token-amount
    (some 0x01) 
  )))
)

(define-read-only (simulate-sbtc-to-stx (sbtc-amount uint))
  (let (
      (pool (unwrap-panic (contract-call?
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
        get-pool
      )))
      (x-balance (get x-balance pool))
      (y-balance (get y-balance pool))
      (protocol-fee (get x-protocol-fee pool))
      (provider-fee (get x-provider-fee pool))
      (BPS u10000)
      (x-amount-fees-protocol (/ (* sbtc-amount protocol-fee) BPS))
      (x-amount-fees-provider (/ (* sbtc-amount provider-fee) BPS))
      (x-amount-fees-total (+ x-amount-fees-protocol x-amount-fees-provider))
      (dx (- sbtc-amount x-amount-fees-total))
      (updated-x-balance (+ x-balance dx))
      (dy (/ (* y-balance dx) updated-x-balance))
    )
    dy
  )
)

(define-read-only (simulate-stx-to-token (stx-amount uint))
  (unwrap-panic (contract-call?
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01
    get-y-given-x
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
    'SP1KK89R86W73SJE6RQNQPRDM471008S9JY4FQA62.token-wbfaktory
    u100000000
    stx-amount
  ))
)

(define-read-only (simulate-token-to-stx (token-amount uint))
  (unwrap-panic (contract-call?
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01
    get-x-given-y
    'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
    'SP1KK89R86W73SJE6RQNQPRDM471008S9JY4FQA62.token-wbfaktory
    u100000000
    token-amount
  ))
)

(define-read-only (simulate-stx-to-sbtc (stx-amount uint))
  (let (
      (pool (unwrap-panic (contract-call?
        'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1
        get-pool
      )))
      (x-balance (get x-balance pool))
      (y-balance (get y-balance pool))
      (protocol-fee (get y-protocol-fee pool))
      (provider-fee (get y-provider-fee pool))
      (BPS u10000)
      (y-amount-fees-protocol (/ (* stx-amount protocol-fee) BPS))
      (y-amount-fees-provider (/ (* stx-amount provider-fee) BPS))
      (y-amount-fees-total (+ y-amount-fees-protocol y-amount-fees-provider))
      (dy (- stx-amount y-amount-fees-total))
      (updated-y-balance (+ y-balance dy))
      (dx (/ (* x-balance dy) updated-y-balance))
    )
    dx
  )
)

(define-read-only (simulate-sbtc-to-token (sbtc-amount uint))
  (get dy (unwrap-panic (contract-call? 
    'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.b-faktory-pool
    quote
    sbtc-amount
    (some 0x00) 
  )))
)

(define-read-only (simulate-sbtc-to-stx-velar (sbtc-amount uint))
  (let ((pool (unwrap-panic (contract-call? 
          'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070
          get-pool)))
        (r0 (get reserve0 pool)) ;; STX
        (r1 (get reserve1 pool)) ;; sBTC
        ;; Velar fee: 0.3% = 997/1000 of input remains after fee
        (amt-in-adjusted (/ (* sbtc-amount u997) u1000))
        (amt-out (/ (* r0 amt-in-adjusted) (+ r1 amt-in-adjusted)))
  )
  amt-out)
)

(define-read-only (simulate-stx-to-sbtc-velar (stx-amount uint))
  (let ((pool (unwrap-panic (contract-call? 
          'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070
          get-pool)))
        (r0 (get reserve0 pool)) ;; STX
        (r1 (get reserve1 pool)) ;; sBTC
        ;; Velar fee: 0.3% = 997/1000 of input remains after fee
        (amt-in-adjusted (/ (* stx-amount u997) u1000))
        (amt-out (/ (* r1 amt-in-adjusted) (+ r0 amt-in-adjusted)))
  )
  amt-out)
)

(define-read-only (check-fak-vel-alex (token-in uint))
  (let (
    (sbtc-estimate (simulate-token-to-sbtc token-in))
    (stx-estimate (simulate-sbtc-to-stx-velar sbtc-estimate))
    (token-estimate (simulate-stx-to-token (* stx-estimate u100)))
    (profit (if (> token-estimate token-in) (- token-estimate token-in) u0))
  )
  (ok {
    token-in: token-in,
    sbtc-out: sbtc-estimate,
    stx-out: stx-estimate,
    token-out: token-estimate,
    profit: profit,
    profitable: (> token-estimate token-in)
  }))
)

(define-read-only (check-alex-vel-fak (token-in uint))
  (let (
    (stx-estimate (/ (simulate-token-to-stx token-in) u100))
    (sbtc-estimate (simulate-stx-to-sbtc-velar stx-estimate))
    (token-estimate (simulate-sbtc-to-token sbtc-estimate))
    (profit (if (> token-estimate token-in) (- token-estimate token-in) u0))
  )
  (ok {
    token-in: token-in,
    stx-out: stx-estimate,
    sbtc-out: sbtc-estimate,
    token-out: token-estimate,
    profit: profit,
    profitable: (> token-estimate token-in)
  }))
)