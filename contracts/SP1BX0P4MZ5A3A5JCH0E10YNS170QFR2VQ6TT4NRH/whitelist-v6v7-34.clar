(begin 
    (try! (contract-call? .byzantion-market-v7 add-collection "SP2BG645M86A45K524N6SHS43PXBMD456HCG1P11K.creazyhead::creazyhead" "creazyhead" 'SP2BG645M86A45K524N6SHS43PXBMD456HCG1P11K.creazyhead u250 u500 'SP2BG645M86A45K524N6SHS43PXBMD456HCG1P11K))
    
    (try! (contract-call? .byzantion-market-v6 add-collection "SP2BG645M86A45K524N6SHS43PXBMD456HCG1P11K.creazyhead::creazyhead" "creazyhead" 'SP2BG645M86A45K524N6SHS43PXBMD456HCG1P11K.creazyhead u250 u500 'SP2BG645M86A45K524N6SHS43PXBMD456HCG1P11K))

    (ok true)
)