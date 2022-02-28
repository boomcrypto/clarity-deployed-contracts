(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token okcoin-airdrop uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-invalid-user u500)
(define-constant mint-limit u6000)
(define-constant commission-address tx-sender)
(define-data-var last-id uint u0)

(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmWm4pqWNiC4Sw7zsx5rzoGqEqnTC5eu12fqLJ4KDUWeYb/")

(define-private (mint (new-owner principal) (next-id uint))
    (match (nft-mint? okcoin-airdrop next-id new-owner)
            success
              (begin
                (var-set last-id next-id)
                (ok true))
            error (err error)))

(define-public (claim-for (user principal) (id uint))
  (if (is-eq tx-sender commission-address)
    (mint user id)
    (err err-invalid-user))
)

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
  (if (is-eq tx-sender commission-address)
    (begin 
      (var-set ipfs-root new-ipfs-root)
      (ok true)
    )
    (err err-invalid-user)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? okcoin-airdrop token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? okcoin-airdrop token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))