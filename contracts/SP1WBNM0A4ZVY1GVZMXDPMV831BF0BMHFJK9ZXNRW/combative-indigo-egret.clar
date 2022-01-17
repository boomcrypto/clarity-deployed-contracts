;; contract written by Asteria of Syvita
;; rights to this contract are reserved for the Syvita Guild

(define-constant POOL_ADDRESS 'SPV4JEB2Y7HN1050NJGY739F4VDS166RTQ0SFP8A)

(define-constant CONTRACT_ADDRESS (as-contract tx-sender))

(define-constant ERR_UNAUTHORIZED u1000)
(define-data-var price uint u90000)

(define-public (sell-nyc (amount uint))
    (begin
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        ;; send NYC to contract
        (try! (transfer-nyc amount contract-caller CONTRACT_ADDRESS))
        (ok true)
    )
)

(define-public (exit-nyc (amount uint))
    (begin 
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        ;; send NYC to POOL owner address
        (try! (as-contract (transfer-nyc amount CONTRACT_ADDRESS POOL_ADDRESS)))
        (ok true)
    )
)

(define-public (buy-nyc (amount uint))
    (let
        ((user contract-caller))
        (asserts! (not (is-auth-pool)) (err ERR_UNAUTHORIZED))
        ;; transfer stx to deployer
        (try! (stx-transfer? (* amount (var-get price)) user POOL_ADDRESS))
        ;; send NYC to caller
        (try! (as-contract (transfer-nyc amount CONTRACT_ADDRESS user)))
        (ok true)
    )
)

(define-public (change-price (newPrice uint)) ;; price in uSTX
    (begin
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        ;; update price of 1 NYC
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
  (stx-get-balance CONTRACT_ADDRESS)
)

(define-read-only (get-pool-nyc-balance)
  (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-balance POOL_ADDRESS)
)

(define-read-only (get-pool-stx-balance)
  (stx-get-balance POOL_ADDRESS)
)

(define-private (is-auth-pool)
  (is-eq contract-caller POOL_ADDRESS)
)

(define-private (transfer-nyc (amount uint) (from principal) (to principal))
    (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token transfer amount from to none)
)

(define-private (get-balance (user principal))
    (contract-call? 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token get-balance user)
)