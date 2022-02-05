(define-public (pay (id uint) (price uint))
  (begin
    (try! (stx-transfer? (/ (* price u400) u10000) tx-sender 'SP2P3SD0QRKMWSJTW06375CMJXW7DFANGRXKQMN7X))
    (try! (stx-transfer? (/ (* price u250) u10000) tx-sender 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG))
    (ok true)
  )
)
