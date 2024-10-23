(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-whitelisted 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-or-create-land-id 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u5)))
      )
      (print {event: "enable-listing", contract: "SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.nope", land-id: land-id, total-supply: total-supply, land-difficulty: land-difficulty})
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-land-difficulty land-id land-difficulty)
    )
  )
)
