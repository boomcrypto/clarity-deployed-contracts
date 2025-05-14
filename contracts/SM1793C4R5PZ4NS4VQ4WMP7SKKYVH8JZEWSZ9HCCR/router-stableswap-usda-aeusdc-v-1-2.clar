
;; router-stableswap-usda-aeusdc-v-1-2

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)
(use-trait usda-aeusdc-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))
(define-constant ERR_SWAP_A (err u6010))
(define-constant ERR_SWAP_B (err u6011))
(define-constant ERR_QUOTE_A (err u6012))
(define-constant ERR_QUOTE_B (err u6013))

(define-public (get-quote-a
    (amount uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (usda-aeusdc-tokens (tuple (a <usda-aeusdc-ft-trait>) (b <usda-aeusdc-ft-trait>)))
  )
  (let (
    (amount-after-aggregator-fees (try! (get-aggregator-fees provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (usda-aeusdc-qa amount-after-aggregator-fees usda-aeusdc-tokens) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (usda-aeusdc-qa quote-a usda-aeusdc-tokens) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (provider (optional principal))
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (usda-aeusdc-tokens (tuple (a <usda-aeusdc-ft-trait>) (b <usda-aeusdc-ft-trait>)))
  )
  (let (
    (aggregator-fee-token (if (is-eq swaps-reversed false) (get a stableswap-tokens) (get a usda-aeusdc-tokens)))
    (amount-after-aggregator-fees (try! (transfer-aggregator-fees aggregator-fee-token provider amount)))
    (amount-check (asserts! (> amount-after-aggregator-fees u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount-after-aggregator-fees stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (usda-aeusdc-sa amount-after-aggregator-fees usda-aeusdc-tokens) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (usda-aeusdc-sa swap-a usda-aeusdc-tokens) ERR_SWAP_B)
                (unwrap! (stableswap-sa swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
          swaps-reversed: swaps-reversed,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          usda-aeusdc-data: {
            usda-aeusdc-tokens: usda-aeusdc-tokens,
            usda-aeusdc-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (is-stableswap-path-reversed
    (token-in <stableswap-ft-trait>) (token-out <stableswap-ft-trait>)
    (pool-contract <stableswap-pool-trait>)
  )
  (let (
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool)))
  )
    (not (and (is-eq (contract-of token-in) (get x-token pool-data)) (is-eq (contract-of token-out) (get y-token pool-data))))
  )
)

(define-private (is-usda-aeusdc-path-reversed
    (token-in <usda-aeusdc-ft-trait>) (token-out <usda-aeusdc-ft-trait>)
  )
  (not (and (is-eq (contract-of token-in) 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token) (is-eq (contract-of token-out) 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)))
)

(define-private (stableswap-qa
    (amount uint)
    (tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    (is-reversed (is-stableswap-path-reversed (get a tokens) (get b tokens) (get a pools)))
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 get-dy
                 (get a pools)
                 (get a tokens) (get b tokens)
                 amount))
                 (try! (contract-call?
                 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 get-dx
                 (get a pools)
                 (get b tokens) (get a tokens)
                 amount))))
  )
    (ok quote-a)
  )
)

(define-private (usda-aeusdc-qa
    (amount uint)
    (tokens (tuple (a <usda-aeusdc-ft-trait>) (b <usda-aeusdc-ft-trait>)))
  )
  (let (
    (is-reversed (is-usda-aeusdc-path-reversed (get a tokens) (get b tokens)))
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 get-dy
                 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4
                 amount))
                 (try! (contract-call?
                 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 get-dx
                 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4
                 amount))))
  )
    (ok quote-a)
  )
)

(define-private (stableswap-sa
    (amount uint)
    (tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    (is-reversed (is-stableswap-path-reversed (get a tokens) (get b tokens) (get a pools)))
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 swap-x-for-y
                      (get a pools)
                      (get a tokens) (get b tokens)
                      amount u1))
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-2 swap-y-for-x
                      (get a pools)
                      (get b tokens) (get a tokens)
                      amount u1))))
  )
    (ok swap-a)
  )
)

(define-private (usda-aeusdc-sa
    (amount uint)
    (tokens (tuple (a <usda-aeusdc-ft-trait>) (b <usda-aeusdc-ft-trait>)))
  )
  (let (
    (is-reversed (is-usda-aeusdc-path-reversed (get a tokens) (get b tokens)))
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 swap-x-for-y
                      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                      'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4
                      amount u1))
                (try! (contract-call?
                      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-usda-aeusdc-v-1-4 swap-y-for-x
                      'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                      'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4
                      amount u1))))
  )
    (ok swap-a)
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