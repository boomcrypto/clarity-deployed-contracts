
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait .univ2-share-fee-to-trait.share-fee-to-trait)

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
        (amt-out     (unwrap-panic
                      (contract-call?
                       .univ2-library
                       get-amount-out
                       amt-in
                       reserve-in
                       reserve-out
                       (get swap-fee pool)
                       ))) )
    (asserts!
     (and
      (> amt-in u0)
      ) err-preconditions)
    (ok
     {id         : id,
      flipped    : (get flipped res),
      amt-out-min: amt-out})))

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
  (let ((b (try! (swap-args amt-in              token-a token-b)))
        (c (try! (swap-args (get amt-out-min b) token-b token-c)))
        )
    (ok
     {b: (get amt-out-min b),
      c: (get amt-out-min c)})
     ))

(define-read-only
    (get-amount-out-4
     (amt-in   uint)
     (token-a <ft-trait>)
     (token-b <ft-trait>)
     (token-c <ft-trait>)
     (token-d <ft-trait>))
    (let ((b (try! (swap-args amt-in              token-a token-b)))
          (c (try! (swap-args (get amt-out-min b) token-b token-c)))
          (d (try! (swap-args (get amt-out-min c) token-c token-d)))
          )
      (ok
       {b: (get amt-out-min b),
        c: (get amt-out-min c),
        d: (get amt-out-min d)})
      ))

(define-read-only
  (get-amount-out-5
   (amt-in  uint)
   (token-a <ft-trait>)
   (token-b <ft-trait>)
   (token-c <ft-trait>)
   (token-d <ft-trait>)
   (token-e <ft-trait>))
  (let ((b (try! (swap-args amt-in              token-a token-b)))
        (c (try! (swap-args (get amt-out-min b) token-b token-c)))
        (d (try! (swap-args (get amt-out-min c) token-c token-d)))
        (e (try! (swap-args (get amt-out-min d) token-d token-e)))
        )
    (ok
     {b: (get amt-out-min b),
      c: (get amt-out-min c),
      d: (get amt-out-min d),
      e: (get amt-out-min e)})
    ))

;;; eof
