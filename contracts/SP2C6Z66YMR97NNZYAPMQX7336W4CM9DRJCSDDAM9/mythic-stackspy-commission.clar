(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-data-var commission uint u250)
(define-data-var commission-address principal 'SP2C6Z66YMR97NNZYAPMQX7336W4CM9DRJCSDDAM9)

(define-public (pay (id uint) (price uint))
    (if (> (var-get commission) u0)
        (begin  
                (try! (stx-transfer? (/ (* price (var-get commission)) u10000) tx-sender (var-get commission-address)))
                ;; total of 5% = u500
                (try! (stx-transfer? (/ (* price u275) u10000) tx-sender 'SPRTXZF3GKXJKQ877P56HHG9J1M8GAP2A91FC06B))
                (try! (stx-transfer? (/ (* price u75) u10000) tx-sender 'SP2MJ98NVBY9MZQ0BNQBBD32BRDCNDFT7QDDETAVQ))
                (try! (stx-transfer? (/ (* price u75) u10000) tx-sender 'SP37X3WKT41YDB66MRW86WYS0VYZ615STVTW8VBHM))
                (try! (stx-transfer? (/ (* price u75) u10000) tx-sender 'SPSN5FVTJJFWT6F5H403CPW26CD6TWJD7W4N0DQR))
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
