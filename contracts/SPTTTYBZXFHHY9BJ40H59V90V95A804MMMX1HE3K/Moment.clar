;; Use the SIP090 interface (mainnet)
(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Define a new NFT
(define-non-fungible-token Moment uint)

;; Store the last issues token ID
(define-data-var last-id uint u0)

;; Store metadata
(define-map meta uint
  (tuple
    (url (string-ascii 2048))
    ))

;; Mint a new NFT
(define-public (mint (url (string-ascii 2048)))
  (create tx-sender url))

;; SIP009: transfer token to a specified principal
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? Moment token-id sender recipient)
        success (ok success)
        error (err error))
      (err u500)))

;; SIP009: Get the owner of the specified token ID
(define-read-only (get-owner (token-id uint))
  ;; Make sure to replace Moment
  (ok (nft-get-owner? Moment token-id)))

;; SIP009: Get the last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

;; SIP009: Get the token URI. You can set it to any other URI
(define-read-only (get-token-uri (token-id uint))
  (ok (some "https://momentonft.com/moments")))

(define-read-only (get-meta? (id uint))
  (map-get? meta id))

;; Internal - Mint new NFT
(define-private (create (new-owner principal) (url (string-ascii 2048)))
    (let ((next-id (+ u1 (var-get last-id))))
      (match (nft-mint? Moment next-id new-owner)
        success
          (begin
            (var-set last-id next-id)
            (map-insert meta next-id { url: url })
            (ok true))
        error (err error))))
