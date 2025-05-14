---
title: "Trait pool-read-v2-1"
draft: true
---
```
(use-trait ft .ft-trait.ft-trait)
(use-trait ft-mint-trait .ft-mint-trait.ft-mint-trait)

(use-trait oracle-trait .oracle-trait.oracle-trait)

;; How to check when user is in isolation mode
;; 1) Get assets supplied with (get-user-assets)
;; 2) Filter supplied assets by assets that are isolated
;; 3) Filter isolated supplied assets by being enabled as collateral

(define-read-only (is-borroweable (asset principal))
  (let ((reserve-state (get-reserve-data asset)))
    (and
      (get is-active reserve-state)
      (not (get is-frozen reserve-state))
      (get borrowing-enabled reserve-state)
    )
  )
)

(define-read-only (is-active (asset principal))
  (let (
    (reserve-state (get-reserve-data asset))
  )
    (and (get is-active reserve-state) (not (get is-frozen reserve-state)))
  )
)

(define-constant available-assets (list
  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
  'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
  .wstx
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
  'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
  'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
  'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token
))

(define-read-only (get-supplieable-assets)
  available-assets
)

(define-read-only (get-borroweable-assets)
  (list
    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token
    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
    .wstx
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
    'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1
    'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
    'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token
  )
)

(define-read-only (get-assets-used-by (who principal))
  (let (
    (ret (get-user-assets who)))
    (unwrap-panic (as-max-len? (concat (get assets-supplied ret) (get assets-borrowed ret)) u100))))

(define-read-only (is-isolated-asset (asset principal))
  (contract-call? .pool-0-reserve-v2-0 is-isolated-type asset)
)

(define-read-only (get-isolated-mode-assets)
  (filter is-isolated-asset available-assets)
)

(define-read-only (is-borroweable-in-isolation (asset principal))
  (contract-call? .pool-0-reserve-v2-0 is-borroweable-isolated asset)
)

(define-read-only (get-borroweable-assets-in-isolated-mode)
  (filter is-borroweable-in-isolation available-assets)
)

(define-read-only (is-used-as-collateral (who principal) (asset principal))
  (get use-as-collateral (get-user-reserve-data who asset))
)

(define-read-only (get-user-reserve-data (who principal) (asset principal))
  (unwrap-panic (contract-call? .pool-reserve-data get-user-reserve-data-read who asset))
)

(define-read-only (get-asset-borrow-apy (reserve principal))
  (let (
    (reserve-resp (get-reserve-data reserve))
  )
    (calculate-compounded-interest
      (get current-variable-borrow-rate reserve-resp)
      (* u144 u365)
    )
  )
)

(define-read-only (token-to-usd (amount uint) (decimals uint) (unit-price uint))
  (contract-call? .math-v2-0 mul-to-fixed-precision amount decimals unit-price)
)

;; Define a helper function to get reserve data
(define-read-only (get-reserve-data (asset principal))
  (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read asset))
)

(define-read-only (get-max-borroweable
  (useable-collateral uint)
  (borrowed-collateral uint)
  (decimals uint)
  (asset-to-borrow <ft>)
  )
  (let ((price (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0 get-price)))
    (contract-call? .math-v2-0 mul-to-fixed-precision (- useable-collateral borrowed-collateral) decimals price)
  )
)

(define-read-only (get-user-assets (who principal))
  (default-to
    { assets-supplied: (list), assets-borrowed: (list) }
    (contract-call? .pool-reserve-data get-user-assets-read who)))

(define-read-only (is-isolated-type (asset principal))
  (default-to false (contract-call? .pool-reserve-data get-isolated-assets-read asset)))

(define-read-only (get-borrowed-balance-user-usd-ststx (who principal))
  (let (
    (balance (get-borrowed-balance-user-ststx who))
    (unit-price (get-ststx-price))
  )
    (token-to-usd (get compounded-balance balance) u6 unit-price)
  )
)

(define-read-only (get-borrowed-balance-user-usd-aeusdc (who principal))
  (let (
    (balance (get-borrowed-balance-user-aeusdc who))
    (unit-price (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.aeusdc-oracle-v1-0 get-price))
  )
    (token-to-usd (get compounded-balance balance) u6 unit-price)
  )
)

(define-read-only (get-borrowed-balance-user-usd-stx (who principal))
  (let (
    (balance (get-borrowed-balance-user-stx who))
    (unit-price (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.stx-oracle-v1-3 get-price))
  )
    (token-to-usd (get compounded-balance balance) u6 unit-price)
  )
)

(define-read-only (get-borrowed-balance-user-usd-diko (who principal))
  (let (
    (balance (get-borrowed-balance-user-diko who))
    (unit-price (unwrap-panic (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.diko-oracle-v1-0 get-price)))
  )
    (token-to-usd (get compounded-balance balance) u6 unit-price)
  )
)

(define-read-only (get-borrowed-balance-user-usd-usdh (who principal))
  (let (
    (balance (get-borrowed-balance-user-usdh who))
    (unit-price (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.usdh-oracle-v1-0 get-price))
  )
    (token-to-usd (get compounded-balance balance) u8 unit-price)
  )
)

(define-read-only (get-borrowed-balance-user-usd-susdt (who principal))
  (let (
    (balance (get-borrowed-balance-user-susdt who))
    (unit-price (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.susdt-oracle-v1-0 get-price))
  )
    (token-to-usd (get compounded-balance balance) u8 unit-price)
  )
)

(define-read-only (get-borrowed-balance-user-usd-usda (who principal))
  (let (
    (balance (get-borrowed-balance-user-usda who))
    (unit-price (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.usda-oracle-v1-1 get-price))
  )
    (token-to-usd (get compounded-balance balance) u6 unit-price)
  )
)

(define-read-only (get-borrowed-balance-user-usd-ststxbtc (who principal))
  (let (
    (balance (get-borrowed-balance-user-ststxbtc who))
    (unit-price (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.ststxbtc-oracle-v1-0 get-price))
  )
    (token-to-usd (get compounded-balance balance) u6 unit-price)
  )
)

(define-read-only (get-borrowed-balance-user-ststx (who principal))
  (get-user-borrow-balance who 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)
)

(define-read-only (get-borrowed-balance-user-aeusdc (who principal))
  (get-user-borrow-balance who 'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)
)

(define-read-only (get-borrowed-balance-user-stx (who principal))
  (get-user-borrow-balance who .wstx)
)

(define-read-only (get-borrowed-balance-user-diko (who principal))
  (get-user-borrow-balance who 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
)

(define-read-only (get-borrowed-balance-user-usdh (who principal))
  (get-user-borrow-balance who 'SPN5AKG35QZSK2M8GAMR4AFX45659RJHDW353HSG.usdh-token-v1)
)

(define-read-only (get-borrowed-balance-user-susdt (who principal))
  (get-user-borrow-balance who 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt)
)

(define-read-only (get-borrowed-balance-user-usda (who principal))
  (get-user-borrow-balance who 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token)
)

(define-read-only (get-borrowed-balance-user-ststxbtc (who principal))
  (get-user-borrow-balance who 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststxbtc-token)
)


(define-read-only (get-borrowed-balance (asset principal))
  (get total-borrows-variable (get-reserve-data asset))
)

(define-read-only (get-user-borrow-balance (who principal) (reserve principal))
  (let (
    (user-data (unwrap-panic (contract-call? .pool-reserve-data get-user-reserve-data-read who reserve)))
    (reserve-data (unwrap-panic (contract-call? .pool-reserve-data get-reserve-state-read reserve)))
    (principal (get principal-borrow-balance user-data))
    (cumulated-balance 
      (get-compounded-borrow-balance
        (get principal-borrow-balance user-data)
        (get decimals reserve-data)
        (get stable-borrow-rate user-data)
        (get last-updated-block user-data)
        (get last-variable-borrow-cumulative-index user-data)
        (get current-variable-borrow-rate reserve-data)
        (get last-variable-borrow-cumulative-index reserve-data)
        (get last-updated-block reserve-data)
      )))
    {
      principal-balance: principal,
      compounded-balance: cumulated-balance,
      balance-increase: (- cumulated-balance principal),
    }
  )
)

(define-read-only (get-compounded-borrow-balance
  ;; user-data
  (principal-borrow-balance uint)
  (decimals uint)
  (stable-borrow-rate uint)
  (last-updated-block uint)
  (last-variable-borrow-cumulative-index uint)
  ;; reserve-data
  (current-variable-borrow-rate uint)
  (last-variable-borrow-cumulative-index-reserve uint)
  (last-updated-block-reserve uint)
  )
  (let (
    (user-cumulative-index
      (if (is-eq last-variable-borrow-cumulative-index u0)
        last-variable-borrow-cumulative-index-reserve
        last-variable-borrow-cumulative-index
      )
    )
    (cumulated-interest
      (div
        (mul
          (calculate-compounded-interest
            current-variable-borrow-rate
            (- burn-block-height last-updated-block-reserve))
          last-variable-borrow-cumulative-index-reserve)
        user-cumulative-index))
    (compounded-balance (mul-precision-with-factor principal-borrow-balance decimals cumulated-interest)))
    (if (is-eq compounded-balance principal-borrow-balance)
      (if (not (is-eq last-updated-block burn-block-height))
        (+ principal-borrow-balance u1)
        compounded-balance
      )
      compounded-balance
    )
  )
)

(define-read-only (get-ststx-price)
  (let (
    (ststx-price (get last-price (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3 get-price "stSTX")))
  )
    (* ststx-price u100)
  )
)


(define-read-only (calculate-compounded-interest
  (current-liquidity-rate uint)
  (delta uint))
  (begin
    (taylor-6 (get-rt-by-block current-liquidity-rate delta))
  )
)

;; MATH
(define-constant one-8 u100000000)
(define-constant one-12 u1000000000000)
(define-constant fixed-precision u8)

(define-constant max-value u340282366920938463463374607431768211455)

(define-constant e 271828182)
;; (* u144 u365 u10 u60)
(define-constant seconds-in-year u31536000)
;; (* u10 u60)
(define-constant seconds-in-block u600)
;; seconds-year/seconds-block, to multiply with number of blocks to determine seconds passed in x number of blocks, is in fixed-precision
;; (/ (* seconds-in-block one-8) u31536000)
(define-constant sb-by-sy u1903)

(define-read-only (get-max-value)
  max-value
)

(define-read-only (mul (x uint) (y uint))
  (/ (+ (* x y) (/ one-8 u2)) one-8))

(define-read-only (div (x uint) (y uint))
  (/ (+ (* x one-8) (/ y u2)) y))

(define-read-only (mul-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    (mul (/ a (pow u10 (- decimals-a fixed-precision))) b-fixed)
    (mul (* a (pow u10 (- fixed-precision decimals-a))) b-fixed)
  )
)

(define-read-only (div-to-fixed-precision (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    (div (/ a (pow u10 (- decimals-a fixed-precision))) b-fixed)
    (div (* a (pow u10 (- fixed-precision decimals-a))) b-fixed)
  )
)

(define-read-only (div-precision-to-fixed (a uint) (b uint) (decimals uint))
  (let (
    (result (/ (* a (pow u10 decimals)) b)))
    (to-fixed result decimals)
  )
)

;; Multiply a number with arbitrary decimals with a fixed-precision number
;; return number with arbitrary decimals
(define-read-only (mul-precision-with-factor (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    ;; convert a and b-fixed in decimals-a precision
    ;; result is in decimals-a precision
    (mul-arbitrary a (* b-fixed (pow u10 (- decimals-a fixed-precision))) decimals-a)
    ;; convert a to fixed precision
    ;; result is in fixed precision, convert to decimals-a
    (/
      (mul-arbitrary (* a (pow u10 (- fixed-precision decimals-a))) b-fixed u8)
      (pow u10 (- fixed-precision decimals-a)))
  )
)

;; Divide a number with arbitrary decimals by a fixed-precision number, then return to
;; number with arbitrary decimals
(define-read-only (div-precision-with-factor (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    ;; convert b-fixed to decimals-a precision
    ;; final result is in decimals-a precision
    (div-arbitrary a (* b-fixed (pow u10 (- decimals-a fixed-precision))) decimals-a)
    ;; convert a to fixed precision
    ;; result is in fixed precision, convert to decimals-a
    (/
      (div-arbitrary (* a (pow u10 (- fixed-precision decimals-a))) b-fixed u8)
      (pow u10 (- fixed-precision decimals-a)))
  )
)

(define-read-only (mul-arbitrary (x uint) (y uint) (arbitrary-prec uint))
  (/ (+ (* x y) (/ (pow u10 arbitrary-prec) u2)) (pow u10 arbitrary-prec)))

(define-read-only (div-arbitrary (x uint) (y uint) (arbitrary-prec uint))
  (/ (+ (* x (pow u10 arbitrary-prec)) (/ y u2)) y))

(define-read-only (add-precision-to-fixed (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    (+ (/ a (pow u10 (- decimals-a fixed-precision))) b-fixed)
    (+ (* a (pow u10 (- fixed-precision decimals-a))) b-fixed)
  )
)

(define-read-only (sub-precision-to-fixed (a uint) (decimals-a uint) (b-fixed uint))
  (if (> decimals-a fixed-precision)
    (- (/ a (pow u10 (- decimals-a fixed-precision))) b-fixed)
    (- (* a (pow u10 (- fixed-precision decimals-a))) b-fixed)
  )
)

(define-read-only (to-fixed (a uint) (decimals-a uint))
  (if (> decimals-a fixed-precision)
    (/ a (pow u10 (- decimals-a fixed-precision)))
    (* a (pow u10 (- fixed-precision decimals-a)))
  )
)

;; multiply a number of arbitrary precision with a 8-decimals fixed number
;; convert back to unit of arbitrary precision
(define-read-only (mul-perc (a uint) (decimals-a uint) (b-fixed uint))
  (mul-precision-with-factor a decimals-a b-fixed)
)

(define-read-only (fix-precision (a uint) (decimals-a uint) (b uint) (decimals-b uint))
  (let (
    (a-standard
      (if (> decimals-a fixed-precision)
        (/ a (pow u10 (- decimals-a fixed-precision)))
        (* a (pow u10 (- fixed-precision decimals-a)))
      ))
    (b-standard
      (if (> decimals-b fixed-precision)
        (/ b (pow u10 (- decimals-b fixed-precision)))
        (* b (pow u10 (- fixed-precision decimals-b)))
      ))
  )
    {
      a: a-standard,
      decimals-a: decimals-a,
      b: b-standard,
      decimals-b: decimals-b,
    }
  )
)

(define-read-only (from-fixed-to-precision (a uint) (decimals-a uint))
  (if (> decimals-a fixed-precision)
    (* a (pow u10 (- decimals-a fixed-precision)))
    (/ a (pow u10 (- fixed-precision decimals-a)))
  )
)

;; x-price and y-price are in fixed precision
(define-read-only (get-y-from-x
  (x uint)
  (x-decimals uint)
  (y-decimals uint)
  (x-price uint)
  (y-price uint)
  )
  (if (> x-decimals y-decimals)
    ;; decrease decimals if x has more decimals
    (/ (div-precision-with-factor (mul-precision-with-factor x x-decimals x-price) x-decimals y-price) (pow u10 (- x-decimals y-decimals)))
    ;; do operations in the amounts with greater decimals, convert x to y-decimals
    (div-precision-with-factor (mul-precision-with-factor ( * x (pow u10 (- y-decimals x-decimals))) y-decimals x-price) y-decimals y-price)
  )
)

(define-read-only (is-odd (x uint))
  (not (is-even x))
)

(define-read-only (is-even (x uint))
  (is-eq (mod x u2) u0)
)

;; rate in 8-fixed
;; n-blocks
(define-read-only (get-rt-by-block (rate uint) (blocks uint))
  (/ (* rate (* blocks sb-by-sy)) one-8)
)

(define-read-only (get-sb-by-sy)
  sb-by-sy
)

(define-read-only (get-e) e)

(define-read-only (get-one) one-8)

(define-read-only (get-seconds-in-year)
  seconds-in-year
)

(define-read-only (get-seconds-in-block)
  seconds-in-block
)

(define-constant fact_2 u200000000)
;; (mul u300000000 u200000000)
(define-constant fact_3 u600000000)
;; (mul u400000000 (mul u300000000 u200000000))
(define-constant fact_4 u2400000000)
;; (mul u500000000 (mul u400000000 (mul u300000000 u200000000)))
(define-constant fact_5 u12000000000)
;; (mul u600000000 (mul u500000000 (mul u400000000 (mul u300000000 u200000000))))
(define-constant fact_6 u72000000000)

;; taylor series expansion to the 6th degree to estimate e^x
(define-read-only (taylor-6 (x uint))
  (let (
    (x_2 (mul x x))
    (x_3 (mul x x_2))
    (x_4 (mul x x_3))
    (x_5 (mul x x_4))
  )
    (+
      one-8 x
      (div x_2 fact_2)
      (div x_3 fact_3)
      (div x_4 fact_4)
      (div x_5 fact_5)
      (div (mul x x_5) fact_6)
    )
  )
)
```
