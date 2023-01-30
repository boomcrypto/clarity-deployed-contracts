(define-constant OWNER tx-sender)

(define-constant ERR_S (err u1004))

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