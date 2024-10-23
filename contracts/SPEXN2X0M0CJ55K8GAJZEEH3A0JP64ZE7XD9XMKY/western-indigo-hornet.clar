;; router-stableswap-velar-v-1-1

(use-trait stableswap-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-1.stableswap-pool-trait)
(use-trait velar-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait velar-share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

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
    (stableswap-reversals (tuple (a bool)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (if (is-eq (get a stableswap-reversals) false)
                                   (unwrap! (stableswap-qa amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                                   (unwrap! (stableswap-qb amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)))
                 (unwrap! (velar-qa amount velar-tokens) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qa quote-a velar-tokens) ERR_QUOTE_B)
                 (unwrap-panic (if (is-eq (get a stableswap-reversals) false)
                                   (unwrap! (stableswap-qa quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)
                                   (unwrap! (stableswap-qb quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-b
    (amount uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (stableswap-reversals (tuple (a bool)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (if (is-eq (get a stableswap-reversals) false)
                                   (unwrap! (stableswap-qa amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                                   (unwrap! (stableswap-qb amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)))
                 (unwrap! (velar-qb amount velar-tokens) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qb quote-a velar-tokens) ERR_QUOTE_B)
                 (unwrap-panic (if (is-eq (get a stableswap-reversals) false)
                                   (unwrap! (stableswap-qa quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)
                                   (unwrap! (stableswap-qb quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-c
    (amount uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (stableswap-reversals (tuple (a bool)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (if (is-eq (get a stableswap-reversals) false)
                                   (unwrap! (stableswap-qa amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                                   (unwrap! (stableswap-qb amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)))
                 (unwrap! (velar-qc amount velar-tokens) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qc quote-a velar-tokens) ERR_QUOTE_B)
                 (unwrap-panic (if (is-eq (get a stableswap-reversals) false)
                                   (unwrap! (stableswap-qa quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)
                                   (unwrap! (stableswap-qb quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))))
  )
    (ok quote-b)
  )
)

(define-public (get-quote-d
    (amount uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (stableswap-reversals (tuple (a bool)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>) (e <velar-ft-trait>)))
  )
  (let (
    (quote-a (if (is-eq swaps-reversed false)
                 (unwrap-panic (if (is-eq (get a stableswap-reversals) false)
                                   (unwrap! (stableswap-qa amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)
                                   (unwrap! (stableswap-qb amount stableswap-tokens stableswap-pools) ERR_QUOTE_A)))
                 (unwrap! (velar-qd amount velar-tokens) ERR_QUOTE_A)))
    (quote-b (if (is-eq swaps-reversed false)
                 (unwrap! (velar-qd quote-a velar-tokens) ERR_QUOTE_B)
                 (unwrap-panic (if (is-eq (get a stableswap-reversals) false)
                                   (unwrap! (stableswap-qa quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)
                                   (unwrap! (stableswap-qb quote-a stableswap-tokens stableswap-pools) ERR_QUOTE_B)))))
  )
    (ok quote-b)
  )
)

(define-public (swap-helper-a
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
    (stableswap-reversals (tuple (a bool)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>)))
    (velar-share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (if (is-eq (get a stableswap-reversals) false)
                    (unwrap! (stableswap-sa amount stableswap-tokens stableswap-pools) ERR_SWAP_A)
                    (unwrap! (stableswap-sb amount stableswap-tokens stableswap-pools) ERR_SWAP_A))
                (unwrap! (velar-sa amount velar-tokens velar-share-fee-to) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (velar-sa swap-a velar-tokens velar-share-fee-to) ERR_SWAP_B)
                (if (is-eq (get a stableswap-reversals) false)
                    (unwrap! (stableswap-sa swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B)
                    (unwrap! (stableswap-sb swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B))))
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
            stableswap-reversals: stableswap-reversals,
            stableswap-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          velar-data: {
            velar-tokens: velar-tokens,
            velar-share-fee-to: velar-share-fee-to,
            velar-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
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
    (stableswap-reversals (tuple (a bool)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>)))
    (velar-share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (if (is-eq (get a stableswap-reversals) false)
                    (unwrap! (stableswap-sa amount stableswap-tokens stableswap-pools) ERR_SWAP_A)
                    (unwrap! (stableswap-sb amount stableswap-tokens stableswap-pools) ERR_SWAP_A))
                (unwrap! (velar-sb amount velar-tokens velar-share-fee-to) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (velar-sb swap-a velar-tokens velar-share-fee-to) ERR_SWAP_B)
                (if (is-eq (get a stableswap-reversals) false)
                    (unwrap! (stableswap-sa swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B)
                    (unwrap! (stableswap-sb swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B))))
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
            stableswap-reversals: stableswap-reversals,
            stableswap-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          velar-data: {
            velar-tokens: velar-tokens,
            velar-share-fee-to: velar-share-fee-to,
            velar-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
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
    (stableswap-reversals (tuple (a bool)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>)))
    (velar-share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (if (is-eq (get a stableswap-reversals) false)
                    (unwrap! (stableswap-sa amount stableswap-tokens stableswap-pools) ERR_SWAP_A)
                    (unwrap! (stableswap-sb amount stableswap-tokens stableswap-pools) ERR_SWAP_A))
                (unwrap! (velar-sc amount velar-tokens velar-share-fee-to) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (velar-sc swap-a velar-tokens velar-share-fee-to) ERR_SWAP_B)
                (if (is-eq (get a stableswap-reversals) false)
                    (unwrap! (stableswap-sa swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B)
                    (unwrap! (stableswap-sb swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B))))
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
            stableswap-reversals: stableswap-reversals,
            stableswap-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          velar-data: {
            velar-tokens: velar-tokens,
            velar-share-fee-to: velar-share-fee-to,
            velar-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
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
    (stableswap-reversals (tuple (a bool)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>) (e <velar-ft-trait>)))
    (velar-share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    (swap-a (if (is-eq swaps-reversed false)
                (if (is-eq (get a stableswap-reversals) false)
                    (unwrap! (stableswap-sa amount stableswap-tokens stableswap-pools) ERR_SWAP_A)
                    (unwrap! (stableswap-sb amount stableswap-tokens stableswap-pools) ERR_SWAP_A))
                (unwrap! (velar-sd amount velar-tokens velar-share-fee-to) ERR_SWAP_A)))
    (swap-b (if (is-eq swaps-reversed false)
                (unwrap! (velar-sd swap-a velar-tokens velar-share-fee-to) ERR_SWAP_B)
                (if (is-eq (get a stableswap-reversals) false)
                    (unwrap! (stableswap-sa swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B)
                    (unwrap! (stableswap-sb swap-a stableswap-tokens stableswap-pools) ERR_SWAP_B))))
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
            stableswap-reversals: stableswap-reversals,
            stableswap-swap: (if (is-eq swaps-reversed false) swap-a swap-b)
          },
          velar-data: {
            velar-tokens: velar-tokens,
            velar-share-fee-to: velar-share-fee-to,
            velar-swap: (if (is-eq swaps-reversed false) swap-b swap-a)
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
    (quote-a (contract-call?
             'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-1 get-dy
             (get a pools)
             (get a tokens) (get b tokens)
             amount))
  )
    (ok quote-a)
  )
)

(define-private (stableswap-qb
    (amount uint)
    (tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    (quote-a (contract-call?
             'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-1 get-dx
             (get a pools)
             (get a tokens) (get b tokens)
             amount))
  )
    (ok quote-a)
  )
)

(define-private (velar-qa
    (amount uint)
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>)))
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
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>)))
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
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>)))
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
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>) (e <velar-ft-trait>)))
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

(define-private (stableswap-sa
    (amount uint)
    (tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-1 swap-x-for-y
                  (get a pools)
                  (get a tokens) (get b tokens)
                  amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (stableswap-sb
    (amount uint)
    (tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    (swap-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-core-v-1-1 swap-y-for-x
                  (get a pools)
                  (get a tokens) (get b tokens)
                  amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (velar-sa
    (amount uint)
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>)))
    (share-fee-to <velar-share-fee-to-trait>)
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
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>)))
    (share-fee-to <velar-share-fee-to-trait>)
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
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>)))
    (share-fee-to <velar-share-fee-to-trait>)
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
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>) (e <velar-ft-trait>)))
    (share-fee-to <velar-share-fee-to-trait>)
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

(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)