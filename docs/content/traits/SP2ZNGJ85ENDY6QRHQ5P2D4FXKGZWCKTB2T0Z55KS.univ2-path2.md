---
title: "Trait univ2-path2"
draft: true
---
```
(use-trait ft-trait .dao-traits-v4.sip010-ft-trait)
(use-trait share-fee-to-trait .dao-traits-v4.share-fee-to-trait)

(define-constant err-preconditions  (err u2001))
(define-constant err-postconditions (err u2002))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public
  (do-swap
   (amt-in       uint)
   (token-in     <ft-trait>)
   (token-out    <ft-trait>)
   (share-fee-to <share-fee-to-trait>))
  (let ((args (try! (swap-args amt-in token-in token-out))))
     (contract-call?
      .univ2-router
      swap-exact-tokens-for-tokens
      (get id        args)
      (if (get flipped args) token-out token-in)
      (if (get flipped args) token-in token-out)
      token-in
      token-out
      share-fee-to
      amt-in
      (get amt-out-min args) )))

(define-read-only
  (swap-args
   (amt-in    uint)
   (token-in  <ft-trait>)
   (token-out <ft-trait>))
  (let ((res (unwrap-panic
              (contract-call?
               .univ2-core
               lookup-pool
               (contract-of token-in)
               (contract-of token-out)
               )))
        (id  (unwrap-panic
              (contract-call?
               .univ2-core
               get-pool-id
               (if (get flipped res) (contract-of token-out) (contract-of token-in))
               (if (get flipped res) (contract-of token-in)  (contract-of token-out))
               )))

        (pool        (get pool res))
        (reserve-in  (if (get flipped res) (get reserve1 pool) (get reserve0 pool)))
        (reserve-out (if (get flipped res) (get reserve0 pool) (get reserve1 pool)))
        (amt-out     (get-amount-out
                      amt-in
                      reserve-in
                      reserve-out
                      (get swap-fee pool)
                      )))
    (asserts!
     (and
      (> amt-in u0)
      ) err-preconditions)
    (ok
     {id         : id,
      flipped    : (get flipped res),
      amt-out-min: amt-out})))

(define-read-only
  (amount-out
   (amt-in    uint)
   (token-in  <ft-trait>)
   (token-out <ft-trait>))
  (let ((res (unwrap-panic
              (contract-call?
               .univ2-core
               lookup-pool
               (contract-of token-in)
               (contract-of token-out)
               )))
        (pool        (get pool res))
        (reserve-in  (if (get flipped res) (get reserve1 pool) (get reserve0 pool)))
        (reserve-out (if (get flipped res) (get reserve0 pool) (get reserve1 pool)))
        (amt-out     (get-amount-out
                       amt-in
                       reserve-in
                       reserve-out
                       (get swap-fee pool))) )
    amt-out))

;; univ2-library/core
(define-read-only
   (get-amount-out
     (amt-in       uint)
     (reserve-in   uint)
     (reserve-out  uint)
     (swap-fee     (tuple (num uint) (den uint)))
     )

    (let ((amt-in-adjusted (/ (* amt-in (get num swap-fee)) (get den swap-fee))) )

    (/ (* amt-in-adjusted reserve-out)
       (+ reserve-in amt-in-adjusted)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public
  (swap-3
   (amt-in       uint)
   (amt-out-min  uint)
   (token-a      <ft-trait>)
   (token-b      <ft-trait>)
   (token-c      <ft-trait>)
   (share-fee-to <share-fee-to-trait>))
  (let ((b (try! (do-swap amt-in          token-a token-b share-fee-to)))
        (c (try! (do-swap (get amt-out b) token-b token-c share-fee-to)))
        )
    (asserts!
     (>= (get amt-out c) amt-out-min)
     err-postconditions)
    (ok
     {b: b,
      c: c})
    ))

(define-public
  (swap-4
   (amt-in       uint)
   (amt-out-min  uint)
   (token-a      <ft-trait>)
   (token-b      <ft-trait>)
   (token-c      <ft-trait>)
   (token-d      <ft-trait>)
   (share-fee-to <share-fee-to-trait>))
  (let ((b (try! (do-swap amt-in          token-a token-b share-fee-to)))
        (c (try! (do-swap (get amt-out b) token-b token-c share-fee-to)))
        (d (try! (do-swap (get amt-out c) token-c token-d share-fee-to)))
        )
    (asserts!
     (>= (get amt-out d) amt-out-min)
     err-postconditions)
    (ok
     {b: b,
      c: c,
      d: d})
    ))

(define-public
  (swap-5
   (amt-in       uint)
   (amt-out-min  uint)
   (token-a      <ft-trait>)
   (token-b      <ft-trait>)
   (token-c      <ft-trait>)
   (token-d      <ft-trait>)
   (token-e      <ft-trait>)
   (share-fee-to <share-fee-to-trait>))
  (let ((b (try! (do-swap amt-in          token-a token-b share-fee-to)))
        (c (try! (do-swap (get amt-out b) token-b token-c share-fee-to)))
        (d (try! (do-swap (get amt-out c) token-c token-d share-fee-to)))
        (e (try! (do-swap (get amt-out d) token-d token-e share-fee-to)))
        )
    (asserts!
     (>= (get amt-out e) amt-out-min)
     err-postconditions)
    (ok
     {b: b,
      c: c,
      d: d,
      e: e})
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-read-only
  (get-amount-out-3
   (amt-in   uint)
   (token-a <ft-trait>)
   (token-b <ft-trait>)
   (token-c <ft-trait>))
  (let ((b (amount-out amt-in token-a token-b))
        (c (amount-out b      token-b token-c)))

    {b: b,
     c: c}))

(define-read-only
    (get-amount-out-4
     (amt-in   uint)
     (token-a <ft-trait>)
     (token-b <ft-trait>)
     (token-c <ft-trait>)
     (token-d <ft-trait>)
     (ids     (list 4 uint)))
    (let ((b (amount-out amt-in  token-a token-b))
          (c (amount-out b       token-b token-c))
          (d (amount-out c       token-c token-d))
          )

      {b: b,
      c: c,
      d: d}))

(define-read-only
  (get-amount-out-5
   (amt-in  uint)
   (token-a <ft-trait>)
   (token-b <ft-trait>)
   (token-c <ft-trait>)
   (token-d <ft-trait>)
   (token-e <ft-trait>))
  (let ((b (amount-out amt-in  token-a token-b))
        (c (amount-out b       token-b token-c))
        (d (amount-out c       token-c token-d))
        (e (amount-out d       token-d token-e))
        )
    {b: b,
    c: c,
    d: d,
    e: e}))

;;; eof
```
