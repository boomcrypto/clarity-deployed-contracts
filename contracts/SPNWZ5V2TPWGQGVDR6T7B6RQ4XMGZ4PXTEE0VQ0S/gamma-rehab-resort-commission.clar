(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
        (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SP2SE1WTDPJEJ417SJEJPG31QBP1W3SD9CGB4759A))
        (ok true)
    )
)