
;; constants
(define-constant ERR-NOT-TOKEN-OWNER (err u88001))
(define-constant ERR-TOKEN-ALREADY-MIGRATED (err u88002))

;; map
(define-map token-migrated
  { token-id: uint }
  {
    is-migrated: bool
  }
)

;; 
;; Main functions
;; 

(define-read-only (is-migrated (token-id uint))
  (default-to 
    false
    (get is-migrated (map-get? token-migrated { token-id: token-id }))
  )
)

(define-public (migrate-token (token-id uint))
  (let (
    (old-tile-id (contract-call? .tiles get-token-tile-id token-id))
    (old-level (contract-call? .tiles get-token-level token-id))
    (token-is-migrated (is-migrated token-id))
    (token-owner (unwrap-panic (unwrap-panic (contract-call? .tiles get-owner token-id))))
  )
    ;; Can only migrate once
    (asserts! (is-eq token-is-migrated false) ERR-TOKEN-ALREADY-MIGRATED)

    ;; Need to be owner of token
    (asserts! (is-eq tx-sender token-owner) ERR-NOT-TOKEN-OWNER)

    ;; Add to map
    (map-set token-migrated {token-id: token-id} {is-migrated: true})

    ;; Mint same tile + second random tile
    (contract-call? .board-tiles-manager mint-for-migration token-id old-tile-id old-level)
  )
)
