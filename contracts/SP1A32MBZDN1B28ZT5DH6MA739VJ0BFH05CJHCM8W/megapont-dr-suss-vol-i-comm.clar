(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u250)
(define-data-var commission-address principal 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX)

(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin  
                (try! (stx-transfer? (/ (* price (var-get commission)) u10000) tx-sender (var-get commission-address)))
                (try! (stx-transfer? (/ (* price u1000) u10000) tx-sender 'SP3MQWSKAESKY7JFBS88GFQ47AZDKC3XH3ZHTWWYT))

                (ok true)
        )
        (ok true)
    )
)

(define-public (set-commission (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get commission-address)) ERR-NOT-AUTHORIZED)
        (var-set commission amount)
        (ok true)
    )
)

(define-public (set-commission-address (address principal))
    (begin
        (asserts! (is-eq tx-sender (var-get commission-address)) ERR-NOT-AUTHORIZED)
        (var-set commission-address address)
        (ok true)
    )
)

(define-public (get-commission)
    (ok (var-get commission))
)

(define-public (get-commission-address)
    (ok (var-get commission-address))
)
