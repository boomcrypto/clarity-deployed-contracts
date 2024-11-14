---
title: "Trait reserve-data-v2"
draft: true
---
```
;; Define the contract

;; Define the authorized principal
(define-constant authorized-principal 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE)

;; Define a map to keep track of which pools to check
(define-map pools-to-check uint bool)

;; Define a function to get reserves for a single id
(define-read-only (get-reserves (id uint))
  (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool id)
)

;; Function to add a pool to check (only authorized principal can call)
(define-public (add-pool-to-check (id uint))
  (begin
    (asserts! (is-eq tx-sender authorized-principal) (err u403))
    (ok (map-set pools-to-check id true))
  )
)

;; Function to remove a pool from checking (only authorized principal can call)
(define-public (remove-pool-from-check (id uint))
  (begin
    (asserts! (is-eq tx-sender authorized-principal) (err u403))
    (ok (map-delete pools-to-check id))
  )
)

;; Function to get reserves for all added pools
(define-read-only (get-multiple-reserves)
  (ok {
    pool1: (get-pool-if-active u1),
    pool2: (get-pool-if-active u2),
    pool3: (get-pool-if-active u3),
    pool4: (get-pool-if-active u4),
    pool5: (get-pool-if-active u5),
    pool6: (get-pool-if-active u6),
    pool7: (get-pool-if-active u7),
    pool8: (get-pool-if-active u8),
    pool9: (get-pool-if-active u9),
    pool10: (get-pool-if-active u10),
    pool11: (get-pool-if-active u11),
    pool12: (get-pool-if-active u12),
    pool13: (get-pool-if-active u13),
    pool14: (get-pool-if-active u14),
    pool15: (get-pool-if-active u15),
    pool16: (get-pool-if-active u16),
    pool17: (get-pool-if-active u17),
    pool18: (get-pool-if-active u18),
    pool19: (get-pool-if-active u19),
    pool20: (get-pool-if-active u20)
  })
)

;; Helper function to get pool data if it's active
(define-private (get-pool-if-active (id uint))
  (if (default-to false (map-get? pools-to-check id))
    (some (get-reserves id))
    none
  )
)
```
