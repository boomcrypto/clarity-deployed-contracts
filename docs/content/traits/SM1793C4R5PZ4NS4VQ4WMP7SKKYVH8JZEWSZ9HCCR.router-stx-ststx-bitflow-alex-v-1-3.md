---
title: "Trait router-stx-ststx-bitflow-alex-v-1-3"
draft: true
---
```

;; router-stx-ststx-bitflow-alex-v-1-3

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait a-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_MINIMUM_RECEIVED (err u4002))
(define-constant ERR_SWAP_A (err u5001))
(define-constant ERR_SWAP_B (err u5002))
(define-constant ERR_SCALED_AMOUNT_A (err u6001))
(define-constant ERR_QUOTE_A (err u7001))
(define-constant ERR_QUOTE_B (err u7002))

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (token-x <a-ft-trait>) (token-y <a-ft-trait>)
    (factor uint)
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (unwrap! (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                           (contract-of token-x) (contract-of token-y)
                           factor
                           amount-after-aggregator-fees) ERR_QUOTE_A))
    (scaled-amount (unwrap! (scale-alex-amount quote-a token-y) ERR_SCALED_AMOUNT_A))
    (quote-b (unwrap! (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy
                           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                           scaled-amount) ERR_QUOTE_B))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint) (provider (optional principal))
    (token-x <a-ft-trait>) (token-y <a-ft-trait>)
    (factor uint)
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (unwrap! (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx
                           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                           amount-after-aggregator-fees) ERR_QUOTE_A))
    (scaled-amount (unwrap! (scale-bitflow-amount quote-a token-x) ERR_SCALED_AMOUNT_A))    
    (quote-b (unwrap! (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                           (contract-of token-x) (contract-of token-y)
                           factor
                           scaled-amount) ERR_QUOTE_B))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-x-trait provider amount)))
    (swap-a (unwrap! (alex-sa amount-after-aggregator-fees token-x-trait token-y-trait factor) ERR_SWAP_A))
    (scaled-amount (unwrap! (scale-alex-amount swap-a token-y-trait) ERR_SCALED_AMOUNT_A))  
    (swap-b (unwrap! (bitflow-sa scaled-amount) ERR_SWAP_B))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          bitflow-data: {
            b-swap: swap-b
          },
          alex-data: {
            a-tokens: {
              a: (contract-of token-x-trait),
              b: (contract-of token-y-trait)
            },
            a-factors: {
              a: factor
            },
            a-swap: swap-a
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint) (provider (optional principal))
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token provider amount)))
    (swap-a (unwrap! (bitflow-sb amount-after-aggregator-fees) ERR_SWAP_A))
    (scaled-amount (unwrap! (scale-bitflow-amount swap-a token-x-trait) ERR_SCALED_AMOUNT_A))
    (swap-b (unwrap! (alex-sa scaled-amount token-x-trait token-y-trait factor) ERR_SWAP_B))
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-b",
        caller: tx-sender, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          bitflow-data: {
            b-swap: swap-a
          },
          alex-data: {
            a-tokens: {
              a: (contract-of token-x-trait),
              b: (contract-of token-y-trait)
            },
            a-factors: {
              a: factor
            },
            a-swap: swap-b
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (bitflow-sa (amount uint))
  (let (
    (swap-a (try! (contract-call?
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y
                  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                  amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (bitflow-sb (amount uint))
  (let (
    (swap-a (try! (contract-call?
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x
                  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                  amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (alex-sa
    (amount uint)
    (a-token <a-ft-trait>) (b-token <a-ft-trait>)
    (factor uint)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
                  a-token b-token
                  factor
                  amount (some u1))))
  )
    (ok swap-a)
  )
)

(define-private (scale-bitflow-amount (amount uint) (a-token <a-ft-trait>))
  (let (
    (b-decimals u6)
    (a-decimals (unwrap-panic (contract-call? a-token get-decimals)))
    (scaled-amount
      (if (is-eq b-decimals a-decimals)
        amount
        (if (> b-decimals a-decimals)
          (/ amount (pow u10 (- b-decimals a-decimals)))
          (* amount (pow u10 (- a-decimals b-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

(define-private (scale-alex-amount (amount uint) (a-token <a-ft-trait>))
  (let (
    (a-decimals (unwrap-panic (contract-call? a-token get-decimals)))
    (b-decimals u6)
    (scaled-amount
      (if (is-eq a-decimals b-decimals)
        amount
        (if (> a-decimals b-decimals)
          (/ amount (pow u10 (- a-decimals b-decimals)))
          (* amount (pow u10 (- b-decimals a-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

(define-private (get-aggregator-fees (provider (optional principal)) (amount uint))
  (let (
    (call-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.aggregator-core-v-1-1 get-aggregator-fees
                  (as-contract tx-sender) provider amount)))
    (amount-after-fees (- amount (get amount-fees-total call-a)))
  )
    (ok amount-after-fees)
  )
)

(define-private (transfer-aggregator-fees (token <ft-trait>) (provider (optional principal)) (amount uint))
  (let (
    (call-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.aggregator-core-v-1-1 transfer-aggregator-fees
                  token (as-contract tx-sender) provider amount)))
    (amount-after-fees (- amount (get amount-fees-total call-a)))
  )
    (ok amount-after-fees)
  )
)
```
