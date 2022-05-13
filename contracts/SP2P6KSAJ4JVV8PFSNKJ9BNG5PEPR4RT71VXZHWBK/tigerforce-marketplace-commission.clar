(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
;;commission 
(define-data-var commission uint u100)
(define-data-var commission-address principal 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C)
;;royalty
(define-data-var royalty uint u500)
(define-data-var royalty-address principal 'SP1YN8WZ50C237MBJZ6GQD339NNZSKA55RJ9YZ9YQ)


(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin  
                (try! (stx-transfer? (/ (* price (var-get commission)) u10000) tx-sender (var-get commission-address)))
                (try! (stx-transfer? (/ (* price (var-get royalty)) u10000) tx-sender (var-get royalty-address)))
                (ok true)
        )
        (ok true)
    )
)


;;royalty func
(define-public (set-royalty (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set royalty amount)
        (ok true)
    )
)

(define-public (set-royalty-address (address principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (var-set royalty-address address)
        (ok true)
    )
)


(define-public (get-royalty)
    (ok (var-get royalty))
)

(define-public (get-royalty-address)
    (ok (var-get royalty-address))
)



;;comission func
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