
(try! 
  (contract-call? .pool-borrow-v1-1 set-usage-as-collateral-enabled
    .wstx
    true
    u50000000
    u70000000
    u10000000
  )
)