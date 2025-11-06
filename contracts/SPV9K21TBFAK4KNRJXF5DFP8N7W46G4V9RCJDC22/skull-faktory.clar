(begin
  ;; Add initial balanced liquidity 
  (try! (contract-call? 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.skullcoin-faktory-pool add-liquidity u1427000))
  ;; Transfer additional token B to achieve desired ratio
  (try! (contract-call?
    'SP3BRXZ9Y7P5YP28PSR8YJT39RT51ZZBSECTCADGR.skullcoin-stxcity
    transfer u792755065244611 tx-sender 'SPV9K21TBFAK4KNRJXF5DFP8N7W46G4V9RCJDC22.skullcoin-faktory-pool none
  ))
  (ok true)
)