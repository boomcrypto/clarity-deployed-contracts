(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u10) u100) tx-sender 'SP18C0G0DPCPRAP24N5SP3952KBZ2RE6KXT99XERV))
        (ok true)))