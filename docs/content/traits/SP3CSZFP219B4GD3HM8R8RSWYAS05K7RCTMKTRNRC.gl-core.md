---
title: "Trait gl-core"
draft: true
---
```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; traits
(use-trait ft-trait       'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait lp-token-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ft-plus-trait.ft-plus-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-create-preconditions     (err u101))
(define-constant err-create-postconditions    (err u102))
(define-constant err-mint-preconditions       (err u103))
(define-constant err-mint-postconditions      (err u104))
(define-constant err-burn-preconditions       (err u105))
(define-constant err-burn-postconditions      (err u106))
(define-constant err-open-preconditions       (err u107))
(define-constant err-open-postconditions      (err u108))
(define-constant err-close-preconditions      (err u109))
(define-constant err-close-postconditions     (err u110))
(define-constant err-liquidate-preconditions  (err u111))
(define-constant err-liquidate-postconditions (err u112))
(define-constant err-collect-preconditions    (err u113))

(define-constant err-permissions              (err u100))
(define-constant err-invariants               (err u199))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; permissions
(define-data-var owner principal tx-sender)
(define-read-only (get-owner) (var-get owner))
(define-public (set-owner (new-owner principal))
  (begin
   (try! (OWNER))
   (ok (var-set owner new-owner)) ))

(define-private
 (OWNER)
 (begin
  (asserts! (is-eq contract-caller (get-owner)) err-permissions)
  (ok true)))

(define-private
 (INTERNAL)
 (is-eq contract-caller .gl-api))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SIP tokens
(define-private (call-get-decimals (token <ft-trait>))
  (unwrap-panic (contract-call? token get-decimals)))

(define-private (call-get-balance (token <ft-trait>))
  (let ((protocol (as-contract tx-sender)))
    (unwrap-panic (contract-call? token get-balance protocol))))

(define-private (call-transfer-from (token <ft-trait>) (amt uint) (user principal))
  (let ((protocol (as-contract tx-sender)))
    (if (> amt u0)
        (unwrap-panic (contract-call? token transfer amt user protocol none))
        false)))

(define-private (call-transfer-to (token <ft-trait>) (amt uint) (user principal))
  (let ((protocol (as-contract tx-sender)))
    (if (> amt u0)
        (unwrap-panic (as-contract (contract-call? token transfer amt protocol user none)))
        false)))

(define-private (call-get-total-supply (token <lp-token-trait>))
  (unwrap-panic (contract-call? token get-total-supply)))

(define-private (call-mint (token <lp-token-trait>) (amt uint) (user principal))
  (unwrap-panic (as-contract (contract-call? token mint amt user))))

(define-private (call-burn (token <lp-token-trait>) (amt uint) (user principal))
  (unwrap-panic (as-contract (contract-call? token burn amt user))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; invariants
(define-private
  (INVARIANTS
   (id          uint)
   (base-token  <ft-trait>)
   (quote-token <ft-trait>))

  (let ((pool          (contract-call? .gl-pools lookup id))
        (base-balance  (call-get-balance base-token))
        (quote-balance (call-get-balance quote-token)))

    (asserts!
     (and
      ;; balance >= reserves + collateral
      (>= base-balance  (+ (get base-reserves  pool) (get base-collateral  pool)))
      (>= quote-balance (+ (get quote-reserves pool) (get quote-collateral pool)))
      ;; reserves >= interest
      (>= (get base-reserves  pool) (get base-interest  pool))
      (>= (get quote-reserves pool) (get quote-interest pool))
      )
     err-invariants)

    (ok true) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; create

(define-public
  (create
   (symbol      (string-ascii 65))
   (base-token  <ft-trait>)
   (quote-token <ft-trait>)
   (lp-token    <lp-token-trait>))
  (let ((base  (contract-of base-token))
        (quote (contract-of quote-token))
        (lp    (contract-of lp-token)))

    (unwrap-panic (OWNER))

    ;; Pre-conditions
    (asserts!
     (and (is-none (contract-call? .gl-pools lookup-pair base quote))
          (is-none (contract-call? .gl-pools lookup-pair quote base))
          (is-none (contract-call? .gl-pools lookup-lp   lp)))
     err-create-preconditions)

    ;; Update global state

    ;; Update local state
    (let ((pool (try! (contract-call? .gl-pools create symbol base quote lp))))
      (try! (contract-call? .gl-fees init (get id pool)))

      ;; Post-conditions

      ;; Return
      (let ((event
             {op  : "create",
              user: tx-sender,
              pool: pool}))
        (print event)
        (ok event)) )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mint
(define-public
  (mint
   (id          uint)
   (base-token  <ft-trait>)
   (quote-token <ft-trait>)
   (lp-token    <lp-token-trait>)
   (base-amt    uint)
   (quote-amt   uint)
   (ctx         {price: uint, base-decimals: uint, quote-decimals: uint}))

  (let ((user         tx-sender)
        (total-supply (call-get-total-supply lp-token))
        (pool         (contract-call? .gl-pools lookup id))
        (lp-amt       (unwrap-panic
                       (contract-call?
                        .gl-pools calc-mint id base-amt quote-amt total-supply ctx)))
        )

    ;; Pre-conditions
    (asserts!
     (and
      (INTERNAL)
      (is-eq (get base-token  pool) (contract-of base-token))
      (is-eq (get quote-token pool) (contract-of quote-token))
      (is-eq (get lp-token    pool) (contract-of lp-token))
      (or (> base-amt u0) (> quote-amt u0))
      (> lp-amt u0)
      ) err-mint-preconditions)

    ;; Update global state
    (call-transfer-from base-token  base-amt  user)
    (call-transfer-from quote-token quote-amt user)
    (call-mint          lp-token    lp-amt    user)

    ;; Update local state
    (try! (contract-call? .gl-pools mint id base-amt quote-amt))
    (try! (contract-call? .gl-fees update id))

    ;; Post-conditions
    (try! (INVARIANTS id base-token quote-token))

    ;; Return
    (let ((event
           {op          : "mint",
            user        : user,
            pool        : pool,
            base-amt    : base-amt,
            quote-amt   : quote-amt,
            total-supply: total-supply,
            ctx         : ctx,
            lp-amt      : lp-amt,
           }))
      (print event)
      (ok event)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; burn
(define-public
  (burn
   (id          uint)
   (base-token  <ft-trait>)
   (quote-token <ft-trait>)
   (lp-token    <lp-token-trait>)
   (lp-amt      uint)
   (ctx         {price: uint, base-decimals: uint, quote-decimals: uint}))

  (let ((user         tx-sender)
        (total-supply (call-get-total-supply lp-token))
        (pool         (contract-call? .gl-pools lookup id))
        (amts         (try!
                       (contract-call? .gl-pools calc-burn id lp-amt total-supply ctx)))
        (base-amt     (get base  amts))
        (quote-amt    (get quote amts))
        )

    ;; Pre-conditions
    (asserts!
     (and
      (INTERNAL)
      (is-eq (get base-token  pool) (contract-of base-token))
      (is-eq (get quote-token pool) (contract-of quote-token))
      (is-eq (get lp-token    pool) (contract-of lp-token))
      (> lp-amt u0)
      (or (> base-amt u0) (> quote-amt u0))
      ) err-burn-preconditions)

    ;; Update global state
    (call-transfer-to base-token  base-amt  user)
    (call-transfer-to quote-token quote-amt user)
    (call-burn        lp-token    lp-amt    user)

    ;; Update local state
    (try! (contract-call? .gl-pools burn id base-amt quote-amt))
    (try! (contract-call? .gl-fees update id))

    ;; Post-conditions
    (try! (INVARIANTS id base-token quote-token))

    ;; Return
    (let ((event
           {op          : "burn",
            user        : user,
            pool        : pool,
            lp-amt      : lp-amt,
            total-supply: total-supply,
            ctx         : ctx,
            base-amt    : base-amt,
            quote-amt   : quote-amt,
           }))
      (print event)
      (ok event)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; open
(define-public
  (open
   (id            uint)
   (base-token    <ft-trait>)
   (quote-token   <ft-trait>)
   (long          bool)
   (collateral0   uint)
   (leverage      uint)
   (ctx           {price: uint, base-decimals: uint, quote-decimals: uint}))

  (let ((user       tx-sender)
        (pool       (contract-call? .gl-pools lookup id))
        (cf         (contract-call? .gl-params static-fees collateral0))
        (collateral (get remaining cf))
        (fee        (get fee cf))
        )

    ;; Pre-conditions
    (asserts!
     (and
      (INTERNAL)
      (is-eq (contract-of base-token)  (get base-token  pool))
      (is-eq (contract-of quote-token) (get quote-token pool))
      (> fee u0)
      (> collateral u0)
      ) err-open-preconditions)

    ;; Update global state
    (if long
        (call-transfer-from quote-token collateral0 user)
        (call-transfer-from base-token  collateral0 user) )

    (if long
        (call-transfer-to quote-token fee .gl-fees-bank)
        (call-transfer-to base-token  fee .gl-fees-bank) )

    ;; Update local state
    (let ((pos (try! (contract-call?
                      .gl-positions open user id long collateral leverage ctx)))
          )
      (try! (contract-call? .gl-pools open id (get collateral-tagged pos) (get interest-tagged pos)))
      (try! (contract-call? .gl-fees update id))

      ;; Post-conditions
      (try! (INVARIANTS id base-token quote-token))

      ;; Return
      (let ((event
             {op      : "open",
              user    : user,
              pool    : pool,
              position: pos,
              fee     : fee,
             }))
        (print event)
        (ok event)) )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; close
(define-public
  (close
   (id            uint)
   (base-token    <ft-trait>)
   (quote-token   <ft-trait>)
   (position-id   uint)
   (ctx           {price: uint, base-decimals: uint, quote-decimals: uint}))

  (let ((user     tx-sender)
      ;;(protocol (as-contract tx-sender))
        (pool     (contract-call? .gl-pools lookup id))
        (position (contract-call? .gl-positions lookup position-id))
        )

    ;; Pre-conditions
    (asserts!
     (and
      (INTERNAL)
      (is-eq (contract-of base-token)  (get base-token  pool))
      (is-eq (contract-of quote-token) (get quote-token pool))
      (is-eq id   (get pool position))
      (is-eq user (get user position))
      ) err-close-preconditions)

    ;; Update local state
    (let ((deltas    (get deltas (try! (contract-call? .gl-positions close position-id ctx))))
          (base-amt  (contract-call? .gl-math eval u0 (get base-transfer  deltas)))
          (quote-amt (contract-call? .gl-math eval u0 (get quote-transfer deltas)))
          )
      (try! (contract-call? .gl-pools close id deltas))
      (try! (contract-call? .gl-fees update id))

      ;; Update global state
      (call-transfer-to base-token  base-amt  user)
      (call-transfer-to quote-token quote-amt user)

      ;; Post-conditions
      (try! (INVARIANTS id base-token quote-token))

      ;; Return
      (let ((event
             {op      : "close",
              user    : user,
              pool    : pool,
              position: position,
              deltas  : deltas,
             }))
        (print event)
        (ok event))
      ) ) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; liquidate

;; if liquidatable, close without permission check. diff fee structure
(define-public
  (liquidate
   (id            uint)
   (base-token    <ft-trait>)
   (quote-token   <ft-trait>)
   (position-id   uint)
   (ctx           {price: uint, base-decimals: uint, quote-decimals: uint}))

  (let ((user     tx-sender)
        (pool     (contract-call? .gl-pools lookup id))
        (position (contract-call? .gl-positions lookup position-id))
        )

    ;; Pre-conditions
    (asserts!
     (and
      (INTERNAL)
      (is-eq (contract-of base-token)  (get base-token  pool))
      (is-eq (contract-of quote-token) (get quote-token pool))
      (is-eq id   (get pool position))
      (contract-call? .gl-positions is-liquidatable position-id ctx)
      ) err-liquidate-preconditions)

    ;; Update local state
    (let ((deltas          (get deltas (try! (contract-call? .gl-positions close position-id ctx))))
          (base-amt        (contract-call? .gl-math eval u0 (get base-transfer  deltas)))
          (quote-amt       (contract-call? .gl-math eval u0 (get quote-transfer deltas)))
          (base-amt-final  (contract-call? .gl-params liquidation-fees base-amt))
          (quote-amt-final (contract-call? .gl-params liquidation-fees quote-amt))
          )
      (try! (contract-call? .gl-pools close id deltas))
      (try! (contract-call? .gl-fees update id))

      ;; Update global state
      ;; liquidator gets liquidation fee, user gets whatever is left
      (call-transfer-to base-token  (get fee base-amt-final) user)
      (call-transfer-to quote-token (get fee quote-amt-final) user)
      (call-transfer-to base-token  (get remaining base-amt-final) (get user position))
      (call-transfer-to quote-token (get remaining quote-amt-final) (get user position))

      ;; Post-conditions
      (try! (INVARIANTS id base-token quote-token))

      ;; Return
      (let ((event
             {op      : "liquidate",
              user    : user,
              pool    : pool,
              position: position,
              deltas  : deltas,
             }))
        (print event)
        (ok event))
      ) ) )

;;; eof

```
