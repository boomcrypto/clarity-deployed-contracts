(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u300) u10000) tx-sender 'SP305TZHTGMGEDYETNBTN7XBFH11VG81XGG7R9K5C))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
        (ok true)))