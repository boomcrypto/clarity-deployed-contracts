(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)
(define-constant A tx-sender)
(define-data-var ix uint u1000)
(define-public (six (k uint))
  (begin
    (asserts! (is-eq tx-sender A) (err u0))
    (ok (var-set ix k))
  )
)
(six u10)

(define-public (purchase-name (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (factor uint) (dx uint) (min-dy (optional uint)))
    (let 
    (
    (new-dx (- dx (var-get ix)))
    (res (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool-v1-1 swap-helper token-x-trait token-y-trait factor new-dx min-dy)))
    )
    (ok res)
    )
)