(begin
    ;; Add initial balanced liquidity (handles both token transfers at 1:1)
    (try! (contract-call? 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.usda-faktory-pool add-liquidity u2668000))
    ;; Transfer additional token B to achieve desired ratio
    (try! (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token transfer u3117158829 tx-sender 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.usda-faktory-pool none))
    (ok true)
)