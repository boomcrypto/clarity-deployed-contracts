;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; errors
(define-constant err-init-preconditions     (err u331))
(define-constant err-init-postconditions    (err u333))
(define-constant err-update-preconditions   (err u334))
(define-constant err-update-postconditions  (err u335))

(define-constant err-permissions            (err u400))
;; (define-constant err-invariants             (err u499))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; permissions
(define-private
  (INTERNAL)
  (begin
   (asserts!
    (or
     (is-eq contract-caller .gl-fees)
     (is-eq contract-caller .gl-core)
     (is-eq contract-caller .gl-positions)
     )
    err-permissions)
   (ok true)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; storage
(define-map fees-store
  uint
  {
  id                   : uint,
  t0                   : uint,
  t1                   : uint,
  borrowing-long       : uint,
  borrowing-short      : uint,
  funding-long         : uint,
  funding-short        : uint,
  long-collateral      : uint, ;;quote
  short-collateral     : uint, ;;base

  borrowing-long-sum   : uint,
  borrowing-short-sum  : uint,
  funding-long-sum     : uint,
  funding-short-sum    : uint,

  received-long-sum    : uint,
  received-short-sum   : uint,
  })

(define-read-only (lookup (id uint)) (unwrap-panic (map-get? fees-store id)))

(define-private
 (insert
  (new
   {
   id                   : uint,
   t0                   : uint,
   t1                   : uint,
   borrowing-long       : uint,
   borrowing-short      : uint,
   funding-long         : uint,
   funding-short        : uint,
   long-collateral      : uint, ;;quote
   short-collateral     : uint, ;;base

   borrowing-long-sum   : uint,
   borrowing-short-sum  : uint,
   funding-long-sum     : uint,
   funding-short-sum    : uint,

   received-long-sum    : uint,
   received-short-sum   : uint,
   }))
 (begin
  (map-set fees-store (get id new) new)
  new))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; init
(define-public
  (init (id uint))
  (begin
   (try! (INTERNAL))
   (ok (insert
    {
    id                   : id,
    t0                   : stacks-block-height,
    t1                   : stacks-block-height,
    borrowing-long       : u0,
    borrowing-short      : u0,
    funding-long         : u0,
    funding-short        : u0,
    long-collateral      : u0,
    short-collateral     : u0,

    borrowing-long-sum   : u0,
    borrowing-short-sum  : u0,
    funding-long-sum     : u0,
    funding-short-sum    : u0,

    received-long-sum    : u0,
    received-short-sum   : u0,
    }))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rolling sums (~ partially applied averages)
(define-read-only
  (extend
   (X   uint)
   (x_m uint)
   (m   uint))
  (+ X (* m x_m)))

(define-read-only
  (slice
   (y_i uint)
   (y_j uint))
  (- y_j y_i))

;; max total supply    = 10^10
;; min decimals        = 10^6
;; max decimals        = 10^8
;; --> max             = 10^18
;; --> min             = 10^6
;; max representable   = 10^38
;;
;; we assume collateral 10^6 <= c <= 10^16
;; (TODO: add checks / make this configurable)
;; 16-6 = 10 + 2 decimals
(define-constant ZEROS u1000000000000) ;;10^12

;; store paid * 1/C = paid * 1/sum(c_i)
(define-read-only
  (divide
   (paid       uint)
   (collateral uint))
  (if (is-eq collateral u0)
      u0
      (/ (* paid ZEROS)
         collateral))) ;;worst case: 10^16 * 10^12  / 10^6 = 10^22

(define-read-only
  (multiply
   (ci    uint)           ;;single position collateral
   (terms uint))          ;;paid_0 * 1/C_0 + ... paid_1 * 1/C_n
  (/ (* ci terms) ZEROS)) ;;worst case: 10^16 * 10^22 = 10^38

;; spiritually amount*fee (< 1)
(define-read-only
  (apply
   (amount uint)
   (fee    uint))
  (get fee (contract-call? .gl-math apply amount fee)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; update

(define-public (update (id uint))
  (begin
    (try! (INTERNAL))
    (ok (insert (current-fees id)))
  ))

(define-read-only (current-fees (id uint))
  (let ((fees     (lookup id))                                   ;;prev/last updated state
        (pool     (contract-call? .gl-pools lookup id))          ;;current state
        (new-fees (contract-call? .gl-params dynamic-fees pool)) ;;current state

        ;; this records:
        ;;   - the sum up to and not including this block
        ;;   - the total (sample) for this block

        (new-terms (- stacks-block-height  (get t1 fees)))

        ;; f_0 + ... + f_i
        (borrowing-long-sum  (extend (get borrowing-long-sum  fees) (get borrowing-long  fees) new-terms))
        (borrowing-short-sum (extend (get borrowing-short-sum fees) (get borrowing-short fees) new-terms))
        (funding-long-sum    (extend (get funding-long-sum    fees) (get funding-long    fees) new-terms))
        (funding-short-sum   (extend (get funding-short-sum   fees) (get funding-short   fees) new-terms))

        ;; payments made from longs to shorts (and vice versa) PER UNIT COLLATERAL:
        ;; paid    : f_0 * C_l_0           + ... + f_i * C_l_i
        ;; received: f_0 * C_l_0 * 1/C_s_0 + ... + f_i * C_l_i * 1/C_s_i
        (paid-long-term      (apply (get long-collateral fees) (* (get funding-long fees) new-terms)))
        (received-short-term (divide paid-long-term (get short-collateral fees)))

        (paid-short-term     (apply (get short-collateral fees) (* (get funding-short fees) new-terms)))
        (received-long-term  (divide paid-short-term (get long-collateral fees)))

        (received-long-sum   (extend (get received-long-sum  fees) received-long-term  u1))
        (received-short-sum  (extend (get received-short-sum fees) received-short-term u1))
        )

    (if (is-eq new-terms u0)
        (merge
            fees
              {
              borrowing-long      : (get borrowing-long   new-fees),
              borrowing-short     : (get borrowing-short  new-fees),
              funding-long        : (get funding-long     new-fees),
              funding-short       : (get funding-short    new-fees),
              long-collateral     : (get quote-collateral pool),
              short-collateral    : (get base-collateral  pool),
             })
            {
             id                   : (get id fees),
             t0                   : (get t0 fees),
             t1                   : stacks-block-height,
             ;; samples
             borrowing-long       : (get borrowing-long   new-fees),
             borrowing-short      : (get borrowing-short  new-fees),
             funding-long         : (get funding-long     new-fees),
             funding-short        : (get funding-short    new-fees),
             long-collateral      : (get quote-collateral pool),
             short-collateral     : (get base-collateral  pool),
             ;; sums
             borrowing-long-sum   : borrowing-long-sum,
             borrowing-short-sum  : borrowing-short-sum,
             funding-long-sum     : funding-long-sum,
             funding-short-sum    : funding-short-sum,
             received-long-sum    : received-long-sum,
             received-short-sum   : received-short-sum,
             })
        )
    )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; query

;; TODO: query without update?

;; (define-private
;;   (query
;;    (id   uint)
;;    (from uint))
;;   (begin
;;    (unwrap-panic (update id))
;;    (ok (do-query id from))))

(define-read-only
  (query
   (id        uint)
   (opened-at uint))
  (let ((fees-i (fees-at-block opened-at id))
        (fees-j (current-fees id)))
    {
    borrowing-long  : (slice (get borrowing-long-sum  fees-i) (get borrowing-long-sum  fees-j)),
    borrowing-short : (slice (get borrowing-short-sum fees-i) (get borrowing-short-sum fees-j)),
    funding-long    : (slice (get funding-long-sum    fees-i) (get funding-long-sum    fees-j)),
    funding-short   : (slice (get funding-short-sum   fees-i) (get funding-short-sum   fees-j)),
    received-long   : (slice (get received-long-sum   fees-i) (get received-long-sum   fees-j)),
    received-short  : (slice (get received-short-sum  fees-i) (get received-short-sum  fees-j)),
    }))

(define-read-only
 (fees-at-block
  (height uint)
  (id     uint))
 (let ((header (unwrap-panic (get-stacks-block-info? id-header-hash height))))
   (at-block header (lookup id)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; calc
(define-read-only
 (calc
  (id         uint)
  (long       bool)
  (collateral uint)
  (from       uint))
 (let ((period (query id from))
       (P_b    (if long
                   (apply    collateral (get borrowing-long  period))
                   (apply    collateral (get borrowing-short period))))
       (P_f    (if long
                   (apply    collateral (get funding-long    period))
                   (apply    collateral (get funding-short   period))))
       (R_f    (if long
                   (multiply collateral (get received-long   period))
                   (multiply collateral (get received-short  period))))
       )

   {
   funding-paid    : P_f,
   funding-received: R_f,
   borrowing-paid  : P_b,
   }))

;;; eof
