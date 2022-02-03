(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u5) u100) tx-sender 'SP1WJY09D3DEE45B1PY8TAV838VCH9HNEJW0QPFND))
        (try! (stx-transfer? (/ (* price u5) u100) tx-sender 'SP2BSD6FH7B641G5QC95M5V3ACB76CDE125FF2CD2))
        (ok true)
    )
)
