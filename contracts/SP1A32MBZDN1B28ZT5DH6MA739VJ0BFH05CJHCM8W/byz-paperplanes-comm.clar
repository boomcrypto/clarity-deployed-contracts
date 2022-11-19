(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP1KMJR4X9BHS7830AA64316SGKZGQY354JRP2TQ7))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP28KZ784B7AA6FGANSCPHV9V5CW4J43XT79DFKHG))


        (ok true)))
