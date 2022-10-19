(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u250)
(define-data-var commission-address principal 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX)

(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin  
                (try! (stx-transfer? (/ (* price (var-get commission)) u10000) tx-sender (var-get commission-address)))
                (try! (stx-transfer? (/ (* price u400) u10000) tx-sender 'SP1B6VYHGCR4E8NG8VDF38S7H4BC7E0D0T8CQR1BZ))
                (try! (stx-transfer? (/ (* price u120) u10000) tx-sender 'SPCE90YFF2C24DYTEQDVJ2Y8TEM5HAXV7JCYGE9K))

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
