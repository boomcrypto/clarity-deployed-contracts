(use-trait sip010-trait 'SP3XXMS38VTAWTVPE5682XSBFXPTH7XCPEBTX8AN2.faktory-trait-v1.sip-010-trait) 

(define-trait aibtc-account (
  (deposit-stx
    (uint)
    (response bool uint)
  )
  (deposit-ft
    (<sip010-trait> uint)
    (response bool uint)
  )
  (withdraw-stx
    (uint)
    (response bool uint)
  )
  (withdraw-ft
    (<sip010-trait> uint)
    (response bool uint)
  )
))