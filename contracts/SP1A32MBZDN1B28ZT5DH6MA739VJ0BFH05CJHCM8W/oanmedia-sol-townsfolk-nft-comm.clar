(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u300) u10000) tx-sender 'SP305TZHTGMGEDYETNBTN7XBFH11VG81XGG7R9K5C))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX))
        (ok true)))