(define-private (unlist-bid (collection-id (string-ascii 256)) (order uint))
    (contract-call? 'SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH.byzantion-market-v6 admin-unbid collection-id order)
)

(define-public (unlist-multiple-bid (collection-ids (list 100 (string-ascii 256))) (orders (list 100 uint)))
    (begin
        (print (map unlist-bid collection-ids orders))
        (ok true)
    )
)