
(use-trait ft-trait       'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait lp-token-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ft-plus-trait.ft-plus-trait)
(use-trait oracle-trait   .gl-oracle-trait-pyth.oracle-trait)

(define-constant err-lock        (err u701))
(define-constant err-oracle      (err u702))
(define-constant err-permissions (err u700))

(define-private (call-get-decimals (token <ft-trait>))
  (unwrap-panic (contract-call? token get-decimals)))

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

(define-data-var oracle principal .gl-oracle-pyth)
(define-public (set-oracle (oracle0 <oracle-trait>))
  (begin
    (try! (OWNER))
    (ok (var-set oracle (contract-of oracle0)))))

;; (ctx0         { identifier: (buff 32), message: (buff 8192), oracle: <oracle-trait> }))

(define-private
  (CONTEXT
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (desired      uint)
    (slippage     uint)
    (ctx          {
                  identifier: (buff 32),
                  message   : (buff 8192),
                  oracle    : <oracle-trait>,
                  }))
  (let ((base-decimals  (call-get-decimals base-token))
        (quote-decimals (call-get-decimals quote-token))
        (oracle1        (get oracle ctx))
        (price          (try! (contract-call? oracle1 price quote-decimals desired slippage
                                (get identifier ctx)
                                (get message ctx)))) )

  (asserts! (is-eq (contract-of oracle1) (var-get oracle)) err-oracle)

  (ok {
      price         : price,
      base-decimals : base-decimals,
      quote-decimals: quote-decimals,
      })))

(define-map LOCK principal uint)

(define-private (check-unlocked)
  (if (is-eq
        (default-to u0 (map-get? LOCK tx-sender))
        stacks-block-height)
    err-lock
    (ok true)
  ))

(define-private (lock)
  (begin
    (try! (check-unlocked))
    (ok (map-set LOCK  tx-sender stacks-block-height))))

(define-public
  (mint
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (lp-token     <lp-token-trait>)
    (base-amt     uint)
    (quote-amt    uint)
    (desired      uint)
    (slippage     uint)
    (ctx0         { identifier: (buff 32), message: (buff 8192), oracle: <oracle-trait> }))

    (let ((ctx (try! (CONTEXT base-token quote-token desired slippage ctx0))))
      (try! (lock))
      (contract-call? .gl-core mint u1 base-token quote-token lp-token base-amt quote-amt ctx)
    ))

(define-public
  (burn
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (lp-token    <lp-token-trait>)
    (lp-amt       uint)
    (desired      uint)
    (slippage     uint)
    (ctx0         { identifier: (buff 32), message: (buff 8192), oracle: <oracle-trait> }))

    (let ((ctx (try! (CONTEXT base-token quote-token desired slippage ctx0))))
      (try! (lock))
      (contract-call? .gl-core burn u1 base-token quote-token lp-token lp-amt ctx)
    ))

(define-public
  (open
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (long         bool)
    (collateral   uint)
    (leverage     uint)
    (desired      uint)
    (slippage     uint)
    (ctx0         { identifier: (buff 32), message: (buff 8192), oracle: <oracle-trait> }))

  (let ((ctx (try! (CONTEXT base-token quote-token desired slippage ctx0))))
    (try! (lock))
     (contract-call? .gl-core open u1 base-token quote-token long collateral leverage ctx)
  ))

(define-public
  (close
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (position-id  uint)
    (desired      uint)
    (slippage     uint)
    (ctx0         { identifier: (buff 32), message: (buff 8192), oracle: <oracle-trait> }))

    (let ((ctx (try! (CONTEXT base-token quote-token desired slippage ctx0))))
      (try! (lock))
      (contract-call? .gl-core close u1 base-token quote-token position-id ctx)
    ))

(define-public
  (liquidate
    (base-token   <ft-trait>)
    (quote-token  <ft-trait>)
    (position-id  uint)
    (desired      uint)
    (slippage     uint)
    (ctx0         { identifier: (buff 32), message: (buff 8192), oracle: <oracle-trait> }))

  (let ((ctx (try! (CONTEXT base-token quote-token desired slippage ctx0))))
    (contract-call? .gl-core liquidate u1 base-token quote-token position-id ctx)
  ))
