(define-public (airdrop) 
    (begin 
        (try! (contract-call? .fast send-many (list 
{to: 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9, amount: u6000000000000000, memo: none} 
{to: 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9, amount: u1000000000000000, memo: none} 

)))
        (ok true)
    )
)

(unwrap-panic (airdrop))
