(begin
    (try! (contract-call? .byzantion-market-v7 add-collection "SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.edtions-with-mint-request::edtions-with-mint-request" "edtions-with-mint-request" 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.edtions-with-mint-request u250 u500 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA))
    (try! (contract-call? .byzantion-market-v7 add-collection "SP1WC6SGNGZGAKSKJF8X78BMP9TMR0M1YWBXCCDWP.madstar-ai-whales::hback-ai-whales-nft" "hback-ai-whales-nft" 'SP1WC6SGNGZGAKSKJF8X78BMP9TMR0M1YWBXCCDWP.madstar-ai-whales u250 u500 'SP1KQF7QTM3A2H205T0VZMPPHH3SVVKT5BX7MPMK))

    (try! (contract-call? .byzantion-market-v6 add-collection "SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.edtions-with-mint-request::edtions-with-mint-request" "edtions-with-mint-request" 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.edtions-with-mint-request u250 u500 'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA))
    (try! (contract-call? .byzantion-market-v6 add-collection "SP1WC6SGNGZGAKSKJF8X78BMP9TMR0M1YWBXCCDWP.madstar-ai-whales::hback-ai-whales-nft" "hback-ai-whales-nft" 'SP1WC6SGNGZGAKSKJF8X78BMP9TMR0M1YWBXCCDWP.madstar-ai-whales u250 u500 'SP1KQF7QTM3A2H205T0VZMPPHH3SVVKT5BX7MPMK))

    (ok true)
)