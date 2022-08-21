(impl-trait 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.commission-trait.commission)

(define-constant COMM-ADDRESS 'SP8F65F85PMRZK043DTME3E1TQ4EM5R3VS8TSJC7)

(define-public (pay (id uint) (price-in-ustx uint))
  (let ((fee (/ (* price-in-ustx u2) u100)))
    (try! (stx-transfer? fee tx-sender COMM-ADDRESS))
    (ok true)
  )
)
