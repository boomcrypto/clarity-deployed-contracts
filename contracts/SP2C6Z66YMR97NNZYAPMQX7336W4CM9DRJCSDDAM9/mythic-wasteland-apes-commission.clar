(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ price u100) tx-sender 'SP2C6Z66YMR97NNZYAPMQX7336W4CM9DRJCSDDAM9))
        (ok true)))