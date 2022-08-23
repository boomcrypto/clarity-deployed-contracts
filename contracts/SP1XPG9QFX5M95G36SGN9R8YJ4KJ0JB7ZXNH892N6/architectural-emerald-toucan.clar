(define-read-only (harvestable (addr principal))
  (at-block (unwrap-panic (get-block-info? id-header-hash u72363))
    (contract-call? 
    'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-staking
     check-harvest addr ))
)
