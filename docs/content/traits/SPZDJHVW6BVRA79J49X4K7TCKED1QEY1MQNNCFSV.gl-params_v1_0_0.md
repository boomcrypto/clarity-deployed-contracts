---
title: "Trait gl-params_v1_0_0"
draft: true
---
```
;; this is the configuration/governance/etc contract
;;
;; put stuff like owner here as well? just to have everything writable
;; in one place
;;
;; needs sanity checks etc as before in case of operator key compromise
;;
;; per pool, ie everything stored in map
;;
;; formula = state + dynamic params + static params for sanity checks

(define-constant err-permissions (err u555))

(define-data-var owner principal tx-sender)
(define-read-only (is-owner) (is-eq tx-sender (var-get owner)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; static parameters

;; constants

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; dynamic parameters

;; Fees are stored as a numerator, with the denominator defined in gl-math
;;
;; Min fee example for 5 second blocks:
;;  1 year     = 6324480 blocks
;;  10% / year ~ 0.000_0016% / block
;;  in math.clar representation: 16
;;
;; Max fee example for 5 second blocks:
;;   8h      = 5760 blocks
;;   4% / 8h ~ 0.000_7% / block
;;   in math.clar representation: 7_000
;;
(define-data-var PARAMS
{
  MIN-FEE: uint,
  MAX-FEE: uint,
  PROTOCOL-FEE: uint,
  LIQUIDATION-FEE: uint,
  MIN-LONG-COLLATERAL: uint,
  MAX-LONG-COLLATERAL: uint,
  MIN-SHORT-COLLATERAL: uint,
  MAX-SHORT-COLLATERAL: uint,
  MIN-LONG-LEVERAGE: uint,
  MAX-LONG-LEVERAGE: uint,
  MIN-SHORT-LEVERAGE: uint,
  MAX-SHORT-LEVERAGE: uint,
  LIQUIDATION-THRESHOLD: uint,
}
{
  ;; TODO: good defaults?
  MIN-FEE: u1,
  MAX-FEE: u1,
  ;; Fraction of collateral
  PROTOCOL-FEE: u1000,
  ;; Fraction of remaining collateral
  LIQUIDATION-FEE: u2,
  ;; Depend on coin decimals.
  MIN-LONG-COLLATERAL: u1,
  MAX-LONG-COLLATERAL: u1000000000,
  MIN-SHORT-COLLATERAL: u1,
  MAX-SHORT-COLLATERAL: u1000000000,
  ;; E.g. 1 and 10
  MIN-LONG-LEVERAGE: u1,
  MAX-LONG-LEVERAGE: u10,
  MIN-SHORT-LEVERAGE: u1,
  MAX-SHORT-LEVERAGE: u10,
  ;; C.f. is_liquidatable, e.g. 1
  LIQUIDATION-THRESHOLD: u1,
})

(define-public
  (set-params
    (new-params {
      MIN-FEE: uint,
      MAX-FEE: uint,
      PROTOCOL-FEE: uint,
      LIQUIDATION-FEE: uint,
      MIN-LONG-COLLATERAL: uint,
      MAX-LONG-COLLATERAL: uint,
      MIN-SHORT-COLLATERAL: uint,
      MAX-SHORT-COLLATERAL: uint,
      MIN-LONG-LEVERAGE: uint,
      MAX-LONG-LEVERAGE: uint,
      MIN-SHORT-LEVERAGE: uint,
      MAX-SHORT-LEVERAGE: uint,
      LIQUIDATION-THRESHOLD: uint,
    }))
  (begin
    (asserts! (is-owner) err-permissions)
    (ok (var-set PARAMS new-params))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; API: fees (borrowing & funding)
(define-read-only
 (dynamic-fees
  (pool
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
   }
   ))

 ;; testnet blocks: 0.001% / block
 ;;    1      / 1 000 00
 ;; -> 1 0000 / 1 000 000 000
 ;; -> *DECIMALS
 (let ((max-fee           (get MAX-FEE (var-get PARAMS)))
       (long-utilization  (utilization (get base-reserves  pool) (get base-interest  pool)))
       (short-utilization (utilization (get quote-reserves pool) (get quote-interest pool)))
       (borrowing-long    (check-fee (scale max-fee long-utilization)))
       (borrowing-short   (check-fee (scale max-fee short-utilization)))
      )
   {
   borrowing-long : borrowing-long,
   borrowing-short: borrowing-short,
   funding-long   : (funding-fee borrowing-long  long-utilization  short-utilization),
   funding-short  : (funding-fee borrowing-short short-utilization long-utilization),
   }) )

(define-read-only
  (utilization
   (reserves uint)
   (interest uint))
  (if (or (is-eq reserves u0)
          (is-eq interest u0))
      u0
      (/ interest (/ reserves u100))))

(define-read-only (scale (fee uint) (utilization_ uint))
  (/ (* fee utilization_) u100))

(define-read-only (check-fee (fee uint))
  (let ((min-fee (get MIN-FEE (var-get PARAMS)))
        (max-fee (get MAX-FEE (var-get PARAMS))))

    (if (and (<= min-fee fee)
             (<= fee max-fee))
      fee
      (if (< fee min-fee)
          min-fee
          max-fee))))

(define-read-only (imbalance (n uint) (m uint))
  (if (>= n m) (- n m) u0))

(define-read-only
  (funding-fee
    (base-fee uint)
    (col1 uint)
    (col2 uint))

  (let ((imb (imbalance col1 col2)))
    (if (is-eq imb u0)
      u0
      (check-fee (scale base-fee imb))
  )))

;; one-off protocol fee
(define-read-only
 (static-fees
  (collateral uint))

 (let ((fee       (/ collateral (get PROTOCOL-FEE (var-get PARAMS))))
       (remaining (- collateral fee)))
   {
   fee      : fee,
   remaining: remaining,
   }))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; API: position properties
(define-read-only
 (is-legal-position
  (position
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
   }
   )
  )

 (let ((params     (var-get PARAMS))
       (collateral (get collateral position))
       (leverage   (get leverage position)))
  (if (get long position)
      (and (>= collateral (get MIN-LONG-COLLATERAL params))
           (<= collateral (get MAX-LONG-COLLATERAL params))
           (>= leverage   (get MIN-LONG-LEVERAGE params))
           (<= leverage   (get MAX-LONG-LEVERAGE params)))
      (and (>= collateral (get MIN-SHORT-COLLATERAL params))
           (<= collateral (get MAX-SHORT-COLLATERAL params))
           (>= leverage   (get MIN-SHORT-LEVERAGE params))
           (<= leverage   (get MAX-SHORT-LEVERAGE params)))
  )))

;; this may also want pool, fees
;; and possibly historical data
;; to take into account fee pressure
(define-read-only
 (is-liquidatable
  (position
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
   }
   )
  (pnl
   {
   loss     : uint,
   profit   : uint,
   remaining: uint,
   payout   : uint,
   }
   )
  )
  (let ((pct      (* (get LIQUIDATION-THRESHOLD (var-get PARAMS)) (get leverage position)))
        (required (/ (* (get collateral position) pct) u100))
        )
  (<= (get remaining pnl) required)))

(define-read-only
  (liquidation-fees
    (amt uint))

  (let ((fee (/ amt (get LIQUIDATION-FEE (var-get PARAMS)))))
    {
      fee: fee,
      remaining: (- amt fee),
    }
  ))

;;; eof

```
