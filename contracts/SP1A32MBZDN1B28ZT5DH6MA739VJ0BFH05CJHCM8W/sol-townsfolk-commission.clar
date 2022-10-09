(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u300) u10000) tx-sender 'SP305TZHTGMGEDYETNBTN7XBFH11VG81XGG7R9K5C))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX))
        (ok true)))