(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u315) u10000) tx-sender 'SP1WPW265R43CEDYQSY1NMPE2C2EN73A7HY8PBNDM))
        (try! (stx-transfer? (/ (* price u135) u10000) tx-sender 'SP2S1JA1G39BAS9C6W48P7TX01ABJCDJ8ETR32T4J))
        (try! (stx-transfer? (/ (* price u50) u10000) tx-sender 'SP2WB83VDSPMVK2J1PKZHDQK4XJMS68962STTK5K3))
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
        (ok true)))