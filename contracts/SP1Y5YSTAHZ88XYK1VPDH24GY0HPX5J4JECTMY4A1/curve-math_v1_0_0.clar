;; https://curve.fi/files/stableswap-paper.pdf
;; StableSwap3Pool.vy
;;
;; Invariant
;; =========
;; A*n^n * sum(x_i) + D = A*D*n^n + D^(n+1)/(n^n * prod(x_i))
;;
;; A         = given (e.g. 85)
;; n         = 2     (pair)
;; {x_i}     = {x, y}
;; sum(x_i)  = x + y = s
;; prod(x_i) = x * y = p
;;
;; let c = 4A
;; let P = D^3/4p
;;
;; f(D)  = (c-1)D + D^3/4p - cs
;; f'(D) = (c-1)  + 3D^2/4p
;;
;; f(x) = c(x+y) + D - cD - D^3/4xy
;; f'(x) = c - D^3/4y * -1/x^2
;;
;; x_n+1 = x_n - f(x_n)/f'(x_n)
(define-constant EPSILON u2)
(define-constant n       u2)
(define-constant n1      u3)
(define-constant nn      u4)

(define-constant ITERATIONS (list
u1 u2 u3 u4 u5 u6 u7 u8 u9 u10
u11 u12 u13 u14 u15 u16 u17 u18 u19
u20 u21 u22 u23 u24 u25 u26 u27 u28 u29
u30 u31 u32 u33 u34 u35 u36 u37 u38 u39
u40 u41 u42 u43 u44 u45 u46 u47 u48 u49
u50 u51 u52 u53 u54 u55 u56 u57 u58 u59
u60 u61 u62 u63 u64 u65 u66 u67 u68 u69
u70 u71 u72 u73 u74 u75 u76 u77 u78 u79
u80 u81 u82 u83 u84 u85 u86 u87 u88 u89
u90 u91 u92 u93 u94 u95 u96 u97 u99 u99
u100
))
(define-constant NITER (len ITERATIONS))

(define-read-only (done (x0 uint) (x1 uint))
  (let ((delta (if (> x0 x1) (- x0 x1) (- x1 x0))))
    (<= delta EPSILON)))

;;======================================================================
;; (/ (* D D D) (* nn x y))
(define-read-only
  (g (D uint)
     (x uint)
     (y uint))
  (let ((a (if (> x y) x y))
        (b (if (> x y) y x))
        (z0 D)
        (z1 (/ (* z0 D) (* a n)))
        (z2 (/ (* z1 D) (* b n))))
    z2))

;; (/ (* D D D) (* nn y))
(define-read-only
 (g_ (D uint)
    (y uint))
 (let ((z0 D)
       (z1 (/ (* z0 D) y))
       (z2 (/ (* z1 D) nn))
       )
   z2))

(define-read-only (c (A uint)) (* nn A))

;;======================================================================
(define-constant err-convergence (err u844))
(define-constant err-wtf         (err u855))

(define-read-only
  (find-D
   (D uint)
   (x uint)
   (y uint)
   (A uint))
  (let ((res
         (fold find-D-step
               ITERATIONS
               {Dn: (find-D-guess D x y), D: u0, x: x, y: y, A: A, i: u0})))
    (print res)

    (if (done (get Dn res) (get D res))
        (ok (get Dn res))
        (begin
         (asserts! (is-eq (get i res) NITER) err-wtf)
         (asserts! false                     err-convergence)
         (ok u0)
         ))
    ))

(define-read-only
  (find-D-step
   (i   uint)
   (acc {Dn: uint, D: uint, x: uint, y: uint, A: uint, i: uint}))
  (if (done (get Dn acc) (get D acc))
      acc
      {Dn: (find-D-next (get Dn acc) (get x acc) (get y acc) (get A acc)),
       D : (get Dn acc),
       x : (get x acc),
       y : (get y acc),
       A : (get A acc),
       i : i}))

(define-read-only (find-D-guess (D uint) (x uint) (y uint))
  (if (is-eq D u0) (+ x y) D))

;; f(D) step:
;;
;; num = (c-1)D + P - cs
;; den = (c-1) + (P*(n+1)/D)
;;
;; D - num/den = D*(den/den) - num/den
;; (c-1)D + (n+1)P - (c-1)D - P + cs = nP + cs
;;
;; den: ( (c-1)*D + (P*(n+1)) ) / D
;;
;; (nP + cs) * D  /  (c-1)D + (n+1)P
(define-read-only
 (find-D-next
  (D uint)
  (x uint)
  (y uint)
  (A uint))
 (let ((P   (g D x y))
       (num (* (+ (* n P)
                  (* (c A) (+ x y)))
               D))
       (den (+ (* (- (c A) u1) D)
               (* (+ n u1) P)))
       )
   (/ num den)
   ))

;;======================================================================
(define-read-only
  (find-x
   (x uint)
   (y uint)
   (D uint)
   (A uint))
  (let ((res
         (fold find-x-step
               ITERATIONS
               {xn: (find-x-guess x y D), x: u0, y: y, D: D, A: A, i: u0})))
    (print res)

    (if (done (get xn res) (get x res))
        (ok (get xn res))
        (begin
         (asserts! (is-eq (get i res) NITER) err-wtf)
         (asserts! false                     err-convergence)
         (ok u0)
         ))
    ))

(define-read-only
  (find-x-step
   (i   uint)
   (acc {xn: uint, x: uint, y: uint, D: uint, A: uint, i: uint}))
  (if (done (get xn acc) (get x acc))
      acc
      {xn: (find-x-next (get xn acc) (get y acc) (get D acc) (get A acc)),
       x : (get xn acc),
       y : (get y acc),
       D : (get D acc),
       A : (get A acc),
       i : i}))

(define-read-only (find-x-guess (x uint) (y uint) (D uint)) (+ x y)) ;;x ?

;; f(x) step:
;;
;; (multiply both sides by x)
;;
;; let P' = D^3/4y
;;
;; f(x)  = cxx + cyx - (c-1)Dx - P'
;; f'(x) = 2cx + cy  - (c-1)D
;;
;; multiply x by den/den:
;;
;; num = 2cxx + cyx - (c-1)Dx - cxx - cyx + (c-1)Dx + P' = cxx + P' (DDD/4y)
;; den                                                   = 2cx + cy - (c-1)D
;;
(define-read-only
 (find-x-next
  (x uint)
  (y uint)
  (D uint)
  (A uint))
 (let ((P_  (g_ D y))
       (c_  (c A))
       (t0  (* c_ x x))
       (t1  (* u2 c_ x))
       (t2  (* c_ y))
       (t3  (* (- c_ u1) D))
       (num (+ t0 P_))
       (den (- (+ t1 t2) t3))
       )
   (/ num den)
   ))

;;======================================================================
(define-constant err-dx   (err u800))
(define-constant err-mint (err u801))

(define-read-only
  (find-dx
   (x  uint)
   (y  uint)
   (dy uint)
   (D  uint)
   (A  uint))
  (let ((y_ (+ y dy))
        (D_ (try! (find-D D x y A)))
        (x_ (try! (find-x x y_ D_ A)))
        )
    (asserts! (< x_ x) err-dx)
    (ok (- x x_))))

;;======================================================================
(define-read-only
  (mint
   (x  uint)
   (dx uint)
   (y  uint)
   (dy uint)
   (u  uint) ;; total supply
   (A  uint)
   )
  (let ((x_ (+ x dx))
        (y_ (+ y dy))
        (D0 (try! (find-D u0 x y A)))
        (D1 (try! (find-D u0 x_ y_ A)))
        )
    (asserts! (> D1 D0) err-mint)
    (ok
     (if (is-eq u u0)
         D1 ;; initial liquidity
         (/ (* u (- D1 D0)) D0)) )
    ))

(define-read-only
  (burn
   (x uint)
   (y uint)
   (u uint) ;; total supply
   (v uint) ;; liquidity
   )
  {dx: (/ (* x v) u),
   dy: (/ (* y v) u)
  })

;;; eof
