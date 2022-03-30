(define-public (transfer-bananas (amount uint))
    (begin
        (try! (contract-call? .btc-monkeys-bananas transfer amount tx-sender .banana-vault none))
        (ok true)
    )
)