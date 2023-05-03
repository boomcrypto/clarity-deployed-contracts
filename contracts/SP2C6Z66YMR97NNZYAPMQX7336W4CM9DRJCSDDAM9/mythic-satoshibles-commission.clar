(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u400) u10000) tx-sender 'SP2P3SD0QRKMWSJTW06375CMJXW7DFANGRXKQMN7X))
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP2C6Z66YMR97NNZYAPMQX7336W4CM9DRJCSDDAM9))
        (ok true)))
