(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u200) u10000) tx-sender 'SP1HRRWG5GHVNXR85V6SKSVR7MZQGDYT0VFQ3PA6H))
    (ok true)))