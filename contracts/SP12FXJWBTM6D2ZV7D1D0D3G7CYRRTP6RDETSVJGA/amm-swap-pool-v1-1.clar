(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-POOL (err u2001))
(define-constant ERR-INVALID-LIQUIDITY (err u2003))
(define-constant ERR-POOL-ALREADY-EXISTS (err u2000))
(define-constant ERR-PERCENT-GREATER-THAN-ONE (err u5000))
(define-constant ERR-EXCEEDS-MAX-SLIPPAGE (err u2020))
(define-constant ERR-ORACLE-NOT-ENABLED (err u7002))
(define-constant ERR-ORACLE-AVERAGE-BIGGER-THAN-ONE (err u7004))
(define-constant ERR-PAUSED (err u1001))
(define-constant ERR-SWITCH-THRESHOLD-BIGGER-THAN-ONE (err u7005))
(define-constant ERR-NO-LIQUIDITY (err u2002))
(define-constant ERR-MAX-IN-RATIO (err u4001))
(define-constant ERR-MAX-OUT-RATIO (err u4002))
(define-data-var contract-owner principal tx-sender)
(define-data-var pool-nonce uint u0)
(define-data-var paused bool false)
(define-data-var switch-threshold uint u80000000)
(define-map pools-id-map
    uint 
    {
        token-x: principal,
        token-y: principal,
        factor: uint
    }    
)
(define-map pools-data-map
  {
    token-x: principal,
    token-y: principal,
    factor: uint
  }
  {
    pool-id: uint,
    total-supply: uint,
    balance-x: uint,
    balance-y: uint,
    pool-owner: principal,    
    fee-rate-x: uint,
    fee-rate-y: uint,
    fee-rebate: uint,
    oracle-enabled: bool,
    oracle-average: uint,
    oracle-resilient: uint,
    start-block: uint,
    end-block: uint,
    threshold-x: uint,
    threshold-y: uint,
    max-in-ratio: uint,
    max-out-ratio: uint
  }
)
(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)
(define-read-only (get-pool-details-by-id (pool-id uint))
    (ok (unwrap! (map-get? pools-id-map pool-id) ERR-INVALID-POOL))
)
(define-read-only (get-pool-details (token-x principal) (token-y principal) (factor uint))
    (ok (unwrap! (get-pool-exists token-x token-y factor) ERR-INVALID-POOL))
)
(define-read-only (get-pool-exists (token-x principal) (token-y principal) (factor uint))
    (map-get? pools-data-map { token-x: token-x, token-y: token-y, factor: factor }) 
)
(define-read-only (get-balances (token-x principal) (token-y principal) (factor uint))
  (let
    (
      (pool (try! (get-pool-details token-x token-y factor)))
    )
    (ok {balance-x: (get balance-x pool), balance-y: (get balance-y pool)})
  )
)
(define-read-only (get-start-block (token-x principal) (token-y principal) (factor uint))
    (ok (get start-block (try! (get-pool-details token-x token-y factor))))
)
(define-read-only (get-end-block (token-x principal) (token-y principal) (factor uint))
    (ok (get end-block (try! (get-pool-details token-x token-y factor))))
)
(define-read-only (get-max-in-ratio (token-x principal) (token-y principal) (factor uint))
    (ok (get max-in-ratio (try! (get-pool-details token-x token-y factor))))
)
(define-read-only (get-max-out-ratio (token-x principal) (token-y principal) (factor uint))
    (ok (get max-out-ratio (try! (get-pool-details token-x token-y factor))))
)

(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)
(use-trait loan-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-flash-loan-user.flash-loan-user-trait)
(use-trait vault-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-vault.vault-trait)

(define-public (swap-helper (token-x-trait <vault-trait>) (token-y-trait <loan-trait>) (factor <ft-trait>) (dx uint))
    (ok (list 
        (contract-call? token-x-trait flash-loan token-y-trait factor dx none)
    ))
)