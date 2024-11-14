(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ price u40) tx-sender 'SP2DH26XMQ9N1BH48MBPDBE2JM9EFGYMCZY0C903M))
        (ok true)))
