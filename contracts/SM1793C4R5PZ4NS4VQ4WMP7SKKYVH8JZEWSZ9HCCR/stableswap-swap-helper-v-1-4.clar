
;; stableswap-swap-helper-v-1-4

;; Use Stableswap ft trait and Stableswap pool trait
(use-trait stableswap-ft-trait .sip-010-trait-ft-standard-v-1-1.sip-010-trait)
(use-trait stableswap-pool-trait .stableswap-pool-trait-v-1-4.stableswap-pool-trait)

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

;; Remove an admin from the admins list
(define-public (remove-admin (admin principal))
  (let (
    (admins-list (var-get admins))
    (caller tx-sender)
  )
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
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (stableswap-qa amount (get a stableswap-tokens) (get b stableswap-tokens) (get a stableswap-pools))))
  )
    ;; Return number of b tokens the caller would receive
    (ok quote-a)
  )
)

;; Get quote for swap-helper-b
(define-public (get-quote-b
    (amount uint)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (stableswap-qa amount (get a stableswap-tokens) (get b stableswap-tokens) (get a stableswap-pools))))
    (quote-b (try! (stableswap-qa quote-a (get c stableswap-tokens) (get d stableswap-tokens) (get b stableswap-pools))))
  )
    ;; Return number of d tokens the caller would receive
    (ok quote-b)
  )
)

;; Get quote for swap-helper-c
(define-public (get-quote-c
    (amount uint)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (stableswap-qa amount (get a stableswap-tokens) (get b stableswap-tokens) (get a stableswap-pools))))
    (quote-b (try! (stableswap-qa quote-a (get c stableswap-tokens) (get d stableswap-tokens) (get b stableswap-pools))))
    (quote-c (try! (stableswap-qa quote-b (get e stableswap-tokens) (get f stableswap-tokens) (get c stableswap-pools))))
  )
    ;; Return number of f tokens the caller would receive
    (ok quote-c)
  )
)

;; Get quote for swap-helper-d
(define-public (get-quote-d
    (amount uint)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>) (g <stableswap-ft-trait>) (h <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>) (d <stableswap-pool-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (stableswap-qa amount (get a stableswap-tokens) (get b stableswap-tokens) (get a stableswap-pools))))
    (quote-b (try! (stableswap-qa quote-a (get c stableswap-tokens) (get d stableswap-tokens) (get b stableswap-pools))))
    (quote-c (try! (stableswap-qa quote-b (get e stableswap-tokens) (get f stableswap-tokens) (get c stableswap-pools))))
    (quote-d (try! (stableswap-qa quote-c (get g stableswap-tokens) (get h stableswap-tokens) (get d stableswap-pools))))
  )
    ;; Return number of h tokens the caller would receive
    (ok quote-d)
  )
)

;; Get quote for swap-helper-e
(define-public (get-quote-e
    (amount uint)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>) (g <stableswap-ft-trait>) (h <stableswap-ft-trait>) (i <stableswap-ft-trait>) (j <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>) (d <stableswap-pool-trait>) (e <stableswap-pool-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Get quotes for each swap
    (quote-a (try! (stableswap-qa amount (get a stableswap-tokens) (get b stableswap-tokens) (get a stableswap-pools))))
    (quote-b (try! (stableswap-qa quote-a (get c stableswap-tokens) (get d stableswap-tokens) (get b stableswap-pools))))
    (quote-c (try! (stableswap-qa quote-b (get e stableswap-tokens) (get f stableswap-tokens) (get c stableswap-pools))))
    (quote-d (try! (stableswap-qa quote-c (get g stableswap-tokens) (get h stableswap-tokens) (get d stableswap-pools))))
    (quote-e (try! (stableswap-qa quote-d (get i stableswap-tokens) (get j stableswap-tokens) (get e stableswap-pools))))
  )
    ;; Return number of j tokens the caller would receive
    (ok quote-e)
  )
)

;; Swap via 1 Stableswap pool
(define-public (swap-helper-a
    (amount uint) (min-received uint)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (try! (stableswap-sa amount (get a stableswap-tokens) (get b stableswap-tokens) (get a stableswap-pools))))
  )
    (begin
      ;; Assert that swap-a is greater than or equal to min-received
      (asserts! (>= swap-a min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of b tokens the caller received
      (print {
        action: "swap-helper-a",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-a,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: swap-a
            }
          }
        }
      })
      (ok swap-a)
    )
  )
)

;; Swap via 2 Stableswap pools
(define-public (swap-helper-b
    (amount uint) (min-received uint)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (try! (stableswap-sa amount (get a stableswap-tokens) (get b stableswap-tokens) (get a stableswap-pools))))
    (swap-b (try! (stableswap-sa swap-a (get c stableswap-tokens) (get d stableswap-tokens) (get b stableswap-pools))))
  )
    (begin
      ;; Assert that swap-b is greater than or equal to min-received
      (asserts! (>= swap-b min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of d tokens the caller received
      (print {
        action: "swap-helper-b",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-b,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: swap-a,
              b: swap-b
            }
          }
        }
      })
      (ok swap-b)
    )
  )
)

;; Swap via 3 Stableswap pools
(define-public (swap-helper-c
    (amount uint) (min-received uint)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (try! (stableswap-sa amount (get a stableswap-tokens) (get b stableswap-tokens) (get a stableswap-pools))))
    (swap-b (try! (stableswap-sa swap-a (get c stableswap-tokens) (get d stableswap-tokens) (get b stableswap-pools))))
    (swap-c (try! (stableswap-sa swap-b (get e stableswap-tokens) (get f stableswap-tokens) (get c stableswap-pools))))
  )
    (begin
      ;; Assert that swap-c is greater than or equal to min-received
      (asserts! (>= swap-c min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of f tokens the caller received
      (print {
        action: "swap-helper-c",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-c,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: swap-a,
              b: swap-b,
              c: swap-c
            }
          }
        }
      })
      (ok swap-c)
    )
  )
)

;; Swap via 4 Stableswap pools
(define-public (swap-helper-d
    (amount uint) (min-received uint)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>) (g <stableswap-ft-trait>) (h <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>) (d <stableswap-pool-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (try! (stableswap-sa amount (get a stableswap-tokens) (get b stableswap-tokens) (get a stableswap-pools))))
    (swap-b (try! (stableswap-sa swap-a (get c stableswap-tokens) (get d stableswap-tokens) (get b stableswap-pools))))
    (swap-c (try! (stableswap-sa swap-b (get e stableswap-tokens) (get f stableswap-tokens) (get c stableswap-pools))))
    (swap-d (try! (stableswap-sa swap-c (get g stableswap-tokens) (get h stableswap-tokens) (get d stableswap-pools))))
  )
    (begin
      ;; Assert that swap-d is greater than or equal to min-received
      (asserts! (>= swap-d min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of h tokens the caller received
      (print {
        action: "swap-helper-d",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-d,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: swap-a,
              b: swap-b,
              c: swap-c,
              d: swap-d
            }
          }
        }
      })
      (ok swap-d)
    )
  )
)

;; Swap via 5 Stableswap pools
(define-public (swap-helper-e
    (amount uint) (min-received uint)
    (stableswap-tokens (tuple (a <stableswap-ft-trait>) (b <stableswap-ft-trait>) (c <stableswap-ft-trait>) (d <stableswap-ft-trait>) (e <stableswap-ft-trait>) (f <stableswap-ft-trait>) (g <stableswap-ft-trait>) (h <stableswap-ft-trait>) (i <stableswap-ft-trait>) (j <stableswap-ft-trait>)))
    (stableswap-pools (tuple (a <stableswap-pool-trait>) (b <stableswap-pool-trait>) (c <stableswap-pool-trait>) (d <stableswap-pool-trait>) (e <stableswap-pool-trait>)))
  )
  (let (
    ;; Assert that swap-status is true and amount is greater than 0
    (swap-status-check (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS))
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Perform each swap
    (swap-a (try! (stableswap-sa amount (get a stableswap-tokens) (get b stableswap-tokens) (get a stableswap-pools))))
    (swap-b (try! (stableswap-sa swap-a (get c stableswap-tokens) (get d stableswap-tokens) (get b stableswap-pools))))
    (swap-c (try! (stableswap-sa swap-b (get e stableswap-tokens) (get f stableswap-tokens) (get c stableswap-pools))))
    (swap-d (try! (stableswap-sa swap-c (get g stableswap-tokens) (get h stableswap-tokens) (get d stableswap-pools))))
    (swap-e (try! (stableswap-sa swap-d (get i stableswap-tokens) (get j stableswap-tokens) (get e stableswap-pools))))
  )
    (begin
      ;; Assert that swap-e is greater than or equal to min-received
      (asserts! (>= swap-e min-received) ERR_MINIMUM_RECEIVED)

      ;; Print swap data and return number of j tokens the caller received
      (print {
        action: "swap-helper-e",
        caller: tx-sender, 
        data: {
          amount: amount,
          min-received: min-received,
          received: swap-e,
          stableswap-data: {
            stableswap-tokens: stableswap-tokens,
            stableswap-pools: stableswap-pools,
            stableswap-swaps: {
              a: swap-a,
              b: swap-b,
              c: swap-c,
              d: swap-d,
              e: swap-e
            }
          }
        }
      })
      (ok swap-e)
    )
  )
)

;; Helper function for removing an admin
(define-private (admin-not-removable (admin principal))
  (not (is-eq admin (var-get admin-helper)))
)

;; Check if input and output tokens are swapped relative to the pool's x and y tokens
(define-private (is-stableswap-path-reversed
    (token-in <stableswap-ft-trait>) (token-out <stableswap-ft-trait>)
    (pool-contract <stableswap-pool-trait>)
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

;; Get Stableswap quote using get-dy or get-dx based on token path
(define-private (stableswap-qa
    (amount uint)
    (token-in <stableswap-ft-trait>) (token-out <stableswap-ft-trait>)
    (pool <stableswap-pool-trait>)
  )
  (let (
    ;; Determine if the token path is reversed
    (is-reversed (is-stableswap-path-reversed token-in token-out pool))
    
    ;; Get quote based on path
    (quote-a (if (is-eq is-reversed false)
                 (try! (contract-call?
                 .stableswap-core-v-1-4 get-dy
                 pool
                 token-in token-out
                 amount))
                 (try! (contract-call?
                 .stableswap-core-v-1-4 get-dx
                 pool
                 token-out token-in
                 amount))))
  )
    (ok quote-a)
  )
)

;; Perform Stableswap swap using swap-x-for-y or swap-y-for-x based on token path
(define-private (stableswap-sa
    (amount uint)
    (token-in <stableswap-ft-trait>) (token-out <stableswap-ft-trait>)
    (pool <stableswap-pool-trait>)
  )
  (let (
    ;; Determine if the token path is reversed
    (is-reversed (is-stableswap-path-reversed token-in token-out pool))
    
    ;; Perform swap based on path
    (swap-a (if (is-eq is-reversed false)
                (try! (contract-call?
                      .stableswap-core-v-1-4 swap-x-for-y
                      pool
                      token-in token-out
                      amount u1))
                (try! (contract-call?
                      .stableswap-core-v-1-4 swap-y-for-x
                      pool
                      token-out token-in
                      amount u1))))
  )
    (ok swap-a)
  )
)