(begin
    (try! (contract-call? .byzantion-market-v7 add-collection "SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.stacks-angel::stacks-angel" "stacks-angel" 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.stacks-angel u250 u500 'SP32V83MWS15JRR2F77347CCR7QRTDVBC9MDKQJRG))
    (try! (contract-call? .byzantion-market-v7 add-collection "SP1N09G5ME7DSAT82GTCQS13E6Q3TXX7CY2MG8HM5.spatial-dust::spatial-dust" "spatial-dust" 'SP1N09G5ME7DSAT82GTCQS13E6Q3TXX7CY2MG8HM5.spatial-dust u250 u500 'SP1N09G5ME7DSAT82GTCQS13E6Q3TXX7CY2MG8HM5))

    (try! (contract-call? .byzantion-market-v6 add-collection "SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.stacks-angel::stacks-angel" "stacks-angel" 'SP1GWHGESCF29TV10Q6X0VZYWH4QJ6CM9NK6DSH9J.stacks-angel u250 u500 'SP32V83MWS15JRR2F77347CCR7QRTDVBC9MDKQJRG))
    (try! (contract-call? .byzantion-market-v6 add-collection "SP1N09G5ME7DSAT82GTCQS13E6Q3TXX7CY2MG8HM5.spatial-dust::spatial-dust" "spatial-dust" 'SP1N09G5ME7DSAT82GTCQS13E6Q3TXX7CY2MG8HM5.spatial-dust u250 u500 'SP1N09G5ME7DSAT82GTCQS13E6Q3TXX7CY2MG8HM5))

    (ok true)
)