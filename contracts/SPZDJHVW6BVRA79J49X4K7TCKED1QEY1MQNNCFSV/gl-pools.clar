;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-create-preconditions     (err u201))
(define-constant err-create-postconditions    (err u202))
(define-constant err-mint-preconditions       (err u203))
(define-constant err-mint-postconditions      (err u204))
(define-constant err-burn-preconditions       (err u205))
(define-constant err-burn-postconditions      (err u206))
(define-constant err-open-preconditions       (err u207))
(define-constant err-open-postconditions      (err u208))
(define-constant err-close-preconditions      (err u209))
(define-constant err-close-postconditions     (err u210))
(define-constant err-liquidate-preconditions  (err u211))
(define-constant err-liquidate-postconditions (err u212))

(define-constant err-permissions              (err u200))
(define-constant err-invariants               (err u299))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; permissions
(define-private
 (INTERNAL)
 (begin
  (asserts! (is-eq contract-caller .gl-core) err-permissions)
  (ok true)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; storage
(define-data-var pool-id uint u0)
(define-private (next-pool-id)
  (let ((id  (var-get pool-id))
        (nxt (+ id u1)))
    (var-set pool-id nxt)
    nxt))
(define-read-only (get-nr-pools) (var-get pool-id))

;;----------------------------------------------------------------------
(define-map pools-store
  uint
  {
  id               : uint,
  symbol           : (string-ascii 65),
  base-token       : principal,
  quote-token      : principal,
  lp-token         : principal,
  ;; reserve tokens provided by LPs
  base-reserves    : uint,
  quote-reserves   : uint,
  ;; total open interest
  base-interest    : uint,
  quote-interest   : uint,
  ;; collateral tokens provided by users
  base-collateral  : uint,
  quote-collateral : uint,
  ;; net funding fee flows (paid - received)
  ;;base-transferred : int,
  ;;quote-transferred: int,
  })

(define-read-only (lookup (id uint)) (unwrap-panic (map-get? pools-store id)))

(define-private
  (insert
   (new
    {
    id               : uint,
    symbol           : (string-ascii 65),
    base-token       : principal,
    quote-token      : principal,
    lp-token         : principal,
    base-reserves    : uint,
    quote-reserves   : uint,
    base-interest    : uint,
    quote-interest   : uint,
    base-collateral  : uint,
    quote-collateral : uint,
    }))
  (begin
   (map-set pools-store (get id new) new)
   new))

;;----------------------------------------------------------------------
(define-map index {base: principal, quote: principal} uint)

(define-map lp-tokens principal uint)

(define-read-only
  (lookup-pair
   (base  principal)
   (quote principal))
  (map-get? index {base: base, quote: quote}))

(define-read-only (lookup-lp (lp-token principal)) (map-get? lp-tokens lp-token))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; create
(define-public
  (create
   (symbol      (string-ascii 65))
   (base-token  principal)
   (quote-token principal)
   (lp-token    principal))
  (let ((pool
         {
         id               : (next-pool-id),
         symbol           : symbol,
         base-token       : base-token,
         quote-token      : quote-token,
         lp-token         : lp-token,
         base-reserves    : u0,
         quote-reserves   : u0,
         base-interest    : u0,
         quote-interest   : u0,
         base-collateral  : u0,
         quote-collateral : u0,
         }))
    (try! (INTERNAL))
    (map-set index     {base: base-token, quote: quote-token} (get id pool))
    (map-set lp-tokens lp-token                               (get id pool))
    (ok (insert pool))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; reserves
(define-read-only (total-reserves (id uint))
  (let ((pool (lookup id)))
    {
    base : (get base-reserves  pool),
    quote: (get quote-reserves pool),
    } ))

(define-read-only (unlocked-reserves (id uint))
  (let ((pool (lookup id)))
    {
    base : (- (get base-reserves  pool) (get base-interest  pool)),
    quote: (- (get quote-reserves pool) (get quote-interest pool)),
    } ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mint
;;
;; lp tokens represent a share of the CURRENT POOL VALUE
;; pool-value = quote-tokens + (base-tokens * current-price)
;; (mint-value: same thing but for tokens added to pool)
;;
;; intuitively:
;;
;; lp-tokens  = mint-value/pool-value * total-supply
;; burn-value = lp-tokens/total-supply * pool-value
;;            = (mint-value/pool-value)*total-supply/total-supply * pool-value
;;            = mint-value
;;
;; error terms:
;; lp-tokens equation: takes share of current pool-value not of new pool-value
;; burn-value equation: total-supply has increased by lp-tokens
;;
;; lp = mv/(pv+mv) * ts
;; bv = (mv/(pv+mv) * ts)/(ts + (mv/(pv+mv) * ts)) * (pv+mv)
;;    = mv*ts / (ts + (mv/(pv+mv) * ts))
;; let mv/(pv+mv) = s <= 1.0
;;    = mv*ts / (1+s)*ts
;;    = mv*ts * 1/(1+s) * 1/ts
;;    = mv * 1/(1+s)
;;
;; if we special case ts=0 to return mv lp token:
;; lp = mv
;; bv = mv/mv * mv = mv
;;
;; subsequently, to reduce error, e.g. approximate
;;
;; f(x)              = mv/(pv+mv) * x          = s*x
;; f_0 = f(ts)       = mv/(pv+mv) * ts         = s*ts
;; f_1 = f(ts + f_0) = mv/(pv+mv) * (ts + f_0) = s*(ts+(s*ts)) = s*ts + s*s*ts = f_0 + s*f_0
;; ...
;;
;; bv = f_1 / (ts+f_1) * (pv+mv)
;;    = mv/(pv+mv)*(ts+f_0) * 1/(ts+f_1) * (pv+mv)
;;    = mv * (ts+f_0)/(ts+f_1)
;;    = mv * (1+s)(ts) * 1/(ts + s*ts + s*s*ts)
;;    = mv * (1+s)(ts) * 1/(1+s+s*s)*ts
;;    = mv * (1+s)/((1+s) + (s*s))
(define-public
  (mint
   (id        uint)
   (base-amt  uint)
   (quote-amt uint))
  (let ((pool (lookup id)))
    (try! (INTERNAL))
    (ok (insert
     (merge
      pool
      {
      base-reserves : (+ (get base-reserves  pool) base-amt),
      quote-reserves: (+ (get quote-reserves pool) quote-amt),
      })))) )

;; FIXME: asserts: max pool share? max mint/burn delta?

(define-public
  (calc-mint
   (id           uint)
   (base-amt     uint)
   (quote-amt    uint)
   (total-supply uint)
   (ctx          {price: uint, base-decimals: uint, quote-decimals: uint}) )
  (let ((pv  (get total-as-quote (contract-call?
                                  .gl-math value (total-reserves id) ctx)))
        (mv  (get total-as-quote (contract-call?
                                  .gl-math value {base: base-amt, quote: quote-amt} ctx)))
        )
    (ok (f mv pv total-supply) )))

(define-read-only
  (f (mv uint)
     (pv uint)
     (ts uint))
  (if (is-eq ts u0)
      mv
      (/ (* mv ts) pv)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; burn
(define-public
  (burn
   (id        uint)
   (base-amt  uint)
   (quote-amt uint))
  (let ((pool (lookup id)))
    (try! (INTERNAL))
    (ok (insert
     (merge
      pool
      {
      base-reserves : (- (get base-reserves  pool) base-amt),
      quote-reserves: (- (get quote-reserves pool) quote-amt),
      })))) )

(define-public
  (calc-burn
   (id           uint)
   (lp-amt       uint)
   (total-supply uint)
   (ctx          {price: uint, base-decimals: uint, quote-decimals: uint}) )
  (let ((pool-value     (get total-as-quote
                             (contract-call? .gl-math value (total-reserves id) ctx)))
        (burn-value     (g lp-amt total-supply pool-value))
        (unlocked       (unlocked-reserves id))
        (value          (contract-call? .gl-math value unlocked ctx))
        (unlocked-value (get total-as-quote value))
        (amts           (contract-call? .gl-math balanced value burn-value ctx))
        )

    (asserts!
     (and
      (>= unlocked-value burn-value)
      (<= (get base  amts) (get base  unlocked))
      (<= (get quote amts) (get quote unlocked))
      ) err-burn-preconditions)
    (ok amts)))

(define-read-only
  (g
   (lp uint)
   (ts uint)
   (pv uint))
  (/ (* lp pv)
     ts))

;; lp*pv / ts < uv
;; FIXME: rename and wrapper in gl-library
(define-read-only
  (max-burn
   (id           uint)
   (total-supply uint)
   (ctx          {price: uint, base-decimals: uint, quote-decimals: uint}) )
  (let ((pool-value     (get total-as-quote
                             (contract-call? .gl-math value (total-reserves id)    ctx)))
        (unlocked-value (get total-as-quote
                             (contract-call? .gl-math value (unlocked-reserves id) ctx))) )
    (- (/ (* unlocked-value total-supply) pool-value) u1) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; open
(define-public
  (open
   (id         uint)
   (collateral {base: uint, quote: uint})
   (interest   {base: uint, quote: uint})
   )

  (let ((pool     (lookup id))
        (reserves (unlocked-reserves id)))

    (unwrap-panic (INTERNAL))

    (asserts!
     (and
      (>= (get base  reserves) (get base interest))
      (>= (get quote reserves) (get quote interest))
      ) err-open-preconditions)

    (ok (insert
     (merge
      pool
      {
      base-interest   : (+ (get base-interest    pool) (get base  interest)),
      quote-interest  : (+ (get quote-interest   pool) (get quote interest)),
      base-collateral : (+ (get base-collateral  pool) (get base  collateral)),
      quote-collateral: (+ (get quote-collateral pool) (get quote collateral)),
      })))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; close
(define-public
  (close
   (id uint)
   (d
    {
    base-interest   : (list 100 {op: uint, arg: uint}),
    quote-interest  : (list 100 {op: uint, arg: uint}),
    base-transfer   : (list 100 {op: uint, arg: uint}),
    base-reserves   : (list 100 {op: uint, arg: uint}),
    base-collateral : (list 100 {op: uint, arg: uint}),
    quote-transfer  : (list 100 {op: uint, arg: uint}),
    quote-reserves  : (list 100 {op: uint, arg: uint}),
    quote-collateral: (list 100 {op: uint, arg: uint}),
    })
   )

  (let ((pool (lookup id)))

    (unwrap-panic (INTERNAL))

    (asserts! true err-close-preconditions) ;;type checker hint

    (ok (insert
     (merge
      pool
      {
      base-interest   : (contract-call? .gl-math eval (get base-interest   pool) (get base-interest   d)),
      quote-interest  : (contract-call? .gl-math eval (get quote-interest  pool) (get quote-interest  d)),
      base-reserves   : (contract-call? .gl-math eval (get base-reserves   pool) (get base-reserves   d)),
      quote-reserves  : (contract-call? .gl-math eval (get quote-reserves  pool) (get quote-reserves  d)),
      base-collateral : (contract-call? .gl-math eval (get base-collateral pool) (get base-collateral d)),
      quote-collateral: (contract-call? .gl-math eval (get quote-collateral pool) (get quote-collateral d)),
      })))

    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; liquidate

;;; eof
