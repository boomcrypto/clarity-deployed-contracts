;; token math
;; ==========
;; * base/quote tokens may have different decimals
;; * lift -> calculate -> lower
;; * assume prices are unit prices (implicitly /one)
;; * outputs should just work with native repr we use for
;;   reserves/collateral/interest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; x = lower(lift(x))
(define-read-only
  (lift
   (tokens {base: uint, quote: uint})
   (ctx    {base-decimals: uint, quote-decimals: uint, price: uint}))
  (let ((bd (get base-decimals  ctx))
        (qd (get quote-decimals ctx))
        (s  (>= bd qd))
        (n  (if s (- bd qd) (- qd bd)))
        (m  (pow u10 n)))
    {
    base : (if s (get base tokens) (* (get base tokens) m)),
    quote: (if s (* (get quote tokens) m) (get quote tokens)),
    }
    ))

(define-read-only
  (lower
   (tokens {base: uint, quote: uint})
   (ctx    {base-decimals: uint, quote-decimals: uint, price: uint}))
  (let ((bd (get base-decimals  ctx))
        (qd (get quote-decimals ctx))
        (s  (>= bd qd))
        (n  (if s (- bd qd) (- qd bd)))
        (m  (pow u10 n)))
    {
    base : (if s (get base tokens) (/ (get base tokens) m)),
    quote: (if s (/ (get quote tokens) m) (get quote tokens)),
    }
    ))

(define-read-only
  (one
   (ctx {base-decimals: uint, quote-decimals: uint, price: uint}))
  (let ((bd (get base-decimals  ctx))
        (qd (get quote-decimals ctx))
        (s  (>= bd qd)))
    (if s (pow u10 bd) (pow u10 qd)) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; amount = price/one * volume
(define-read-only
  (to-amount
   (price  uint) ;;quote
   (volume uint) ;;base
   (one1   uint))
  (/ (* price volume) one1))

(define-read-only
  (from-amount
   (amount uint) ;;quote
   (price  uint) ;;quote
   (one1   uint))
  (/ (* amount one1) price))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; base  = quote-to-base(base-to-quote(base))
;; quote = base-to-quote(quote-to-base(quote))
(define-read-only
  (base-to-quote
   (tokens uint) ;;volume
   (ctx    {price: uint, base-decimals: uint, quote-decimals: uint}))
  (let ((lifted  (lift {base: tokens, quote: (get price ctx)} ctx))
        (amt0    (to-amount (get quote lifted) (get base lifted) (one ctx)))
        (lowered (lower {base: u0, quote: amt0} ctx)))
    (get quote lowered)))

(define-read-only
  (quote-to-base
   (tokens uint) ;;amount
   (ctx    {price: uint, base-decimals: uint, quote-decimals: uint}))
  (let ((l1      (lift {base: u0, quote: tokens         } ctx))
        (l2      (lift {base: u0, quote: (get price ctx)} ctx))
        (vol0    (from-amount (get quote l1) (get quote l2) (one ctx)))
        (lowered (lower {base: vol0, quote: u0} ctx)))
    (get base lowered) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; API: value of a bag of tokens expressed in terms of each token
(define-read-only
  (value
   (tokens {base: uint, quote: uint})
   (ctx    {price: uint, base-decimals: uint, quote-decimals: uint}))
  (let ((base                  (get base  tokens))
        (quote                 (get quote tokens))
        (base-as-quote         (base-to-quote base  ctx))
        (quote-as-base         (quote-to-base quote ctx))
        (total-as-base         (+ base  quote-as-base))
        (total-as-quote        (+ quote base-as-quote))
        (have-more-base        (> base-as-quote quote))
        (base-excess-as-base   (if have-more-base (- base quote-as-base)  u0))
        (base-excess-as-quote  (if have-more-base (- base-as-quote quote) u0))
        (quote-excess-as-base  (if have-more-base u0 (- quote-as-base base)))
        (quote-excess-as-quote (if have-more-base u0 (- quote base-as-quote)))
        )
    {
    base                  : base,
    quote                 : quote,
    base-as-quote         : base-as-quote,
    quote-as-base         : quote-as-base,
    total-as-base         : total-as-base,
    total-as-quote        : total-as-quote,
    have-more-base        : have-more-base,
    base-excess-as-base   : base-excess-as-base,
    base-excess-as-quote  : base-excess-as-quote,
    quote-excess-as-base  : quote-excess-as-base,
    quote-excess-as-quote : quote-excess-as-quote,
    } ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; API: balanced burning
;;
;; first pay out from extra
;; then equally from base/quote
(define-read-only
  (balanced
   (state
    {
    base                  : uint,
    quote                 : uint,
    base-as-quote         : uint,
    quote-as-base         : uint,
    total-as-base         : uint,
    total-as-quote        : uint,
    have-more-base        : bool,
    base-excess-as-base   : uint,
    base-excess-as-quote  : uint,
    quote-excess-as-base  : uint,
    quote-excess-as-quote : uint,
    })
   (burn-value uint) ;;as quote
   (ctx    {price: uint, base-decimals: uint, quote-decimals: uint})
   )
  ;; TODO: this needs to check if we can pay out what we want to pay out
  ;; (or proof that burn-value > unlocked-value implies that)
  ;; and possibly fallback strategies
  (if (get have-more-base state)
      (if (>= (get base-excess-as-quote state) burn-value)
          {base : (quote-to-base burn-value ctx), ;;assert < base-excess-as-base
           quote: u0}
          (let ((base1 (get base-excess-as-base state))
                (left  (- burn-value (get base-excess-as-quote state)))
                (quote (/ left u2))
                (base2 (quote-to-base quote ctx))
                (base  (+ base1 base2)))
            {base : base,
             quote: quote}))
      (if (>= (get quote-excess-as-quote state) burn-value)
          {base : u0,
           quote: burn-value}
           (let ((quote1 (get quote-excess-as-quote state))
                 (left   (- burn-value quote1))
                 (quote2 (/ left u2))
                 (base   (quote-to-base quote2 ctx))
                 (quote  (+ quote1 quote2)))
             {base : base,
              quote: quote})) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; API: borrowing/funding fees
;;
;; Fees are represented as a numerator with a fixed denominator.
;; Intuitively, a reasonable denominator for hourly fees would be something
;; like 100_000 (smallest representable fee = 0.001% per hour).
;; Assuming worst-case block times of ~3 seconds, we need to divide that by ~1000
;; (but we add an extra 0 just in case).
(define-constant DENOM u1000000000) ;;10^9

;; - params.clar calculates a per block fee rate (numerator)
;; - we add decimals and store/use that representations in fees.clar
;; - when calculating absolute fee amounts we need to take the various
;;   representations into account
;;
;; - `x' is a number representing some amount of tokens
;;   on the order of 10^16 (<=10bn with 6 decimals).
;; - 0 <= NUM <= DENOM (10^9)
;; - stacks can represent uints up to ~10^38
;; - x*NUM < 10^25
(define-read-only
  (apply
   (x   uint)
   (num uint)) ;;per-block fee rate
  (let ((fee       (/ (* x num) DENOM))
        (remaining (if (<= fee x) (- x fee) u0))
        (fee_      (if (<= fee x) fee x))
        )
    {
    fee      : fee_,
    remaining: remaining,
    }))

;; FIXME call this in params/static-fees

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; API: formula dsl
(define-constant ADD u1)
(define-constant SUB u2)
(define-constant MUL u3)
(define-constant DIV u4)

(define-read-only
 (eval
  (n      uint)
  (instrs (list 100 {op: uint, arg: uint})))
 (fold eval-1 instrs n))

(define-read-only
  (eval-1
   (instr {op: uint, arg: uint})
   (n     uint))
  (let ((op  (get op  instr))
        (arg (get arg instr))
        (res (if (is-eq op ADD)
            (some (+ n arg))
            (if (is-eq op SUB)
                (some (- n arg))
                (if (is-eq op MUL)
                    (some (* n arg))
                    (if (is-eq op DIV)
                        (some (/ n arg))
                        none)
                        ))))
        )
    (unwrap-panic res)))

;;; eof
