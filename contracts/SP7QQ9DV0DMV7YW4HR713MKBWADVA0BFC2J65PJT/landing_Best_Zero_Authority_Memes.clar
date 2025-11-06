
    (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token Best_Zero_Authority_Memes uint)
(define-constant TOTAL u5000)
(define-constant ERROR-NOT-IMPLEMENTED u1)
(define-constant ERROR-UNAUTHORIZED u1000)
(define-constant ERROR-ALREADY-MINTED u1001)

(define-constant IPFS-ROOT "ipfs://ipfs/bafybeie5gy5p2b4qstnnef5gpf4qkkpe66b724g7klv4dgffojtmhlizlm/{id}.json")

(define-map minters
    principal
    bool
)
(define-data-var last-token-id uint u0)

(define-public (mint)
    (let ((token-id (+ u1 (var-get last-token-id))))
        (var-set last-token-id token-id)
        (asserts! (not (default-to false (map-get? minters tx-sender)))
            (err ERROR-ALREADY-MINTED)
        )
        (asserts! (<= token-id TOTAL) (err ERROR-ALREADY-MINTED))
        (map-set minters tx-sender true)
        (nft-mint? Best_Zero_Authority_Memes token-id tx-sender)
    )
)

(define-public (transfer
        (id uint)
        (sender principal)
        (recipient principal)
    )
    (err ERROR-NOT-IMPLEMENTED)
)

(define-public (burn (id uint))
    (let ((owner (unwrap! (nft-get-owner? Best_Zero_Authority_Memes id) (err ERROR-UNAUTHORIZED))))
        (asserts! (is-eq owner tx-sender) (err ERROR-UNAUTHORIZED))
        (nft-burn? Best_Zero_Authority_Memes id owner)
    )
)

(define-read-only (get-last-token-id)
    (ok TOTAL)
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? Best_Zero_Authority_Memes id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some IPFS-ROOT))
)

