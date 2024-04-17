(define-public (pay (id uint) (price uint)) 
    (begin 
        ;; PP (3%)
        (try! (stx-transfer? (/ (* price u300) u10000) tx-sender 'SP14ZJHGEVVSYWX3MNSREFD4S9RCX8VF338SEHXMF))

        ;; Tope (3%)
        (try! (stx-transfer? (/ (* price u300) u10000) tx-sender 'SP7VK7V27R0H2C7WRR378457WX8VX1Q32RCZRV6H))

        ;; IceArc & Brick (3%)
        (try! (stx-transfer? (/ (* price u300) u10000) tx-sender 'SP1MY9XZK0JQW3R09RKSW3GRFT56JS8V42N4RD781))

        ;; BM Team (1%)
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP1ECNM1B4J935RYX0VRXYKZFKFSEPY8REPQHAF8K))

        ;; Gamma
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S))

        (ok true)
    )
)