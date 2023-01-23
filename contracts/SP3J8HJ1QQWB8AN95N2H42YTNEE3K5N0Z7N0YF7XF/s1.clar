(impl-trait .s-trait.s-trait)

(use-trait token-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

(define-constant err-tok u2000)

(define-read-only (scale (val uint) (mul uint) (div uint))
  (/ (* val (pow u10 mul)) (pow u10 div))
)

(define-private (ex
  (a <token-trait>)
  (b <token-trait>)
  (x uint)
  (b-div uint)
  (b-mul uint)
)
  (let
    (
      (y (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper a b x none)))
    )
    (ok (scale y b-mul b-div))
  )
)

(define-private (ex-b
  (a <token-trait>)
  (b uint)
  (x uint)
)
  (if (is-eq b u1)  (ex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx  x u8 u6)
  (if (is-eq b u2)  (ex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd x u8 u8)
  (if (is-eq b u3)  (ex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc  x u8 u8)
  (if (is-eq b u4)  (ex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token x u8 u8)
  (if (is-eq b u5)  (ex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko x u8 u6)
  (if (is-eq b u6)  (ex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda x u8 u6)
  (if (is-eq b u9)  (ex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia  x u8 u6)
  (if (is-eq b u10) (ex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc x u8 u6)
  (err err-tok)
  ))))))))
)

(define-public (z
  (a uint)
  (b uint)
  (x uint)
)
  (if (is-eq a u1)  (ex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx  b (scale x u8 u6))
  (if (is-eq a u2)  (ex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd b (scale x u8 u8))
  (if (is-eq a u3)  (ex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc  b (scale x u8 u8))
  (if (is-eq a u4)  (ex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token b (scale x u8 u8))
  (if (is-eq a u5)  (ex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko b (scale x u8 u6))
  (if (is-eq a u6)  (ex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda b (scale x u8 u6))
  (if (is-eq a u9)  (ex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia  b (scale x u8 u6))
  (if (is-eq a u10) (ex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc b (scale x u8 u6))
  (err err-tok)
  ))))))))
)