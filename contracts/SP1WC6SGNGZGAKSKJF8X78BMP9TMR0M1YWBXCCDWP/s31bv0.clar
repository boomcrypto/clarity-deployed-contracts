(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token sip31-badge uint)
(define-constant TOTAL u10000)
(define-constant ERROR-NOT-IMPLEMENTED u1)
(define-constant ERROR-UNAUTHORIZED u1000)
(define-constant ERROR-ALREADY-MINTED u1001)
(define-constant ERROR-CROSSED-DEADLINE u1002)
(define-constant DEADLINE u908016)

(define-constant IPFS-ROOT "https://bafybeid5lixlhqezitsvwoh6szuqd5e25li7gygjwsehevqqkbityfh4b4.ipfs.w3s.link/{id}.json")

(define-map minters
    principal
    bool
)
(define-data-var last-token-id uint u0)

(define-public (mint (address principal))
    (let ((token-id (+ u1 (var-get last-token-id))))
        (var-set last-token-id token-id)
        (asserts! (is-eq (default-to false (map-get? minters tx-sender)) true)
            (err ERROR-ALREADY-MINTED)
        )
        (asserts! (< burn-block-height DEADLINE) (err ERROR-CROSSED-DEADLINE))
        (asserts! (< token-id TOTAL) (err ERROR-ALREADY-MINTED))
        (map-set minters tx-sender true)
        (nft-mint? sip31-badge token-id tx-sender)
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
    (let ((owner (unwrap! (nft-get-owner? sip31-badge id) (err ERROR-UNAUTHORIZED))))
        (asserts! (is-eq owner tx-sender) (err ERROR-UNAUTHORIZED))
        (nft-burn? sip31-badge id owner)
    )
)

(define-read-only (get-last-token-id)
    (ok TOTAL)
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? sip31-badge id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some IPFS-ROOT))
)
