(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SP22GDAFDYGH1C23RSAH2KTJFS5THE0SF1D9RK1B1))
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP1GPNZB0JSC9RXJTXVBAMSPQE29WM1SE8V39R6K2))
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S))
        (ok true)))