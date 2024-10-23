(define-public (execute (sender principal))
  (begin
    ;; enable the token for staking
    (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-whitelisted 'SP1HM6VC441GS3F6W9WATAD053A56GM1ZSW9JMX6Z.jackbinswitch-stxcity true))
    (let 
      (
        ;; create a unique id for the staked token
        (land-id (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands get-or-create-land-id 'SP1HM6VC441GS3F6W9WATAD053A56GM1ZSW9JMX6Z.jackbinswitch-stxcity)))
        ;; lookup the total supply of the staked token
        (total-supply (unwrap-panic (contract-call? 'SP1HM6VC441GS3F6W9WATAD053A56GM1ZSW9JMX6Z.jackbinswitch-stxcity get-total-supply)))
        ;; calculate the initial difficulty based on the total supply
        (land-difficulty (/ total-supply (pow u10 u4)))
      )
      (print {event: "enable-listing", contract: "SP1HM6VC441GS3F6W9WATAD053A56GM1ZSW9JMX6Z.jackbinswitch-stxcity", land-id: land-id, total-supply: total-supply, land-difficulty: land-difficulty})
      ;; set initial difficulty based on total supply to normalize energy output
      (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.lands set-land-difficulty land-id land-difficulty)
    )
  )
)
