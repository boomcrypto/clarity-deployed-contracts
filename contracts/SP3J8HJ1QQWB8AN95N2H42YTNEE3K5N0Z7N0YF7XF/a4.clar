(define-constant ERR_O u1000)
(define-constant ERR_L u1001)
(define-constant ERR_Q u1002)
(define-constant ERR_F u1003)
(define-constant ERR_R u1004)
(define-constant ERR_W u1005)

(define-constant A2N "#abcdefghijkl")

(define-constant OWNER tx-sender)

(define-private (w
  (a (string-ascii 1))
  (amt uint)
  (src principal)
  (dst principal)
)
  (if (is-eq a "a") (stx-transfer? amt src dst)
  (err ERR_W)
  )
)

(define-private (r (s uint) (a uint) (b uint) (x uint))
  (if (is-eq s u1) (contract-call? .s1 z a b x)
  (if (is-eq s u2) (contract-call? .s2 z a b x)
  (if (is-eq s u3) (contract-call? .s3 z a b x)
  (err ERR_R)
  )))
)

(define-private (t2
  (q (response uint uint))
  (v (list 21 uint))
)
  (unwrap-panic (as-max-len? (append v (unwrap-panic q)) u21))
)

(define-private (t
  (q (string-ascii 3))
  (v (list 21 (response uint uint)))
)
  (match (unwrap-panic (element-at v (- (len v) u1)))
    x (let
        (
          (s (unwrap-panic (index-of A2N (unwrap-panic (element-at q u0)))))
          (a (unwrap-panic (index-of A2N (unwrap-panic (element-at q u1)))))
          (b (unwrap-panic (index-of A2N (unwrap-panic (element-at q u2)))))
          (y (r s a b x))
          ;;(y (ok (+ x u1)))
        )
        (unwrap-panic (as-max-len? (append v y) u21))
      )
    x (unwrap-panic (as-max-len? (append v (err x)) u21))
  )
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
;;    (try! (w a x tx-sender (as-contract tx-sender)))
;;    (as-contract
      (let
        (
          (v (fold t q (list (ok x))))
          (resp (unwrap! (element-at v (- (len v) u1)) (err ERR_F)))
        )
        (match resp
          y (begin
              (asserts! (>= y Y) (err ERR_L))
;;              (try! (w b y tx-sender sender))
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