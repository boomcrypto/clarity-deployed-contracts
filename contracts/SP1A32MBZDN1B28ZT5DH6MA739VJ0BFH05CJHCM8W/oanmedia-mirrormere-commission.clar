(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u750) u10000) tx-sender 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX))
        (ok true)))