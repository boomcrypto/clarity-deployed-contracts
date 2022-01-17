;; French Bean NFT

;; use the SIP090 interface (mainet?)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; define a new NFT. 
(define-non-fungible-token FRENCH-BEANS-NFT uint)

;; Store the last issues token ID
(define-data-var last-id uint u0)

;; Claim a new NFT
(define-public (claim)
  (mint tx-sender))

;; SIP009: Transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? FRENCH-BEANS-NFT token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? FRENCH-BEANS-NFT token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some "ipfs://bafybeia4xg542ak7kigujvrudq43dsku5o5wosnecdowimbbp6xixg773y/")))

;; Internal - Mint new NFT
(define-private (mint (new-owner principal))
    (let ((next-id (+ u1 (var-get last-id))))
      (match (nft-mint? FRENCH-BEANS-NFT next-id new-owner)
        success
          (begin
            (var-set last-id next-id)
            (ok true))
        error (err error))))