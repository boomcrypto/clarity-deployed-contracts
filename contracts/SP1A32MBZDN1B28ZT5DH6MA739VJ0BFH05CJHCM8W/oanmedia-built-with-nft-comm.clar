(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SP1N134B2Z1PZQVNBYVKMGND5H5PHY3ZH6EK8TASP))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX))
        (ok true)))
