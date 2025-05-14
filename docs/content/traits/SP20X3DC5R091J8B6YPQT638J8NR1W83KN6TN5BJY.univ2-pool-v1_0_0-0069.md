---
title: "Trait univ2-pool-v1_0_0-0069"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(use-trait lp-token-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-lp-token-trait_v1_0_0.univ2-lp-token-trait)
(use-trait fees-trait     'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-trait_v1_0_0.univ2-fees-trait)

(impl-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-trait_v1_0_0.univ2-pool-trait)

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
(define-constant owner 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-registry_v1_0_0)

(define-data-var pool
  {
  symbol            : (string-ascii 32),
  token0            : principal,
  token1            : principal,
  lp-token          : principal,
  fees              : principal,
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
  reserve0          : u0,
  reserve1          : u0,
  block-height      : stacks-block-height,
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
      block-height     : stacks-block-height,
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
    (symbol   (string-ascii 32))
    )
  {
    symbol           : symbol,
    token0           : (contract-of token0),
    token1           : (contract-of token1),
    lp-token         : (contract-of lp-token),
    fees             : (contract-of fees),
    reserve0         : u0,
    reserve1         : u0,
    block-height     : stacks-block-height,
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
    (symbol   (string-ascii 32))
    )

  (let ((t0    (contract-of token0))
        (t1    (contract-of token1))
        (lp    (contract-of lp-token))
        (pool_ (make-pool token0 token1 lp-token fees symbol)))

    ;; Pre-conditions
    (asserts!
      (and (not (is-eq t0 t1))
           ;; TODO: more not is-eq?
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
        (liquidity    (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math mint r0 amt0 r1 amt1 total-supply))
        )

    ;; Pre-conditions
    (asserts!
      (and (is-eq (get lp-token pool_) (contract-of lp-token))
           (is-eq (get token0   pool_) (contract-of token0))
           (is-eq (get token1   pool_) (contract-of token1))
           (> amt0 u0)
           (> amt1 u0)
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
      (> (* (+ total-supply liquidity) (+ r0 amt0)) u0)
      (> (* (+ total-supply liquidity) (+ r1 amt1)) u0)
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

        (res          (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math burn r0 r1 total-supply liquidity))
        (amt0         (get dx res))
        (amt1         (get dy res))
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

        (amt-out
         (try! (if is-token0
                 (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math find-dx r1 r0 amt-in-adjusted)
                 (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-math find-dx r0 r1 amt-in-adjusted))) )

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

;;; eof

```
