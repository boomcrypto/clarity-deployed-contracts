---
title: "Trait stableswap-sbtc-reader-pool-2-v-1-2"
draft: true
---
```
;; stableswap-sbtc-reader-pool-2-v-1-2

;; Error constants
(define-constant ERR_INVALID_PRINCIPAL (err u7001))
(define-constant ERR_NO_POOL_DATA (err u7002))
(define-constant ERR_NO_USER_DATA (err u7003))

;; Address for sBTC token contract
(define-constant SBTC_TOKEN_CONTRACT 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)

;; Get total sBTC balance in sBTC-pBTC Stableswap pool
(define-read-only (get-total-sbtc-balance)
  (let (
    ;; Get pool's total sBTC balance
    (pool-sbtc-balance (unwrap! (contract-call? 'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token get-balance
                                'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-sbtc-pbtc-v-1-1) ERR_NO_POOL_DATA))
  )
    ;; Return pool's total sBTC balance
    (ok pool-sbtc-balance)
  )
)

;; Get a user's sBTC balance in sBTC-pBTC Stableswap pool
(define-read-only (get-user-sbtc-balance (user principal))
  (let (
    ;; Gather all pool data
    (pool-data (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-sbtc-pbtc-v-1-1 get-pool) ERR_NO_POOL_DATA))
    (x-token (get x-token pool-data))
    (y-token (get y-token pool-data))
    (x-balance (get x-balance pool-data))
    (y-balance (get y-balance pool-data))
    (total-shares (get total-shares pool-data))

    ;; Assert that user principal is standard
    (user-address-check (asserts! (is-standard user) ERR_INVALID_PRINCIPAL))
    
    ;; Get pool's total sBTC balance
    (pool-sbtc-balance
      (if (is-eq x-token SBTC_TOKEN_CONTRACT)
        x-balance
        y-balance
      )
    )

    ;; Get user's LP Token balance and staked LP Token balances
    (user-lp-balance (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-pool-sbtc-pbtc-v-1-1 get-balance
                              user) ERR_NO_USER_DATA))
    (user-staking-data-a (unwrap! (contract-call? 'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.stableswap-staking-sbtc-pbtc-v-1-1 get-user
                                  user) ERR_NO_USER_DATA))
    (user-staking-data-b (unwrap! (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.stableswap-staking-sbtc-pbtc-v-1-2 get-user
                                  user) ERR_NO_USER_DATA))
    (user-lp-staked-balance-a (default-to u0 (get lp-staked user-staking-data-a)))
    (user-lp-staked-balance-b (default-to u0 (get lp-staked user-staking-data-b)))

    ;; Calculate user's total LP Token balance and proportional sBTC balance
    (user-total-lp-balance (+ user-lp-balance user-lp-staked-balance-a user-lp-staked-balance-b))
    (user-sbtc-balance (/ (* user-total-lp-balance pool-sbtc-balance) total-shares))
  )
    ;; Return user's sBTC balance in pool
    (ok user-sbtc-balance)
  )
)
```
