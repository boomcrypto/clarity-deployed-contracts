;; router-xyk-alex-v-1-2

(use-trait x-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait a-ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(use-trait x-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-1.xyk-pool-trait)

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

(define-public (get-quote-a
    (amount uint)
    (pool-trait <x-pool-trait>)
    (x-token-trait <x-ft-trait>) (y-token-trait <x-ft-trait>)
    (xyk-reversed bool)
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (quote-a (if (is-eq xyk-reversed false)
                 (unwrap! (contract-call? pool-trait get-dy amount) ERR_QUOTE_A)
                 (unwrap! (contract-call? pool-trait get-dx amount) ERR_QUOTE_A)))
    (xyk-token-out (if (is-eq xyk-reversed false) y-token-trait x-token-trait))
    (scaled-amount (unwrap! (scale-xyk-amount quote-a xyk-token-out token-x-trait) ERR_SCALED_AMOUNT_A))           
    (quote-b (unwrap! (contract-call?
                      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                      (contract-of token-x-trait) (contract-of token-y-trait)
                      factor
                      scaled-amount) ERR_QUOTE_B))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint)
    (pool-trait <x-pool-trait>)
    (x-token-trait <x-ft-trait>) (y-token-trait <x-ft-trait>)
    (xyk-reversed bool)
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (quote-a (unwrap! (contract-call?
                      'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-helper
                      (contract-of token-x-trait) (contract-of token-y-trait)
                      factor
                      amount) ERR_QUOTE_A))
    (xyk-token-in (if (is-eq xyk-reversed false) x-token-trait y-token-trait))
    (scaled-amount (unwrap! (scale-alex-amount quote-a token-y-trait xyk-token-in) ERR_SCALED_AMOUNT_A))
    (quote-b (if (is-eq xyk-reversed false)
                 (unwrap! (contract-call? pool-trait get-dy scaled-amount) ERR_QUOTE_B)
                 (unwrap! (contract-call? pool-trait get-dx scaled-amount) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint)
    (pool-trait <x-pool-trait>)
    (x-token-trait <x-ft-trait>) (y-token-trait <x-ft-trait>)
    (xyk-reversed bool)
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (swap-a (if (is-eq xyk-reversed false)
                (unwrap! (xyk-sa amount pool-trait x-token-trait y-token-trait) ERR_SWAP_A)
                (unwrap! (xyk-sb amount pool-trait x-token-trait y-token-trait) ERR_SWAP_A)))
    (xyk-token-out (if (is-eq xyk-reversed false) y-token-trait x-token-trait))
    (scaled-amount (unwrap! (scale-xyk-amount swap-a xyk-token-out token-x-trait) ERR_SCALED_AMOUNT_A))
    (swap-b (unwrap! (alex-sa scaled-amount token-x-trait token-y-trait factor) ERR_SWAP_B))
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
          xyk-data: {
            x-pool: (contract-of pool-trait),
            x-tokens: {
              a: (contract-of x-token-trait),
              b: (contract-of y-token-trait)
            },
            x-reversed: xyk-reversed,
            x-swap: swap-a
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

(define-public (swap-helper-b
    (amount uint) (min-received uint)
    (pool-trait <x-pool-trait>)
    (x-token-trait <x-ft-trait>) (y-token-trait <x-ft-trait>)
    (xyk-reversed bool)
    (token-x-trait <a-ft-trait>) (token-y-trait <a-ft-trait>)
    (factor uint)
  )
  (let (
    (swap-a (unwrap! (alex-sa amount token-x-trait token-y-trait factor) ERR_SWAP_A))
    (xyk-token-in (if (is-eq xyk-reversed false) x-token-trait y-token-trait))
    (scaled-amount (unwrap! (scale-alex-amount swap-a token-y-trait xyk-token-in) ERR_SCALED_AMOUNT_A))
    (swap-b (if (is-eq xyk-reversed false)
                (unwrap! (xyk-sa scaled-amount pool-trait x-token-trait y-token-trait) ERR_SWAP_B)
                (unwrap! (xyk-sb scaled-amount pool-trait x-token-trait y-token-trait) ERR_SWAP_B)))
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
          xyk-data: {
            x-pool: (contract-of pool-trait),
            x-tokens: {
              a: (contract-of x-token-trait),
              b: (contract-of y-token-trait)
            },
            x-reversed: xyk-reversed,
            x-swap: swap-b
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

(define-private (xyk-sa
    (amount uint)
    (pool-trait <x-pool-trait>)
    (a-token <x-ft-trait>) (b-token <x-ft-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-x-for-y
                  pool-trait
                  a-token b-token
                  amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (xyk-sb
    (amount uint)
    (pool-trait <x-pool-trait>)
    (a-token <x-ft-trait>) (b-token <x-ft-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-y-for-x
                  pool-trait
                  a-token b-token
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

(define-private (scale-xyk-amount (amount uint) (x-token <x-ft-trait>) (a-token <a-ft-trait>))
  (let (
    (x-decimals (unwrap-panic (contract-call? x-token get-decimals)))
    (a-decimals (unwrap-panic (contract-call? a-token get-decimals)))
    (scaled-amount
      (if (is-eq x-decimals a-decimals)
        amount
        (if (> x-decimals a-decimals)
          (/ amount (pow u10 (- x-decimals a-decimals)))
          (* amount (pow u10 (- a-decimals x-decimals)))
        )
      )
    )
  )
    (ok scaled-amount)
  )
)

(define-private (scale-alex-amount (amount uint) (a-token <a-ft-trait>) (x-token <x-ft-trait>))
  (let (
    (a-decimals (unwrap-panic (contract-call? a-token get-decimals)))
    (x-decimals (unwrap-panic (contract-call? x-token get-decimals)))
    (scaled-amount
      (if (is-eq a-decimals x-decimals)
        amount
        (if (> a-decimals x-decimals)
          (/ amount (pow u10 (- a-decimals x-decimals)))
          (* amount (pow u10 (- x-decimals a-decimals)))
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