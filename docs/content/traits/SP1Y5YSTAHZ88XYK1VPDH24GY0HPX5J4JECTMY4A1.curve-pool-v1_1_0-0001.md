---
title: "Trait curve-pool-v1_1_0-0001"
draft: true
---
```
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
(define-constant owner .curve-registry_v1_1_0)

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
(define-public
  (mint
    (token0   <ft-trait>)
    (token1   <ft-trait>)
    (lp-token <lp-token-trait>)
    (amt0     uint)
    (amt1     uint))

  (let ((pool_        (do-get-pool))
        (user         tx-sender)
        (protocol     (as-contract tx-sender))

        (total-supply (try! (contract-call? lp-token get-total-supply)))
        (r0           (get reserve0 pool_))
        (r1           (get reserve1 pool_))

        (amts         (try! (lift token0 token1 amt0 amt1)))
        (rs           (try! (lift token0 token1 r0 r1)))

        (liquidity    (try! (contract-call?
                             .curve-math_v1_0_0
                             mint
                             (get amt0 rs) (get amt0 amts) (get amt1 rs) (get amt1 amts)
                             total-supply (get A pool_))))
        )

    ;; Pre-conditions
    (asserts!
      (and (is-eq (get lp-token pool_) (contract-of lp-token))
           (is-eq (get token0   pool_) (contract-of token0))
           (is-eq (get token1   pool_) (contract-of token1))
           (> amt0 u0)
           (> amt1 u0)
           (> (get amt0 amts) u0)
           (> (get amt1 amts) u0)
           (> liquidity u0) )
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
      (> (* (+ total-supply liquidity) (+ (get amt0 rs) (get amt0 amts))) u0)
      (> (* (+ total-supply liquidity) (+ (get amt1 rs) (get amt1 amts))) u0)
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

        (rs           (try! (lift token0 token1 r0 r1)))

        (res          (contract-call?
                       .curve-math_v1_0_0
                       burn
                       (get amt0 rs) (get amt1 rs) total-supply liquidity))
        (amt0_        (get dx res))
        (amt1_        (get dy res))
        (amts         (try! (lower token0 token1 amt0_ amt1_)))
        (amt0         (get amt0 amts))
        (amt1         (get amt1 amts))
        )

    ;; Pre-conditions
    (asserts!
      (and (is-eq (get lp-token pool_) (contract-of lp-token))
           (is-eq (get token0   pool_) (contract-of token0))
           (is-eq (get token1   pool_) (contract-of token1))
           (> liquidity u0)
           (> amt0 u0)
           (> amt1 u0) )
      err-burn-preconditions)

    ;; Update global state
    (try! (as-contract (contract-call? token0 transfer amt0 protocol user none)))
    (try! (as-contract (contract-call? token1 transfer amt1 protocol user none)))
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
        (rs  (try! (lift t0_ t1_ r0 r1)))
        (dx  (if is-token0
                 (get amt0 (try! (lift t0_ t1_ amt-in-adjusted u0)))
                 (get amt1 (try! (lift t0_ t1_ u0 amt-in-adjusted)))))

        (amt-out_
         (if is-token0
             (unwrap-panic (contract-call? .curve-math_v1_0_0 find-dx
                                           (get amt1 rs) (get amt0 rs) dx u0 (get A pool_)))
             (unwrap-panic (contract-call? .curve-math_v1_0_0 find-dx
                                           (get amt0 rs) (get amt1 rs) dx u0 (get A pool_)))))

        (amt-out (if is-token0
                     (get amt1 (try! (lower t0_ t1_ u0 amt-out_)))
                     (get amt0 (try! (lower t0_ t1_ amt-out_ u0))) ))


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
      (begin
        (try! (as-contract (contract-call? token-in transfer
                                          amt-fee-protocol
                                          protocol
                                          (contract-of fees)
                                          none)))
        (try! (contract-call? fees receive is-token0 amt-fee-protocol)))
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
      (print event)
      (ok event) )
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; precison
(define-constant err-precision (err u666))

;; pools using this code must not allow tokens with settable decimals
(define-private
 (lift
  (token0 <ft-trait>)
  (token1 <ft-trait>)
  (amt0   uint)
  (amt1   uint)
  )

 (let ((d0          (try! (contract-call? token0 get-decimals)))
       (d1          (try! (contract-call? token1 get-decimals)))
       (amt0-lifted (if (is-eq d0 u6) amt0 (/ amt0 u100)))
       (amt1-lifted (if (is-eq d1 u6) amt1 (/ amt1 u100)))
       )

   (asserts!
    (and
     (or (is-eq d0 u6) (is-eq d0 u8))
     (or (is-eq d1 u6) (is-eq d1 u8)))
    err-precision)

   (ok
    {amt0: amt0-lifted,
     amt1: amt1-lifted})))

(define-private
 (lower
  (token0 <ft-trait>)
  (token1 <ft-trait>)
  (amt0   uint)
  (amt1   uint)
  )

 (let ((d0           (try! (contract-call? token0 get-decimals)))
       (d1           (try! (contract-call? token1 get-decimals)))
       (amt0-lowered (if (is-eq d0 u6) amt0 (* amt0 u100)))
       (amt1-lowered (if (is-eq d1 u6) amt1 (* amt1 u100)))
       )

   (asserts!
    (and
     (or (is-eq d0 u6) (is-eq d0 u8))
     (or (is-eq d1 u6) (is-eq d1 u8)))
    err-precision)

   (ok
    {amt0: amt0-lowered,
     amt1: amt1-lowered})))

;;; eof

```
