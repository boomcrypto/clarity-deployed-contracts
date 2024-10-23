;; router-stableswap-alex-v-1-1

(use-trait stableswap-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-1.stableswap-pool-trait)
(use-trait alex-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

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
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (alex-factors (tuple (a uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (alex-qa amount alex-tokens alex-factors) ERR_QUOTE_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount quote-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get b alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qa scaled-amount-a alex-tokens alex-factors) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa scaled-amount-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (alex-qb amount alex-tokens alex-factors) ERR_QUOTE_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount quote-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get c alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qb scaled-amount-a alex-tokens alex-factors) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa scaled-amount-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-c
    (amount uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (alex-qc amount alex-tokens alex-factors) ERR_QUOTE_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount quote-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get d alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qc scaled-amount-a alex-tokens alex-factors) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa scaled-amount-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-d
    (amount uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (stableswap-qa amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (alex-qd amount alex-tokens alex-factors) ERR_QUOTE_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount quote-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount quote-a (get e alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (alex-qd scaled-amount-a alex-tokens alex-factors) ERR_QUOTE_B)
                 (unwrap! (stableswap-qa scaled-amount-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (alex-factors (tuple (a uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (alex-sa amount alex-tokens alex-factors) ERR_SWAP_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount swap-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get b alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sa scaled-amount-a alex-tokens alex-factors) ERR_SWAP_B)
                (unwrap! (stableswap-sa scaled-amount-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
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
          alex-data: {
            alex-tokens: alex-tokens,
            alex-factors: alex-factors,
            alex-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
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
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (alex-sb amount alex-tokens alex-factors) ERR_SWAP_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount swap-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get c alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sb scaled-amount-a alex-tokens alex-factors) ERR_SWAP_B)
                (unwrap! (stableswap-sa scaled-amount-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            alex-tokens: alex-tokens,
            alex-factors: alex-factors,
            alex-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
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
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (alex-sc amount alex-tokens alex-factors) ERR_SWAP_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount swap-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get d alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sc scaled-amount-a alex-tokens alex-factors) ERR_SWAP_B)
                (unwrap! (stableswap-sa scaled-amount-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            alex-tokens: alex-tokens,
            alex-factors: alex-factors,
            alex-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
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
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (alex-tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
    (alex-factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (stableswap-sa amount stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (alex-sd amount alex-tokens alex-factors) ERR_SWAP_A)))
    (scaled-amount-a (if (is-eq swaps-reversed false)
                         (unwrap! (scale-up-stableswap-amount swap-a (get b stableswap-tokens) (get a alex-tokens)) ERR_SCALED_AMOUNT_A)
                         (unwrap! (scale-down-alex-amount swap-a (get e alex-tokens) (get a stableswap-tokens)) ERR_SCALED_AMOUNT_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (alex-sd scaled-amount-a alex-tokens alex-factors) ERR_SWAP_B)
                (unwrap! (stableswap-sa scaled-amount-a stableswap-tokens stableswap-pools) ERR_SWAP_B)))
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
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          alex-data: {
            alex-tokens: alex-tokens,
            alex-factors: alex-factors,
            alex-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
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

(define-private (alex-qa
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (factors (tuple (a uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                           (contract-of a-token) (contract-of b-token)
                           (get a factors)
                           amount)))
  )
    (ok quote-a)
  )
)

(define-private (alex-qb
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (c-token (get c tokens))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-a
                           (contract-of a-token) (contract-of b-token) (contract-of c-token)
                           (get a factors) (get b factors)
                           amount)))
  )
    (ok quote-a)
  )
)

(define-private (alex-qc
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (c-token (get c tokens))
    (d-token (get d tokens))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-b
                           (contract-of a-token) (contract-of b-token) (contract-of c-token)
                           (contract-of d-token)
                           (get a factors) (get b factors) (get c factors)
                           amount)))
  )
    (ok quote-a)
  )
)

(define-private (alex-qd
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (a-token (get a tokens))
    (b-token (get b tokens))
    (c-token (get c tokens))
    (d-token (get d tokens))
    (e-token (get e tokens))
    (quote-a (unwrap-panic (contract-call?
                           'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper-c
                           (contract-of a-token) (contract-of b-token) (contract-of c-token)
                           (contract-of d-token) (contract-of e-token)
                           (get a factors) (get b factors) (get c factors) (get d factors)
                           amount)))
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

(define-private (alex-sa
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>)))
    (factors (tuple (a uint)))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper
                  (get a tokens) (get b tokens)
                  (get a factors)
                  amount (some u1))))
  )
    (ok swap-a)
  )
)

(define-private (alex-sb
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint)))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a
                  (get a tokens) (get b tokens) (get c tokens)
                  (get a factors) (get b factors)
                  amount (some u1))))
  )
    (ok swap-a)
  )
)

(define-private (alex-sc
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint)))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens)
                  (get a factors) (get b factors) (get c factors)
                  amount (some u1))))
  )
    (ok swap-a)
  )
)

(define-private (alex-sd
    (amount uint)
    (tokens (tuple (a <alex-ft-trait>) (b <alex-ft-trait>) (c <alex-ft-trait>) (d <alex-ft-trait>) (e <alex-ft-trait>)))
    (factors (tuple (a uint) (b uint) (c uint) (d uint)))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens) (get e tokens)
                  (get a factors) (get b factors) (get c factors) (get d factors)
                  amount (some u1))))
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

(define-private (scale-up-stableswap-amount (amount uint) (stableswap-token <stableswap-ft-trait>) (alex-token <alex-ft-trait>))
  (let (
    (stableswap-decimals (unwrap-panic (contract-call? stableswap-token get-decimals)))
    (alex-decimals (unwrap-panic (contract-call? alex-token get-decimals)))
    (scaled-amount
      (if (is-eq stableswap-decimals alex-decimals)
        amount
        (if (> stableswap-decimals alex-decimals)
          (/ amount (pow u10 (- stableswap-decimals alex-decimals)))
          (* amount (pow u10 (- alex-decimals stableswap-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

(define-private (scale-down-alex-amount (amount uint) (alex-token <alex-ft-trait>) (stableswap-token <stableswap-ft-trait>))
  (let (
    (alex-decimals (unwrap-panic (contract-call? alex-token get-decimals)))
    (stableswap-decimals (unwrap-panic (contract-call? stableswap-token get-decimals)))
    (scaled-amount
      (if (is-eq alex-decimals stableswap-decimals)
        amount
        (if (> alex-decimals stableswap-decimals)
          (/ amount (pow u10 (- alex-decimals stableswap-decimals)))
          (* amount (pow u10 (- stableswap-decimals alex-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)