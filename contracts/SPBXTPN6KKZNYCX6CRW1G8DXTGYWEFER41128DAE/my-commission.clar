(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SPBXTPN6KKZNYCX6CRW1G8DXTGYWEFER41128DAE))
    (ok true)))