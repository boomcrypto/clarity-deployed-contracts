(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP1ARERX87QP739CYWCKRV6KV5MK3YTK5XFB48AMB))
        (ok true)))