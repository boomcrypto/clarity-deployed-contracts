---
title: "Trait path-apply_v1_0_0"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(use-trait share-fee-to-trait .univ2-share-fee-to-trait.share-fee-to-trait)

(use-trait univ2v2-pool-trait .univ2-pool-trait_v1_0_0.univ2-pool-trait)
(use-trait univ2v2-fees-trait .univ2-fees-trait_v1_0_0.univ2-fees-trait)

(use-trait curve-pool-trait   .curve-pool-trait_v1_0_0.curve-pool-trait)
(use-trait curve-fees-trait   .curve-fees-trait_v1_0_0.curve-fees-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; max 2047 edge tuples
(define-constant MAX-EDGES    u500) ;;effectively max nr of pools (stx -> *)
(define-constant MAX-PATH-LEN u4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pool types
(define-constant UNIV2   "u")
(define-constant UNIV2V2 "v")
(define-constant CURVE   "c")

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
 (id (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
 (get c edge))
(define-read-only
 (from-is-token0 (edge {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
 (get f edge))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public
  (apply
   (path   (list 4 {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
   (amt-in uint)

   ;; ctx
   (token1         (optional <ft-trait>))
   (token2         (optional <ft-trait>))
   (token3         (optional <ft-trait>))
   (token4         (optional <ft-trait>))
   (token5         (optional <ft-trait>))

   ;; v1
   (share-fee-to   (optional <share-fee-to-trait>))

   ;; v2
   (univ2v2-pool-1 (optional <univ2v2-pool-trait>))
   (univ2v2-pool-2 (optional <univ2v2-pool-trait>))
   (univ2v2-pool-3 (optional <univ2v2-pool-trait>))
   (univ2v2-pool-4 (optional <univ2v2-pool-trait>))

   (univ2v2-fees-1 (optional <univ2v2-fees-trait>))
   (univ2v2-fees-2 (optional <univ2v2-fees-trait>))
   (univ2v2-fees-3 (optional <univ2v2-fees-trait>))
   (univ2v2-fees-4 (optional <univ2v2-fees-trait>))

   (curve-pool-1   (optional <curve-pool-trait>))
   (curve-pool-2   (optional <curve-pool-trait>))
   (curve-pool-3   (optional <curve-pool-trait>))
   (curve-pool-4   (optional <curve-pool-trait>))

   (curve-fees-1   (optional <curve-fees-trait>))
   (curve-fees-2   (optional <curve-fees-trait>))
   (curve-fees-3   (optional <curve-fees-trait>))
   (curve-fees-4   (optional <curve-fees-trait>))
   )
  (let ((swap1 (try! (swap (element-at? path u0) amt-in
                           token1 token2
                           share-fee-to
                           univ2v2-pool-1 univ2v2-fees-1
                           curve-pool-1 curve-fees-1)))
        (swap2 (try! (swap (element-at? path u1) (get amt-out swap1)
                           token2 token3
                           share-fee-to
                           univ2v2-pool-2 univ2v2-fees-2
                           curve-pool-2 curve-fees-2)))
        (swap3 (try! (swap (element-at? path u2) (get amt-out swap2)
                           token3 token4
                           share-fee-to
                           univ2v2-pool-3 univ2v2-fees-3
                           curve-pool-3 curve-fees-3)))
        (swap4 (try! (swap (element-at? path u3) (get amt-out swap3)
                           token4 token5
                           share-fee-to
                           univ2v2-pool-4 univ2v2-fees-4
                           curve-pool-4 curve-fees-4)))
        )
    (ok
    {swap1: swap1,
     swap2: swap2,
     swap3: swap3,
     swap4: swap4,
    }) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-private
  (swap
   (edge   (optional {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool}))
   (amt-in uint)

   (token-in     (optional <ft-trait>))
   (token-out    (optional <ft-trait>))
   (share-fee-to (optional <share-fee-to-trait>))
   (univ2v2-pool (optional <univ2v2-pool-trait>))
   (univ2v2-fees (optional <univ2v2-fees-trait>))
   (curve-pool   (optional <curve-pool-trait>))
   (curve-fees   (optional <curve-fees-trait>))
   )
  (match
   edge
   e
    (if (is-univ2   e) (swap-univ2   e amt-in
                                     (unwrap-panic token-in) (unwrap-panic token-out)
                                     (unwrap-panic share-fee-to))
    (if (is-univ2v2 e) (swap-univ2v2 e amt-in
                                     (unwrap-panic token-in) (unwrap-panic token-out)
                                     (unwrap-panic univ2v2-pool) (unwrap-panic univ2v2-fees))
    (if (is-curve   e) (swap-curve   e amt-in
                                     (unwrap-panic token-in) (unwrap-panic token-out)
                                     (unwrap-panic curve-pool) (unwrap-panic curve-fees))
    (err u0))))
   (ok {amt-in: amt-in, amt-out: amt-in}) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public
  (swap-univ2
   (edge         {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (amt-in       uint)
   (token-in     <ft-trait>)
   (token-out    <ft-trait>)
   (share-fee-to <share-fee-to-trait>) )
  (let ((res
         (try!
          (contract-call?
           .univ2-router
           swap-exact-tokens-for-tokens
           (id edge)
           (if (from-is-token0 edge) token-in token-out)
           (if (from-is-token0 edge) token-out token-in)
           token-in
           token-out
           share-fee-to
           amt-in
           u1 ;;amt-out-min
           ))))
    (ok {amt-in: amt-in, amt-out: (get amt-out res)}) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public
  (swap-univ2v2
   (edge         {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (amt-in       uint)
   (token-in     <ft-trait>)
   (token-out    <ft-trait>)
   (univ2v2-pool <univ2v2-pool-trait>)
   (univ2v2-fees <univ2v2-fees-trait>)
   )
  (let ((res
         (try!
          (contract-call?
           univ2v2-pool
           swap
           token-in
           token-out
           univ2v2-fees
           amt-in
           u1 ;;amt-out-min
           ))))
    (ok {amt-in: amt-in, amt-out: (get amt-out res)}) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-public
  (swap-curve
   (edge         {a:(string-ascii 1),b:principal,c:uint,d:principal,e:principal,f:bool})
   (amt-in       uint)
   (token-in     <ft-trait>)
   (token-out    <ft-trait>)
   (curve-pool   <curve-pool-trait>)
   (curve-fees   <curve-fees-trait>)
   )
  (let ((res (try! (contract-call?
                      curve-pool
                      swap
                      token-in
                      token-out
                      curve-fees
                      amt-in
                      u1 ;;amt-out-min
                      ))))
    (ok {amt-in: amt-in, amt-out: (get amt-out res)}) ))

;;; eof

```
