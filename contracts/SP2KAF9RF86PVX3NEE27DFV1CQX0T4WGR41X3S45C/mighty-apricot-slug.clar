(define-read-only (get-name-details (namespace (buff 20))
                                (name (buff 48)))
    (contract-call? 'SP000000000000000000002Q6VF78.bns name-resolve namespace name)
)