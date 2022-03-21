(impl-trait .commission-trait.commission)

(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u69) u1000) tx-sender 'SP2N3BAG4GBF8NHRPH6AY4YYH1SP6NK5TGCY7RDFA))
    (try! (stx-transfer? (/ (* price u25) u1000) tx-sender 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG))
    (ok true)
  )
)
