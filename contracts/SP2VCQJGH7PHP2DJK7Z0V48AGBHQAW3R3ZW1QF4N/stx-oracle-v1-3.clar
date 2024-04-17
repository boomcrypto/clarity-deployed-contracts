(impl-trait .oracle-trait.oracle-trait)
(use-trait ft .ft-trait.ft-trait)

(define-read-only (to-fixed (a uint) (decimals-a uint))
  (contract-call? .math to-fixed a decimals-a)
)

;; prices are fixed to 8 decimals
(define-public (get-asset-price (token <ft>))
  (let (
    (oracle-data (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3
      get-price
      "STX"
    ))
  )
    ;; convert to fixed precision
    (ok (to-fixed (get last-price oracle-data) u6))
  )
)


;; prices are fixed to 8 decimals
(define-read-only (get-price)
  (let (
    (oracle-data (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-oracle-v2-3
      get-price
      "STX"
    ))
  )
    ;; convert to fixed precision
    (to-fixed (get last-price oracle-data) u6)
  )
)
