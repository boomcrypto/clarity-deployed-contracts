(begin 
    (try! (contract-call? .byzantion-market-v7 add-collection "SP1S7NH168W3GMJXAJAHVVF19N0PVRA5S6M5TAZ89.phil-crypto::phil-crypto" "phil-crypto" 'SP1S7NH168W3GMJXAJAHVVF19N0PVRA5S6M5TAZ89.phil-crypto u250 u500 'SP1S7NH168W3GMJXAJAHVVF19N0PVRA5S6M5TAZ89))
    (try! (contract-call? .byzantion-market-v7 add-collection "SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80.the-mother::the-mother" "the-mother" 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80.the-mother u250 u500 'SP2EQVT3KBS364AC2SZH2Y4E6NQ6H7JA96BDX8A80))

    (ok true)
)