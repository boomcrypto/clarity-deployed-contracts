(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SP3EB7YHV5NERS2HMCGSGKNMN0BEH52W9H7YE4T9C))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX))
        (ok true)))