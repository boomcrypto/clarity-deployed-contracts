(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SP23S6MAB11EVBRE04SFBF53ZV39S757PJY53VN53))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
        (ok true)))