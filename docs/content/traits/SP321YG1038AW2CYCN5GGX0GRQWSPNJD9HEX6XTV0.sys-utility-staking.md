---
title: "Trait sys-utility-staking"
draft: true
---
```
;;
;; =========
;; CONSTANTS
;; =========
;;

(define-constant err-invalid-argument                 (err u3002))
(define-constant err-not-authorized                   (err u3403))
(define-constant err-cycle-not-started                (err u3010))
(define-constant err-balance-too-low                  (err u3011))
;;
;; =========
;; DATA MAPS
;; =========
;;
(define-map staked-amounts principal  uint)

;;
;; ================
;; PUBLIC FUNCTIONS
;; ================
;;

(define-public (enter-staking (owner principal) (amount uint))
    (let 
        (
         (contract-addr (contract-call? .sys-admin get-owner))
         (curstake (default-to u0 (map-get? staked-amounts owner)))
         )
      (try! (contract-call? .sys-admin assert-invoked-by-operator))
      (try! (contract-call? .sys-utility transfer amount
                            owner
                            contract-addr
                            none))
      (map-set staked-amounts owner (+ curstake amount))
      (ok true)
      )
  )

(define-public (leave-staking (aowner principal) (amount uint))
    (let
        (
         (curstake (default-to u0 (map-get? staked-amounts aowner)))
         (contract-addr (contract-call? .sys-admin get-owner))
         )
      (try! (contract-call? .sys-admin assert-invoked-by-operator))
      (if (>= curstake amount)
          (begin
           (map-set staked-amounts aowner (- curstake amount))
           (contract-call? .sys-utility transfer amount
                           contract-addr aowner none)
           )
          err-balance-too-low)
      )
  )

;;
;; ===================
;; READ ONLY FUNCTIONS
;; ===================
;;
(define-read-only (get-staked-amount (who principal))
    (default-to u0 (map-get? staked-amounts who)))

```
