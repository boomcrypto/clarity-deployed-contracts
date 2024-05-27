(impl-trait .traits.pair-logic-trait)

(define-public (swap-given-in 
        (token-in principal)
        (token-out principal)
        (reserve-in uint)
        (reserve-out uint)
        (amount-in uint))
    (let
      ((reserve-in-virtual (to-virtual-reserve reserve-in))
       (reserve-out-virtual (to-virtual-reserve reserve-out))
       (d (try! (invariant-max reserve-in-virtual reserve-out-virtual)))
       (y (try! (get-y d (+ reserve-in-virtual amount-in)))))
      (ok (- reserve-out-virtual y))))

(define-public (swap-given-out
        (token-in principal)
        (token-out principal)
        (reserve-in uint)
        (reserve-out uint)
        (amount-out uint))
    (let
      ((reserve-in-virtual (to-virtual-reserve reserve-in))
       (reserve-out-virtual (to-virtual-reserve reserve-out))
       (d (try! (invariant-max reserve-in-virtual reserve-out-virtual)))
       (y (try! (get-y d (- reserve-out-virtual amount-out)))))
      (ok (- y reserve-in-virtual))))

(define-public (join
        (token0 principal)
        (token1 principal)
        (reserve0 uint)
        (reserve1 uint)
        (lp-supply uint)
        (amount0 uint)
        (amount1 uint))
    (let
      ((reserve0-virtual (to-virtual-reserve reserve0))
       (reserve1-virtual (to-virtual-reserve reserve1))
       (lp-supply-virtual (to-virtual-lp-supply lp-supply))
       (invariant-before (try! (invariant-max reserve0-virtual reserve1-virtual)))
       (invariant-after (try! (invariant-min (+ reserve0-virtual amount0) (+ reserve1-virtual amount1)))))
      (ok (if (>= invariant-before invariant-after)
              u0
              (/ (* lp-supply-virtual (- invariant-after invariant-before)) invariant-before)))))

(define-public (exit
        (token0 principal)
        (token1 principal)
        (reserve0 uint)
        (reserve1 uint)
        (lp-supply uint)
        (amount-lp uint))
    (let
      ((reserve0-virtual (to-virtual-reserve reserve0))
       (reserve1-virtual (to-virtual-reserve reserve1))
       (lp-supply-virtual (to-virtual-lp-supply lp-supply)))
      (ok {
          amount0: (/ (* amount-lp reserve0-virtual) lp-supply-virtual),
          amount1: (/ (* amount-lp reserve1-virtual) lp-supply-virtual),
      })))

(define-constant AMP 2000)
(define-constant err-diverged (err u123598234))

(define-private (invariant-min (r0 uint) (r1 uint))
  (invariant true (to-int r0) (to-int r1)))

(define-private (invariant-max (r0 uint) (r1 uint))
  (invariant false (to-int r0) (to-int r1)))

(define-private (div-ceil (a uint) (b uint))
  (if (is-eq a u0) u0 (+ (/ (- a u1) b) u1)))

(define-private (to-virtual-reserve (r uint)) (+ u1 r))
(define-private (to-virtual-lp-supply (r uint)) (+ u2 r))

(define-constant two_a_minus_1 3999)

(define-private (min (a int) (b int))
  (if (< a b) a b)) 

(define-private (max (a int) (b int))
  (if (> a b) a b)) 

(define-private (inv-step-1 (m bool) (a int) (b int) (two-as int) (d int))
  (let
      ((tmp (/ (* d (/ (* d d) a)) b 4))
      (d-next (/  (* d (+ two-as (* 2 tmp))) (+ (* d two_a_minus_1) (* 3 tmp))))
      (e (- d d-next)))
    (if (< (* e e) 4) (err (to-uint (if m (min d d-next) (max d d-next)))) (ok d-next))))



(define-private (inv-step-2 (m bool) (a int) (b int) (two-as int) (d0 int))
  (let
    ((d1 (try! (inv-step-1 m a b two-as d0)))
     (d2 (try! (inv-step-1 m a b two-as d1)))
     (d3 (try! (inv-step-1 m a b two-as d2)))
     (d4 (try! (inv-step-1 m a b two-as d3)))
     (d5 (try! (inv-step-1 m a b two-as d4)))
     (d6 (try! (inv-step-1 m a b two-as d5))))
    (inv-step-1 m a b two-as d6)))

(define-private (inv-step-3 (m bool) (a int) (b int) (two-as int) (d0 int))
  (let
    ((d1 (try! (inv-step-2 m a b two-as d0)))
     (d2 (try! (inv-step-2 m a b two-as d1)))
     (d3 (try! (inv-step-2 m a b two-as d2)))
     (d4 (try! (inv-step-2 m a b two-as d3)))
     (d5 (try! (inv-step-2 m a b two-as d4)))
     (d6 (try! (inv-step-2 m a b two-as d5))))
    (inv-step-2 m a b two-as d6)))

(define-private (inv-step-4 (m bool) (a int) (b int) (two-as int) (d0 int))
  (let
    ((d1 (try! (inv-step-3 m a b two-as d0)))
     (d2 (try! (inv-step-3 m a b two-as d1)))
     (d3 (try! (inv-step-3 m a b two-as d2)))
     (d4 (try! (inv-step-3 m a b two-as d3)))
     (d5 (try! (inv-step-3 m a b two-as d4)))
     (d6 (try! (inv-step-3 m a b two-as d5))))
    (inv-step-3 m a b two-as d6)))

(define-read-only (invariant (m bool) (a int) (b int))
  (match (inv-step-4 m a b (* 4000 (+ a b)) (+ a b))
         unused err-diverged
         d (ok d)))

(define-private (y-step-1 (d int) (c int) (b int) (y int))
  (let
    ((y-next (/ (+ (* y y) c) (+ y y b)))
     (e (- y y-next)))
    (if (< (* e e) 4) (err (+ u1 (to-uint (max y y-next)))) (ok y-next))))

(define-private (y-step-2 (d int) (c int) (b int) (y0 int))
  (let
    ((y1 (try! (y-step-1 d c b y0)))
     (y2 (try! (y-step-1 d c b y1)))
     (y3 (try! (y-step-1 d c b y2)))
     (y4 (try! (y-step-1 d c b y3)))
     (y5 (try! (y-step-1 d c b y4)))
     (y6 (try! (y-step-1 d c b y5))))
    (y-step-1 d c b y6)))

(define-private (y-step-3 (d int) (c int) (b int) (y0 int))
  (let
    ((y1 (try! (y-step-2 d c b y0)))
     (y2 (try! (y-step-2 d c b y1)))
     (y3 (try! (y-step-2 d c b y2)))
     (y4 (try! (y-step-2 d c b y3)))
     (y5 (try! (y-step-2 d c b y4)))
     (y6 (try! (y-step-2 d c b y5))))
    (y-step-2 d c b y6)))

(define-private (y-step-4 (d int) (c int) (b int) (y0 int))
  (let
    ((y1 (try! (y-step-3 d c b y0)))
     (y2 (try! (y-step-3 d c b y1)))
     (y3 (try! (y-step-3 d c b y2)))
     (y4 (try! (y-step-3 d c b y3)))
     (y5 (try! (y-step-3 d c b y4)))
     (y6 (try! (y-step-3 d c b y5))))
    (y-step-3 d c b y6)))

(define-read-only (get-y (d uint) (x uint))
  (let ((d- (to-int d)) (x- (to-int x)))
    (match (y-step-4 d- (/ (* (/ (* d- d-) x-) d-) AMP 8) (- (+ x- (/ d- 2 AMP)) d-) (/ d- 2))
           unused err-diverged
           y (ok y))))

