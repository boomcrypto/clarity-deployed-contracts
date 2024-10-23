;; Define the contract

;; Define the authorized principal
(define-constant authorized-principal 'SPGYCP878RYFVT03ZT8TWGPKNYTSQB1578VVXHGE)

;; Define a map to keep track of which pools to check
(define-map pools-to-check uint bool)

;; Define a function to get simplified reserves for a single id
(define-read-only (get-simplified-reserves (id uint))
  (let ((pool-data (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool id)))
    {
      lp-token: (get lp-token pool-data),
      reserve0: (get reserve0 pool-data),
      reserve1: (get reserve1 pool-data)
    }
  )
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

;; Function to get simplified reserves for all added pools
(define-public (get-multiple-simplified-reserves)
  (ok {
    pool1: (get-simplified-pool-if-active u1),
    pool2: (get-simplified-pool-if-active u2),
    pool3: (get-simplified-pool-if-active u3),
    pool4: (get-simplified-pool-if-active u4),
    pool5: (get-simplified-pool-if-active u5),
    pool6: (get-simplified-pool-if-active u6),
    pool7: (get-simplified-pool-if-active u7),
    pool8: (get-simplified-pool-if-active u8),
    pool9: (get-simplified-pool-if-active u9),
    pool10: (get-simplified-pool-if-active u10),
    pool11: (get-simplified-pool-if-active u11),
    pool12: (get-simplified-pool-if-active u12),
    pool13: (get-simplified-pool-if-active u13),
    pool14: (get-simplified-pool-if-active u14),
    pool15: (get-simplified-pool-if-active u15),
    pool16: (get-simplified-pool-if-active u16),
    pool17: (get-simplified-pool-if-active u17),
    pool18: (get-simplified-pool-if-active u18),
    pool19: (get-simplified-pool-if-active u19),
    pool20: (get-simplified-pool-if-active u20)
  })
)

;; Helper function to get simplified pool data if it's active
(define-private (get-simplified-pool-if-active (id uint))
  (if (default-to false (map-get? pools-to-check id))
    (some (get-simplified-reserves id))
    none
  )
)

;; Function to get a list of active pools
(define-read-only (get-active-pools)
  (filter is-pool-active (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20))
)

;; Helper function to check if a pool is active
(define-private (is-pool-active (id uint))
  (default-to false (map-get? pools-to-check id))
)