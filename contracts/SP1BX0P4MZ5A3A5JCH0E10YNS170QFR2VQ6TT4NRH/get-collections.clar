(define-private (get-collection (id (string-ascii 256)))
    (contract-call? .byzantion-market-v6 get-collection-by-id id)
)

(define-public (get-all (ids (list 1000 (string-ascii 256))))
    (begin
        (print (map get-collection ids))
        (ok true)
    )
)