;; miamicoin-artweek

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

;; Non Fungible Token, using sip-009
(define-non-fungible-token miamicoin-artweek uint)

;; Constants
(define-constant err-no-more-nfts u300)
(define-constant err-already-claimed u400)
(define-constant err-invalid-user u500)

(define-constant mint-limit u100)
(define-constant commission-address tx-sender)

;; Internal variables
(define-map redemptions 
  {user: principal}
  {redeemed: bool}
)
(define-data-var last-id uint u0)
(define-data-var total-price uint u0)
(define-data-var artist-address principal 'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6)
(define-data-var ipfs-root (string-ascii 80) "ipfs://ipfs/QmV2yPwwGS87smoAkVLfwjfy8ytkdhKVPJ7UYjYvCr2s1a/")

;; private functions
(define-private (mint (new-owner principal))
  (let ((next-id (+ u1 (var-get last-id)))
        (count (var-get last-id)))
      (asserts! (< count mint-limit) (err err-no-more-nfts))
      (match (map-get? redemptions {user: new-owner})
        result (err err-already-claimed)
        (mint-helper new-owner next-id)
    )
  )
)

(define-private (mint-helper (new-owner principal) (next-id uint))
    (match (nft-mint? miamicoin-artweek next-id new-owner)
            success
              (begin
                (map-set redemptions {user: new-owner} {redeemed: true})
                (var-set last-id next-id)
                (ok true))
            error (err error)))

;; public functions
(define-public (claim)
  (mint tx-sender))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (if (and
        (is-eq tx-sender sender))
      (match (nft-transfer? miamicoin-artweek token-id sender recipient)
        success (ok success)
        error (err error))
      (err err-invalid-user)))

;; read-only functions
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? miamicoin-artweek token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get last-id)))

(define-read-only (get-token-uri (token-id uint))
    (ok (some (concat (concat (var-get ipfs-root) "{id}") ".json"))))

(define-public (set-ipfs-root (new-ipfs-root (string-ascii 80)))
  (if (is-eq tx-sender commission-address)
    (begin
      (var-set ipfs-root new-ipfs-root)
      (ok true)
    )
    (err err-invalid-user)))
