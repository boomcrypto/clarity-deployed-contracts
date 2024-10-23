(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-whitelisted 'SP3MTMK7R8GQKYHN3XZGBFS81NSDD1YAZW305H2CS.dogwifknife true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-or-create-land-id 'SP3MTMK7R8GQKYHN3XZGBFS81NSDD1YAZW305H2CS.dogwifknife)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP3MTMK7R8GQKYHN3XZGBFS81NSDD1YAZW305H2CS.dogwifknife get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u5)))
      )
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-land-difficulty land-id land-difficulty)
    )
  )
)
