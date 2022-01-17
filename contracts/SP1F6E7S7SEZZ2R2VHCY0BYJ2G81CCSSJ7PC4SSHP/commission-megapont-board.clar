(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u35) u1000) tx-sender 'SPGAKH27HF1T170QET72C727873H911BKNMPF8YB))
        (try! (stx-transfer? (/ (* price u5) u1000) tx-sender 'SP39E0V32MC31C5XMZEN1TQ3B0PW2RQSJB8TKQEV9))
        (try! (stx-transfer? (/ (* price u5) u1000) tx-sender 'SP1C39PEYB976REP9B19QMFDJHHF27A63WANDGTX4))
        (try! (stx-transfer? (/ (* price u5) u1000) tx-sender 'SP11QRBEVACSP2MAYB1FE64PZGXXRWE4R3HY5E68H))
        (ok true)
    )
)
