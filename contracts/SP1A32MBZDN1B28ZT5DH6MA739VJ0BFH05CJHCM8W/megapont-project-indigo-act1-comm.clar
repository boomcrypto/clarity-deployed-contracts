(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u50) u10000) tx-sender 'SP1EV6DEGJYN4NC4GS94MTXKF8PAQ5ZNA4QHJ2VZ6))
        (try! (stx-transfer? (/ (* price u270) u10000) tx-sender 'SP1WPW265R43CEDYQSY1NMPE2C2EN73A7HY8PBNDM))
        (try! (stx-transfer? (/ (* price u180) u10000) tx-sender 'SP2H2ZB08EW097TPDQPDPPJ6B73YAZS4V2KNSDC04))
        (try! (stx-transfer? (/ (* price u100) u10000) tx-sender 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX))
        (ok true)))
