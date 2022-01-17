(define-fungible-token main)
(define-fungible-token vote)
(define-data-var owner principal tx-sender)
(define-map mainTokenHolders {address: principal} {amount: uint})

(begin (ft-mint? main u1000000 tx-sender))
(begin (ft-mint? vote u1000000 tx-sender))

;; Task 1
(define-public (transfer-token (address principal) (amount uint))
    (if (is-eq tx-sender (var-get owner))
        (match (ft-transfer? main amount tx-sender address)
            success (begin (map-insert mainTokenHolders { address: address } {amount: amount}) (ok success))
            error (err error)
        ) 
        (err u500)
    )
)

;; Task 2
(define-public (issue-vote-tokens (address principal)) 
    (begin
        (let ((amount (default-to u0 (get amount (map-get? mainTokenHolders {address: address})))))
            (unwrap! (ft-transfer? vote amount tx-sender address) (err 8))
                (ok 1) 
        )
    )
)

(define-public (check-balance (address principal))
    (begin
        (ok (ft-get-balance main address)) 
    )
)

