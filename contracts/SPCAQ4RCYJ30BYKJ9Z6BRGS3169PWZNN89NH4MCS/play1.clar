(use-trait token-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-trait target-trait (
  (swap-x-for-y (<token-trait> <token-trait> uint uint) (response (list 2 uint) uint))
  (swap-y-for-x (<token-trait> <token-trait> uint uint) (response (list 2 uint) uint))
))

(define-public (play (in uint) (target <target-trait>) 
    (xy1 bool) (x1 <token-trait>) (y1 <token-trait>)
    (xy2 bool) (x2 <token-trait>) (y2 <token-trait>)
    (xy3 bool) (x3 <token-trait>) (y3 <token-trait>)
  )
  (let
    (
      (a (play-priv target xy1 x1 y1 in))
      (b (play-priv target xy2 x2 y2 a))
      (c (play-priv target xy3 x3 y3 b))  
    )
    (asserts! (> c in) (err u420))
    (ok true)
  )
)

(define-private (play-priv (target <target-trait>) (xy bool) (t1 <token-trait>) (t2 <token-trait>) (amount uint))
  (if xy
    (unwrap-panic (element-at (unwrap-panic (contract-call? target swap-x-for-y t1 t2 amount u0)) u1))
    (unwrap-panic (element-at (unwrap-panic (contract-call? target swap-y-for-x t1 t2 amount u0)) u0))
  )
)