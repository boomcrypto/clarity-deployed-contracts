;;; UniswapV2Library.sol

(define-constant err-library-preconditions (err u300))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; quote
(define-read-only
  (quote
    (amt-in      uint)
    (reserve-in  uint)
    (reserve-out uint))

  (begin

    (asserts!
      (and (> amt-in      u0)
           (> reserve-in  u0)
           (> reserve-out u0))
      err-library-preconditions)

     (ok (/ (* amt-in reserve-out)
            reserve-in) )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; get-amount-out
(define-read-only
   (get-amount-out
     (amt-in       uint)
     (reserve-in   uint)
     (reserve-out  uint)
     (swap-fee     (tuple (num uint) (den uint)))
     )

    (let ((dummy-fee       {num: u500, den: u1000})
          (amts            (contract-call? .univ2-core calc-swap
                             amt-in swap-fee dummy-fee dummy-fee))
          (amt-in-adjusted (get amt-in-adjusted amts)) )

    (asserts!
        (and (> amt-in          u0)
             (> amt-in-adjusted u0)
             (> reserve-in      u0)
             (> reserve-out     u0))
        err-library-preconditions)

    (ok (/ (* amt-in-adjusted reserve-out)
           (+ reserve-in amt-in-adjusted)) )))

;; (reserve-out - amt-out)*(reserve-in + amt-in-adjusted) >= reserve-in*reserve-out
;;
;; reserve-out*reserve-in + reserve-out*amt-in-adjusted
;; - amt-out*(reserve-in + amt-in-adjusted) >= reserve-in*reserve-out
;;
;; reserve-out*reserve-in + reserve-out*amt-in-adjusted
;; - reserve-in*reserve-out >= amt-out * (reserve-in + amt-in-adjusted)
;;
;; (reserve-out * amt-in-adjusted) / (reserve-in + amt-in-adjusted) >= amt-out

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; get-amount-in
(define-read-only
   (get-amount-in
     (amt-out     uint)
     (reserve-in  uint)
     (reserve-out uint)
     (swap-fee    (tuple (num uint) (den uint))) )

  (begin
    (asserts!
        (and (> amt-out     u0)
             (> reserve-in  u0)
             (> reserve-out u0))
        err-library-preconditions)

    (let ((x (+ (/ (* reserve-in amt-out)
                   (- reserve-out amt-out)) u1))
          (y (/ (* x (get den swap-fee)) (get num swap-fee))) )
        (ok (+ y u1) ))))

;; amt-in = (reserve-in * amt-out) / (reserve-out - amt-out) * 1/fee
;; <-->
;; amt-out = amt-in*fee*reserve-out / (reserve-in + amt-in*fee)
;;
;; reserve-in*amt-out + amt-in*fee*amt-out = amt-in*fee*reserve-out
;; reserve-in*amt-out/amt-in*fee + amt-out = reserve-out
;; reserve-in*amt-out/amt-in*fee = reserve-out - amt-out
;; amt-in*fee = (reserve-in*amt-out)/(reserve-out - amt-out)
;; amt-in = (reserve-in * amt-out) / (reserve-out - amt-out) * 1/fee

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; get-amounts-out
;; (define-read-only
;;   (get-amounts-out
;;     (amt-in uint)
;;     (root   principal)
;;     (path   (list 50 principal)))
;;   (let ((res
;;          (fold step
;;                path
;;                {prev  : root,
;;                 amt-in: amt-in,
;;                 amts  : (list)}) ))
;;     (ok (get amts res)) ))

;; (define-read-only
;;   (step
;;     (elt principal)
;;     (s (tuple (prev principal) (amt-in uint) (amts (list 50 uint)) ) ) )

;;   (let ((prev        (get prev   s))
;;         (amt-in      (get amt-in s))
;;         (amts        (get amts   s))
;;         (pool        (get pool (unwrap-panic (contract-call? .univ2-core lookup-pool prev elt))))
;;         (is-token0   (is-eq prev (get token0 pool)))
;;         (reserve-in  (if is-token0 (get reserve0 pool) (get reserve1 pool)))
;;         (reserve-out (if is-token0 (get reserve1 pool) (get reserve0 pool)))
;;         (amt-out     (unwrap-panic (get-amount-out amt-in
;;                                                    reserve-in
;;                                                    reserve-out
;;                                                    (get swap-fee pool)))) )
;;     {
;;       prev  : elt,
;;       amt-in: amt-out,
;;       amts  : (unwrap-panic (as-max-len? (append amts amt-in) u50)),
;;     }))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; get-amount-in
;;; TODO
;;; needs caller to reverse path...

;;; eof
