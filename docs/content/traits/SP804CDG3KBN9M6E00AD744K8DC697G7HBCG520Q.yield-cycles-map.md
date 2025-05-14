---
title: "Trait yield-cycles-map"
draft: true
---
```
;; smart contract for 
;; additional functionality to retrieve cycle-related data from yield

(define-constant ERR_ALREADY_INSTANTIATED (err u101))
(define-constant ERR_WRONG_CYCLE_ID (err u102))
(define-constant ERR_NOT_ADMIN (err u103))

(define-constant ADMIN contract-caller)

(define-map yield-cycles-map
  { cycle-id: uint }
  {
    nr-blocks-snapshot: uint,
    nr-snapshots-cycle: uint,
  }
)

(define-read-only (get-yield-cycle-data (cycle-id uint)) 
  (map-get? yield-cycles-map {cycle-id: cycle-id})
)

(define-public (insert-yield-cycle-data (cycle-id uint))
  (let 
    (
      ;; (yield-data (contract-call? .yield cycle-data))
      (yield-data (contract-call? 'SP804CDG3KBN9M6E00AD744K8DC697G7HBCG520Q.sbtc-yield-rewards-v3 cycle-data))
      (yield-cycle-id (get cycle-id yield-data))
      (nr-blocks-snapshot (get nr-blocks-snapshot yield-data))
      (nr-snapshots-cycle (get nr-snapshots-cycle yield-data))
    )
    (asserts! (is-eq yield-cycle-id cycle-id) ERR_WRONG_CYCLE_ID)
    (asserts! 
      (is-none (map-get? yield-cycles-map {cycle-id: cycle-id})) 
      ERR_ALREADY_INSTANTIATED
    )
    (ok
      (map-insert 
        yield-cycles-map 
        {cycle-id: cycle-id}
        {
          nr-blocks-snapshot: nr-blocks-snapshot,
          nr-snapshots-cycle: nr-snapshots-cycle,
        }
      )
    )
  )
)

(define-public 
  (admin-set-yield-cycle-data 
    (cycle-id uint) 
    (nr-blocks-snapshot uint) 
    (nr-snapshots-cycle uint)
  )
  (begin 
    (asserts! (is-eq ADMIN contract-caller) ERR_NOT_ADMIN)
    (ok 
      (map-set 
        yield-cycles-map 
        {cycle-id: cycle-id}
        {
          nr-blocks-snapshot: nr-blocks-snapshot,
          nr-snapshots-cycle: nr-snapshots-cycle,
        }
      )
    )
  )
)

```
