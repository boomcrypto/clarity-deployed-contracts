(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP21C4YMBBN87AWZVRRC1G2VRM5J3PXKHZ4N4XDR4))
        (try! (stx-transfer? (/ (* price u300) u10000) tx-sender 'SP3J05S9NZBXTEA6F5R398TV6ZE104QSV39DFYWKE))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX))
        (ok true)))