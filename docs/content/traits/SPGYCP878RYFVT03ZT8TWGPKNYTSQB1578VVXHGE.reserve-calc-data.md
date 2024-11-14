---
title: "Trait reserve-calc-data"
draft: true
---
```
;; Define the contract owner
(define-constant contract-owner 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE)

;; Define the multiplier (3/1000 = 0.003)
(define-data-var multiplier uint u3)

;; Define the divisor for the multiplier (1000)
(define-constant MULTIPLIER_DIVISOR u1000)

;; Define the contract to call
(define-constant reserve-contract 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE.reserve-data-v4)

;; Define a map to store authorized principals
(define-map authorized-users principal bool)

;; Function to check if a principal is authorized
(define-private (is-authorized (user principal))
  (default-to false (map-get? authorized-users user)))

;; Function to add an authorized user (only contract owner can call)
(define-public (add-authorized-user (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u101))
    (ok (map-set authorized-users user true))))

;; Function to remove an authorized user (only contract owner can call)
(define-public (remove-authorized-user (user principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u102))
    (ok (map-delete authorized-users user))))

;; Function to update the multiplier (only contract owner can call)
(define-public (set-multiplier (new-multiplier uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u100))
    (ok (var-set multiplier new-multiplier))))

;; Main function to calculate reserves (only authorized users can call)
(define-public (calculate-reserves)
  (begin
    (asserts! (is-authorized tx-sender) (err u103))
    (let ((reserves (unwrap-panic (contract-call? reserve-contract get-multiple-simplified-reserves)))
          (mult (var-get multiplier)))
      (ok {
        pool3: (match (get pool3 reserves)
                 reserve (some (/ (* (get reserve0 reserve) mult) MULTIPLIER_DIVISOR))
                 none),
        pool4: (match (get pool4 reserves)
                 reserve (some (/ (* (get reserve1 reserve) mult) MULTIPLIER_DIVISOR))
                 none),
        pool5: (match (get pool5 reserves)
                 reserve (some (/ (* (get reserve0 reserve) mult) MULTIPLIER_DIVISOR))
                 none),
        pool6: (match (get pool6 reserves)
                 reserve (some (/ (* (get reserve0 reserve) mult) MULTIPLIER_DIVISOR))
                 none),
        pool7: (match (get pool7 reserves)
                 reserve (some (/ (* (get reserve0 reserve) mult) MULTIPLIER_DIVISOR))
                 none)
      }))))
```
