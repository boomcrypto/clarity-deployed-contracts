---
title: "Trait memegoat-otc-v3"
draft: true
---
```
(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)


;; ERRS

(define-constant ERR-INSUFFICIENT-AMOUNT (err u5001))
(define-constant ERR-NOT-AUTHORIZED (err u5009))
(define-constant ERR-PAUSED (err u7000))
(define-constant ERR-POOL-NOT-FUNDED (err u8000))
(define-constant ERR-POOL-FUNDED (err u8001))
(define-constant ERR-OTC-SOLD-OUT (err u8002))

(define-constant ONE_8 u100000000)
(define-constant ONE_6 u1000000)

;; DATA MAPS AND VARS

;; set caller as contract owner
(define-data-var contract-owner principal tx-sender)

;; amount allocated for otc
(define-constant MEMEGOAT-POOL u470000000000000) ;; 470 miliion Memegoat

;; stx pool
(define-data-var stx-pool uint u0)
(define-data-var min-stx-deposit uint u1000000) ;; 1 STX
(define-data-var memegoat-rate uint u50000) ;;50k goatsx
(define-data-var vault-funded bool true)
(define-data-var paused bool false)
(define-data-var amount-sold uint u0)


;; MANAGEMENT CALLS

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)

(define-public (fund-otc)
  (begin
    (try! (check-is-owner))
    (asserts! (not (var-get vault-funded)) ERR-POOL-FUNDED)
    (try! (contract-call? .memegoatstx transfer-fixed (decimals-to-fixed MEMEGOAT-POOL) tx-sender .memegoat-vault-v1 none))
    (var-set vault-funded true)
    (var-set paused false)
    (ok true)
  )
)

(define-public (set-pause (action bool))
  (begin
    (try! (check-is-owner))
    (var-set paused action)
    (ok true)
  )
)

(define-public (set-rate (amount uint))
  (begin
    (try! (check-is-owner))
    (var-set memegoat-rate amount)
    (ok true)
  )
)

;; READ ONLY CALLS

(define-read-only (calculate-allocation (amount uint))
  (* (var-get memegoat-rate) amount) 
)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-read-only (get-memegoat-pool)
  (ok MEMEGOAT-POOL)
)

(define-read-only (get-stx-pool)
  (ok (var-get stx-pool))
)

(define-read-only (get-memegoat-rate)
  (ok (var-get memegoat-rate))
)

;; PRIVATE CALLS

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)

(define-private (decimals-to-fixed (amount uint)) 
  (/ (* amount ONE_8) ONE_6)
)

;; PUBLiC CALLS

;; buy otc
(define-public (buy-otc (amount uint))
  (begin
    (asserts! (>= amount (var-get min-stx-deposit)) ERR-INSUFFICIENT-AMOUNT)
    (asserts! (not (var-get paused)) ERR-PAUSED)
    (asserts! (var-get vault-funded) ERR-POOL-NOT-FUNDED)
    (let
      (
        (sender tx-sender)
        (stx-pool-balance (var-get stx-pool))
        (total-amount-sold (var-get amount-sold))
        (amount-to-send (calculate-allocation amount))
      )
      
      (asserts! (<= total-amount-sold MEMEGOAT-POOL) ERR-OTC-SOLD-OUT)
    
      ;; transfer stx to vault
      (try! (stx-transfer? amount tx-sender .memegoat-vault-v1))
      
      ;; transfer token from vault
      (as-contract (try! (contract-call? .memegoat-vault-v1 transfer-ft .memegoatstx (decimals-to-fixed amount-to-send) sender)))      

      ;; increment pool balance
      (var-set stx-pool (+ stx-pool-balance amount))
      
      ;; increment amount sold
      (var-set amount-sold (+ total-amount-sold amount-to-send))
    )
    (ok true)
  )
)
```
