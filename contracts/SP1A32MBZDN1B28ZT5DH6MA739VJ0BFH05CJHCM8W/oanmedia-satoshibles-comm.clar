(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u400) u10000) tx-sender 'SP2P3SD0QRKMWSJTW06375CMJXW7DFANGRXKQMN7X))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX))
        (ok true)))