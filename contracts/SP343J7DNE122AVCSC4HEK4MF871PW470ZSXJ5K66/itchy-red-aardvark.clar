(define-constant MIAMICOIN_TOKEN 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token)
(define-constant POOL_ADDRESS 'SP2F8X5AT0726E8B7GGXDADHD53ARM5927SJN3TQ6)

(define-constant ERR_UNAUTHORIZED u1)

(define-data-var price uint u15000) ;; price in uSTX for 1 MIA
(define-data-var amountOfMIA uint u0)

(define-public (sell-mia (amount uint))
    (begin
        (asserts! (is-eq contract-caller POOL_ADDRESS) (err ERR_UNAUTHORIZED))
        ;; send MIA to contract
        (try! (transfer-mia amount contract-caller (as-contract tx-sender)))
        (var-set amountOfMIA (+ (var-get amountOfMIA) amount))
        (ok true)
    )
)

(define-public (exit-mia (amount uint))
    (begin 
        (asserts! (is-eq contract-caller POOL_ADDRESS) (err ERR_UNAUTHORIZED))
        ;; send MIA to caller
        (try! (transfer-mia amount (as-contract tx-sender) contract-caller))
        (var-set amountOfMIA (- (var-get amountOfMIA) amount))
        (ok true)
    )
)

(define-public (buy-mia (amount uint))
    (begin
        (asserts! (not (is-eq contract-caller POOL_ADDRESS)) (err ERR_UNAUTHORIZED))
        ;; transfer stx to deployer
        (try! (stx-transfer? (* amount (var-get price)) contract-caller POOL_ADDRESS))
        ;; send MIA to caller
        (try! (transfer-mia amount (as-contract tx-sender) contract-caller))
        (var-set amountOfMIA (- (var-get amountOfMIA) amount))
        (ok true)
    )
)

(define-public (change-price (newPrice uint)) ;; price in uSTX
    (begin
        (asserts! (is-eq contract-caller POOL_ADDRESS) (err ERR_UNAUTHORIZED))
        (var-set price newPrice)
        (ok true)
    )
)

(define-read-only (get-price)
    (ok (var-get price))
)

(define-read-only (get-remaining)
    (ok (var-get amountOfMIA))
)

(define-private (transfer-mia (amount uint) (from principal) (to principal))
    (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token transfer amount from to none)
)

(define-private (get-balance (user principal))
    (contract-call? 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token get-balance user)
)