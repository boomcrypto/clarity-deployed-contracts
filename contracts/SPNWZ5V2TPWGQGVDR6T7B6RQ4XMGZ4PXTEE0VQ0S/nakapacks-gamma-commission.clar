(define-public (pay (id uint) (price uint)) 
    (begin 
        ;; Team (2.5%)
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4))

        ;; Gamma (2%)
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S))

        (ok true)
    )
)