;;Contract that allows to burn spaghetti to get spoints
(define-public (og-collect (item uint) (amount uint)) 
    (begin 
        (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti burn amount))
        (unwrap-panic (contract-call? .spoints collect item amount))
        (ok true)))

(contract-call? .spoints principal-approve (as-contract tx-sender))