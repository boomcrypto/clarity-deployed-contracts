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
;; Get user's sBTC balance (from LP share, includes staked + unstaked LP)
(define-read-only
 (get-user-sBTC-balance (user principal) (staked-lp-amt uint))
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
       (user-liquidity (+ liquidity staked-lp-amt))
       (r0           (get reserve0 pool))
       (r1           (get reserve1 pool))
       (res          (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math burn r0 r1 total-supply user-liquidity))
       (amt0         (get dx res))
       (amt1         (get dy res))
       )
   amt1))

