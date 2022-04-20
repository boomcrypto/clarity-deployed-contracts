(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SPW4Z5DWXR1N6P83ZPGG50MD27DK5P5N85KGMV1E))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
        (ok true)))