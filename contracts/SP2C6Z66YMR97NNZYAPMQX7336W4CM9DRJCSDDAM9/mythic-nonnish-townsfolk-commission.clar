(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u300) u10000) tx-sender 'SP305TZHTGMGEDYETNBTN7XBFH11VG81XGG7R9K5C))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2C6Z66YMR97NNZYAPMQX7336W4CM9DRJCSDDAM9))
        (ok true)))