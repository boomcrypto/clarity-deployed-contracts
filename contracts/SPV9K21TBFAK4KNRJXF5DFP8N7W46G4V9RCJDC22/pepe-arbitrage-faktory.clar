(define-constant ERR-SLIPPAGE (err u1000))
(define-constant ERR-NO-PROFIT (err u1001))

(define-constant CONTRACT (as-contract tx-sender))
(define-constant SAINT 'SP000000000000000000002Q6VF78)

(define-constant VELAR-POOL-ID u11)

(define-public (arb-fak-bit-vel
    (pepe-in uint)
    (min-pepe-out uint))
  (begin
    (try! (contract-call? 
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
      transfer 
      pepe-in 
      tx-sender 
      CONTRACT
      none
    ))
    (let ((sbtc-out (try! (as-contract (swap-pepe-to-sbtc pepe-in))))
          (stx-out (try! (as-contract (swap-sbtc-to-stx sbtc-out))))
          (pepe-out (try! (as-contract (swap-stx-to-pepe stx-out))))
          (pepe-arbitrager tx-sender)
          (burnt-pepe (if (> pepe-out pepe-in) (- pepe-out pepe-in) u0)))
          (asserts! (>= pepe-out min-pepe-out) ERR-SLIPPAGE)
          (asserts! (> pepe-out pepe-in) ERR-NO-PROFIT)
          (try! (as-contract (contract-call? 
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
            transfer 
            pepe-in 
            CONTRACT 
            pepe-arbitrager
            none
          )))
          (try! (as-contract (contract-call? 
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
            transfer 
            burnt-pepe 
            CONTRACT 
            SAINT
            none
          )))
          (ok {
            pepe-in: pepe-in,
            pepe-out: pepe-out,
            burnt-pepe: burnt-pepe
          })
        )
      )
    )

(define-private (swap-pepe-to-sbtc (pepe-amount uint))
  (let (
      (result (try! (contract-call? 
        'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ.pepe-faktory-pool-v2
        execute
        pepe-amount
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

(define-private (swap-stx-to-pepe (stx-amount uint))
  (let (
      (result (try! (contract-call?
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router
        swap-exact-tokens-for-tokens
        VELAR-POOL-ID
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
        stx-amount
        u1
      )))
    )
    (ok (get amt-out result))
  )
)

(define-public (arb-fak-vel-vel
    (pepe-in uint)
    (min-pepe-out uint))
  (begin
    (try! (contract-call? 
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
      transfer 
      pepe-in 
      tx-sender 
      CONTRACT
      none
    ))
    (let ((sbtc-out (try! (as-contract (swap-pepe-to-sbtc pepe-in))))
          (stx-out (try! (as-contract (swap-sbtc-to-stx-velar sbtc-out))))
          (pepe-out (try! (as-contract (swap-stx-to-pepe stx-out))))
          (pepe-arbitrager tx-sender)
          (burnt-pepe (if (> pepe-out pepe-in) (- pepe-out pepe-in) u0)))
          (asserts! (>= pepe-out min-pepe-out) ERR-SLIPPAGE)
          (asserts! (> pepe-out pepe-in) ERR-NO-PROFIT)
          (try! (as-contract (contract-call? 
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
            transfer 
            pepe-in 
            CONTRACT 
            pepe-arbitrager
            none
          )))
          (try! (as-contract (contract-call? 
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
            transfer 
            burnt-pepe 
            CONTRACT 
            SAINT
            none
          )))
          (ok {
            pepe-in: pepe-in,
            pepe-out: pepe-out,
            burnt-pepe: burnt-pepe
          })
        )
      )
    )

;; REVEEEEEERSE
(define-public (arb-vel-bit-fak
    (pepe-in uint)
    (min-pepe-out uint))
  (begin
    (try! (contract-call? 
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
      transfer 
      pepe-in 
      tx-sender 
      CONTRACT
      none
    ))
    (let ((stx-out (try! (as-contract (swap-pepe-to-stx pepe-in))))
          (sbtc-out (try! (as-contract (swap-stx-to-sbtc stx-out))))
          (pepe-out (try! (as-contract (swap-sbtc-to-pepe sbtc-out))))
          (pepe-arbitrager tx-sender)
          (burnt-pepe (if (> pepe-out pepe-in) (- pepe-out pepe-in) u0)))
          (asserts! (>= pepe-out min-pepe-out) ERR-SLIPPAGE)
          (asserts! (> pepe-out pepe-in) ERR-NO-PROFIT)
          (try! (as-contract (contract-call? 
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
            transfer 
            pepe-in 
            CONTRACT 
            pepe-arbitrager
            none
          )))

          (try! (as-contract (contract-call? 
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
            transfer 
            burnt-pepe 
            CONTRACT 
            SAINT
            none
          )))
          
          (ok {
            pepe-in: pepe-in,
            pepe-out: pepe-out,
            burnt-pepe: burnt-pepe
          })
        )
      )
    )

(define-private (swap-pepe-to-stx (pepe-amount uint))
  (let (
      (result (try! (contract-call?
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router
        swap-exact-tokens-for-tokens
        VELAR-POOL-ID
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
        pepe-amount
        u1
      )))
    )
    (ok (get amt-out result))
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

(define-private (swap-sbtc-to-pepe (sbtc-amount uint))
  (let (
      (result (try! (contract-call?
        'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ.pepe-faktory-pool-v2
        execute
        sbtc-amount
        (some 0x00) 
      )))
    )
    (ok (get dy result))
  )
)

(define-public (arb-vel-vel-fak
    (pepe-in uint)
    (min-pepe-out uint))
  (begin
    (try! (contract-call? 
      'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
      transfer 
      pepe-in 
      tx-sender 
      CONTRACT
      none
    ))
    (let ((stx-out (try! (as-contract (swap-pepe-to-stx pepe-in))))
          (sbtc-out (try! (as-contract (swap-stx-to-sbtc-velar stx-out))))
          (pepe-out (try! (as-contract (swap-sbtc-to-pepe sbtc-out))))
          (pepe-arbitrager tx-sender)
          (burnt-pepe (if (> pepe-out pepe-in) (- pepe-out pepe-in) u0)))
          (asserts! (>= pepe-out min-pepe-out) ERR-SLIPPAGE)
          (asserts! (> pepe-out pepe-in) ERR-NO-PROFIT)
          (try! (as-contract (contract-call? 
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
            transfer 
            pepe-in 
            CONTRACT 
            pepe-arbitrager
            none
          )))
          (try! (as-contract (contract-call? 
            'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k68639zxz 
            transfer 
            burnt-pepe 
            CONTRACT 
            SAINT
            none
          )))
          (ok {
            pepe-in: pepe-in,
            pepe-out: pepe-out,
            burnt-pepe: burnt-pepe
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
(define-read-only (check-fak-bit-vel (pepe-in uint))
  (let (
    (sbtc-estimate (simulate-pepe-to-sbtc pepe-in))
    (stx-estimate (simulate-sbtc-to-stx sbtc-estimate))
    (pepe-estimate (simulate-stx-to-pepe stx-estimate))
    (profit (if (> pepe-estimate pepe-in) (- pepe-estimate pepe-in) u0))
  )
  (ok {
    pepe-in: pepe-in,
    sbtc-out: sbtc-estimate,
    stx-out: stx-estimate,
    pepe-out: pepe-estimate,
    profit: profit,
    profitable: (> pepe-estimate pepe-in)
  }))
)

(define-read-only (check-vel-bit-fak (pepe-in uint))
  (let (
    (stx-estimate (simulate-pepe-to-stx pepe-in))
    (sbtc-estimate (simulate-stx-to-sbtc stx-estimate))
    (pepe-estimate (simulate-sbtc-to-pepe sbtc-estimate))
    (profit (if (> pepe-estimate pepe-in) (- pepe-estimate pepe-in) u0))
  )
  (ok {
    pepe-in: pepe-in,
    stx-out: stx-estimate,
    sbtc-out: sbtc-estimate,
    pepe-out: pepe-estimate,
    profit: profit,
    profitable: (> pepe-estimate pepe-in)
  }))
)

(define-read-only (simulate-pepe-to-sbtc (pepe-amount uint))
  (get dy (unwrap-panic (contract-call? 
    'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ.pepe-faktory-pool-v2
    quote
    pepe-amount
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

(define-read-only (simulate-stx-to-pepe (stx-amount uint))
  (let ((pool (unwrap-panic (contract-call? 
          'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core 
          get-pool 
          VELAR-POOL-ID)))
        (r0 (get reserve0 pool))
        (r1 (get reserve1 pool))
        (swap-fee (get swap-fee pool))
        (amt-in-adjusted (/ (* stx-amount (get num swap-fee)) (get den swap-fee)))
        (amt-out (/ (* r1 amt-in-adjusted) (+ r0 amt-in-adjusted)))
  )
  amt-out)
)

(define-read-only (simulate-pepe-to-stx (pepe-amount uint))
  (let ((pool (unwrap-panic (contract-call? 
          'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core 
          get-pool 
          VELAR-POOL-ID)))
        (r0 (get reserve0 pool))
        (r1 (get reserve1 pool))
        (swap-fee (get swap-fee pool))
        (amt-in-adjusted (/ (* pepe-amount (get num swap-fee)) (get den swap-fee)))
        (amt-out (/ (* r0 amt-in-adjusted) (+ r1 amt-in-adjusted)))
  )
  amt-out)
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

(define-read-only (simulate-sbtc-to-pepe (sbtc-amount uint))
  (get dy (unwrap-panic (contract-call? 
    'SP6SA6BTPNN5WDAWQ7GWJF1T5E2KWY01K9SZDBJQ.pepe-faktory-pool-v2
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

(define-read-only (check-fak-vel-vel (pepe-in uint))
  (let (
    (sbtc-estimate (simulate-pepe-to-sbtc pepe-in))
    (stx-estimate (simulate-sbtc-to-stx-velar sbtc-estimate))
    (pepe-estimate (simulate-stx-to-pepe stx-estimate))
    (profit (if (> pepe-estimate pepe-in) (- pepe-estimate pepe-in) u0))
  )
  (ok {
    pepe-in: pepe-in,
    sbtc-out: sbtc-estimate,
    stx-out: stx-estimate,
    pepe-out: pepe-estimate,
    profit: profit,
    profitable: (> pepe-estimate pepe-in)
  }))
)

(define-read-only (check-vel-vel-fak (pepe-in uint))
  (let (
    (stx-estimate (simulate-pepe-to-stx pepe-in))
    (sbtc-estimate (simulate-stx-to-sbtc-velar stx-estimate))
    (pepe-estimate (simulate-sbtc-to-pepe sbtc-estimate))
    (profit (if (> pepe-estimate pepe-in) (- pepe-estimate pepe-in) u0))
  )
  (ok {
    pepe-in: pepe-in,
    stx-out: stx-estimate,
    sbtc-out: sbtc-estimate,
    pepe-out: pepe-estimate,
    profit: profit,
    profitable: (> pepe-estimate pepe-in)
  }))
)