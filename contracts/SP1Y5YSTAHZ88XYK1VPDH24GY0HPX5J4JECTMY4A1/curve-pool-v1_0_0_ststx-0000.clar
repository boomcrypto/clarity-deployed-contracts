;; stx-ststx
;; er * stx = 1 ststx
;; er eg 1.045

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait lp-token-trait .curve-lp-token-trait_v1_0_0.curve-lp-token-trait)
(use-trait fees-trait     .curve-fees-trait_v1_0_0.curve-fees-trait)

(impl-trait .curve-pool-trait_v1_0_0.curve-pool-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-init-preconditions   (err u101))
(define-constant err-init-postconditions  (err u102))
(define-constant err-mint-preconditions   (err u103))
(define-constant err-mint-postconditions  (err u104))
(define-constant err-burn-preconditions   (err u105))
(define-constant err-burn-postconditions  (err u106))
(define-constant err-swap-preconditions   (err u107))
(define-constant err-swap-postconditions  (err u108))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; storage
(define-data-var initialized bool false)
(define-constant owner .curve-registry_v1_0_0)

(define-data-var pool
  {
  symbol            : (string-ascii 32),
  token0            : principal,
  token1            : principal,
  lp-token          : principal,
  fees              : principal,
  A                 : uint,
  reserve0          : uint,
  reserve1          : uint,
  block-height      : uint,
  burn-block-height : uint,
  }
  {
  symbol            : "",
  token0            : tx-sender, ;;arbitrary
  token1            : tx-sender,
  lp-token          : tx-sender,
  fees              : tx-sender,
  A                 : u85,
  reserve0          : u0,
  reserve1          : u0,
  block-height      : block-height,
  burn-block-height : burn-block-height,
  })

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; read
(define-read-only (get-pool)    (ok (var-get pool)))
(define-read-only (do-get-pool) (var-get pool))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; write
(define-private
  (update-reserves
    (r0 uint)
    (r1 uint))
  (let ((pool_ (do-get-pool)))
    (ok (var-set pool (merge pool_ {
      reserve0         : r0,
      reserve1         : r1,
      block-height     : block-height,
      burn-block-height: burn-block-height,
      })) )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ctors
(define-private
  (make-pool
    (token0   <ft-trait>)
    (token1   <ft-trait>)
    (lp-token <lp-token-trait>)
    (fees     <fees-trait>)
    (A        uint)
    (symbol   (string-ascii 32))
    )
  {
    symbol           : symbol,
    token0           : (contract-of token0),
    token1           : (contract-of token1),
    lp-token         : (contract-of lp-token),
    fees             : (contract-of fees),
    A                : A,
    reserve0         : u0,
    reserve1         : u0,
    block-height     : block-height,
    burn-block-height: burn-block-height,
  })

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init
(define-public
  (init
    (token0   <ft-trait>)
    (token1   <ft-trait>)
    (lp-token <lp-token-trait>)
    (fees     <fees-trait>)
    (A         uint)
    (symbol   (string-ascii 32))
    )

  (let ((t0    (contract-of token0))
        (t1    (contract-of token1))
        (lp    (contract-of lp-token))
        (pool_ (make-pool token0 token1 lp-token fees A symbol)))

    ;; Pre-conditions
    (asserts!
      (and (not (is-eq t0 t1))
           (is-eq contract-caller owner)
           (not (var-get initialized))
      )
      err-init-preconditions)

    ;; Update global state

    ;; Update local state
    (var-set pool pool_)
    (var-set initialized true)

    ;; Post-conditions

    ;; Return
    (let ((event
          {op  : "init",
           user: tx-sender,
           pool: pool_}))
      (print event)
      (ok pool_)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; mint
;;;
;;; in mint, all values are expressed as stx

;; we want nice, human interpretable numbers for `liquidity' so we
;; special case mint to move the pool to a balanced part of the curve
;; where D ~ x+y and liquidity ~ value share of D
(define-public
  (initial-mint
    (token0   <ft-trait>)
    (token1   <ft-trait>)
    (lp-token <lp-token-trait>)
    (amt0     uint)
  ;;(amt1     uint)
    )

  (let ((pool_        (do-get-pool))
        (user         tx-sender)
        (protocol     (as-contract tx-sender))

        (total-supply (try! (contract-call? lp-token get-total-supply)))
        (r0           (get reserve0 pool_))
        (r1           (get reserve1 pool_))

        ;; provide N*R stx and N ststx
        (ratio        (try! (get-ratio)))
      ;;(amt0         (mult-ratio amt1 ratio))
        (amt1         (div-ratio amt0 ratio))

        ;; liq tokens can now be read as:
        ;; TS  : total pool value expressed in stx
        ;; L   : value contribution in terms of stx (given er at mint time)
        ;; L/TS: value share
        ;;(as long as we are in the flat part of the curve)
        (pv           (* u2 amt0))

        (liquidity
         (try! (contract-call?
                .curve-math_v1_0_0
                mint
                u0 amt0 u0 amt0 ;;XXX: amt0 is stx value of amt1 by construction
                total-supply (get A pool_))))
        )

    ;; Pre-conditions
    (asserts!
      (and (is-eq (get lp-token pool_) (contract-of lp-token))
           (is-eq (get token0   pool_) (contract-of token0))
           (is-eq (get token1   pool_) (contract-of token1))
           (and (> amt0 u0) (> amt1 u0))
           (> liquidity u0)
           ;; first mint
           (is-eq r0 u0)
           (is-eq r1 u0)
           ;; nice numbers (TODO: modulo rounding errors?)
           (is-eq liquidity pv)
           )
      err-mint-preconditions)

    ;; Update global state
    (try! (contract-call? token0 transfer amt0 user protocol none))
    (try! (contract-call? token1 transfer amt1 user protocol none))
    (try! (as-contract (contract-call? lp-token mint liquidity user)))

    ;; Update local state
    (unwrap-panic (update-reserves (+ r0 amt0) (+ r1 amt1)))

    ;; Post-conditions
    (asserts!
     (and
      ;; Guard against overflow in burn.
      (>= (* (+ total-supply liquidity) (+ r0 amt0)) u0)
      (>= (* (+ total-supply liquidity) (+ r1 amt1)) u0)
      )
     err-mint-postconditions)

    ;; Return
    (let ((event
           {op          : "mint",
            user        : user,
            pool        : pool_,
            amt0        : amt0,
            amt1        : amt1,
            liquidity   : liquidity,
            total-supply: total-supply
            }))
      (print event)
      (ok event)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; after the initial mint, single sided mints only to simplify calculations
(define-public
  (mint
    (token0   <ft-trait>)
    (token1   <ft-trait>)
    (lp-token <lp-token-trait>)
    (amt0_    uint)
    (amt1_    uint))

  (let ((pool_        (do-get-pool))
        (user         tx-sender)
        (protocol     (as-contract tx-sender))

        (total-supply (try! (contract-call? lp-token get-total-supply)))
        (r0           (get reserve0 pool_))
        (r1           (get reserve1 pool_))

        (res0              (try! (contract-call? .curve-fees-v1_0_0_ststx-0000 calc-fees amt0_)))
        (amt0              (get amt-in-adjusted  res0))
        (amt0-fee-lps      (get amt-fee-lps      res0))
        (amt0-fee-protocol (get amt-fee-protocol res0))
        (amt0-fee          (+ amt0-fee-lps amt0-fee-protocol))

        (res1              (try! (contract-call? .curve-fees-v1_0_0_ststx-0000 calc-fees amt1_)))
        (amt1              (get amt-in-adjusted  res1))
        (amt1-fee-lps      (get amt-fee-lps      res1))
        (amt1-fee-protocol (get amt-fee-protocol res1))
        (amt1-fee          (+ amt1-fee-lps amt1-fee-protocol))

        (ratio        (try! (get-ratio)))
        ;; (x            (div-ratio r0   ratio))
        ;; (dx           (div-ratio amt0 ratio))
        (y            (mult-ratio r1   ratio))
        (dy           (mult-ratio amt1 ratio))

        (liquidity
         (if (is-eq amt1 u0)
             ;; provide stx
             (try! (contract-call?
                    .curve-math_v1_0_0
                    mint
                    r0 amt0 y u1
                    ;; x dx r1 u1
                    total-supply (get A pool_)))
             ;; provide ststx -> virtualize
             (try! (contract-call?
                    .curve-math_v1_0_0
                    mint
                    r0 u1 y dy
                    ;; x u1 r1 amt1
                    total-supply (get A pool_))) ))
        )

    ;; Pre-conditions
    (asserts!
      (and (is-eq (get lp-token pool_) (contract-of lp-token))
           (is-eq (get token0   pool_) (contract-of token0))
           (is-eq (get token1   pool_) (contract-of token1))
           (or (>     amt0 u0) (>     amt1 u0))
           (or (is-eq amt0 u0) (is-eq amt1 u0))
           (> liquidity u0) )
      err-mint-preconditions)

    ;; Update global state
    (if (> amt0 u0) (try! (contract-call? token0 transfer amt0_ user protocol none)) true)
    (if (> amt1 u0) (try! (contract-call? token1 transfer amt1_ user protocol none)) true)
    (try! (as-contract (contract-call? lp-token mint liquidity user)))

    (if (> amt0-fee u0)
         (try! (as-contract (contract-call? token0 transfer
                                            amt0-fee
                                            protocol
                                            .curve-fees-v1_0_0_ststx-0000
                                            none)))
      true)

    (if (> amt1-fee u0)
         (try! (as-contract (contract-call? token1 transfer
                                            amt1-fee
                                            protocol
                                            .curve-fees-v1_0_0_ststx-0000
                                            none)))
      true)

    ;; Update local state
    (unwrap-panic (update-reserves (+ r0 amt0) (+ r1 amt1)))

    ;; Post-conditions
    (asserts!
     (and
      ;; Guard against overflow in burn.
      (>= (* (+ total-supply liquidity) (+ r0 amt0)) u0)
      (>= (* (+ total-supply liquidity) (+ r1 amt1)) u0)
      )
     err-mint-postconditions)

    ;; Return
    (let ((event
           {op          : "mint",
            user        : user,
            pool        : pool_,
            amt0        : amt0_,
            amt1        : amt1_,
            liquidity   : liquidity,
            total-supply: total-supply,
            }))
      (print (merge event {
        amt0-fee    : amt0-fee,
        amt1-fee    : amt1-fee,
      }))
      (ok event)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; burn
(define-public
  (burn
    (token0    <ft-trait>)
    (token1    <ft-trait>)
    (lp-token  <lp-token-trait>)
    (liquidity uint))

  (let ((pool_        (do-get-pool))
        (user         tx-sender)
        (protocol     (as-contract tx-sender))

        (total-supply (try! (contract-call? lp-token get-total-supply)))
        (r0           (get reserve0 pool_))
        (r1           (get reserve1 pool_))

        (res          (contract-call?
                       .curve-math_v1_0_0
                       burn
                       r0 r1 total-supply liquidity))
        (amt0         (get dx res))
        (amt1         (get dy res))
        )

    ;; Pre-conditions
    (asserts!
      (and (is-eq (get lp-token pool_) (contract-of lp-token))
           (is-eq (get token0   pool_) (contract-of token0))
           (is-eq (get token1   pool_) (contract-of token1))
           (> liquidity u0)
           (or (> amt0 u0)
               (> amt1 u0))
           )
      err-burn-preconditions)

    ;; Update global state
    (if (> amt0 u0) (try! (as-contract (contract-call? token0 transfer amt0 protocol user none))) true)
    (if (> amt1 u0) (try! (as-contract (contract-call? token1 transfer amt1 protocol user none))) true)
    (try! (as-contract (contract-call? lp-token burn liquidity user)))

    ;; Update local state
    (unwrap-panic (update-reserves (- r0 amt0) (- r1 amt1)))

    ;; Post-conditions

    ;; Return
    (let ((event
          {op          : "burn",
           user        : user,
           pool        : pool_,
           liquidity   : liquidity,
           amt0        : amt0,
           amt1        : amt1,
           total-supply: total-supply
           }))
      (print event)
      (ok event)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; swap
(define-constant MAX-SWAP-SIZE {num: u1000, den: u10000}) ;; 10%

(define-read-only
 (check-max-swap-size
  (amt     uint)
  (reserve uint) )
 (<= amt
     (/ (* reserve (get num MAX-SWAP-SIZE))
        (get den MAX-SWAP-SIZE))
     ) )

(define-public
  (swap
   (token-in        <ft-trait>)
   (token-out       <ft-trait>)
   (fees            <fees-trait>)
   (amt-in          uint)
   (amt-out-desired uint))

  (let ((pool_     (var-get pool))
        (user      tx-sender)
        (protocol  (as-contract tx-sender))

        (t0        (get token0 pool_))
        (t1        (get token1 pool_))
        (is-token0 (is-eq (contract-of token-in) t0))

        (r0        (get reserve0 pool_))
        (r1        (get reserve1 pool_))

        (res              (try! (contract-call? fees calc-fees amt-in)))
        (amt-in-adjusted  (get amt-in-adjusted  res))
        (amt-fee-lps      (get amt-fee-lps      res))
        (amt-fee-protocol (get amt-fee-protocol res))

        (t0_ (if is-token0 token-in token-out))
        (t1_ (if is-token0 token-out token-in))

        (ratio     (try! (get-ratio)))
        (x         (div-ratio r0 ratio))
        (dx        (div-ratio amt-in-adjusted ratio))
        (y         (mult-ratio r1 ratio))
        (dy        (mult-ratio amt-in-adjusted ratio))

        (amt-out
         (if is-token0
             (unwrap-panic (contract-call? .curve-math_v1_0_0 find-dx
                                           r1 x dx
                                           u0 (get A pool_)))
             (unwrap-panic (contract-call? .curve-math_v1_0_0 find-dx
                                           r0 y dy
                                           u0 (get A pool_)))))

        (bals (if is-token0
                  {bal0: (+ r0 amt-in-adjusted amt-fee-lps),
                   bal1: (- r1 amt-out)}
                  {bal0: (- r0 amt-out),
                   bal1: (+ r1 amt-in-adjusted amt-fee-lps)}))
        )

    (asserts!
     (and
      (or (is-eq (contract-of token-in) t0)
          (is-eq (contract-of token-in) t1))
      (or (is-eq (contract-of token-out) t0)
          (is-eq (contract-of token-out) t1))
      (not (is-eq (contract-of token-in) (contract-of token-out)))

      (is-eq (contract-of fees) (get fees pool_))

      (>  amt-in          u0)
      (>  amt-out-desired u0)
      (>  amt-in-adjusted u0)
      (>= amt-out         amt-out-desired)

      (check-max-swap-size amt-in (if is-token0 r0 r1))

      )
     err-swap-preconditions)

    ;; Update global state
    (try! (contract-call? token-in transfer amt-in user protocol none))
    (try! (as-contract (contract-call? token-out transfer amt-out protocol user none)))

    (if (> amt-fee-protocol u0)
        (try! (as-contract (contract-call? token-in transfer
                                          amt-fee-protocol
                                          protocol
                                          (contract-of fees)
                                          none)))
        true)

    ;; Update local state
    (unwrap-panic (update-reserves (get bal0 bals) (get bal1 bals)))

    ;; Post-conditions
    ;; (asserts!
    ;;  (if is-token0
    ;;      (and
    ;;       (>= (contract-call? token-in  get-balance protocol) (get bal0 bals))
    ;;       (>= (contract-call? token-out get-balance protocol) (get bal1 bals)))
    ;;      (and
    ;;       (>= (contract-call? token-out get-balance protocol) (get bal0 bals))
    ;;       (>= (contract-call? token-in  get-balance protocol) (get bal1 bals)))
    ;;      )
    ;;  err-swap-postconditions)

    ;; Return
    (let ((event
           {op              : "swap",
            user            : user,
            pool            : pool_ ,
            amt-in          : amt-in,
            amt-out-desired : amt-out-desired,
            amt-out         : amt-out,
            amt-in-adjusted : amt-in-adjusted,
            amt-fee-lps     : amt-fee-lps,
            amt-fee-protocol: amt-fee-protocol,
           }))
      ;; (print event)
      (ok event) )
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; get-ratio

;; todo read only
(define-public (get-ratio)
  (contract-call?
          'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.data-core-v1
          get-stx-per-ststx
          'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.reserve-v1))

(define-read-only
 (mult-ratio
  (n uint)
  (r uint))
 (/ (* n r) u1000000))

(define-read-only
 (div-ratio
  (n uint)
  (r uint))
 (/ (* n u1000000) r))



;;; eof
