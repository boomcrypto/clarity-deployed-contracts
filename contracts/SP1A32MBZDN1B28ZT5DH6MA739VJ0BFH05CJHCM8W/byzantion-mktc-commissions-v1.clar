(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u250)
(define-data-var commission-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)

(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin  
                (try! (stx-transfer? (/ (* price (var-get commission)) u10000) tx-sender (var-get commission-address)))
                (try! (stx-transfer? (/ (* price u100) u50000) tx-sender 'SPF1426KV10TKZ55BPCBDQFM6X4EJZMMF3JMKVY6))
                (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2597NW8VYYVV4C22WQF3DK0WGQS8TAVDDPXQ5H8))
                (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP1GPNZB0JSC9RXJTXVBAMSPQE29WM1SE8V39R6K2))

                (ok true)
        )
        (ok true)
    )
)

(define-public (set-commission (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set commission amount)
        (ok true)
    )
)

(define-public (set-commission-address (address principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
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
