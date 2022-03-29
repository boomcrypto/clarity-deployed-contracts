(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u400) u10000) tx-sender 'SP229FR0MTFR0PX83YS9P5KEHAFPPKTXPG04RKP7T))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
        (ok true)))