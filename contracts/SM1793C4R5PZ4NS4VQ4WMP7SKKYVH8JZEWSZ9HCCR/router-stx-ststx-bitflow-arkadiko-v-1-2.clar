
;; router-stx-ststx-bitflow-arkadiko-v-1-2

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_MINIMUM_RECEIVED (err u4002))
(define-constant ERR_SWAP_A (err u5001))
(define-constant ERR_SWAP_B (err u5002))

(define-read-only (get-quote-a
    (amount uint) (provider (optional principal))
    (token-x principal) (token-y principal)
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.arkadiko-swap-quotes-v-1-1 get-dx
                           token-x token-y
                           amount-after-aggregator-fees)))
    (quote-b (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy
                           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                           quote-a)))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-b
    (amount uint) (provider (optional principal))
    (token-x principal) (token-y principal)
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (quote-a (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx
                           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                           amount-after-aggregator-fees)))
    (quote-b (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.arkadiko-swap-quotes-v-1-1 get-dy
                           token-x token-y
                           quote-a)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees token-y-trait provider amount)))
    (swap-a (unwrap! (arkadiko-b token-x-trait token-y-trait amount-after-aggregator-fees) ERR_SWAP_A))
    (swap-b (unwrap! (bitflow-a swap-a) ERR_SWAP_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: caller, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          token-x-trait: (contract-of token-x-trait),
          token-y-trait: (contract-of token-y-trait)
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint) (provider (optional principal))
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
  )
  (let (
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token provider amount)))
    (swap-a (unwrap! (bitflow-b amount-after-aggregator-fees) ERR_SWAP_A))
    (swap-b (unwrap! (arkadiko-a token-x-trait token-y-trait swap-a) ERR_SWAP_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-b",
        caller: caller, 
        data: {
          amount: amount,
          amount-after-aggregator-fees: amount-after-aggregator-fees,
          min-received: min-received,
          received: swap-b,
          provider: provider,
          token-x-trait: (contract-of token-x-trait),
          token-y-trait: (contract-of token-y-trait)
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (bitflow-a (x-amount uint))
  (let (
    (swap-a (try! (contract-call?
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y
                  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                  x-amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (bitflow-b (y-amount uint))
  (let (
    (swap-a (try! (contract-call?
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x
                  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                  y-amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (arkadiko-a
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (dx uint)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
                  token-x-trait token-y-trait
                  dx u1)))
  )
    (ok (default-to u0 (element-at? swap-a u1)))
  )
)

(define-private (arkadiko-b
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (dy uint)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
                  token-x-trait token-y-trait
                  dy u1)))
  )
    (ok (default-to u0 (element-at? swap-a u0)))
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