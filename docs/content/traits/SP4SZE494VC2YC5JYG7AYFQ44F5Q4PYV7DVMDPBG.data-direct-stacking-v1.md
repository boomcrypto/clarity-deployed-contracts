---
title: "Trait data-direct-stacking-v1"
draft: true
---
```
;; @contract Data Direct Stacking
;; @version 1
;;
;; Tracks direct stacking info for user and pools.
;; If user transfers stSTX to another wallet or unsupported protocol, 
;; the direct stacking amount can be decrased.

;;-------------------------------------
;; Direct Stacking
;;-------------------------------------

;; This % of normal stacking total will be divided according to direct stacking rates
(define-data-var direct-stacking-dependence uint u2000) ;; 20% in bps

(define-data-var total-direct-stacking uint u0)

;; Map pool to amount used for direct stacking
(define-map direct-stacking-pool-amount principal uint)

;; User info
(define-map direct-stacking-user 
  principal 
  {
    pool: principal, 
    amount: uint,
  }
)

(define-read-only (get-direct-stacking-dependence)
  (var-get direct-stacking-dependence)
)

(define-read-only (get-total-direct-stacking)
  (var-get total-direct-stacking)
)

(define-read-only (get-direct-stacking-pool-amount (pool principal))
  (default-to
    u0
    (map-get? direct-stacking-pool-amount pool)
  )
)

(define-read-only (get-direct-stacking-user (user principal))
  (map-get? direct-stacking-user user)
)

(define-public (set-direct-stacking-dependence (dependence uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set direct-stacking-dependence dependence)
    (ok true)
  )
)

(define-public (set-total-direct-stacking (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set total-direct-stacking amount)

    (print { action: "set-total-direct-stacking", data: { amount: amount, block-height: block-height } })
    (ok true)
  )
)

(define-public (set-direct-stacking-pool-amount (pool principal) (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set direct-stacking-pool-amount pool amount)

    (print { action: "set-direct-stacking-pool-amount", data: { pool: pool, amount: amount, block-height: block-height } })
    (ok true)
  )
)

(define-public (set-direct-stacking-user (user principal) (pool principal) (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set direct-stacking-user user { pool: pool, amount: amount })

    (print { action: "set-direct-stacking-user", data: { user: user, pool: pool, amount: amount, block-height: block-height } })
    (ok true)
  )
)

(define-public (delete-direct-stacking-user (user principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-delete direct-stacking-user user)

    (print { action: "delete-direct-stacking-user", data: { user: user, block-height: block-height } })
    (ok true)
  )
)

;;-------------------------------------
;; Supported Protocols
;;-------------------------------------

(define-data-var supported-protocols (list 50 principal) (list))

(define-read-only (get-supported-protocols)
  (var-get supported-protocols)
)

(define-public (set-supported-protocols (protocols (list 50 principal)))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (var-set supported-protocols protocols)
    (ok true)
  )
)

```
