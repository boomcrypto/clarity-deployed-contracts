(define-private (s-1 (x uint))
  (element-at
    (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1
      swap-x-for-y
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token x u1
    ))
    u1
  )
)

(define-private (s-2 (y uint))
  (element-at
    (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1
      swap-y-for-x 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token y u1
    ))
    u0
  )
)

(define-public (z (amount uint))
  (let (
      (one (s-1 amount))
      (two (s-2 (unwrap-panic one)))
    )
    (ok two)
  )
)
