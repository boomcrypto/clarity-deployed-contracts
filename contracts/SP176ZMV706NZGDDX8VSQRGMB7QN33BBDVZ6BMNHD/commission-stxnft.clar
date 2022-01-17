(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u375) u10000) tx-sender 'SP18J677R5GRD7EKK0S096WVQW19SDPWTC0TCBTGV))
        (try! (stx-transfer? (/ (* price u125) u10000) tx-sender 'SP2S1JA1G39BAS9C6W48P7TX01ABJCDJ8ETR32T4J))
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S))
        (ok true)))