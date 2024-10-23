(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-whitelisted 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-or-create-land-id 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u4)))
      )
      (print {event: "enable-listing", contract: "SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20", land-id: land-id, total-supply: total-supply, land-difficulty: land-difficulty})
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-land-difficulty land-id land-difficulty)
    )
  )
)
