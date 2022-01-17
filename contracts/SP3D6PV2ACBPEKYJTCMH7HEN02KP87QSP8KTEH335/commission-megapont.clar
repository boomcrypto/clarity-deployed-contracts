(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ price u100) tx-sender 'SP39E0V32MC31C5XMZEN1TQ3B0PW2RQSJB8TKQEV9))
        (try! (stx-transfer? (/ price u100) tx-sender 'SP11QRBEVACSP2MAYB1FE64PZGXXRWE4R3HY5E68H))
        (try! (stx-transfer? (/ price u100) tx-sender 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C))
        (try! (stx-transfer? (/ price u50) tx-sender 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4))
        (ok true)))
