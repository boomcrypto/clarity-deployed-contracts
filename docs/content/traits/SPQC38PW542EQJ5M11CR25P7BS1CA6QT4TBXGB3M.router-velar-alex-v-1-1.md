---
title: "Trait router-velar-alex-v-1-1"
draft: true
---
```
;; router-velar-alex-v-1-1

(use-trait v-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait v-share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
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

(define-constant CONTRACT_DEPLOYER tx-sender)

(define-constant ALEX_FACTOR_BPS u1000000)

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
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qa amount v-tokens))
                 (unwrap-panic (alex-qa amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qa quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qa quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-b
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qa amount v-tokens))
                 (unwrap-panic (alex-qb amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qb quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qa quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-c
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal) (d principal)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qa amount v-tokens))
                 (unwrap-panic (alex-qc amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qc quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qa quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-d
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal) (d principal) (e principal)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qa amount v-tokens))
                 (unwrap-panic (alex-qd amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qd quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qa quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-e
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qb amount v-tokens))
                 (unwrap-panic (alex-qa amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qa quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qb quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-f
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qb amount v-tokens))
                 (unwrap-panic (alex-qb amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qb quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qb quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-g
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal) (d principal)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qb amount v-tokens))
                 (unwrap-panic (alex-qc amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qc quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qb quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-h
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal) (d principal) (e principal)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qb amount v-tokens))
                 (unwrap-panic (alex-qd amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qd quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qb quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-i
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qc amount v-tokens))
                 (unwrap-panic (alex-qa amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qa quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qc quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-j
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qc amount v-tokens))
                 (unwrap-panic (alex-qb amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qb quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qc quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-k
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal) (d principal)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qc amount v-tokens))
                 (unwrap-panic (alex-qc amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qc quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qc quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-l
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal) (d principal) (e principal)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qc amount v-tokens))
                 (unwrap-panic (alex-qd amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qd quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qc quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-m
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qd amount v-tokens))
                 (unwrap-panic (alex-qa amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qa quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qd quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-n
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qd amount v-tokens))
                 (unwrap-panic (alex-qb amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qb quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qd quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-o
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal) (d principal)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qd amount v-tokens))
                 (unwrap-panic (alex-qc amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qc quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qd quote-a v-tokens))))
  )
    (ok quote-b)
  )
)

(define-read-only (get-quote-p
    (amount uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (a-tokens (tuple (a principal) (b principal) (c principal) (d principal) (e principal)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (velar-qd amount v-tokens))
                 (unwrap-panic (alex-qd amount a-tokens a-factors))))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap-panic (alex-qd quote-a a-tokens a-factors))
                 (unwrap-panic (velar-qd quote-a v-tokens))))
  )
    (ok quote-b)
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
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sa amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sa amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sa swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sa swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
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
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sa amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sb amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sb swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sa swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
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
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-c
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sa amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sc amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sc swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sa swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-c",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-d
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sa amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sd amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sd swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sa swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-d",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-e
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sb amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sa amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sa swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sb swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-e",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-f
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sb amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sb amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sb swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sb swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-f",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-g
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sb amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sc amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sc swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sb swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-g",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-h
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sb amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sd amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sd swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sb swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-h",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-i
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sc amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sa amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sa swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sc swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-i",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-j
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sc amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sb amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sb swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sc swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-j",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-k
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sc amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sc amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sc swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sc swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-k",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-l
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sc amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sd amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sd swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sc swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-l",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-m
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (a-factors (tuple (a uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sd amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sa amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sa swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sd swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-m",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-n
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sd amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sb amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sb swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sd swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-n",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-o
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sd amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sc amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sc swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sd swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-o",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-p
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (v-tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (v-share-fee-to <v-share-fee-to-trait>)
    (a-tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (a-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (velar-sd amount v-tokens v-share-fee-to) ERR_SWAP_A)
                (unwrap! (alex-sd amount a-tokens a-factors) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sd swap-a a-tokens a-factors) ERR_SWAP_B)
                (unwrap! (velar-sd swap-a v-tokens v-share-fee-to) ERR_SWAP_B)))
  )
    (begin
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-p",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          velar-data: {
            v-tokens: v-tokens,
            v-share-fee-to: v-share-fee-to,
            v-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            a-tokens: a-tokens,
            a-factors: a-factors,
            a-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (velar-qa
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
  )
  (let (
    (quote-a (contract-call?
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 amount-out
             amount
             (get a tokens) (get b tokens)))
  )
    (ok quote-a)
  )
)

(define-private (velar-qb
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
  )
  (let (
    (quote-a (contract-call?
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-3
             amount
             (get a tokens) (get b tokens) (get c tokens)))
  )
    (ok (get c quote-a))
  )
)

(define-private (velar-qc
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
  )
  (let (
    (quote-a (contract-call?
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-4
             amount
             (get a tokens) (get b tokens) (get c tokens) (get d tokens)
             (list u1 u2 u3 u4)))
  )
    (ok (get d quote-a))
  )
)

(define-private (velar-qd
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
  )
  (let (
    (quote-a (contract-call?
             'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-5
             amount
             (get a tokens) (get b tokens) (get c tokens) (get d tokens) (get e tokens)))
  )
    (ok (get e quote-a))
  )
)

(define-private (alex-qa
    (amount uint)
    (tokens (tuple (a principal) (b principal)))
    (factors (tuple (a uint)))
  )
  (let (
    (factor-a (get a factors))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                           (get a tokens) (get b tokens)
                           (* factor-a ALEX_FACTOR_BPS)
                           (* amount factor-a))))
  )
    (ok (/ quote-a factor-a))
  )
)

(define-private (alex-qb
    (amount uint)
    (tokens (tuple (a principal) (b principal) (c principal)))
    (factors (tuple (a uint) (b uint)))
  )
  (let (
    (factor-a (get a factors))
    (factor-b (get b factors))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-a
                           (get a tokens) (get b tokens) (get c tokens)
                           (* factor-a ALEX_FACTOR_BPS) (* factor-b ALEX_FACTOR_BPS)
                           (* amount factor-a))))
  )
    (ok (/ quote-a factor-b))
  )
)

(define-private (alex-qc
    (amount uint)
    (tokens (tuple (a principal) (b principal) (c principal) (d principal)))
    (factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (factor-a (get a factors))
    (factor-c (get c factors))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-b
                           (get a tokens) (get b tokens) (get c tokens) (get d tokens)
                           (* factor-a ALEX_FACTOR_BPS) (* (get b factors) ALEX_FACTOR_BPS)
                           (* factor-c ALEX_FACTOR_BPS)
                           (* amount factor-a))))
  )
    (ok (/ quote-a factor-c))
  )
)

(define-private (alex-qd
    (amount uint)
    (tokens (tuple (a principal) (b principal) (c principal) (d principal) (e principal)))
    (factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (factor-a (get a factors))
    (factor-d (get d factors))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-c
                           (get a tokens) (get b tokens) (get c tokens) (get d tokens) (get e tokens)
                           (* factor-a ALEX_FACTOR_BPS) (* (get b factors) ALEX_FACTOR_BPS)
                           (* (get c factors) ALEX_FACTOR_BPS) (* factor-d ALEX_FACTOR_BPS)
                           (* amount factor-a))))
  )
    (ok (/ quote-a factor-d))
  )
)

(define-private (velar-sa
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>)))
    (share-fee-to <v-share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap
                  amount
                  (get a tokens) (get b tokens)
                  share-fee-to)))
  )
    (ok (get amt-out swap-a))
  )
)

(define-private (velar-sb
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>)))
    (share-fee-to <v-share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-3
                  amount u1
                  (get a tokens) (get b tokens) (get c tokens)
                  share-fee-to)))
  )
    (ok (get amt-out (get c swap-a)))
  )
)

(define-private (velar-sc
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>)))
    (share-fee-to <v-share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-4
                  amount u1
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens)
                  share-fee-to)))
  )
    (ok (get amt-out (get d swap-a)))
  )
)

(define-private (velar-sd
    (amount uint)
    (tokens (tuple (a <v-ft-trait>) (b <v-ft-trait>) (c <v-ft-trait>) (d <v-ft-trait>) (e <v-ft-trait>)))
    (share-fee-to <v-share-fee-to-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-5
                  amount u1
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens) (get e tokens)
                  share-fee-to)))
  )
    (ok (get amt-out (get e swap-a)))
  )
)

(define-private (alex-sa
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>)))
    (factors (tuple (a uint)))
  )
  (let (
    (factor-a (get a factors))
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
                  (get a tokens) (get b tokens)
                  (* factor-a ALEX_FACTOR_BPS)
                  (* amount factor-a) (some u1))))
  )
    (ok (/ swap-a factor-a))
  )
)

(define-private (alex-sb
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>)))
    (factors (tuple (a uint) (b uint)))
  )
  (let (
    (factor-a (get a factors))
    (factor-b (get b factors))
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                  (get a tokens) (get b tokens) (get c tokens)
                  (* factor-a ALEX_FACTOR_BPS) (* factor-b ALEX_FACTOR_BPS)
                  (* amount factor-a) (some u1))))
  )
    (ok (/ swap-a factor-b))
  )
)

(define-private (alex-sc
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (factor-a (get a factors))
    (factor-c (get c factors))
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens)
                  (* factor-a ALEX_FACTOR_BPS) (* (get b factors) ALEX_FACTOR_BPS)
                  (* factor-c ALEX_FACTOR_BPS)
                  (* amount factor-a) (some u1))))
  )
    (ok (/ swap-a factor-c))
  )
)

(define-private (alex-sd
    (amount uint)
    (tokens (tuple (a <a-ft-trait>) (b <a-ft-trait>) (c <a-ft-trait>) (d <a-ft-trait>) (e <a-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (factor-a (get a factors))
    (factor-d (get d factors))
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens) (get e tokens)
                  (* factor-a ALEX_FACTOR_BPS) (* (get b factors) ALEX_FACTOR_BPS)
                  (* (get c factors) ALEX_FACTOR_BPS) (* factor-d ALEX_FACTOR_BPS)
                  (* amount factor-a) (some u1))))
  )
    (ok (/ swap-a factor-d))
  )
)

(define-private (admin-not-removeable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)
```
