(define-read-only (get-usda-supply-at-block (block uint))
  (at-block
    (unwrap-panic (get-block-info? id-header-hash block))
    (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-total-supply)
  )
)
