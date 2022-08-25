(begin 
    (try! (contract-call? .byzantion-market-v7 add-collection "SP1NKN5S805RDB78MMQKD26F00XEFE89X02DPSZW4.rugaritas::rugaritas" "rugaritas" 'SP1NKN5S805RDB78MMQKD26F00XEFE89X02DPSZW4.rugaritas u250 u500 'SP1NKN5S805RDB78MMQKD26F00XEFE89X02DPSZW4))
    (try! (contract-call? .byzantion-market-v7 add-collection "SP2N65XG5NHHZQB50X119YMZ018AP0FCSXDJPNE05.tfoust-labyrinth-collection::tfoust-labyrinth-collection" "tfoust-labyrinth-collection" 'SP2N65XG5NHHZQB50X119YMZ018AP0FCSXDJPNE05.tfoust-labyrinth-collection u250 u500 'SP2N65XG5NHHZQB50X119YMZ018AP0FCSXDJPNE05))

    (try! (contract-call? .byzantion-market-v6 add-collection "SP1NKN5S805RDB78MMQKD26F00XEFE89X02DPSZW4.rugaritas::rugaritas" "rugaritas" 'SP1NKN5S805RDB78MMQKD26F00XEFE89X02DPSZW4.rugaritas u250 u500 'SP1NKN5S805RDB78MMQKD26F00XEFE89X02DPSZW4))
    (try! (contract-call? .byzantion-market-v6 add-collection "SP2N65XG5NHHZQB50X119YMZ018AP0FCSXDJPNE05.tfoust-labyrinth-collection::tfoust-labyrinth-collection" "tfoust-labyrinth-collection" 'SP2N65XG5NHHZQB50X119YMZ018AP0FCSXDJPNE05.tfoust-labyrinth-collection u250 u500 'SP2N65XG5NHHZQB50X119YMZ018AP0FCSXDJPNE05))

    (ok true)
)