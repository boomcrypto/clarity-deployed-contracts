
;; router-xyk-velar-v-1-3

;; Use all required traits
(use-trait xyk-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait xyk-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-2.xyk-pool-trait)
(use-trait velar-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait velar-share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u6001))
(define-constant ERR_INVALID_AMOUNT (err u6002))
(define-constant ERR_INVALID_PRINCIPAL (err u6003))
(define-constant ERR_ALREADY_ADMIN (err u6004))
(define-constant ERR_ADMIN_LIMIT_REACHED (err u6005))
(define-constant ERR_ADMIN_NOT_IN_LIST (err u6006))
(define-constant ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER (err u6007))
(define-constant ERR_SWAP_STATUS (err u6008))
(define-constant ERR_MINIMUM_RECEIVED (err u6009))

;; Contract deployer address
(define-constant CONTRACT_DEPLOYER tx-sender)

;; Admins list and helper var used to remove admins
(define-data-var admins (list 5 principal) (list tx-sender))
(define-data-var admin-helper principal tx-sender)

;; Data var used to enable or disable quotes and swaps
(define-data-var swap-status bool true)

;; Get admins list
(define-read-only (get-admins)
  (ok (var-get admins))
)

;; Get admin helper var
(define-read-only (get-admin-helper)
  (ok (var-get admin-helper))
)

;; Get swap status
(define-read-only (get-swap-status)
  (ok (var-get swap-status))
)

;; Add an admin to the admins list
(define-public (add-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an existing admin and new admin is not in admins-list
      (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-none (index-of admins-list admin)) ERR_ALREADY_ADMIN)

      ;; Add admin to list with max length of 5
      (var-set admins (unwrap! (as-max-len? (append admins-list admin) u5) ERR_ADMIN_LIMIT_REACHED))

      ;; Print add admin data and return true
      (print {action: "add-admin", caller: caller, data: {admin: admin}})
      (ok true)
    )
  )
)

;; Remove an admin from the admins list
(define-public (remove-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an existing admin and admin to remove is in admins-list
      (asserts! (is-some (index-of admins-list caller)) ERR_NOT_AUTHORIZED)
      (asserts! (is-some (index-of admins-list admin)) ERR_ADMIN_NOT_IN_LIST)

      ;; Assert contract deployer cannot be removed
      (asserts! (not (is-eq admin CONTRACT_DEPLOYER)) ERR_CANNOT_REMOVE_CONTRACT_DEPLOYER)

      ;; Set admin-helper to admin to remove and filter admins-list to remove admin
      (var-set admin-helper admin)
      (var-set admins (filter admin-not-removable admins-list))

      ;; Print remove admin data and return true
      (print {action: "remove-admin", caller: caller, data: {admin: admin}})
      (ok true)
    )
  )
)

;; Enable or disable quotes and swaps
(define-public (set-swap-status (status bool))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is an admin
      (asserts! (is-some (index-of (var-get admins) caller)) ERR_NOT_AUTHORIZED)

      ;; Set swap-status to status
      (var-set swap-status status)

      ;; Print function data and return true
      (print {action: "set-swap-status", caller: caller, data: {status: status}})
      (ok true)
    )
  )
)

;; Get quote for swap-helper-a
(define-public (get-quote-a
    (amount uint)
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    
    ;; Get quotes for each swap
    (quote-a (try! (if (is-eq swaps-reversed false)
                       (xyk-quote-a amount xyk-tokens xyk-pools)
                       (velar-quote-a amount velar-tokens))))
    (quote-b (try! (if (is-eq swaps-reversed false)
                       (velar-quote-a quote-a velar-tokens)
                       (xyk-quote-a quote-a xyk-tokens xyk-pools))))
  )
    ;; Return number of tokens the caller would receive
    (ok quote-b)
  )
)

;; Get quote for swap-helper-b
(define-public (get-quote-b
    (amount uint)
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    
    ;; Get quotes for each swap
    (quote-a (try! (if (is-eq swaps-reversed false)
                       (xyk-quote-a amount xyk-tokens xyk-pools)
                       (velar-quote-b amount velar-tokens))))
    (quote-b (try! (if (is-eq swaps-reversed false)
                       (velar-quote-b quote-a velar-tokens)
                       (xyk-quote-a quote-a xyk-tokens xyk-pools))))
  )
    ;; Return number of tokens the caller would receive
    (ok quote-b)
  )
)

;; Get quote for swap-helper-c
(define-public (get-quote-c
    (amount uint)
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    
    ;; Get quotes for each swap
    (quote-a (try! (if (is-eq swaps-reversed false)
                       (xyk-quote-a amount xyk-tokens xyk-pools)
                       (velar-quote-c amount velar-tokens))))
    (quote-b (try! (if (is-eq swaps-reversed false)
                       (velar-quote-c quote-a velar-tokens)
                       (xyk-quote-a quote-a xyk-tokens xyk-pools))))
  )
    ;; Return number of tokens the caller would receive
    (ok quote-b)
  )
)

;; Get quote for swap-helper-d
(define-public (get-quote-d
    (amount uint)
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>) (e <velar-ft-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    
    ;; Get quotes for each swap
    (quote-a (try! (if (is-eq swaps-reversed false)
                       (xyk-quote-a amount xyk-tokens xyk-pools)
                       (velar-quote-d amount velar-tokens))))
    (quote-b (try! (if (is-eq swaps-reversed false)
                       (velar-quote-d quote-a velar-tokens)
                       (xyk-quote-a quote-a xyk-tokens xyk-pools))))
  )
    ;; Return number of tokens the caller would receive
    (ok quote-b)
  )
)

;; Perform swap via XYK Core and Velar
(define-public (swap-helper-a
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>)))
    (velar-share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (if (is-eq swaps-reversed false)
                (try! (xyk-swap-a amount xyk-tokens xyk-pools))
                (try! (velar-swap-a amount velar-tokens velar-share-fee-to))))
    (swap-b (if (is-eq swaps-reversed false)
                (try! (velar-swap-a swap-a velar-tokens velar-share-fee-to))
                (try! (xyk-swap-a swap-a xyk-tokens xyk-pools))))
  )
    (begin
      ;; Assert that swap-b is greater than or equal to min-received
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of tokens the caller received
      (print {
        action: "swap-helper-a",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          velar-data: {
            velar-tokens: velar-tokens,
            velar-share-fee-to: velar-share-fee-to,
            velar-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

;; Perform swap via XYK Core and Velar
(define-public (swap-helper-b
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>)))
    (velar-share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (if (is-eq swaps-reversed false)
                (try! (xyk-swap-a amount xyk-tokens xyk-pools))
                (try! (velar-swap-b amount velar-tokens velar-share-fee-to))))
    (swap-b (if (is-eq swaps-reversed false)
                (try! (velar-swap-b swap-a velar-tokens velar-share-fee-to))
                (try! (xyk-swap-a swap-a xyk-tokens xyk-pools))))
  )
    (begin
      ;; Assert that swap-b is greater than or equal to min-received
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of tokens the caller received
      (print {
        action: "swap-helper-b",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          velar-data: {
            velar-tokens: velar-tokens,
            velar-share-fee-to: velar-share-fee-to,
            velar-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

;; Perform swap via XYK Core and Velar
(define-public (swap-helper-c
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>)))
    (velar-share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (if (is-eq swaps-reversed false)
                (try! (xyk-swap-a amount xyk-tokens xyk-pools))
                (try! (velar-swap-c amount velar-tokens velar-share-fee-to))))
    (swap-b (if (is-eq swaps-reversed false)
                (try! (velar-swap-c swap-a velar-tokens velar-share-fee-to))
                (try! (xyk-swap-a swap-a xyk-tokens xyk-pools))))
  )
    (begin
      ;; Assert that swap-b is greater than or equal to min-received
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of tokens the caller received
      (print {
        action: "swap-helper-c",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          velar-data: {
            velar-tokens: velar-tokens,
            velar-share-fee-to: velar-share-fee-to,
            velar-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

;; Perform swap via XYK Core and Velar
(define-public (swap-helper-d
    (amount uint) (min-received uint)
    (swaps-reversed bool)
    (xyk-tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (xyk-pools (tuple (a <xyk-pool-trait>)))
    (velar-tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>) (e <velar-ft-trait>)))
    (velar-share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
    
    ;; Perform each swap
    (swap-a (if (is-eq swaps-reversed false)
                (try! (xyk-swap-a amount xyk-tokens xyk-pools))
                (try! (velar-swap-d amount velar-tokens velar-share-fee-to))))
    (swap-b (if (is-eq swaps-reversed false)
                (try! (velar-swap-d swap-a velar-tokens velar-share-fee-to))
                (try! (xyk-swap-a swap-a xyk-tokens xyk-pools))))
  )
    (begin
      ;; Assert that swap-b is greater than or equal to min-received
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of tokens the caller received
      (print {
        action: "swap-helper-d",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          swaps-reversed: swaps-reversed,
          xyk-data: {
            xyk-tokens: xyk-tokens,
            xyk-pools: xyk-pools,
            xyk-swaps: {
              a: (if (is-eq swaps-reversed false) swap-a swap-b)
            }
          },
          velar-data: {
            velar-tokens: velar-tokens,
            velar-share-fee-to: velar-share-fee-to,
            velar-swaps: {
              a: (if (is-eq swaps-reversed false) swap-b swap-a)
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

;; Helper function for removing an admin
(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

;; Check if token path for swap via XYK Core is reversed relative to the pool's tokens
(define-private (is-xyk-path-reversed
    (token-in <xyk-ft-trait>) (token-out <xyk-ft-trait>)
    (pool-contract <xyk-pool-trait>)
  )
  (let (
    (pool-data (unwrap-panic (contract-call? pool-contract get-pool)))
  )
    (not
      (and
        (is-eq (contract-of token-in) (get x-token pool-data))
        (is-eq (contract-of token-out) (get y-token pool-data))
      )
    )
  )
)

;; Get swap quote via XYK Core using two tokens
(define-private (xyk-quote-a
    (amount uint)
    (tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    ;; Determine if token path is reversed
    (is-reversed (is-xyk-path-reversed (get a tokens) (get b tokens) (get a pools)))

    ;; Get quote based on path direction
    (quote-result (if (is-eq is-reversed false)
                      (try! (contract-call?
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dy
                            (get a pools)
                            (get a tokens) (get b tokens)
                            amount))
                      (try! (contract-call?
                            'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 get-dx
                            (get a pools)
                            (get b tokens) (get a tokens)
                            amount))))
  )
    (ok quote-result)
  )
)

;; Get swap quote via Velar using two tokens
(define-private (velar-quote-a
    (amount uint)
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>)))
  )
  (let (
    (quote-result (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 amount-out
                  amount
                  (get a tokens) (get b tokens)))
  )
    (ok quote-result)
  )
)

;; Get swap quote via Velar using three tokens
(define-private (velar-quote-b
    (amount uint)
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>)))
  )
  (let (
    (quote-result (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-3
                  amount
                  (get a tokens) (get b tokens) (get c tokens)))
  )
    (ok (get c quote-result))
  )
)

;; Get swap quote via Velar using four tokens
(define-private (velar-quote-c
    (amount uint)
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>)))
  )
  (let (
    (quote-result (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-4
                  amount
                  (get a tokens) (get b tokens) (get c tokens) (get d tokens)
                  (list u1 u2 u3 u4)))
  )
    (ok (get d quote-result))
  )
)

;; Get swap quote via Velar using five tokens
(define-private (velar-quote-d
    (amount uint)
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>) (e <velar-ft-trait>)))
  )
  (let (
    (quote-result (contract-call?
                  'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 get-amount-out-5
                  amount
                  (get a tokens) (get b tokens) (get c tokens)
                  (get d tokens) (get e tokens)))
  )
    (ok (get e quote-result))
  )
)

;; Perform swap via XYK Core using two tokens
(define-private (xyk-swap-a
    (amount uint)
    (tokens (tuple (a <xyk-ft-trait>) (b <xyk-ft-trait>)))
    (pools (tuple (a <xyk-pool-trait>)))
  )
  (let (
    ;; Determine if token path is reversed
    (is-reversed (is-xyk-path-reversed (get a tokens) (get b tokens) (get a pools)))

    ;; Perform swap based on path direction
    (swap-result (if (is-eq is-reversed false)
                     (try! (contract-call?
                           'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y
                           (get a pools)
                           (get a tokens) (get b tokens)
                           amount u1))
                     (try! (contract-call?
                           'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-y-for-x
                           (get a pools)
                           (get b tokens) (get a tokens)
                           amount u1))))
  )
    (ok swap-result)
  )
)

;; Perform swap via Velar using two tokens
(define-private (velar-swap-a
    (amount uint)
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>)))
    (share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    (swap-result (try! (contract-call?
                       'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 do-swap
                       amount
                       (get a tokens) (get b tokens)
                       share-fee-to)))
  )
    (ok (get amt-out swap-result))
  )
)

;; Perform swap via Velar using three tokens
(define-private (velar-swap-b
    (amount uint)
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>)))
    (share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    (swap-result (try! (contract-call?
                       'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-3
                       amount u1
                       (get a tokens) (get b tokens) (get c tokens)
                       share-fee-to)))
  )
    (ok (get amt-out (get c swap-result)))
  )
)

;; Perform swap via Velar using four tokens
(define-private (velar-swap-c
    (amount uint)
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>)))
    (share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    (swap-result (try! (contract-call?
                       'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-4
                       amount u1
                       (get a tokens) (get b tokens) (get c tokens) (get d tokens)
                       share-fee-to)))
  )
    (ok (get amt-out (get d swap-result)))
  )
)

;; Perform swap via Velar using five tokens
(define-private (velar-swap-d
    (amount uint)
    (tokens (tuple (a <velar-ft-trait>) (b <velar-ft-trait>) (c <velar-ft-trait>) (d <velar-ft-trait>) (e <velar-ft-trait>)))
    (share-fee-to <velar-share-fee-to-trait>)
  )
  (let (
    (swap-result (try! (contract-call?
                       'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-path2 swap-5
                       amount u1
                       (get a tokens) (get b tokens) (get c tokens) (get d tokens) (get e tokens)
                       share-fee-to)))
  )
    (ok (get amt-out (get e swap-result)))
  )
)