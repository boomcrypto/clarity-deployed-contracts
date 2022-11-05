(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u400) u10000) tx-sender 'SP5T742YTQR68RNMBB4QRWRWD9SR01C6E1WNJ06T))
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SPEJ66Q0Q6JRY9YB4GBKPB6FXT8W4N7R1Q5SPTPS))
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2F0M4PGG50F7H6NN6WK15HJCCWW1ZQBBRFHXEPH))
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S))
        (ok true)))