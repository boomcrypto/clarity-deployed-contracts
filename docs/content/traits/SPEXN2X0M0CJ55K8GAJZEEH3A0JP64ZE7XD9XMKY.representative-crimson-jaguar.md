---
title: "Trait representative-crimson-jaguar"
draft: true
---
```
;; router-stx-ststx-bitflow-velar-v-1-1

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-constant ERR_NOT_AUTHORIZED (err "ERR_NOT_AUTHORIZED"))
(define-constant ERR_INVALID_AMOUNT (err "ERR_INVALID_AMOUNT"))
(define-constant ERR_SWAP_STATUS (err "ERR_SWAP_STATUS"))
(define-constant ERR_MINIMUM_OUTPUT (err "ERR_MINIMUM_OUTPUT"))
(define-constant ERR_SWAP_A (err "ERR_SWAP_A"))
(define-constant ERR_SWAP_B (err "ERR_SWAP_B"))

(define-data-var contract-admin principal tx-sender)
(define-data-var swap-status bool true)

(define-read-only (get-contract-admin)
  (ok (var-get contract-admin))
)

(define-read-only (get-swap-status)
  (ok (var-get swap-status))
)

(define-read-only (get-route-a-output (amount uint) (id uint) (reversed bool))
  (let (
    (velar-pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool id))
    (r0 (if (is-eq reversed true)
            (get reserve1 velar-pool)
            (get reserve0 velar-pool)))
    (r1 (if (is-eq reversed true)
            (get reserve0 velar-pool)
            (get reserve1 velar-pool)))
    (quote-a (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library quote amount r0 r1)))
    (quote-b (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy
                           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                           quote-a)))
  )
    (ok quote-b)
  )
)

(define-read-only (get-route-b-output (amount uint) (id uint) (reversed bool))
  (let (
    (velar-pool (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool id))
    (r0 (if (is-eq reversed true)
            (get reserve1 velar-pool)
            (get reserve0 velar-pool)))
    (r1 (if (is-eq reversed true)
            (get reserve0 velar-pool)
            (get reserve1 velar-pool)))
    (quote-a (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx
                           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                           amount)))
    (quote-b (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library quote quote-a r0 r1)))
  )
    (ok quote-b)
  )
)

(define-public (set-swap-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get contract-admin)) ERR_NOT_AUTHORIZED)
      (var-set swap-status status)
      (print {action: "set-swap-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

(define-public (set-contract-admin (admin principal))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get contract-admin)) ERR_NOT_AUTHORIZED)
      (var-set contract-admin admin)
      (print {action: "set-contract-admin", caller: caller, data: {admin: admin}})
      (ok true)
    )
  )
)

(define-public (swap-route-a
    (amount uint) (min-output uint)
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (swap-a (unwrap! (velar-a amount id token0 token1 token-in token-out share-fee-to) ERR_SWAP_A))
    (swap-b (unwrap! (bitflow-a swap-a) ERR_SWAP_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-output) ERR_MINIMUM_OUTPUT)
      (print {
        action: "swap-route-a",
        caller: caller, 
        data: {
          amount: amount,
          min-output: min-output,
          output: swap-b,
          id: id,
          token0: (contract-of token0),
          token1: (contract-of token1),
          token-in: (contract-of token-in),
          token-out: (contract-of token-out),
          share-fee-to: (contract-of share-fee-to)
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-route-b
    (amount uint) (min-output uint)
    (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (swap-a (unwrap! (bitflow-b amount) ERR_SWAP_A))
    (swap-b (unwrap! (velar-a swap-a id token0 token1 token-in token-out share-fee-to) ERR_SWAP_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-output) ERR_MINIMUM_OUTPUT)
      (print {
        action: "swap-route-b",
        caller: caller, 
        data: {
          amount: amount,
          min-output: min-output,
          output: swap-b,
          id: id,
          token0: (contract-of token0),
          token1: (contract-of token1),
          token-in: (contract-of token-in),
          token-out: (contract-of token-out),
          share-fee-to: (contract-of share-fee-to)
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (bitflow-a (amount uint))
  (let (
    (swap-a (try! (contract-call?
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y
                  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                  amount u0)))
  )
    (ok swap-a)
  )
)

(define-private (bitflow-b (amount uint))
  (let (
    (swap-a (try! (contract-call?
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x
                  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                  'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                  amount u0)))
  )
    (ok swap-a)
  )
)

(define-private (velar-a
    (amount uint) (id uint)
    (token0 <ft-trait>) (token1 <ft-trait>)
    (token-in <ft-trait>) (token-out <ft-trait>)
    (share-fee-to <share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
                  id 
                  token0 token1
                  token-in token-out
                  share-fee-to
                  amount u1)))
  )
    (ok (get amt-out swap-a))
  )
)
```
