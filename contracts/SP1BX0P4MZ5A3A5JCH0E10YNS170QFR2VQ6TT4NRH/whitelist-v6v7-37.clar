(begin
    (try! (contract-call? .byzantion-market-v7 add-collection "SP31NAVB7EY8AMREE3EPHJS7XFJ3Y0C66W5RPR6QW.crypto-buds::crypto-buds" "crypto-buds" 'SP31NAVB7EY8AMREE3EPHJS7XFJ3Y0C66W5RPR6QW.crypto-buds u250 u500 'SP31NAVB7EY8AMREE3EPHJS7XFJ3Y0C66W5RPR6QW))

    (try! (contract-call? .byzantion-market-v6 add-collection "SP31NAVB7EY8AMREE3EPHJS7XFJ3Y0C66W5RPR6QW.crypto-buds::crypto-buds" "crypto-buds" 'SP31NAVB7EY8AMREE3EPHJS7XFJ3Y0C66W5RPR6QW.crypto-buds u250 u500 'SP31NAVB7EY8AMREE3EPHJS7XFJ3Y0C66W5RPR6QW))

    (ok true)
)