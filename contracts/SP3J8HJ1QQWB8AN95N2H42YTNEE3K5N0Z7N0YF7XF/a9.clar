(define-constant OWNER tx-sender)

(define-constant ERR_O (err u1000))
(define-constant ERR_L (err u1001))
(define-constant ERR_Q (err u1002))
(define-constant ERR_F (err u1003))
(define-constant ERR_S (err u1004))
(define-constant ERR_X (err u1005))

(define-constant ERR_ALEX_A (err u2100))
(define-constant ERR_ALEX_B (err u2101))

(define-constant T_STX  "a")
(define-constant T_XUSD "b")
(define-constant T_XBTC "c")

(define-private (wstx-xusd-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
u50000000 u50000000 (* dx u100) none))))
(ok (get dy r))))

(define-private (xusd-wstx-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wxusd
u50000000 u50000000 dx none))))
(ok (/ (get dx r) u100))))

(define-private (wstx-xbtc-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-x-for-y
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
u50000000 u50000000 (* dx u100) none))))
(ok (get dy r))))

(define-private (xbtc-wstx-a (dx uint))
(let ((r (try! (contract-call?
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01 swap-y-for-x
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc
u50000000 u50000000 dx none))))
(ok (/ (get dx r) u100))))

(define-public (swap-alex
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq a T_STX)
    (if (is-eq b T_XUSD) (wstx-xusd-a x)
    (if (is-eq b T_XBTC) (wstx-xbtc-a x)
    ERR_ALEX_B))
  (if (is-eq a T_XUSD)
    (if (is-eq b T_STX)  (xusd-wstx-a x)
    ERR_ALEX_B)
  (if (is-eq a T_XBTC)
    (if (is-eq b T_STX) (xbtc-wstx-a x)
    ERR_ALEX_B)
  ERR_ALEX_A)))
)

(define-public (swap
  (s (string-ascii 1))
  (a (string-ascii 1))
  (b (string-ascii 1))
  (x uint)
)
  (if (is-eq s "a") (swap-alex a b x)
  ERR_S
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
      (f (unwrap! (element-at q u0) ERR_Q))
      (l (unwrap! (element-at q (- (len q) u1)) ERR_Q))
      (a (unwrap! (element-at f u1) ERR_Q))
      (b (unwrap! (element-at l u2) ERR_Q))
    )
    (asserts! (is-eq tx-sender OWNER) ERR_O)
    (let
      (
        (vals (fold t q (list (ok x))))
        (last (unwrap! (element-at vals (- (len vals) u1)) ERR_F)) 
      )
      (match last
        y (begin
            ;;(asserts! (>= y Y) (err y))
            (ok (fold t2 vals (list)))
          )
        y (err y)
      )
    )
  )
)