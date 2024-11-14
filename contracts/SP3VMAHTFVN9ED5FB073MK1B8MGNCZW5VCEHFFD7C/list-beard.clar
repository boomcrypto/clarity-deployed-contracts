(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-whitelisted 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ.trevors-beard-bonding-curve true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-or-create-land-id 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ.trevors-beard-bonding-curve)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ.trevors-beard-bonding-curve get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u4)))
      )
      (print {event: "enable-listing", contract: "SP38GBVK5HEJ0MBH4CRJ9HQEW86HX0H9AP1HZ3SVZ.trevors-beard-bonding-curve", land-id: land-id, total-supply: total-supply, land-difficulty: land-difficulty})
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-land-difficulty land-id land-difficulty)
    )
  )
)
