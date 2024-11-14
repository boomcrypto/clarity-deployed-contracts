---
title: "Trait router-stableswap-xyk-v-1-1"
draft: true
---
```
;; router-stableswap-xyk-v-1-1

(use-trait stableswap-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-1.stableswap-pool-trait)
(use-trait xyk-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-1.xyk-pool-trait)

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
    (var-set admins (unwrap! (as-max-len? (append admins-list admin) u5) ERR_ADMIN_LIMIT_REACHED))
    (print {action: "add-admin", caller: caller, data: {admin: admin}})
    (ok true)
  )
)

(define-public (remove-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
    (asserts! (is-some (index-of admins-list admin)) ERR_ADMIN_NOT_IN_LIST)
    (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)
    (var-set admin-helper admin)
    (var-set admins (filter admin-not-removable admins-list))
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
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (xyk-qa amount xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (xyk-qa quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (xyk-sa amount xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (xyk-sa swap-a xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (stableswap-sa swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (stableswap-qa
    (amount uint)
    (tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    (is-reversed (is-stableswap-reversed (get a tokens) (get b tokens) (get a pools)))
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-1 get-dy
                 (get a pools)
                 (get a tokens) (get b tokens)
                 amount))
                 (try! (contract-call?
                 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-1 get-dx
                 (get a pools)
                 (get b tokens) (get a tokens)
                 amount))))
  )
    (ok quote-a)
  )
)

(define-private (xyk-qa
    (amount uint)
    (tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (pool-contract (get a pools))
    (is-reversed (is-xyk-reversed (get a tokens) (get b tokens) (get a pools)))
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                 pool-contract get-dy
                 amount))
                 (try! (contract-call?
                 pool-contract get-dx
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
    (is-reversed (is-stableswap-reversed (get a tokens) (get b tokens) (get a pools)))
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-1 swap-x-for-y
                      (get a pools)
                      (get a tokens) (get b tokens)
                      amount u1))
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-1 swap-y-for-x
                      (get a pools)
                      (get b tokens) (get a tokens)
                      amount u1))))
  )
    (ok swap-a)
  )
)

(define-private (xyk-sa
    (amount uint)
    (tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (is-reversed (is-xyk-reversed (get a tokens) (get b tokens) (get a pools)))
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-x-for-y
                      (get a pools)
                      (get a tokens) (get b tokens)
                      amount u1))
                (try! (contract-call?
                      'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-y-for-x
                      (get a pools)
                      (get b tokens) (get a tokens)
                      amount u1))))
  )
    (ok swap-a)
  )
)

(define-private (is-stableswap-reversed
    (token-in <stableswap-ft-trait>) (token-out <stableswap-ft-trait>)
    (pool-contract <stableswap-pool-trait>)
  )
  (let (
    (token-in-contract (contract-of token-in))
    (token-out-contract (contract-of token-out))
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool)))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
  )
    (if (and (is-eq token-in-contract x-token) (is-eq token-out-contract y-token))
      false
      true
    )
  )
)

(define-private (is-xyk-reversed
    (token-in <xyk-ft-trait>) (token-out <xyk-ft-trait>)
    (pool-contract <xyk-pool-trait>)
  )
  (let (
    (token-in-contract (contract-of token-in))
    (token-out-contract (contract-of token-out))
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool)))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
  )
    (if (and (is-eq token-in-contract x-token) (is-eq token-out-contract y-token))
      false
      true
    )
  )
)

(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)
```
