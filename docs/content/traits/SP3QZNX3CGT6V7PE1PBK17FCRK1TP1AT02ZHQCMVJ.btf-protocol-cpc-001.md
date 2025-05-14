---
title: "Trait btf-protocol-cpc-001"
draft: true
---
```
(define-constant ERR-PERMISSION-DENIED (err u401))
(define-constant ERR-PRECONDITION-FAILED (err u412))
(define-constant ERR-PRINCIPAL-NOT-FOUND (err u404))
(define-map manager-permissions principal uint)
(define-map contract-lock-status principal bool)
(define-read-only (get-permission-level (user principal))
  (default-to u0 (map-get? manager-permissions user))
)
(define-read-only (has-permission (user principal) (required-level uint))
  (>= (get-permission-level user) required-level)
)
(define-read-only (is-contract-unlocked (contract-id principal))
  (default-to true (map-get? contract-lock-status contract-id))
)
(define-public (add-manager (new-manager principal) (new-level uint))
  (let (
    (caller-level (get-permission-level tx-sender))
  )
    (begin
      (asserts! (> caller-level u0) ERR-PERMISSION-DENIED)
      (asserts! (> new-level u0)   ERR-PRECONDITION-FAILED)
      (asserts! (<= new-level caller-level) ERR-PRECONDITION-FAILED)
      (map-set manager-permissions new-manager new-level)
      (ok true)
    )
  )
)
(define-public (remove-manager (manager principal))
  (match (map-get? manager-permissions manager)
    manager-level
    (let (
      (caller-level (get-permission-level tx-sender))
    )
      (begin
        (asserts! (> caller-level u0)              ERR-PERMISSION-DENIED)
        (asserts! (>= caller-level manager-level)  ERR-PRECONDITION-FAILED)
        (map-delete manager-permissions manager)
        (ok true)
      )
    )
    ERR-PRINCIPAL-NOT-FOUND
  )
)
(define-public (lock-target-contract (contract-id principal))
  (begin
    (asserts! (>= (get-permission-level tx-sender) u50) ERR-PERMISSION-DENIED)
    (map-set contract-lock-status contract-id false)
    (ok true)
  )
)
(define-public (unlock-target-contract (contract-id principal))
  (begin
    (asserts! (>= (get-permission-level tx-sender) u50) ERR-PERMISSION-DENIED)
    (map-set contract-lock-status contract-id true)
    (ok true)
  )
)
(map-set manager-permissions tx-sender u100)
(map-set manager-permissions .stx-fund-001 u1)

```
