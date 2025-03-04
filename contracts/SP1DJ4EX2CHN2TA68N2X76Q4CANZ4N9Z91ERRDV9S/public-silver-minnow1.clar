(define-read-only (fn7)
  (let
    (
      (var26 (contract-call? 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-sbtc-stx-v-1-1 get-pool))
      (var27 (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt u100000000))
      (var28 (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 get-pool-details 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wsbtc u5000000))
    )
    {var26: (ok var26), var27: (ok var27), var28: (ok var28)}
  )
)


