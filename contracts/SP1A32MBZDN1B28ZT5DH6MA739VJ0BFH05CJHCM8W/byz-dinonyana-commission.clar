(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
        (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SPPCHF5474M4X5ZS79TCKSNRKJ24Y71J77ZKTAP3))

        (ok true)))