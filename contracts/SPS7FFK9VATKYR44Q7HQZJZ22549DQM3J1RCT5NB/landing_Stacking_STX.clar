
    (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token Stacking_STX uint)
(define-constant TOTAL u5000)
(define-constant ERROR-NOT-IMPLEMENTED u1)
(define-constant ERROR-UNAUTHORIZED u1000)
(define-constant ERROR-ALREADY-MINTED u1001)

(define-constant IPFS-ROOT "ipfs://ipfs/bafybeifn6x764vlz4bxraejcdogfuezlctedmyaihx2yiefl44p4b6d6ke/{id}.json")

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
        (nft-mint? Stacking_STX token-id tx-sender)
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
    (let ((owner (unwrap! (nft-get-owner? Stacking_STX id) (err ERROR-UNAUTHORIZED))))
        (asserts! (is-eq owner tx-sender) (err ERROR-UNAUTHORIZED))
        (nft-burn? Stacking_STX id owner)
    )
)

(define-read-only (get-last-token-id)
    (ok TOTAL)
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? Stacking_STX id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some IPFS-ROOT))
)

(contract-call? 'SP2GW18TVQR75W1VT53HYGBRGKFRV5BFYNAF5SS5J.ZADAO-V2-MultiW-Bounty create-bounty u75000000 "Stacking STX Made Easy" "ce19e18d-dc4d-4bd1-9cd5-e4471bfd14aa" 'SP4SZE494VC2YC5JYG7AYFQ44F5Q4PYV7DVMDPBG.ststx-token)

