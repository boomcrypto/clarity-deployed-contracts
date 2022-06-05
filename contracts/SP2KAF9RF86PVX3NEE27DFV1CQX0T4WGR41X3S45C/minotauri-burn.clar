
(define-private (mint (id uint))
    (contract-call? .minotauri-nft admin-mint tx-sender)
)

(define-public (multiple-mint (ids (list 1250 uint)))
    (begin
        (map mint ids)
        (ok true)
    )
)

(define-private (burn (id uint))
    (contract-call? .minotauri-nft burn id tx-sender)
)

(define-public (multiple-burn (ids (list 1250 uint)))
    (begin
        (map burn ids)
        (ok true)
    )
)