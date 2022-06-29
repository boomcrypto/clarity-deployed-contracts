;; SIP009 NFT trait on mainnet
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant contract-owner tx-sender)

(define-constant err-owner-only (err u100))

(define-constant err-not-token-owner (err u101))

(define-non-fungible-token duckie-token uint)

(define-data-var last-token-id uint u0)

;; Get Token ID
(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

;; Get Token URI
(define-read-only (get-token-uri (token-id uint))
    (ok none)
)

;; Get Owner
(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? duckie-token token-id))
)

;; Transfer
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (nft-transfer? duckie-token token-id sender recipient)
    )
)

;; Mint
(define-public (mint (recipient principal))
    (let 
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (nft-mint? duckie-token token-id recipient))
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

