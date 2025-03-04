;;; 0070: wstx-sbtc

(define-constant SBTC       'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token)
(define-constant POOL       'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070)
(define-constant LP-TOKEN   'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-lp-token-v1_0_0-0070)
(define-constant UNIV2-MATH 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math)

(define-read-only
 (get-total-sBTC-balance)
 (let ((pool (contract-call?
              'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070
              do-get-pool))
       ;; {
       ;; symbol            : (string-ascii 32),
       ;; token0            : principal,
       ;; token1            : principal,
       ;; lp-token          : principal,
       ;; fees              : principal,
       ;; reserve0          : uint,
       ;; reserve1          : uint,
       ;; block-height      : uint,
       ;; burn-block-height : uint,
       ;; }
       (r1   (get reserve1 pool))
       (bal  (unwrap-panic (contract-call?
                    'SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
                    get-balance
                    'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070
                    )))
       )
   (asserts! (<= r1 bal) (err u1)) ;;grift check
   (ok r1)))

;; an LP does not have a balance in a pool, they have a claim to a share
;; of the pool's reserves.
;; We can simulate what would happen if an LP where to burn their shares
;; at a point in time.
;; Note that we would like
;;   sum(map(get-user-sBTC-balance, LPs)) == get-total-sBTC-balance
;; mathematically:
;;     r1*s0/(s0+...+sN) + ... + r1*sN/(s0+...+sN)
;;   = (r1*s0 + ... + r1*sN) / (s0+...+sN)
;;   = r1*(s0+...+sN) / (s0+...+sN)
;;   = r1
;; however
;; 1) this is not guaranteed to hold when evaluated as a clarity
;;    expression
;; 2) there is not necessarily a canonical amount each LP would receive
;;    if all LPs were to actually burn their shares in sequence (because
;;    burn() is not commutative)
;;
;; (I think it's fine in practice though)
(define-read-only
 (get-user-sBTC-balance (user principal))
 (let ((pool         (contract-call?
                      'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070
                      do-get-pool))
       (total-supply (unwrap-panic (contract-call?
                            'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-lp-token-v1_0_0-0070
                            get-total-supply)))
       (liquidity    (unwrap-panic (contract-call?
                            'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-lp-token-v1_0_0-0070
                            get-balance
                            user)))
       (r0           (get reserve0 pool))
       (r1           (get reserve1 pool))
       (res          (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math burn r0 r1 total-supply liquidity))
       (amt0         (get dx res))
       (amt1         (get dy res))
       )
   amt1))

;;; eof
