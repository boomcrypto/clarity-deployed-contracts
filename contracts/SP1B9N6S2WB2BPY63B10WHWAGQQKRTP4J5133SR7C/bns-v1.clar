(define-public (pay (id uint) (price uint)) 
    (begin 
        
        (try! (stx-transfer? (/ (* price u269) u10000) tx-sender 'SP2M3X5BNG4XM107R15QZV87WCS4JB8TF0SH8BST3))
        (ok true)
    )
)