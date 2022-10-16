(define-public (pay (id uint) (price uint))
    (begin
        (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SP1N134B2Z1PZQVNBYVKMGND5H5PHY3ZH6EK8TASP))
        (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX))
        (ok true)))
