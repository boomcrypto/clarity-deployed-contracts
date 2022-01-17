;; contract written by Asteria of Syvita
;; rights to this contract are reserved for the Syvita Guild

(define-constant POOL_ADDRESS 'SP2F8X5AT0726E8B7GGXDADHD53ARM5927SJN3TQ6)

(define-constant CONTRACT_ADDRESS (as-contract tx-sender))

(define-constant ERR_UNAUTHORIZED u1000)
(define-data-var price uint u15000) ;; price in uSTX for 1 MIA

(define-public (sell-mia (amount uint))
    (begin
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        ;; send MIA to contract
        (try! (transfer-mia amount contract-caller CONTRACT_ADDRESS))
        (ok true)
    )
)

(define-public (exit-mia (amount uint))
    (begin 
        (asserts! (is-auth-pool) (err ERR_UNAUTHORIZED))
        ;; send MIA to POOL owner address
        (try! (as-contract (transfer-mia amount CONTRACT_ADDRESS POOL_ADDRESS)))
        (ok true)
    )
)

(define-public (buy-mia (amount uint))
    (let
        ((user contract-caller))
        (asserts! (not (is-auth-pool)) (err ERR_UNAUTHORIZED))
        ;; transfer stx to deployer
        (try! (stx-transfer? (* amount (var-get price)) user POOL_ADDRESS))
        ;; send MIA to caller
        (try! (as-contract (transfer-mia amount CONTRACT_ADDRESS user)))
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
    (ok (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token get-balance (as-contract tx-sender)))
)

(define-read-only (get-contract-stx-balance)
  (stx-get-balance CONTRACT_ADDRESS)
)

(define-read-only (get-pool-mia-balance)
  (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token get-balance POOL_ADDRESS)
)

(define-read-only (get-pool-stx-balance)
  (stx-get-balance POOL_ADDRESS)
)

(define-private (is-auth-pool)
  (is-eq contract-caller POOL_ADDRESS)
)

(define-private (transfer-mia (amount uint) (from principal) (to principal))
    (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer amount from to none)
)

(define-private (get-balance (user principal))
    (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token get-balance user)
)