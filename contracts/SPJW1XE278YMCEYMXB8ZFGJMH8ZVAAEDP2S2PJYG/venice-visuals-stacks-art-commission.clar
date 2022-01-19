(impl-trait .commission-trait.commission)

(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u50) u1000) tx-sender 'SP1NYHBF7GNF9CE7P5KB27VZTHK3V8XANTMXNHD2))
    (try! (stx-transfer? (/ (* price u25) u1000) tx-sender 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG))
    (ok true)
  )
)
