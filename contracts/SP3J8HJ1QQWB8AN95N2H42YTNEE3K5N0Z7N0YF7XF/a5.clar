(use-trait token-alex 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

(define-constant OWNER tx-sender)

(define-constant ERR_O u1000)
(define-constant ERR_L u1001)
(define-constant ERR_Q u1002)
(define-constant ERR_F u1003)
(define-constant ERR_S u1004)
(define-constant ERR_X u1005)

(define-constant ERR_ALEX_A u2100)
(define-constant ERR_ALEX_B u2101)

(define-constant T_STX  "a")
(define-constant T_XUSD "b")
(define-constant T_XBTC "c")
(define-constant T_ALEX "d")
(define-constant T_DIKO "e")
(define-constant T_USDA "f")
(define-constant T_STSW "g")
(define-constant T_LBTC "h")
(define-constant T_MIA2 "i")
(define-constant T_NYC2 "j")
(define-constant T_MIA1 "k")
(define-constant T_NYC1 "l")

(define-private (xfer
  (a (string-ascii 1))
  (amt uint)
  (src principal)
  (dst principal)
)
  (if (is-eq a T_STX) (stx-transfer? amt src dst)
  (err ERR_X)
  )
)

(define-public (swap
  (s (string-ascii 1))
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq s "a") (swap-alex a b x)
  (err ERR_S)
  )
)

(define-private (t
  (q (string-ascii 3))
  (v (list 21 (response uint uint)))
)
  (match (unwrap-panic (element-at v (- (len v) u1)))
    x (let
        (
          (s (unwrap-panic (element-at q u0)))
          (a (unwrap-panic (element-at q u1)))
          (b (unwrap-panic (element-at q u2)))
          (y (swap s a b x))
        )
        (unwrap-panic (as-max-len? (append v y) u21))
      )
    x (unwrap-panic (as-max-len? (append v (err x)) u21))
  )
)

(define-private (t2
  (q (response uint uint))
  (v (list 21 uint))
)
  (unwrap-panic (as-max-len? (append v (unwrap-panic q)) u21))
)

(define-public (Z
  (q (list 20 (string-ascii 3)))
  (x uint)
  (Y uint)
)
  (let
    (
      (sender tx-sender)
      (f (unwrap! (element-at q u0) (err ERR_Q)))
      (l (unwrap! (element-at q (- (len q) u1)) (err ERR_Q)))
      (a (unwrap! (element-at f u1) (err ERR_Q)))
      (b (unwrap! (element-at l u2) (err ERR_Q)))
    )
    (asserts! (is-eq tx-sender OWNER) (err ERR_O))
;;    (try! (xfer a x tx-sender (as-contract tx-sender)))
;;    (as-contract
      (let
        (
          (v (fold t q (list (ok x))))
          (resp (unwrap! (element-at v (- (len v) u1)) (err ERR_F)))
        )
        (match resp
          y (begin
              (asserts! (>= y Y) (err ERR_L))
;;              (try! (xfer b y tx-sender sender))
              (ok (fold t2 v (list)))
            )
          y (err y)
        )
      )
;;    )
  )
)

(define-public (z
  (q (list 20 (string-ascii 3)))
  (x uint)
)
  (Z q x (+ x u1))
)

(define-private (scale (val uint) (mul uint) (div uint))
  (/ (* val (pow u10 mul)) (pow u10 div))
)

(define-public (ex-alex
  (a <token-alex>)
  (b <token-alex>)
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

(define-public (ex-alex-b
  (a <token-alex>)
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq b T_STX)  (ex-alex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx  x u8 u6)
  (if (is-eq b T_XUSD) (ex-alex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd x u8 u8)
  (if (is-eq b T_XBTC) (ex-alex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc  x u8 u8)
  (if (is-eq b T_ALEX) (ex-alex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token x u8 u8)
  (if (is-eq b T_DIKO) (ex-alex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko x u8 u6)
  (if (is-eq b T_USDA) (ex-alex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda x u8 u6)
  (if (is-eq b T_MIA2) (ex-alex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia  x u8 u6)
  (if (is-eq b T_NYC2) (ex-alex a 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc x u8 u6)
  (err ERR_ALEX_B)
  ))))))))
)

(define-public (swap-alex
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq a T_STX)  (ex-alex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx  b (scale x u8 u6))
  (if (is-eq a T_XUSD) (ex-alex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd b (scale x u8 u8))
  (if (is-eq a T_XBTC) (ex-alex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc  b (scale x u8 u8))
  (if (is-eq a T_ALEX) (ex-alex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token b (scale x u8 u8))
  (if (is-eq a T_DIKO) (ex-alex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wdiko b (scale x u8 u6))
  (if (is-eq a T_USDA) (ex-alex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda b (scale x u8 u6))
  (if (is-eq a T_MIA2) (ex-alex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia  b (scale x u8 u6))
  (if (is-eq a T_NYC2) (ex-alex-b 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc b (scale x u8 u6))
  (err ERR_ALEX_A)
  ))))))))
)