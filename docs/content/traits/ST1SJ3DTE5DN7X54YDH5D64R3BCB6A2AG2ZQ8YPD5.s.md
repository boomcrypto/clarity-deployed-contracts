---
title: "Trait s"
draft: true
---
```
(define-constant ERR-INVALID-POOL-ERR (err u2001))
(define-constant ERR-TOO-MANY-POOLS (err u2004))

(define-data-var pools-list (list 2000 uint) (list))

(define-map pools-map
  { pool-id: uint }
  {
    token-x: principal, ;; collateral
    token-y: principal, ;; token
    expiry: uint    
  }
)

;; @desc get-pool-contracts
;; @param pool-id; pool-id
;; @returns (response (tuple) uint)
(define-read-only (get-pool-contracts (pool-id uint))
    (ok (unwrap! (map-get? pools-map {pool-id: pool-id}) ERR-INVALID-POOL-ERR))
)

;; @desc get-pools
;; @returns (optional (tuple))
(define-read-only (get-pools)
    (map get-pool-contracts (var-get pools-list))
)

(define-read-only (get-pools-by-ids (pool-ids (list 26 uint)))
  (map get-pool-contracts pool-ids)
)

;; test 
(define-public (add_poll (tx principal) (ty principal) (expiry uint))
    (let
      (
        (pool_len (len (var-get pools-list)))
        (new_pool_id (+ pool_len u1))
      )
      (map-set pools-map
        { pool-id: new_pool_id }
        {
          token-x: tx,
          token-y: ty,
          expiry: expiry
        })
      (var-set pools-list (unwrap! (as-max-len? (append (var-get pools-list) new_pool_id) u2000) ERR-TOO-MANY-POOLS))
      (ok true)
    )
)

(define-public (get-pools-public)
    (ok (map get-pool-contracts (var-get pools-list)))
)

```
