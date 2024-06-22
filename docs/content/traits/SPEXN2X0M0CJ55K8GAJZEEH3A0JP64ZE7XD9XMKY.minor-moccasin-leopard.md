---
title: "Trait minor-moccasin-leopard"
draft: true
---
```
;; router-aeusdc-ststx-v-2-1

(define-constant ERR_NOT_AUTHORIZED (err "ERR_NOT_AUTHORIZED"))
(define-constant ERR_INVALID_AMOUNT (err "ERR_INVALID_AMOUNT"))
(define-constant ERR_SWAP_STATUS (err "ERR_SWAP_STATUS"))
(define-constant ERR_MINIMUM_OUTPUT (err "ERR_MINIMUM_OUTPUT"))
(define-constant ERR_CALL_A (err "ERR_CALL_A"))
(define-constant ERR_CALL_B (err "ERR_CALL_B"))

(define-data-var contract-owner principal tx-sender)
(define-data-var swap-status bool true)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-read-only (get-swap-status)
  (ok (var-get swap-status))
)

(define-read-only (get-route-a-output (amount uint))
  (let (
    (a (contract-call? 
       'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool
       u6))
    (r0 (get reserve0 a))
    (r1 (get reserve1 a))
    (b (try! (contract-call? 
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library quote
             amount r1 r0)))
    (c (unwrap-panic (contract-call?
                     'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy
                     'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                     'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                     b)))
  )
    (ok c)
  )
)

(define-read-only (get-route-b-output (amount uint))
  (let (
    (a (unwrap-panic (contract-call?
                     'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx
                     'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                     'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                     amount)))
    (b (contract-call? 
       'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool
        u6))
    (r0 (get reserve0 b))
    (r1 (get reserve1 b))
    (c (try! (contract-call? 
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-library quote
              a r0 r1)))
  )
    (ok c)
  )
)

(define-public (swap-route-a (amount uint) (min-output uint))
  (let (
    (a (unwrap! (velar-a amount) ERR_CALL_A))
    (b (unwrap! (bitflow-a a) ERR_CALL_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (>= b min-output) ERR_MINIMUM_OUTPUT)
      (print {action: "swap-route-a", caller: caller, amount: amount, min-output: min-output, output: b})
      (ok b)
    )
  )
)

(define-public (swap-route-b (amount uint) (min-output uint))
  (let (
    (a (unwrap! (bitflow-b amount) ERR_CALL_A))
    (b (unwrap! (velar-b a) ERR_CALL_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (>= b min-output) ERR_MINIMUM_OUTPUT)
      (print {action: "swap-route-b", caller: caller, amount: amount, min-output: min-output, output: b})
      (ok b)
    )
  )
)

(define-public (set-swap-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
      (var-set swap-status status)
      (print {action: "set-swap-status", caller: caller, status: status})
      (ok true)
    )
  )
)

(define-public (set-contract-owner (owner principal))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get contract-owner)) ERR_NOT_AUTHORIZED)
      (var-set contract-owner owner)
      (print {action: "set-contract-owner", caller: caller, owner: owner})
      (ok true)
    )
  )
)

(define-private (bitflow-a (amount uint))
  (let (
    (call (try! (contract-call?
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-x-for-y
                'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                amount u0)))
  )
    (ok call)
  )
)

(define-private (bitflow-b (amount uint))
  (let (
    (call (try! (contract-call?
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 swap-y-for-x
                'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                amount u0)))
  )
    (ok call)
  )
)

(define-private (velar-a (amount uint))
  (let (
    (call (try! (contract-call?
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
                u6
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
                amount u1)))
  )
    (ok (get amt-out call))
  )
)

(define-private (velar-b (amount uint))
  (let (
    (call (try! (contract-call?
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
                u6
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
                'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
                amount u1)))
  )
    (ok (get amt-out call))
  )
)
```
