(define-non-fungible-token example uint)

(define-constant CONTRACT-CREATOR tx-sender)

(define-constant ERR-NOT-AUTHORIZED (err u0))

(define-data-var token-uri (string-ascii 256) "")
(define-data-var last-id uint u0)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
    (nft-transfer? example token-id sender recipient)
  )
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? example token-id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (some (var-get token-uri)))
)

(define-public (mint (token-id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-CREATOR) ERR-NOT-AUTHORIZED)
    (try! (nft-mint? example token-id recipient))
    (var-set last-id token-id)
    (ok true)
  )
)

(define-public (set-token-uri (new-token-uri (string-ascii 256)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-CREATOR) (err ERR-NOT-AUTHORIZED))
    (var-set token-uri new-token-uri)
    (ok true)
  )
)