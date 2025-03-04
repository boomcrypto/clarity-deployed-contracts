;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; max 2047 edge tuples
(define-constant MAX-EDGES    u250) ;;effectively max nr of pools (stx -> *)
(define-constant MAX-PATH-LEN u4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pool types
(define-constant UNIV2   "u")
(define-constant UNIV2V2 "v")
(define-constant CURVE   "c")
(define-constant USDH    "h")
(define-constant STSTX   "s")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; edges
(define-read-only
  (is-univ2 (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (is-eq (get a edge) UNIV2))
(define-read-only
  (is-univ2v2 (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (is-eq (get a edge) UNIV2V2))
(define-read-only
  (is-curve (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (is-eq (get a edge) CURVE))
(define-read-only
  (is-usdh (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (is-eq (get a edge) USDH))
(define-read-only
  (is-ststx (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
  (is-eq (get a edge) STSTX))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pool ctx
(define-read-only
  (reserves
   (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (pool {r0:uint,r1:uint,fee:{num:uint,den:uint},A:uint,R:uint}))
  {reserve-in : (if (get f edge) (get r0 pool) (get r1 pool)),
   reserve-out: (if (get f edge) (get r1 pool) (get r0 pool))})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only
  (eval
   (path   (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
   (pools  (list 4 {r0:uint,r1:uint,fee:{num:uint,den:uint},A:uint,R:uint}))
   (amt-in uint))
  (let ((amt-out1 (eval1 (element-at? path u0) (element-at? pools u0) amt-in))
        (amt-out2 (eval1 (element-at? path u1) (element-at? pools u1) amt-out1))
        (amt-out3 (eval1 (element-at? path u2) (element-at? pools u2) amt-out2))
        (amt-out4 (eval1 (element-at? path u3) (element-at? pools u3) amt-out3)))
    {amt-out1: amt-out1,
     amt-out2: amt-out2,
     amt-out3: amt-out3,
     amt-out4: amt-out4}))

(define-read-only
  (eval1
   (edge   (optional {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
   (pool   (optional {r0:uint,r1:uint,fee:{num:uint,den:uint},A:uint,R:uint}))
   (amt-in uint))
  (if (is-none edge)
      amt-in
      (unwrap-panic (eval2 (unwrap-panic edge) (unwrap-panic pool) amt-in))))

(define-read-only
  (eval2
   (edge   {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (pool   {r0:uint,r1:uint,fee:{num:uint,den:uint},A:uint,R:uint})
   (amt-in uint))
  (if (is-univ2   edge) (eval-univ2   edge pool amt-in)
  (if (is-univ2v2 edge) (eval-univ2v2 edge pool amt-in)
  (if (is-curve   edge) (eval-curve   edge pool amt-in)
  (if (is-usdh    edge) (eval-usdh    edge pool amt-in)
  (if (is-ststx   edge) (eval-ststx   edge pool amt-in)
  (err u0) ))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only
  (eval-univ2
   (edge   {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (pool   {r0:uint,r1:uint,fee:{num:uint,den:uint},A:uint,R:uint})
   (amt-in uint))
  (let ((rs (reserves edge pool))
        ;; univ2-library
        (amt-in-adjusted (/ (* amt-in (get num (get fee pool)))
                            (get den (get fee pool)) ) ))
    (ok (/ (* amt-in-adjusted (get reserve-out rs))
           (+ (get reserve-in rs) amt-in-adjusted)) ) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only
  (eval-univ2v2
   (edge   {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (pool   {r0:uint,r1:uint,fee:{num:uint,den:uint},A:uint,R:uint})
   (amt-in uint))
  (let ((rs (reserves edge pool))
        ;; univ2-fees/calc-fees
        (amt-in-adjusted
         (/ (* amt-in (get num (get fee pool)))
            (get den (get fee pool)))))
    (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math find-dx
                    (get reserve-out rs) (get reserve-in rs) amt-in-adjusted)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; default curve pools
(define-read-only
  (eval-curve
   (edge   {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (pool   {r0:uint,r1:uint,fee:{num:uint,den:uint},A:uint,R:uint})
   (amt-in uint))
  (let ((rs (reserves edge pool))
        ;; curve-fees/calc-fees
        (amt-in-adjusted
         (/ (* amt-in (get num (get fee pool)))
            (get den (get fee pool)))) )
    (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-math_v1_0_0 find-dx
                    (get reserve-out rs) (get reserve-in rs) amt-in-adjusted
                    u0 ;;D
                    (get A pool)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ststx
(define-read-only
  (eval-ststx
   (edge   {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (pool   {r0:uint,r1:uint,fee:{num:uint,den:uint},A:uint,R:uint})
   (amt-in uint))
  (let ((rs       (reserves edge pool))
        (r-in     (get reserve-in rs))
        (r-out    (get reserve-out rs))
        (stx-in   (get f edge))
        ;; curve-fees/calc-fees
        (amt-in-adjusted
         (/ (* amt-in (get num (get fee pool)))
            (get den (get fee pool))))
        ;; ratio adjusted
        (ratio    (get R pool))
        (r-in_    (if stx-in (div-ratio r-in ratio) (mult-ratio r-in ratio)))
        (dx       (if stx-in (div-ratio amt-in-adjusted ratio) (mult-ratio amt-in-adjusted ratio))))

    (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-math_v1_0_0 find-dx
                    r-out r-in dx
                    u0 (get A pool))))

(define-read-only
 (mult-ratio (n uint) (r uint))
   (/ (* n r) u1000000))

(define-read-only
 (div-ratio (n uint) (r uint))
 (/ (* n u1000000) r))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; usdh (token0)
(define-read-only
 (eval-usdh
  (edge   {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
  (pool   {r0:uint,r1:uint,fee:{num:uint,den:uint},A:uint,R:uint})
  (amt-in uint))
 (let ((usdh-in (get f edge))
       (rs    (reserves edge pool))
       (r-in  (if usdh-in (lift (get reserve-in rs)) (get reserve-in rs)))
       (r-out (if usdh-in (get reserve-out rs) (lift (get reserve-out rs))))

       ;; curve-fees/calc-fees
       (amt-in-adjusted
        (/ (* amt-in (get num (get fee pool)))
           (get den (get fee pool))))

       (amt-in-final (if usdh-in (lift amt-in-adjusted) amt-in-adjusted))

       (amt-out
        (try! (contract-call?
         'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-math_v1_0_0 find-dx
         r-out r-in amt-in-final
         u0 ;;D
         (get A pool)) ))
        )

   (ok (if usdh-in amt-out (lower amt-out))) ))

(define-read-only (lift  (amt uint)) (/ amt u100))
(define-read-only (lower (amt uint)) (* amt u100))

;;; eof
