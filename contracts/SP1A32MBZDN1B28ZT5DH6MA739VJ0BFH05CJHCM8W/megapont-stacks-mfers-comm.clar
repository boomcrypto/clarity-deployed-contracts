(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u690) u10000) tx-sender 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX))
        (ok true)))