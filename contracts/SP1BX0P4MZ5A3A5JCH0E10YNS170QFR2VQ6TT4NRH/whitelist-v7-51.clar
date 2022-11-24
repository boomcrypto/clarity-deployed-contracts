(begin 
    (try! (contract-call? .byzantion-market-v7 add-collection "SP2PFH9S05944J1Q5AG9DXS4SSNKNRRTYE8PT16MV.damonkey::damonkey" "damonkey" 'SP2PFH9S05944J1Q5AG9DXS4SSNKNRRTYE8PT16MV.damonkey u250 u500 'SP2PFH9S05944J1Q5AG9DXS4SSNKNRRTYE8PT16MV))
    (try! (contract-call? .byzantion-market-v7 add-collection "SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7.blueberries-for-breakfast::blueberries-for-breakfast" "blueberries-for-breakfast" 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7.blueberries-for-breakfast u250 u500 'SP352FR22PRMWG4EYV0EJE0JXGCS3GWTZMB6HD6S7))
    (try! (contract-call? .byzantion-market-v7 add-collection "SP15GZEM23JBZ9D5BWXDKPT73CYR3QDH15KT81GC7.eggless-invasion::eggless-invasion" "eggless-invasion" 'SP15GZEM23JBZ9D5BWXDKPT73CYR3QDH15KT81GC7.eggless-invasion u250 u500 'SP15GZEM23JBZ9D5BWXDKPT73CYR3QDH15KT81GC7))

    (ok true)
)