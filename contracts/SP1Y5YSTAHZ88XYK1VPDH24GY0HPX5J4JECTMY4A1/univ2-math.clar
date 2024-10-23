
(define-read-only (min (a uint) (b uint)) (if (<= a b) a b))


;;======================================================================
(define-constant err-dx   (err u800))
;; (define-constant err-mint (err u801))

(define-read-only
 (find-dx
  (x uint)
  (y uint)
  (dy uint)
  )
 (let (;; get-amout-out with dy = amt-in-adjusted (in/in' * out)
       (dx (/ (* dy x) (+ y dy)))
       (k  (* x y))
       (a  (- x dx))
       (b  (+ y dy))
       )
   (asserts! (>= (* a b) k) err-dx)
   (ok dx)
   ))

;;======================================================================
(define-read-only
  (mint
   (x  uint)
   (dx uint)
   (y  uint)
   (dy uint)
   (u  uint) ;; total supply
   )
  (if (is-eq u u0)
      (sqrti (* dx dy))
      (min (/ (* dx u) x)
           (/ (* dy u) y))) )

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
