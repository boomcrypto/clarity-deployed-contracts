---
title: "Trait muddy-amethyst-spider"
draft: true
---
```
;; router-stx-ststx-bitflow-alex-v-2-1

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

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

(define-read-only (get-quote-a
    (amount uint)
    (token-x principal) (token-y principal)
    (token-z principal)
    (factor-x uint) (factor-y uint)
  )
  (let (
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-a
                           token-x token-y
                           token-z
                           (* factor-x u1000000)
                           (* factor-y u1000000)
                           (* amount factor-y))))
    (quote-b (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dy
                           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                           (/ quote-a factor-y))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-b
    (amount uint)
    (token-x principal) (token-y principal)
    (token-z principal)
    (factor-x uint) (factor-y uint)
  )
  (let (
    (quote-a (unwrap-panic (contract-call?
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-stx-ststx-v-1-2 get-dx
                           'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
                           'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stx-ststx-lp-token-v-1-2
                           amount)))
    (quote-b (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-a
                           token-x token-y
                           token-z
                           (* factor-x u1000000)
                           (* factor-y u1000000)
                           (* quote-a factor-x))))
  )
    (ok (/ quote-b factor-x))
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

(define-public (swap-helper-a
    (amount uint) (min-received uint)
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (token-z-trait <ft-trait>)
    (factor-x uint) (factor-y uint)
  )
  (let (
    (swap-a (unwrap! (alex-a token-x-trait token-y-trait token-z-trait factor-x factor-y amount) ERR_SWAP_A))
    (swap-b (unwrap! (bitflow-a swap-a) ERR_SWAP_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (> factor-x u0) ERR_INVALID_AMOUNT)
      (asserts! (> factor-y u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: caller, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          token-x-trait: (contract-of token-x-trait),
          token-y-trait: (contract-of token-y-trait),
          token-z-trait: (contract-of token-z-trait),
          factor-x: factor-x,
          factor-y: factor-y
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint)
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (token-z-trait <ft-trait>)
    (factor-x uint) (factor-y uint)
  )
  (let (
    (swap-a (unwrap! (bitflow-b amount) ERR_SWAP_A))
    (swap-b (unwrap! (alex-b token-x-trait token-y-trait token-z-trait factor-x factor-y swap-a) ERR_SWAP_B))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (> factor-x u0) ERR_INVALID_AMOUNT)
      (asserts! (> factor-y u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-b",
        caller: caller, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          token-x-trait: (contract-of token-x-trait),
          token-y-trait: (contract-of token-y-trait),
          token-z-trait: (contract-of token-z-trait),
          factor-x: factor-x,
          factor-y: factor-y
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

(define-private (alex-a
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (token-z-trait <ft-trait>)
    (factor-x uint) (factor-y uint)
    (dx uint)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                  token-x-trait token-y-trait
                  token-z-trait
                  (* factor-x u1000000)
                  (* factor-y u1000000)
                  (* dx factor-y) (some u1))))
  )
    (ok (/ swap-a factor-y))
  )
)

(define-private (alex-b
    (token-x-trait <ft-trait>) (token-y-trait <ft-trait>)
    (token-z-trait <ft-trait>)
    (factor-x uint) (factor-y uint)
    (dx uint)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                  token-x-trait token-y-trait
                  token-z-trait
                  (* factor-x u1000000)
                  (* factor-y u1000000)
                  (* dx factor-x) (some u1))))
  )
    (ok (/ swap-a factor-x))
  )
)

(define-private (admin-not-removeable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)
```
