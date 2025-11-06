
    (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token Feline_Friday uint)
(define-constant TOTAL u5000)
(define-constant ERROR-NOT-IMPLEMENTED u1)
(define-constant ERROR-UNAUTHORIZED u1000)
(define-constant ERROR-ALREADY-MINTED u1001)

(define-constant IPFS-ROOT "ipfs://ipfs/bafybeies4slgt7kckf4mb7szzq4ofkpqyzzout35rt5bq7phbnzy7bkrhq/{id}.json")

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
        (nft-mint? Feline_Friday token-id tx-sender)
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
    (let ((owner (unwrap! (nft-get-owner? Feline_Friday id) (err ERROR-UNAUTHORIZED))))
        (asserts! (is-eq owner tx-sender) (err ERROR-UNAUTHORIZED))
        (nft-burn? Feline_Friday id owner)
    )
)

(define-read-only (get-last-token-id)
    (ok TOTAL)
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? Feline_Friday id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some IPFS-ROOT))
)

(contract-call? 'SP2GW18TVQR75W1VT53HYGBRGKFRV5BFYNAF5SS5J.ZADAO-V2-MultiW-Bounty create-bounty u1000000000000 "Feline Friday Meme Showdown" "8bba3bcf-3260-441c-ae07-b060da97cd3d" 'SP1AY6K3PQV5MRT6R4S671NWW2FRVPKM0BR162CT6.leo-token)

