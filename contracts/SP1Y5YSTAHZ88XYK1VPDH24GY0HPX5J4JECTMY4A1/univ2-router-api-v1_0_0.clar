;;; UniswapV2Router02.sol

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(use-trait pool-trait     .univ2-pool-trait_v1_0_0.univ2-pool-trait)
(use-trait lp-token-trait .univ2-lp-token-trait_v1_0_0.univ2-lp-token-trait)
(use-trait fees-trait     .univ2-fees-trait_v1_0_0.univ2-fees-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-constant err-router-preconditions  (err u200))
(define-constant err-router-postconditions (err u201))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; add-liquidity
(define-private
  (add-liquidity-calc
    (pool_        <pool-trait>)
    (amt0-desired uint)
    (amt1-desired uint)
    (amt0-min     uint)
    (amt1-min     uint))
  (let ((pool (try! (contract-call? pool_ get-pool)))
        (r0   (get reserve0 pool))
        (r1   (get reserve1 pool)))
    (if (and (is-eq r0 u0) (is-eq r1 u0))
        (ok {amt0: amt0-desired, amt1: amt1-desired})
        (let ((amt1-optimal (try! (contract-call? .univ2-library quote amt0-desired r0 r1)))
              (amt0-optimal (try! (contract-call? .univ2-library quote amt1-desired r1 r0))) )
            ;; Note we do not use optimal if > desired.
            (if (<= amt1-optimal amt1-desired)
                (begin
                  (asserts! (>= amt1-optimal amt1-min) err-router-preconditions)
                  (ok {amt0: amt0-desired, amt1: amt1-optimal}))
                (begin
                  (asserts!
                    (and
                      (<= amt0-optimal amt0-desired)
                      (>= amt0-optimal amt0-min))
                    err-router-preconditions)
                  (ok {amt0: amt0-optimal, amt1: amt1-desired})) )) )))

(define-public
  (add-liquidity
    (pool         <pool-trait>)
    (token0       <ft-trait>)
    (token1       <ft-trait>)
    (lp-token     <lp-token-trait>)
    (amt0-desired uint)
    (amt1-desired uint)
    (amt0-min     uint)
    (amt1-min     uint))

  (let ((amts (try! (add-liquidity-calc
                pool amt0-desired amt1-desired amt0-min amt1-min))))

    (asserts!
     (and (<= amt0-min amt0-desired)
          (<= amt1-min amt1-desired)
          (>= amt0-min u0)
          (>= amt1-min u0)
          (>= amt0-desired u0)
          (>= amt1-desired u0))
     err-router-preconditions)

    (contract-call? pool mint
      token0
      token1
      lp-token
      (get amt0 amts)
      (get amt1 amts)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; remove-liquidity
(define-public
  (remove-liquidity
    (pool      <pool-trait>)
    (token0    <ft-trait>)
    (token1    <ft-trait>)
    (lp-token  <lp-token-trait>)
    (liquidity uint)
    (amt0-min  uint)
    (amt1-min  uint))

  (let ((event (try! (contract-call? pool burn
                  token0 token1 lp-token liquidity))))

    (asserts!
      (and (>= (get amt0 event) amt0-min)
           (>= (get amt1 event) amt1-min))
      err-router-postconditions)

    (ok event) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; swap
(define-public
  (swap-exact-tokens-for-tokens
    (pool_          <pool-trait>)
    (token0         <ft-trait>)
    (token1         <ft-trait>)
    (token-in       <ft-trait>)
    (token-out      <ft-trait>)
    (fees_          <fees-trait>)
    (amt-in      uint)
    (amt-out-min uint))

  (let ((pool      (try! (contract-call? pool_ get-pool)))
        (fees      (try! (contract-call? fees_ get-fees)))
        (is-token0 (is-eq (contract-of token0) (contract-of token-in)))
        (amt-out   (try! (contract-call? .univ2-library get-amount-out
          amt-in
          (if is-token0 (get reserve0 pool) (get reserve1 pool))
          (if is-token0 (get reserve1 pool) (get reserve0 pool))
          (get swap-fee fees) )))
       (event      (try! (contract-call? pool_ swap
          token-in
          token-out
          fees_
          amt-in
          amt-out))) )

    (asserts!
     (and (is-eq (get token0 pool) (contract-of token0))
          (is-eq (get token1 pool) (contract-of token1))
          (> amt-in      u0)
          (> amt-out-min u0) )
     err-router-preconditions)

    (asserts!
      (and (>= (get amt-out event) amt-out-min))
      err-router-postconditions)

    (ok event) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public
  (swap-tokens-for-exact-tokens
    (pool_        <pool-trait>)
    (token0       <ft-trait>)
    (token1       <ft-trait>)
    (token-in     <ft-trait>)
    (token-out    <ft-trait>)
    (fees_        <fees-trait>)
    (amt-in-max   uint)
    (amt-out      uint))

  (let ((pool      (try! (contract-call? pool_ get-pool)))
        (fees      (try! (contract-call? fees_ get-fees)))
        (is-token0 (is-eq (contract-of token0) (contract-of token-in)))
        (amt-in    (try! (contract-call? .univ2-library get-amount-in
          amt-out
          (if is-token0 (get reserve0 pool) (get reserve1 pool))
          (if is-token0 (get reserve1 pool) (get reserve0 pool))
          (get swap-fee fees) )))
        (event     (try! (contract-call? pool_ swap
          token-in
          token-out
          fees_
          amt-in
          amt-out))) )

  (asserts!
   (and (is-eq (get token0 pool) (contract-of token0))
        (is-eq (get token1 pool) (contract-of token1))
        (> amt-in-max u0)
        (> amt-out    u0) )
   err-router-preconditions)

  (asserts!
    (and (<= (get amt-in event) amt-in-max))
    err-router-postconditions)

  (ok event) ))

;;; eof
