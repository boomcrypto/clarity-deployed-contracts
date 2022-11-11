(begin 
    (try! (contract-call? .byzantion-market-v7 add-collection "SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.there-is-no-second-best::There-is-No-Second-Best" "There-is-No-Second-Best" 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.there-is-no-second-best u250 u250 'SP2J9XB6CNJX9C36D5SY4J85SA0P1MQX7R5VFKZZX))
    (try! (contract-call? .byzantion-market-v7 add-collection "SP2WXB0P8E5Q562KRVNMQ64FJF0HQKV7V6ZBAGEFT.container::container" "container" 'SP2WXB0P8E5Q562KRVNMQ64FJF0HQKV7V6ZBAGEFT.container u100 u500 'SP2DADKD5KK22MHMVN3DCSKS10T17CM7PDTC6WQV8))
    (try! (contract-call? .byzantion-market-v7 add-collection "SP2WXB0P8E5Q562KRVNMQ64FJF0HQKV7V6ZBAGEFT.equipment::equipment" "equipment" 'SP2WXB0P8E5Q562KRVNMQ64FJF0HQKV7V6ZBAGEFT.equipment u100 u500 'SP2DADKD5KK22MHMVN3DCSKS10T17CM7PDTC6WQV8))

    (ok true)
)
