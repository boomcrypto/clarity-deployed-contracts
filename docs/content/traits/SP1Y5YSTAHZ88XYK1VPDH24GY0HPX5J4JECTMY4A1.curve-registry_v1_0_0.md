---
title: "Trait curve-registry_v1_0_0"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; traits
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(use-trait lp-token-trait .curve-lp-token-trait_v1_0_0.curve-lp-token-trait)
(use-trait pool-trait     .curve-pool-trait_v1_0_0.curve-pool-trait)
(use-trait fees-trait     .curve-fees-trait_v1_0_0.curve-fees-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-auth                   (err u1001))
(define-constant err-no-such-pool           (err u1002))
(define-constant err-init-preconditions     (err u1003))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ownership

(define-data-var owner principal tx-sender)
(define-read-only (get-owner) (var-get owner))
(define-private (check-owner)
  (ok (asserts! (is-eq tx-sender (get-owner)) err-auth)))
(define-public (set-owner (new-owner principal))
  (begin
   (try! (check-owner))
   (ok (var-set owner new-owner)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; storage
(define-data-var pool-id uint u0)

(define-private (next-pool-id)
  (let ((id  (var-get pool-id))
        (nxt (+ id u1)))
    (var-set pool-id nxt)
    nxt))

(define-read-only (get-nr-pools) (var-get pool-id))

(define-map pools
  uint
  {
    id               : uint,
    symbol           : (string-ascii 32),
    token0           : principal,
    token1           : principal,
    lp-token         : principal,
    contract         : principal,
    fees             : principal,
  })

(define-map index
  {token0: principal, token1: principal}
  uint)

(define-map pool-index
  {token0: principal, token1: principal}
  principal)

;; Set of known lp-tokens.
(define-map lp-tokens principal bool)

;; Set of known pool contracts
(define-map pool-contracts principal bool)

;; Set of known fee contracts
(define-map fees-contracts principal bool)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; read
(define-read-only (get-pool (id uint))
  (map-get? pools id))

(define-read-only (do-get-pool (id uint))
  (unwrap-panic (get-pool id)))

(define-read-only (get-pool-id (token0 principal) (token1 principal))
  (map-get? index {token0: token0, token1: token1}))

(define-read-only (get-pool-contract (token0 principal) (token1 principal))
  (map-get? pool-index {token0: token0, token1: token1}))

(define-read-only (lookup-pool (token0 principal) (token1 principal))
  (match (get-pool-id token0 token1)
         id (some {pool: (do-get-pool id), flipped: false, id: id})
         (match (get-pool-id token1 token0)
                id (some {pool: (do-get-pool id), flipped: true, id: id})
                none)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; register (create)
(define-read-only
  (take
    (n   uint)
    (str (string-ascii 32)))
  (if (<= (len str) n)
      str
      (unwrap-panic (slice? str u0 n))))

(define-private
  (make-symbol
    (token0 <ft-trait>)
    (token1 <ft-trait>))
  (let ((sym0 (take u15 (try! (contract-call? token0 get-symbol))))
        (sym1 (take u15 (try! (contract-call? token1 get-symbol)))))
    (asserts! (not (is-eq sym0 sym1)) err-init-preconditions)
    (ok (unwrap-panic (as-max-len? (concat sym0 (concat "-" sym1)) u32)))))

(define-public
  (register
    (token0       <ft-trait>)
    (token1       <ft-trait>)
    (lp-token     <lp-token-trait>)
    (pool         <pool-trait>)
    (fees         <fees-trait>)
    (A            uint))

  (let ((t0     (contract-of token0))
        (t1     (contract-of token1))
        (lp     (contract-of lp-token))
        (p      (contract-of pool))
        (f      (contract-of fees))
        (id     (next-pool-id))
        (symbol (try! (make-symbol token0 token1)))
        (pool_  (try! (contract-call? pool init token0 token1 lp-token fees A symbol))))

    ;; Pre-conditions
    (try! (check-owner))
    (asserts!
      (and
           (is-none (lookup-pool t0 t1))
           (not     (default-to false (map-get? lp-tokens lp)))
           (not     (default-to false (map-get? pool-contracts p)))
           (not     (default-to false (map-get? fees-contracts f)))
      )
      err-init-preconditions)

    ;; Update global state
    (try! (contract-call? lp-token init p symbol))
    (try! (contract-call? fees init p))

    ;; Update local state
    (map-set pools id
      {
        id      : id,
        symbol  : symbol,
        token0  : t0,
        token1  : t1,
        lp-token: lp,
        fees    : f,
        contract: p,
      })
    (map-set index {token0: t0, token1: t1} id)
    (map-set pool-index {token0: t0, token1: t1} p)
    (map-set lp-tokens lp true)
    (map-set fees-contracts f true)
    (map-set pool-contracts p true)

    ;; Post-conditions

    ;; Return
    (let ((event
          {op  : "create",
           user: tx-sender,
           pool: pool_}))
      (print event)
      (ok pool_)) ))

;;; eof

```
