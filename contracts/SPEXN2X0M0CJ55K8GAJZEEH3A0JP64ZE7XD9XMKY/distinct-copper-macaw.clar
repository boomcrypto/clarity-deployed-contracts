;; stableswap-sbtc-reader-v-1-1

;; Use Stableswap pool trait
(use-trait stableswap-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-trait-v-1-2.stableswap-pool-trait)

;; Error constants
(define-constant ERR_INVALID_PRINCIPAL (err u7001))
(define-constant ERR_NO_POOL_DATA (err u7002))
(define-constant ERR_NO_USER_DATA (err u7003))
(define-constant ERR_NOT_SBTC_POOL (err u7004))

;; Address for sBTC token contract
(define-constant SBTC_TOKEN_CONTRACT 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2)

;; Get a Stableswap pool's total sBTC balance
(define-public (get-total-sbtc-balance (pool-trait <stableswap-pool-trait>))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))

    ;; Check if pool is a valid sBTC pool
    (pool-validity-check (asserts! (is-sbtc-pool x-token y-token) ERR_NOT_SBTC_POOL))
    
    ;; Get pool's total sBTC balance
    (pool-sbtc-balance
      (if (is-eq x-token SBTC_TOKEN_CONTRACT)
        x-balance
        y-balance
      )
    )
  )
    ;; Return pool's total sBTC balance
    (ok pool-sbtc-balance)
  )
)

;; Get a user's sBTC balance in a Stableswap pool
(define-public (get-user-sbtc-balance (pool-trait <stableswap-pool-trait>) (user principal))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? pool-trait get-pool) ERR_NO_POOL_DATA))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (total-shares (get total-shares pool-data))

    ;; Check if pool is a valid sBTC pool and user principal is standard
    (pool-validity-check (asserts! (is-sbtc-pool x-token y-token) ERR_NOT_SBTC_POOL))
    (user-address-check (asserts! (is-standard user) ERR_INVALID_PRINCIPAL))
    
    ;; Get pool's total sBTC balance
    (pool-sbtc-balance
      (if (is-eq x-token SBTC_TOKEN_CONTRACT)
        x-balance
        y-balance
      )
    )

    ;; Get user's LP Token balance and calculate proportional sBTC balance
    (user-lp-balance (unwrap! (contract-call? pool-trait get-balance user) ERR_NO_USER_DATA))
    (user-sbtc-balance (/ (* user-lp-balance pool-sbtc-balance) total-shares))
  )
    ;; Return user's sBTC balance in pool
    (ok user-sbtc-balance)
  )
)

;; Check if a Stableswap pool is a valid sBTC pool
(define-private (is-sbtc-pool (x-token principal) (y-token principal))
  (or (is-eq x-token SBTC_TOKEN_CONTRACT) (is-eq y-token SBTC_TOKEN_CONTRACT))
)