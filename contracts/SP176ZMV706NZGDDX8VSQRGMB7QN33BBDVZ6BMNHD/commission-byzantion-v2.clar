(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u370) u10000) tx-sender 'SP1WPW265R43CEDYQSY1NMPE2C2EN73A7HY8PBNDM))
        (try! (stx-transfer? (/ (* price u120) u10000) tx-sender 'SP2S1JA1G39BAS9C6W48P7TX01ABJCDJ8ETR32T4J))
        (try! (stx-transfer? (/ (* price u10) u10000) tx-sender 'SP1YSV2B1B78EJQTZN8YBXZZEK70Z0PNMBT6XWKFH))
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
        (ok true)))