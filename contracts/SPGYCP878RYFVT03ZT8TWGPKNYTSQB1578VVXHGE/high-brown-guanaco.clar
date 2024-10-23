(define-public (transfer-liquid-staked-charisma)
  (let 
    (
      (balance 
        (unwrap! 
          (contract-call? 
            'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma 
            get-balance 
            tx-sender
          ) 
          (err u1)
        )
      )
    )
    (try! 
      (contract-call? 
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core 
        mint 
        u54
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
        'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma 
        'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx-scha 
        u1000000 
        balance
      ) 
    )
    (ok true)
  )
)