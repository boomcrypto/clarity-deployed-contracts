;; contract written by Asteria of Syvita
;; rights to this contract are reserved for the Syvita Guild

(define-constant NYCCOIN_TOKEN 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token)
(define-constant POOL_ADDRESS 'SP333V744Y42P93B8W6154VNQ9RDPM9MWCC2QN11J)

(define-constant ERR_UNAUTHORIZED u1)
(define-data-var price uint u9000)

(define-public (sell-nyc (amount uint))
    (begin
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        ;; send MIA to contract
        (try! (transfer-mia amount contract-caller (as-contract tx-sender)))
        (ok true)
    )
)

(define-public (exit-nyc (amount uint))
    (begin 
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        ;; send MIA to caller
        (try! (as-contract (transfer-mia amount (as-contract tx-sender) contract-caller)))
        (ok true)
    )
)

(define-public (buy-nyc (amount uint))
    (begin
        (asserts! (not (is-auth-pool)) (err ERR_UNAUTHORIZED))
        ;; transfer stx to deployer
        (try! (stx-transfer? (* amount (var-get price)) contract-caller POOL_ADDRESS))
        ;; send MIA to caller
        (try! (as-contract (transfer-mia amount (as-contract tx-sender) contract-caller)))
        (ok true)
    )
)

(define-public (change-price (newPrice uint)) ;; price in uSTX
    (begin
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        ;; update price of 1 MIA
        (var-set price newPrice)
        (ok true)
    )
)

(define-read-only (get-price)
    (ok (var-get price))
)

(define-read-only (get-remaining)
    (ok (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-balance (as-contract tx-sender)))
)

(define-read-only (get-contract-stx-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-read-only (get-pool-mia-balance)
  (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-balance POOL_ADDRESS)
)

(define-read-only (get-pool-stx-balance)
  (stx-get-balance POOL_ADDRESS)
)

(define-private (is-auth-pool)
  (is-eq contract-caller POOL_ADDRESS)
)

(define-private (transfer-mia (amount uint) (from principal) (to principal))
    (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer amount from to none)
)

(define-private (get-balance (user principal))
    (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-balance user)
)