;; below is code from https://github.com/alexgo-io/alex-v1/blob/main/clarity/contracts/pool/collateral-rebalancing-pool.clar
(define-constant ERR-INVALID-POOL-ERR (err u2001))
(define-constant ERR-TOO-MANY-POOLS (err u2004))

(define-map pools-map
  { pool-id: uint }
  {
    token-x: principal,
    token-y: principal,
    expiry: uint    
  }
)

(define-data-var pools-list (list 2000 uint) (list))

(define-read-only (get-pool-contracts (pool-id uint))
    (ok (unwrap! (map-get? pools-map {pool-id: pool-id}) ERR-INVALID-POOL-ERR))
)

(define-read-only (get-pools)
    (map get-pool-contracts (var-get pools-list))
)

;; below is test code: add 30 pools
(define-private (add_pool (index uint))
  (begin
    (var-set pools-list (unwrap! (as-max-len? (append (var-get pools-list) index) u2000) ERR-TOO-MANY-POOLS))
    (map-set pools-map
      { pool-id: index }
      {
        token-x: tx-sender,
        token-y: tx-sender,
        expiry: index
      }
    )
    (ok true)
  )
)

(map add_pool (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30))