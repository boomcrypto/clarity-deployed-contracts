(begin
    (try! (contract-call? .byzantion-market-v6 add-collection "SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-nakamoto-guardians::nakamoto-guardians" "nakamoto-guardians" 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-nakamoto-guardians u250 u250 'SP35FG6SHERAY92DN14BBE42BFNFBVEHTN9DCG7EE))
    (try! (contract-call? .byzantion-market-v6 add-collection "SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcutties::bitcutties" "bitcutties" 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.byzantion-bitcutties u250 u500 'SP3PJBFHVSKYP33ZAEKQW8GQXWJYZ53S7AT0KYD4W))
    (ok true)
)