;; router-stableswap-xyk-multihop-v-1-4

(use-trait ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-4.stableswap-pool-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)

(define-constant ERR_NOT_AUTHORIZED (err u6001))
(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_INVALID_PRINCIPAL (err u6003))
(define-constant ERR_ALREADY_ADMIN (err u6004))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u6005))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u6006))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u6007))
(define-constant ERR_SWAP_STATUS (err u6008))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))
(define-constant ERR_SWAP_A (err u6010))
(define-constant ERR_SWAP_B (err u6011))
(define-constant ERR_QUOTE_A (err u6012))
(define-constant ERR_QUOTE_B (err u6013))

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
    (caller tx-sender)
  )
    (begin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)
      (var-set swap-status status)
      (print {action: "set-swap-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

(define-public (get-quote-a
    (amount uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-a amount xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-a quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b amount xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-c
    (amount uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-c amount xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-c quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-a quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-d
    (amount uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-b amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-a amount xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-a quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-b quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-e
    (amount uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-b amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b amount xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-b quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-f
    (amount uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-b amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-c amount xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-c quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-b quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-g
    (amount uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-c amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-a amount xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-a quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-c quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-h
    (amount uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-c amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b amount xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-b quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-c quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-i
    (amount uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-c amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-c amount xyk-tokens xyk-pools) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 get-quote-c quote-a xyk-tokens xyk-pools) ERR_QUOTE_B)
                 (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 get-quote-c quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a amount u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-a amount u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-a swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-b
    (amount uint) (min-received uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a amount u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b amount u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-c
    (amount uint) (min-received uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a amount u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-c amount u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-c swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-a swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-d
    (amount uint) (min-received uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-b amount u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-a amount u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-a swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-b swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
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
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-e
    (amount uint) (min-received uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-b amount u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b amount u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-b swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-e",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-f
    (amount uint) (min-received uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-b amount u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-c amount u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-c swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-b swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-f",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-g
    (amount uint) (min-received uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-c amount u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-a amount u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-a swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-c swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-g",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-h
    (amount uint) (min-received uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-c amount u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b amount u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-b swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-c swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-h",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-public (swap-helper-i
    (amount uint) (min-received uint) (swaps-reversed bool)
    (stableswap-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
    (xyk-tokens (tuple (a <ft-trait>) (b <ft-trait>) (c <ft-trait>) (d <ft-trait>) (e <ft-trait>) (f <ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>) (b <xyk-pool-trait>) (c <xyk-pool-trait>)))
  )
  (let (
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    (swap-a (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-c amount u0 stableswap-tokens stableswap-pools) ERR_SWAP_A)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-c amount u0 xyk-tokens xyk-pools) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-swap-helper-v-1-2 swap-helper-c swap-a u0 xyk-tokens xyk-pools) ERR_SWAP_B)
                (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-swap-helper-v-1-4 swap-helper-c swap-a u0 stableswap-tokens stableswap-pools) ERR_SWAP_B)))
  )
    (begin
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-i",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)