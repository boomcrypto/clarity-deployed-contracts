(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ price u100) tx-sender 'SP39E0V32MC31C5XMZEN1TQ3B0PW2RQSJB8TKQEV9))
        (try! (stx-transfer? (/ price u100) tx-sender 'SP39E0V32MC31C5XMZEN1TQ3B0PW2RQSJB8TKQEV9))
        (try! (stx-transfer? (/ price u100) tx-sender 'SP39E0V32MC31C5XMZEN1TQ3B0PW2RQSJB8TKQEV9))
        (try! (stx-transfer? (/ price u100) tx-sender 'SP39E0V32MC31C5XMZEN1TQ3B0PW2RQSJB8TKQEV9))
        (ok true)))
