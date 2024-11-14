;; Define the contract

;; Define a function to get reserves for a single id
(define-read-only (get-reserves (id uint))
  (let ((pool-data (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-core do-get-pool id)))
    (ok {
      reserve0: (get reserve0 pool-data),
      reserve1: (get reserve1 pool-data)
    })
  )
)

;; Function to get reserves for multiple ids
(define-read-only (get-multiple-reserves)
  (ok {
    reserves1: (unwrap-panic (get-reserves u1)),
    reserves2: (unwrap-panic (get-reserves u2)),
    reserves3: (unwrap-panic (get-reserves u3)),
    reserves4: (unwrap-panic (get-reserves u4)),
    reserves5: (unwrap-panic (get-reserves u5)),
    reserves6: (unwrap-panic (get-reserves u6)),
    reserves7: (unwrap-panic (get-reserves u7))
  })
)