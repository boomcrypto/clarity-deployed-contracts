---
title: "Trait data-pools-v1"
draft: true
---
```
;; Data Provider Contract - Basic Version

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))

(define-data-var next-data-id uint u0)

(define-map pools 
    {data-id: uint} 
    {
        dex: (string-ascii 32),
        pool-contract: principal,
        pool-id: uint,
        reserve0: (string-ascii 32),
        reserve1: (string-ascii 32)
    })

(define-public (add-pool 
    (dex (string-ascii 32))
    (pool-contract principal)
    (pool-id uint)
    (reserve0 (string-ascii 32))
    (reserve1 (string-ascii 32)))
    
    (let ((id (var-get next-data-id)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set pools {data-id: id} 
            {
                dex: dex,
                pool-contract: pool-contract,
                pool-id: pool-id,
                reserve0: reserve0,
                reserve1: reserve1
            })
        (var-set next-data-id (+ id u1))
        (ok id)))

(define-read-only (get-pool (id uint))
    (map-get? pools {data-id: id}))

(define-public (remove-pool (id uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-delete pools {data-id: id}))))
```
