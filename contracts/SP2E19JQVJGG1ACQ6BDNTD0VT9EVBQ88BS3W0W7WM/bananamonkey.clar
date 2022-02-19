(define-non-fungible-token marvin-token uint)

(define-data-var last-token-id uint u1)

(define-public (mint)
    (let
        (
            (token-id (var-get last-token-id))
        )
        (var-set last-token-id (+ token-id u1))
        (nft-mint? marvin-token token-id tx-sender)
        
    )
)

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok none)
    ;;(ok (string-ascii "ipfs://..."))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? marvin-token token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (nft-transfer? marvin-token token-id sender recipient)
)