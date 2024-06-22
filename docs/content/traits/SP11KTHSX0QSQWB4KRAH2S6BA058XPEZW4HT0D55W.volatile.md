---
title: "Trait volatile"
draft: true
---
```
(impl-trait .traits.pair-logic-trait)

(define-public (swap-given-in 
        (token-in principal)
        (token-out principal)
        (reserve-in uint)
        (reserve-out uint)
        (amount-in uint))
    (ok (/ (* (to-virtual-reserve reserve-out) amount-in) (+ (to-virtual-reserve reserve-in) amount-in))))

(define-public (swap-given-out
        (token-in principal)
        (token-out principal)
        (reserve-in uint)
        (reserve-out uint)
        (amount-out uint))
    (ok (div-ceil (* (to-virtual-reserve reserve-in) amount-out) (+ (to-virtual-reserve reserve-out) amount-out))))

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
       (invariant-before (geomean-max reserve0-virtual reserve1-virtual))
       (invariant-after (geomean-min (+ reserve0-virtual amount0) (+ reserve1-virtual amount1))))
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

(define-private (geomean-min (r0 uint) (r1 uint))
  (sqrti (* r0 r1)))

(define-private (geomean-max (r0 uint) (r1 uint))
  (let ((gm (sqrti (* r0 r1)))) (if (< (* gm gm) (* r0 r1)) (+ gm u1) gm)))

(define-private (div-ceil (a uint) (b uint))
  (if (is-eq a u0) u0 (+ (/ (- a u1) b) u1)))

(define-private (to-virtual-reserve (r uint)) (+ u1 r))
(define-private (to-virtual-lp-supply (r uint)) (+ u1 r))




```
