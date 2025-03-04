(define-constant scaling-factor (contract-call? .constants-v1 get-scaling-factor))

(define-read-only (divide-round-up (numerator uint) (denominator uint))
  (if (> (mod numerator denominator) u0)
    (+ u1 (/ numerator denominator))
    (/ numerator denominator)
))

;; true indicates rounding up (ceiling), and false indicates rounding down (floor)
(define-read-only (divide (round-up bool) (num uint) (den uint))
  (if round-up (divide-round-up num den) (/ num den))
)

(define-read-only (sub (a uint) (b uint))
  (if (> b a) none (some (- a b)))
)

(define-read-only (safe-sub (a uint) (b uint))
  (if (> b a) u0 (- a b))
)

(define-read-only (safe-div (a uint) (b uint))
  (if (is-eq b u0) u0 (/ a b))
)

(define-read-only (calculate-interest-portions (current-debt uint) (borrowed-amount uint) (repay-amount uint))
  (let (
      (interest-accrued (- current-debt borrowed-amount))
      (interest-part (divide-round-up (* interest-accrued repay-amount) current-debt))
      (principal-part (- repay-amount interest-part))
    ) 
    {
      principal-part: principal-part,
      interest-part: interest-part
    }
))

(define-read-only (convert-to-debt-shares (debt-params {open-interest: uint, total-debt-shares: uint}) (assets uint) (round-up bool))
  (if (is-eq (get open-interest debt-params) u0)
    assets
    (divide round-up (* assets (get total-debt-shares debt-params)) (get open-interest debt-params))
))

(define-read-only (convert-to-debt-assets (debt-params {open-interest: uint, total-debt-shares: uint}) (shares uint) (round-up bool))
  (if (is-eq (get total-debt-shares debt-params) u0)
    shares
    (divide round-up (* (get open-interest debt-params) shares) (get total-debt-shares debt-params))
))

;; assets * total shares / total assets
(define-read-only (convert-to-shares (asset-params {total-assets: uint, total-shares: uint}) (assets uint) (round-up bool))
  (if (is-eq (get total-assets asset-params) u0)
    assets
    (divide round-up (* assets (get total-shares asset-params)) (get total-assets asset-params))
))

;; shares * total assets / total shares
(define-read-only (convert-to-assets (asset-params {total-assets: uint, total-shares: uint}) (shares uint) (round-up bool))
  (if (is-eq (get total-shares asset-params) u0)
    shares
    (divide round-up (* shares (get total-assets asset-params)) (get total-shares asset-params))
))

(define-read-only (get-market-asset-value (market-asset-price uint) (amount uint))
  (divide-round-up (* amount market-asset-price) scaling-factor)
)

(define-read-only (to-fixed (a uint) (decimals-a uint) (fixed-precision uint))
  (if (> decimals-a fixed-precision)
    (/ a (pow u10 (- decimals-a fixed-precision)))
    (* a (pow u10 (- fixed-precision decimals-a)))
))
