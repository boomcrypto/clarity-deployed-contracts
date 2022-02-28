(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ price u55) tx-sender 'SP305TZHTGMGEDYETNBTN7XBFH11VG81XGG7R9K5C))
        (ok true)))