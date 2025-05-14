---
title: "Trait swap-math"
draft: true
---
```

    (define-read-only (div-ceil (x uint) (y uint))
      (if (is-eq x u0) u0 (+ u1 (/ (- x u1) y))))
    (define-read-only (min (v1 uint) (v2 uint)) (if (<= v1 v2) v1 v2))
    (define-read-only (fraction-compare (num1 uint) (den1 uint) (num2 uint) (den2 uint))
        (if (>= (* num1 den2) (* num2 den1)) true false))
    (define-read-only (calc-mint (r0 uint) (r1 uint) (a0 uint) (a1 uint) (lp-supply uint))
        (if (is-eq lp-supply u0) 
            (sqrti (* a0 a1)) 
            (min (/ (* a0 lp-supply) r0) (/ (* a1 lp-supply) r1))))
    (define-read-only (calc-burn (r0 uint) (r1 uint) (liquidity uint) (lp-supply uint))
        {a0:(/ (* r0 liquidity) lp-supply), a1:(/ (* r1 liquidity) lp-supply)})
    (define-read-only (calc-mint-opt (r0 uint) (r1 uint) (input0 uint) (input1 uint))  
        (if (and (is-eq r0 u0) (is-eq r1 u0))
            {opt0: input0, opt1: input1}
        (let ((opt1 (/ (* input0 r1) r0))
              (opt0 (/ (* input1 r0) r1)))
            (if (<= opt1 input1)  
                {opt0: input0, opt1: opt1}
                {opt0: opt0, opt1: input1}))))
    (define-read-only (calc-swap (r-in uint) (r-out uint) (a-in uint) (trade-fee (tuple (num uint) (den uint))))
        (let ((fee-num (get num trade-fee))
              (fee-den (get den trade-fee))  
              (a-in-real (/ (* a-in (- fee-den fee-num)) fee-den))
              (a-out (/ (* r-out a-in-real) (+ r-in a-in-real))))
            a-out))
    (define-read-only (calc-swap-exact (r-in uint) (r-out uint) (a-out uint) (trade-fee (tuple (num uint) (den uint))))
        (let ((fee-num (get num trade-fee))
              (fee-den (get den trade-fee))
              (a-in-real (div-ceil (* r-in a-out) (- r-out a-out)))
              (a-in (div-ceil (* a-in-real fee-den) (- fee-den fee-num)))) 
            a-in))
    
```
