
    (impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token Landing_Test uint)
(define-constant TOTAL u5000)
(define-constant ERROR-NOT-IMPLEMENTED u1)
(define-constant ERROR-UNAUTHORIZED u1000)
(define-constant ERROR-ALREADY-MINTED u1001)

(define-constant IPFS-ROOT "ipfs://ipfs/bafybeicr7wbspfwcthkynjqwuceggzga23n6vzt4nokmuhdc5akvhttgq4/{id}.json")

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
        (nft-mint? Landing_Test token-id tx-sender)
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
    (let ((owner (unwrap! (nft-get-owner? Landing_Test id) (err ERROR-UNAUTHORIZED))))
        (asserts! (is-eq owner tx-sender) (err ERROR-UNAUTHORIZED))
        (nft-burn? Landing_Test id owner)
    )
)

(define-read-only (get-last-token-id)
    (ok TOTAL)
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? Landing_Test id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some IPFS-ROOT))
)

(contract-call? 'SP2GW18TVQR75W1VT53HYGBRGKFRV5BFYNAF5SS5J.ZADAO-V2-token-bounties create-bounty u1000000 "Landing Test" "8179612c-b8b6-43bf-bd55-beee1f5ee515" 'SP32AEEF6WW5Y0NMJ1S8SBSZDAY8R5J32NBZFPKKZ.wstx)

