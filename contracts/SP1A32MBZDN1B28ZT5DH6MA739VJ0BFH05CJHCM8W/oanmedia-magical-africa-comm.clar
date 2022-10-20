(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SP2TKGQ8V47CKXN3P2AZBT0K93FMD69KJTPW4B54K))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP1GR33848GSTMFR955Z77DAB835XYE9FZG19Y7NX))
        (ok true)))


