---
title: "Trait router-stx-ststx-bitflow-alex-v-1-2"
draft: true
---
```
;; router-stx-ststx-bitflow-alex-v-1-2

(use-trait a-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_INVALID_PRINCIPAL (err u1003))
(define-constant ERR_ALREADY_ADMIN (err u2001))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u2002))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u2003))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u2004))
(define-constant ERR_SWAP_STATUS (err u4001))
(define-constant ERR_MINIMUM_RECEIVED (err u4002))
(define-constant ERR_SWAP_A (err u5001))
(define-constant ERR_SWAP_B (err u5002))
(define-constant ERR_SCALED_AMOUNT_A (err u6001))
(define-constant ERR_QUOTE_A (err u7001))
(define-constant ERR_QUOTE_B (err u7002))

(define-constant CONTRACT_DEPLOYER tx-sender)

(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

(define-data-var swap-status bool true)

(define-read-only (get-admins)
  (ok (var-get admins))
)

(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

(define-read-only (get-swap-status)
  (ok (var-get swap-status))
)

(define-public (add-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (index-of admins-list admin)) ERR_ALREADY_ADMIN)
    (asserts! (is-standard admin) ERR_INVALID_PRINCIPAL)
    (var-set admins (unwrap! (as-max-len? (append admins-list admin) u5) ERR_ADMIN_LIMIT_REACHED))
    (print {action: "add-admin", caller: caller, data: {admin: admin}})
    (ok true)
  )
)

(define-public (remove-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller-in-list (index-of admins-list tx-sender))
    (admin-to-remove-in-list (index-of admins-list admin))
    (caller tx-sender)
  )
    (asserts! (is-some caller-in-list) ERR_NOT_AUTHORIZED)
    (asserts! (is-some admin-to-remove-in-list) ERR_ADMIN_NOT_IN_LIST)
    (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)
    (asserts! (is-standard admin) ERR_INVALID_PRINCIPAL)
    (var-set admin-helper admin)
    (var-set admins (filter admin-not-removeable admins-list))
    (print {action: "remove-admin", caller: caller, data: {admin: admin}})
    (ok true)
  )
)

(define-public (set-swap-status (status bool))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
      (var-set swap-status status)
      (print {action: "set-swap-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

(define-public (get-quote-a
    (amount uint)
    (token-x <a-ft-trait>) (token-y <a-ft-trait>)
    (factor uint)
  )
  (let (
    (quote-a (unwrap! (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                           (contract-of token-x) (contract-of token-y)
                           factor
                           amount) ERR_QUOTE_A))
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
    (amount uint)
    (token-x <a-ft-trait>) (token-y <a-ft-trait>)
    (factor uint)
  )
  (let (
    (quote-a (unwrap! (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx
                           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                           amount) ERR_QUOTE_A))
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
    (amount uint) (min-received uint)
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (swap-a (unwrap! (alex-sa amount token-x-trait token-y-trait factor) ERR_SWAP_A))
    (scaled-amount (unwrap! (scale-alex-amount swap-a token-y-trait) ERR_SCALED_AMOUNT_A))  
    (swap-b (unwrap! (bitflow-sa scaled-amount) ERR_SWAP_B))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
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
    (amount uint) (min-received uint)
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (swap-a (unwrap! (bitflow-sb amount) ERR_SWAP_A))
    (scaled-amount (unwrap! (scale-bitflow-amount swap-a token-x-trait) ERR_SCALED_AMOUNT_A))
    (swap-b (unwrap! (alex-sa scaled-amount token-x-trait token-y-trait factor) ERR_SWAP_B))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-b",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
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

(define-private (admin-not-removeable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)
```
