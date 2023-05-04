(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u690) u10000) tx-sender 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA))
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP2C6Z66YMR97NNZYAPMQX7336W4CM9DRJCSDDAM9))
        (ok true)))