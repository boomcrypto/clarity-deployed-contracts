;; Sip009 Compliant NFT

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token nfttest uint)




;; CONSTANT VARIABLES

(define-constant contract-owner tx-sender)

(define-constant err-invalid-user (err u101))

(define-constant err-invalid-token (err u102))

(define-constant err-sold-out (err u103))




;; DATA VARIABLES

(define-data-var last-token-id uint u0)

(define-data-var mint-limit uint u10)

(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmQ1JopzQsZHe31CoAEZ5Fieq2rxJM9SWQ18CABuuM1Pbs/")




;; READ-ONLY FUNCTIONS

(define-read-only (get-last-token-id) (ok (var-get last-token-id)))

(define-read-only (get-owner (token-id uint)) (ok (nft-get-owner? nfttest token-id)))

(define-read-only (get-token-uri (token-id uint)) (ok (some (concat (concat (var-get ipfs-root) "$TOKEN_ID") ".json"))))




;; PUBLIC FUNCTIONS

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-invalid-user)
        (nft-transfer? nfttest token-id sender recipient)))

(define-public (mint (recipient principal))
    (let
        ((token-id (+ (var-get last-token-id) u1))
            (count (var-get last-token-id)))
        (asserts! (is-eq tx-sender contract-owner) err-invalid-user)
        (asserts! (< count (var-get mint-limit)) err-sold-out)
        (try! (nft-mint? nfttest token-id recipient))
        (var-set last-token-id token-id)
        (ok token-id)))