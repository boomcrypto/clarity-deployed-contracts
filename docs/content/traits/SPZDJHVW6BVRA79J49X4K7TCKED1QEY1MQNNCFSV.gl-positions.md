---
title: "Trait gl-positions"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-open-preconditions       (err u307))
(define-constant err-open-postconditions      (err u308))
(define-constant err-close-preconditions      (err u309))
(define-constant err-close-postconditions     (err u310))
(define-constant err-liquidate-preconditions  (err u311))
(define-constant err-liquidate-postconditions (err u312))

(define-constant err-permissions              (err u300))
(define-constant err-invariants               (err u399))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; states
(define-constant OPEN         u1)
(define-constant CLOSED       u2)
(define-constant LIQUIDATABLE u3)
(define-constant LIQUIDATED   u4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; permissions
(define-private
 (INTERNAL)
 (begin
  (asserts! (is-eq contract-caller .gl-core) err-permissions)
  (ok true)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; storage
(define-data-var position-id uint u0)
(define-private (next-position-id)
  (let ((id  (var-get position-id))
        (nxt (+ id u1)))
    (var-set position-id nxt)
    nxt))
(define-read-only (get-nr-positions) (var-get position-id))

;;----------------------------------------------------------------------
(define-map positions-store
  uint
  {
  id         : uint,
  pool       : uint,
  user       : principal,
  state      : uint,
  long       : bool,
  collateral : uint,
  leverage   : uint,
  interest   : uint,
  entry-price: uint,
  exit-price : uint,
  opened-at  : uint,
  closed-at  : uint,
  })

(define-read-only (lookup (id uint)) (unwrap-panic (map-get? positions-store id)))

(define-private
  (insert
   (new
    {
    id         : uint,
    pool       : uint,
    user       : principal,
    state      : uint,
    long       : bool,
    collateral : uint,
    leverage   : uint,
    interest   : uint,
    entry-price: uint,
    exit-price : uint,
    opened-at  : uint,
    closed-at  : uint,
    }))
  (begin
   (map-set positions-store (get id new) new)
   new))

;;----------------------------------------------------------------------
(define-constant MAX-POSITIONS u100)
(define-map user-positions
  principal
  (list 100 uint))

(define-private
  (insert-user-position
   (user principal)
   (id   uint))
  (map-set user-positions
           user
           (match (map-get? user-positions user)
                  ids (unwrap-panic (as-max-len? (append ids id) u100))
                  (list id))) )

(define-read-only (lookup-user-positions (user principal))
  (map lookup (lookup-user-positions-1 user)))

(define-read-only (lookup-user-positions-1 (user principal))
  (match (map-get? user-positions user)
         ids ids
         (list)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; open
(define-public
  (open
   (user       principal)
   (pool       uint)
   (long       bool)
   (collateral uint)
   (leverage   uint)
   (ctx        {price: uint, base-decimals: uint, quote-decimals: uint})
   )
  (let ((virtual-tokens
         (if long
             (contract-call? .gl-math quote-to-base collateral ctx)
             (contract-call? .gl-math base-to-quote collateral ctx)))
        (interest (* leverage virtual-tokens))
        (pos
         {
         user       : user,
         pool       : pool,
         id         : (next-position-id),
         long       : long,
         state      : OPEN,
         collateral : collateral,
         leverage   : leverage,
         interest   : interest,
         entry-price: (get price ctx),
         exit-price : u0,
         opened-at  : stacks-block-height,
         closed-at  : u0,
         })
        (positions (lookup-user-positions-1 user))
        (maxpos    (< (len positions) MAX-POSITIONS))
        (pool_     (contract-call? .gl-pools lookup pool))
        (legal     (contract-call? .gl-params is-legal-position pos))
        )

    (unwrap-panic (INTERNAL))

    (asserts!
     (and
      maxpos
      legal
      ) err-open-preconditions)

    (insert-user-position user (get id pos))
    (insert pos)

    (ok
     (merge
      pos
      {
      collateral-tagged: (if long
                             {base: u0, quote: collateral}
                             {base: collateral, quote: u0}),
      interest-tagged  : (if long {base: interest, quote: u0}
                             {base: u0, quote: interest}),
      }))
  ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; value
;;
;; LONGS
;; =====
;; collateral in quote token
;; conceptually we buy base tokens for collateral*leverage quote tokens
;; positive pnl -> number of virtual base tokens received as price goes to infinity
;; payouts in base tokens
;;
;; SHORTS
;; ======
;; collateral in base token
;; conceptually we sell collateral*leverage base tokens for quote tokens
;; positive pnl -> number of virtual quote tokens received as price goes to zero
;; payouts in quote tokens

;;; XXX c.f. math/eval
(define-constant ADD u1)
(define-constant SUB u2)

(define-read-only (PLUS  (n uint)) {op: ADD, arg: n})
(define-read-only (MINUS (n uint)) {op: SUB, arg: n})

(define-read-only
  (value
   (id  uint)
   (ctx {price: uint, base-decimals: uint, quote-decimals: uint}))

  (let ((pos  (lookup id))
        (fees (calc-fees id))
        (pnl  (try! (calc-pnl  id ctx (get remaining fees))))
        (long (get long pos))
        (pool (contract-call? .gl-pools lookup (get pool pos)))
        (bc   (get base-collateral pool))
        (qc   (get quote-collateral pool))
        ;; Accounting:
        (deltas
         (if long {
           ;; reduce open interest
           base-interest   : (list (MINUS (get interest pos))),
           quote-interest  : (list),

           ;; -> payout moves from reserves to user
           ;; -> funding-received moves from short collateral to user
           base-transfer   : (list (PLUS  (get payout pnl))
                                   (PLUS  (get funding-received fees))),
           base-reserves   : (list (MINUS (get payout pnl))),
           base-collateral : (list (MINUS (get funding-received fees))), ;; ->

           ;; -> user collateral moves from long collateral to reserves
           ;; -> except funding-paid which stays in long collateral to be
           ;;    moved by a past or future invocation of this function
           quote-transfer  : (list),
           quote-reserves  : (list (PLUS  (min (get collateral   pos) qc))
                                   (MINUS (get funding-paid fees))),
           quote-collateral: (list (PLUS  (get funding-paid fees))
                                   (MINUS (min (get collateral   pos) qc))),
           } {
           base-interest   : (list),
           quote-interest  : (list (MINUS (get interest pos))),

           base-transfer   : (list),
           base-reserves   : (list (PLUS  (min (get collateral pos) bc))
                                   (MINUS (get funding-paid fees))),
           base-collateral : (list (PLUS  (get funding-paid fees)) ;; <-
                                   (MINUS (min (get collateral   pos) bc))),

           quote-transfer  : (list (PLUS (get payout pnl))
                                   (PLUS (get funding-received fees))),
           quote-reserves  : (list (MINUS (get payout pnl))),
           quote-collateral: (list (MINUS (get funding-received fees))),
           }))
        )
    (ok {
    position : pos,
    fees     : fees,
    pnl      : pnl, ;;pnl.remaining is current collateral value
    deltas   : deltas,
    })))

(define-private
  (calc-fees
   (id uint)
   )
  (let ((pos   (lookup id))
        (pool  (contract-call? .gl-pools lookup (get pool pos)))
        (fees  (contract-call? .gl-fees calc
                               (get pool       pos)
                               (get long       pos)
                               (get collateral pos)
                               (get opened-at  pos)))
        (long   (get long pos))

        ;; we can run out of collateral due to pending liquidations
        ;; (in this case the avg total collateral will be larger than it should be)
        ;; users > LPs > protocol
        (c0                            (get collateral     pos))
        (c1 (deduct c0                 (get funding-paid   fees)))
        (c2 (deduct (get remaining c1) (get borrowing-paid fees)))
        (avail-pay                     (if long (get quote-collateral pool) (get base-collateral pool)))
        (funding-paid                  (min (get deducted c1) avail-pay))
        (borrowing-paid                (get deducted c2))
        (remaining                     (get remaining c2))
        (avail                         (if long (get base-collateral pool) (get quote-collateral pool)))
        ;; if `id' is pending liquidation, do not collect fees
        ;; always cap fees by available collateral
        (funding-received              (if (is-eq remaining u0)
                                            u0
                                           (min (get funding-received fees) avail)))
        )
    {
    funding-paid          : funding-paid,
    funding-paid-want     : (get funding-paid fees),
    funding-received      : funding-received,
    funding-received-want : (get funding-received fees),
    borrowing-paid        : borrowing-paid,
    borrowing-paid-want   : (get borrowing-paid fees),
    remaining             : remaining,
    }))

(define-read-only (min (x uint) (y uint)) (if (< x y) x y))

(define-read-only (deduct (x uint) (y uint))
  (if (>= x y)
      {remaining: (- x y), deducted: y}
      {remaining: u0,      deducted: x}))

;; (price - entry-price)*leverage*size
(define-private
  (calc-pnl
   (id        uint)
   (ctx       {price: uint, base-decimals: uint, quote-decimals: uint})
   (remaining uint))
  (let ((pos (lookup id)))
    (if (get long pos)
        (calc-pnl-long  id ctx remaining)
        (calc-pnl-short id ctx remaining))))

(define-private
  (calc-pnl-long
   (id        uint)
   (ctx       {price: uint, base-decimals: uint, quote-decimals: uint})
   (remaining uint))

  (let ((pos     (lookup id))
        (vtokens (get interest pos))
        (val0    (contract-call? .gl-math base-to-quote
                                 vtokens (merge ctx {price: (get entry-price pos)})))
        (val1    (contract-call? .gl-math base-to-quote
                                 vtokens ctx))

        (loss   (if (> val0 val1) (- val0 val1) u0))
        (profit (if (> val1 val0) (- val1 val0) u0))
        (final ;;in quote
         (if (is-eq remaining u0)
             u0 ;;should have been liquidated
             (if (> loss remaining)
                 u0
                 (if (> loss u0)
                     (- remaining loss)
                     (+ remaining profit)))))
        (payout (contract-call? .gl-math quote-to-base final ctx)) ;;at current price!
        )
    ;; assert same as alternative calc
    (asserts! (<= payout (get interest pos)) err-invariants)
    (ok {
    loss     : loss,
    profit   : profit,
    remaining: (if (> final profit) (- final profit) final),
    payout   : payout,
    })))

(define-private
  (calc-pnl-short
   (id        uint)
   (ctx       {price: uint, base-decimals: uint, quote-decimals: uint})
   (remaining-as-base uint))
  (let ((pos     (lookup id))
        (vtokens (* (get leverage pos) (get collateral pos)))
        (val0    (contract-call? .gl-math base-to-quote
                                 vtokens (merge ctx {price: (get entry-price pos)})))
        (val1    (contract-call? .gl-math base-to-quote
                                 vtokens ctx))
        (loss   (if (> val1 val0) (- val1 val0) u0))
        (profit (if (> val0 val1) (- val0 val1) u0))

        (remaining (contract-call? .gl-math base-to-quote remaining-as-base ctx))
        (final ;;in quote
         (if (is-eq remaining u0)
             u0
             (if (> loss remaining)
                 u0
                 (if (> loss u0)
                     (- remaining loss)
                     (+ remaining profit)))))
        (payout final)
        (left   (contract-call? .gl-math quote-to-base (if (> loss remaining) u0 (- remaining loss)) ctx))
      )
    (asserts! (<= payout (get interest pos)) err-invariants)
    (ok {
    loss     : loss,
    profit   : profit,
    remaining: left,
    payout   : final,
    })))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; state
(define-read-only
  (is-liquidatable
   (id  uint)
   (ctx {price: uint, base-decimals: uint, quote-decimals: uint}))
  (let ((v (unwrap-panic (value id ctx))))
    (contract-call? .gl-params is-liquidatable
                    (get position v)
                    (get pnl      v)
                    ) ))

(define-read-only
  (status
   (id  uint)
   (ctx {price: uint, base-decimals: uint, quote-decimals: uint}))
  (if (is-liquidatable id ctx)
      LIQUIDATABLE
      (get state (lookup id))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; close
(define-public
  (close
   (id  uint)
   (ctx {price: uint, base-decimals: uint, quote-decimals: uint}))

   (let ((pos (lookup id)))
     (unwrap-panic (INTERNAL))

     (asserts!
      (and
       (is-eq (status id ctx) OPEN) ;; FIXME or LIQUIDATABLE
       (> stacks-block-height (get opened-at pos)) ;;no same block open/closing
       ;; ...
       ) err-close-preconditions)

     (insert (merge pos {state     : CLOSED,
                         closed-at : stacks-block-height,
                         exit-price: (get price ctx)}))
     (value id ctx)) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; liquidate
;; FIXME: like close but some of collateral0 goes to the liquidator and protocol
;; (define-public
;;   (liquidate
;;    (id    uint)
;;    (ctx {price: uint, base-decimals: uint, quote-decimals: uint}))

;;    (let ((pos (lookup id)))
;;      (unwrap-panic (INTERNAL))

;;     (asserts!
;;       (is-eq (status id ctx) LIQUIDATABLE)
;;        err-liquidate-preconditions)

;;     (insert (merge pos {state: LIQUIDATED,
;;                         closed-at: stacks-block-height,
;;                         exit-price: (get price ctx)}))
;;     (value id ctx)) )

;;; eof


```
