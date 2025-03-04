
(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u500) u10000) tx-sender 'SM18RN48GX7E3ED23M03BY4QD8EA2DG2R4VX4CDYJ))
    (ok true)))