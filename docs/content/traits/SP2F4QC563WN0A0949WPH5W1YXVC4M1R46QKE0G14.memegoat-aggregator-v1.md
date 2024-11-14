---
title: "Trait memegoat-aggregator-v1"
draft: true
---
```
(use-trait dex-trait .dex-aggregator-trait.dex-aggregator-trait)
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-ext 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

;; MEMEGOAT AGGREGATOR ROUTER

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ROUTE-MISMATCH (err u500))
(define-constant ERR-UNREGISTERED-DEX (err u600))


(define-data-var  transfer-fee-percent uint u20000) ;; 2%
(define-data-var contract-owner principal tx-sender)
(define-map registered-dexes principal bool)
(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places
(define-constant ONE_8 (pow u10 u8)) ;; 8 decimal places


;; MANAGEMENT CALLS
(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)

(define-public (register-dex (dex principal))
  (begin
    (try! (check-is-owner)) 
    (ok (map-set registered-dexes dex true))
  )
)

;; PUBLIC CALLS
(define-public (dex-swap 
  (amt-in uint)
  (min-amt-out uint)
  (dex <dex-trait>) 
  (on-alex bool)
  (route1 (optional (list 5 <ft-trait>)))
  (route2 (optional (list 5 <ft-trait-ext>)))
  (factors (optional (list 4 uint)))
  )
  (let 
    (
      (transfer-fee (/ (* amt-in (var-get transfer-fee-percent)) (if on-alex ONE_8 ONE_6)))
      (amount-after-fee (- amt-in transfer-fee))
    )
    (try! (check-dex-registered (contract-of dex)))
    (if on-alex 
      (asserts! (and (is-none route1) (is-some route2)) ERR-ROUTE-MISMATCH)
      (asserts! (and (is-some route1) (is-none route2)) ERR-ROUTE-MISMATCH)      
    )
   (contract-call? dex swap amount-after-fee min-amt-out route1 route2 factors)
  )
)

(define-public (cross-dex-swap 
  (amt-in uint)
  (min-amt-out uint)
  (dex1 <dex-trait>) 
  (dex2 <dex-trait>) 
  (from-alex bool)
  (to-alex bool)
  (factors (optional (list 4 uint)))
  (route1 (optional (list 5 <ft-trait>)))
  (route2 (optional (list 5 <ft-trait-ext>)))
  (route3 (optional (list 5 <ft-trait>)))
  )
  (let 
    (
      (transfer-fee (/ (* amt-in (var-get transfer-fee-percent)) (if from-alex ONE_8 ONE_6)))
      (amount-after-fee (- amt-in transfer-fee))
    )
    (try! (check-dex-registered (contract-of dex1)))
    (try! (check-dex-registered (contract-of dex2)))

    (if from-alex
      (begin
        (let
          (
            (quote (try! (contract-call? dex1 get-quote amount-after-fee none route2 factors)))
            (result1 (try! (contract-call? dex1 swap amount-after-fee (get-last-value quote) none route2 factors)))
            (result2 (try! (contract-call? dex2 swap (get-last-value result1) min-amt-out route1 none none)))
          )
          (ok result2)
        )
      
      )
      (if to-alex
        (let
          (
            (quote (try! (contract-call? dex1 get-quote amount-after-fee route1 none none)))
            (result1 (try! (contract-call? dex1 swap amount-after-fee (get-last-value quote) route1 none none)))
            (result2 (try! (contract-call? dex2 swap (get-last-value result1) min-amt-out none route2 factors)))
          )
          (ok result2)
        )
        (let
          (
            (quote (try! (contract-call? dex1 get-quote amount-after-fee route1 none none)))
            (result1 (try! (contract-call? dex1 swap amount-after-fee (get-last-value quote) route1 none none)))
            (result2 (try! (contract-call? dex2 swap (get-last-value result1) min-amt-out route3 none none)))
          )
          (ok result2)
        )
      )
    )
  )
)

(define-private (get-last-value (result {t2-out: uint, t3-out: uint, t4-out: uint, t5-out: uint}))
  (let 
    (
      (t2 (get t2-out result))
      (t3 (get t3-out result))
      (t4 (get t4-out result))
      (t5 (get t5-out result))
    ) 
    (if (is-eq  t5 u0)
      (if (is-eq t4 u0)
        (if (is-eq t3 u0)
          t2
        t3)
      t4)
    t5)
  )
)

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (check-dex-registered (dex principal))
  (ok (asserts! (match (map-get? registered-dexes dex)
      value true
      false
  ) ERR-UNREGISTERED-DEX))
   
)
```
