;; foobar-defi example contract
(define-fungible-token test u10000)
(define-public (mint-token (amount uint))
    (begin
        (try! (ft-mint? test amount tx-sender))
        (ok true)
    )
)
(define-public (transfer-token (amount uint) (to principal))
    (begin
        (try! (ft-transfer? test amount tx-sender to))
        (ok true)
    )
)