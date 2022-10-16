(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX))
        (ok true)))

